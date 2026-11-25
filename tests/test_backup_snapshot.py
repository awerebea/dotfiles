"""Tests for backup_snapshot.py and backup_home.py.

They run the scripts as subprocesses against scratch directories, with the real
rsync and a fake ssh that runs the remote command locally, so no network or
real host is involved. Run from the repository root:

    python3 -m unittest discover -s tests -v
"""

import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

BIN = Path(__file__).resolve().parents[1] / "scripts" / ".local" / "bin"
SNAP = BIN / "backup_snapshot.py"
HOME_WRAPPER = BIN / "backup_home.py"
VERSION = re.search(r'__version__ = "([^"]+)"', SNAP.read_text(encoding="utf-8"))[1]  # type: ignore[index]

FAKE_SSH = """#!/bin/sh
# Fake ssh: skips options and the host, runs the rest locally.
while [ $# -gt 0 ]; do
  case "$1" in
    -O) exit 0 ;;
    -p|-o|-i|-l|-F) shift 2 ;;
    -*) shift ;;
    *) break ;;
  esac
done
shift  # host
exec sh -c "$*"
"""


@unittest.skipUnless(shutil.which("rsync"), "rsync is required")
class Base(unittest.TestCase):
    def setUp(self) -> None:
        self.td = tempfile.TemporaryDirectory()
        self.root = Path(self.td.name).resolve()
        self.home = self.root / "home"
        self.home.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        ssh = self.bin / "ssh"
        ssh.write_text(FAKE_SSH)
        ssh.chmod(0o755)
        self.src = self.root / "src"
        (self.src / "sub").mkdir(parents=True)
        (self.src / "a.txt").write_text("a")
        (self.src / "sub" / "b.txt").write_text("b")
        self.dst = self.root / "dst"
        self.env = {
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "TMPDIR": str(self.root),
        }

    def tearDown(self) -> None:
        self.td.cleanup()

    def run_py(self, script: Path, *args: str, env: dict[str, str] | None = None, cwd=None):
        full = dict(self.env)
        full.update(env or {})
        return subprocess.run(
            [sys.executable, "-I", str(script), *args],
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
            env=full,
            cwd=cwd or self.root,
            timeout=120,
        )

    def snap(self, *args: str, **kw):
        return self.run_py(SNAP, *args, **kw)

    def backup(self, *extra: str, **kw):
        return self.snap("-s", str(self.src), "-d", str(self.dst), *extra, **kw)

    def snapshots(self) -> list[Path]:
        return sorted(p for p in self.dst.iterdir() if p.name[:2] == "20")


class TestCli(Base):
    def test_version_and_help(self) -> None:
        r = self.snap("--version")
        self.assertEqual((r.returncode, r.stdout), (0, f"backup-snapshot {VERSION}\n"))
        r = self.snap("-h")
        self.assertEqual(r.returncode, 0)
        self.assertIn("--log-level", r.stdout)
        self.assertIn("PATHS:", r.stdout)

    def test_usage_errors_exit_2(self) -> None:
        for args in (
            [],
            ["-s=x", "-d", "y"],
            ["--sourc", "x", "-d", "y"],
            ["--bogus"],
            ["-s", "x", "-d", "y", "-t", "0"],
            ["-s", "x", "-d", "y", "--port", "70000"],
            ["-s", "x", "-d", "y", "--exclude-preset", "nope"],
            ["-s", "x", "-d", "y", "extra"],
            ["-s", "x", "-d", "y", "--exclude-from", "/nonexistent"],
            ["-s", "x", "-d", "y", "-L", "loud"],
        ):
            r = self.snap(*args)
            self.assertEqual(r.returncode, 2, (args, r.stderr))

    def test_squashed_and_attached(self) -> None:
        r = self.snap(f"-s{self.src}", f"-d{self.dst}", "-fyq")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(len(self.snapshots()), 1)

    def test_exclude_dash_value_attached(self) -> None:
        r = self.backup("--exclude=-weird", "-q")
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_wrapper_defaults_and_override(self) -> None:
        r = self.run_py(HOME_WRAPPER, "--version")
        self.assertEqual(r.stdout, f"backup-snapshot {VERSION}\n")
        r = self.run_py(HOME_WRAPPER)
        self.assertEqual(r.returncode, 1)
        self.assertIn("/home/andrei", r.stderr)
        # symlinked invocation
        link = self.bin / "backup-home"
        link.symlink_to(HOME_WRAPPER)
        r = self.run_py(
            link, "-s", str(self.src), "-d", str(self.dst), "--exclude-preset=none", "-q"
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(len(self.snapshots()), 1)

    def test_wrapper_applies_home_preset(self) -> None:
        (self.src / "Downloads").mkdir()
        (self.src / "Downloads" / "big").write_text("x")
        r = self.run_py(HOME_WRAPPER, "-s", str(self.src), "-d", str(self.dst), "-q")
        self.assertEqual(r.returncode, 0, r.stderr)
        data = self.snapshots()[0] / "src"
        self.assertFalse((data / "Downloads").exists())
        self.assertTrue((data / "a.txt").exists())


class TestLocal(Base):
    def test_first_snapshot_layout(self) -> None:
        r = self.backup("-q")
        self.assertEqual(r.returncode, 0, r.stderr)
        (snap,) = self.snapshots()
        self.assertEqual((snap / "src" / "sub" / "b.txt").read_text(), "b")
        marker = (snap / "completed_successfully").read_text()
        self.assertIn("Parent: src", marker)
        self.assertIn(f"Source: {self.src}", marker)
        self.assertTrue((snap / "rsync-log").exists())
        self.assertFalse((self.dst / ".backup_snapshot.lock").exists())

    def test_timeout_skip_force_and_hardlink(self) -> None:
        self.assertEqual(self.backup("-q").returncode, 0)
        r = self.backup("-q")
        self.assertEqual(r.returncode, 0)
        self.assertIn("skipped", r.stderr)
        self.assertEqual(len(self.snapshots()), 1)
        time.sleep(1.1)
        r = self.backup("-q", "-f")
        self.assertEqual(r.returncode, 0, r.stderr)
        first, second = self.snapshots()
        self.assertEqual(
            (first / "src" / "a.txt").stat().st_ino, (second / "src" / "a.txt").stat().st_ino
        )
        # a changed file is a new inode
        (self.src / "a.txt").write_text("changed!")
        time.sleep(1.1)
        self.assertEqual(self.backup("-q", "-f").returncode, 0)
        third = self.snapshots()[2]
        self.assertNotEqual(
            (second / "src" / "a.txt").stat().st_ino, (third / "src" / "a.txt").stat().st_ino
        )

    def test_keep_deletes_oldest_with_yes(self) -> None:
        for _ in range(3):
            self.assertEqual(self.backup("-q", "-f", "-y", "-k", "2").returncode, 0)
            time.sleep(1.1)
        names = [s.name for s in self.snapshots()]
        self.assertEqual(len(names), 2)

    def test_keep_prompt_declined(self) -> None:
        for _ in range(2):
            self.assertEqual(self.backup("-q", "-f").returncode, 0)
            time.sleep(1.1)
        r = self.backup("-q", "-f", "-k", "1")  # stdin is not a tty: answer is "no"
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertGreaterEqual(len(self.snapshots()), 2)

    def test_keep_prompt_pty_answers(self) -> None:
        import pty

        for _ in range(2):
            self.assertEqual(self.backup("-q", "-f").returncode, 0)
            time.sleep(1.1)
        for answer in (b"n", b"y"):
            pid, fd = pty.fork()
            if pid == 0:
                os.environ.update(self.env)
                os.execv(
                    sys.executable,
                    [
                        sys.executable,
                        "-I",
                        str(SNAP),
                        "-s",
                        str(self.src),
                        "-d",
                        str(self.dst),
                        "-q",
                        "-f",
                        "-k",
                        "1",
                    ],
                )
            out = b""
            while b"(y|N)" not in out:
                out += os.read(fd, 1024)
            os.write(fd, answer + b"\n")
            while True:
                try:
                    if not os.read(fd, 1024):
                        break
                except OSError:
                    break
            os.waitpid(pid, 0)
            time.sleep(1.1)
            # the run itself creates one more snapshot, so declining keeps 3, accepting leaves 1
            self.assertEqual(len(self.snapshots()), 3 if answer == b"n" else 1, answer)

    def test_dry_run_leaves_nothing(self) -> None:
        r = self.backup("-n", "-q")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(self.snapshots(), [])
        self.assertFalse((self.dst / ".backup_snapshot.lock").exists())

    def test_excludes(self) -> None:
        (self.src / "skip.log").write_text("x")
        (self.src / "node").mkdir()
        (self.src / "node" / "f").write_text("x")
        ef = self.root / "ex.txt"
        ef.write_text("# comment\n\nnode/\n")
        r = self.backup("-q", "-e", "*.log", "--exclude-from", str(ef))
        self.assertEqual(r.returncode, 0, r.stderr)
        data = self.snapshots()[0] / "src"
        self.assertFalse((data / "skip.log").exists())
        self.assertFalse((data / "node").exists())
        self.assertTrue((data / "a.txt").exists())

    def test_zfs_snapdir_skipped_unless_included(self) -> None:
        (self.src / ".zfs").mkdir()
        (self.src / ".zfs" / "z").write_text("z")
        self.assertEqual(self.backup("-q").returncode, 0)
        self.assertFalse((self.snapshots()[0] / "src" / ".zfs").exists())
        time.sleep(1.1)
        self.assertEqual(self.backup("-q", "-f", "--include-zfs-snapdir").returncode, 0)
        self.assertTrue((self.snapshots()[1] / "src" / ".zfs" / "z").exists())

    def test_interrupted_snapshot_removed(self) -> None:
        self.dst.mkdir()
        stale = self.dst / "2020-01-01_00-00-00"
        (stale / "src").mkdir(parents=True)
        r = self.backup("-q")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertFalse(stale.exists())
        self.assertIn("interrupted", r.stderr)

    def test_lock_held(self) -> None:
        (self.dst / ".backup_snapshot.lock").mkdir(parents=True)
        r = self.backup("-q")
        self.assertEqual(r.returncode, 1)
        self.assertIn("already running", r.stderr)
        self.assertTrue((self.dst / ".backup_snapshot.lock").exists())  # not ours: kept

    def test_parent_name_change_links_previous(self) -> None:
        self.assertEqual(self.backup("-q", "-p", "one").returncode, 0)
        time.sleep(1.1)
        r = self.backup("-q", "-f", "-p", "two", "-L", "info")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("linking against it", r.stderr)
        a, b = self.snapshots()
        self.assertEqual((a / "one" / "a.txt").stat().st_ino, (b / "two" / "a.txt").stat().st_ino)

    def test_errors(self) -> None:
        r = self.snap("-s", str(self.root / "nope"), "-d", str(self.dst))
        self.assertEqual(r.returncode, 1)
        self.assertIn("does not exist", r.stderr)
        r = self.snap("-s", str(self.src / "a.txt"), "-d", str(self.dst))
        self.assertIn("not a directory", r.stderr)
        r = self.snap("-s", "/", "-d", str(self.dst))
        self.assertIn("parent directory name", r.stderr)
        r = self.backup("-p", "a/b")
        self.assertIn("Invalid parent directory name", r.stderr)

    def test_rsync_failure_removes_incomplete(self) -> None:
        fake = self.bin / "rsync"
        fake.write_text(
            "#!/bin/sh\nif [ \"$1\" = --version ]; then echo 'rsync fake'; exit 0; fi\nexit 23\n"
        )
        fake.chmod(0o755)
        r = self.backup("-q")
        self.assertEqual(r.returncode, 1)
        self.assertIn("exit code 23", r.stderr)
        self.assertEqual(self.snapshots(), [])
        self.assertFalse((self.dst / ".backup_snapshot.lock").exists())

    def test_rsync_vanished_is_warning(self) -> None:
        fake = self.bin / "rsync"
        fake.write_text(
            "#!/bin/sh\nif [ \"$1\" = --version ]; then echo 'rsync fake'; exit 0; fi\nexit 24\n"
        )
        fake.chmod(0o755)
        r = self.backup("-q")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("vanished", r.stderr)
        self.assertEqual(len(self.snapshots()), 1)

    def test_sigterm_cleans_up(self) -> None:
        fake = self.bin / "rsync"
        fake.write_text(
            "#!/bin/sh\nif [ \"$1\" = --version ]; then echo 'rsync fake'; exit 0; fi\nsleep 30\n"
        )
        fake.chmod(0o755)
        env = dict(self.env)
        p = subprocess.Popen(
            [sys.executable, "-I", str(SNAP), "-s", str(self.src), "-d", str(self.dst), "-q"],
            env=env,
            stderr=subprocess.PIPE,
            text=True,
        )
        for _ in range(100):
            if self.dst.exists() and any(self.dst.glob("20*")):
                break
            time.sleep(0.1)
        else:
            p.kill()
            self.fail("snapshot never started")
        p.send_signal(signal.SIGTERM)
        err = p.communicate(timeout=30)[1]
        self.assertEqual(p.returncode, 143, err)
        self.assertEqual(self.snapshots(), [])
        self.assertFalse((self.dst / ".backup_snapshot.lock").exists())

    def test_sigint_exit_130(self) -> None:
        fake = self.bin / "rsync"
        fake.write_text(
            "#!/bin/sh\nif [ \"$1\" = --version ]; then echo 'rsync fake'; exit 0; fi\nsleep 30\n"
        )
        fake.chmod(0o755)
        p = subprocess.Popen(
            [sys.executable, "-I", str(SNAP), "-s", str(self.src), "-d", str(self.dst), "-q"],
            env=self.env,
            stderr=subprocess.PIPE,
            text=True,
        )
        for _ in range(100):
            if self.dst.exists() and any(self.dst.glob("20*")):
                break
            time.sleep(0.1)
        p.send_signal(signal.SIGINT)
        p.communicate(timeout=30)
        self.assertEqual(p.returncode, 130)
        self.assertEqual(self.snapshots(), [])


class TestSettings(Base):
    def test_precedence(self) -> None:
        conf = self.root / "c.conf"
        other = self.root / "other"
        third = self.root / "third"
        conf.write_text(
            f"BACKUP_SNAPSHOT_DEST={self.dst}\nBACKUP_SNAPSHOT_SOURCE={self.src}\nBOGUS=1\n"
        )
        r = self.snap("-c", str(conf), "-q")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("unknown key 'BOGUS'", r.stderr)
        self.assertEqual(len(self.snapshots()), 1)
        # env over config
        r = self.snap("-c", str(conf), "-q", env={"BACKUP_SNAPSHOT_DEST": str(other)})
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(other.exists())
        # CLI over env
        r = self.snap(
            "-c", str(conf), "-q", "-d", str(third), env={"BACKUP_SNAPSHOT_DEST": str(other)}
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(third.exists())

    def test_explicit_config_must_exist(self) -> None:
        r = self.snap("-c", str(self.root / "missing.conf"), "-s", "a", "-d", "b")
        self.assertEqual(r.returncode, 1)
        self.assertIn("Config file not found", r.stderr)

    def test_bad_env_values(self) -> None:
        r = self.backup(env={"BACKUP_SNAPSHOT_LOG_LEVEL": "loud"})
        self.assertEqual(r.returncode, 1)
        self.assertIn("BACKUP_SNAPSHOT_LOG_LEVEL", r.stderr)
        r = self.backup(env={"BACKUP_SNAPSHOT_KEEP": "zero"})
        self.assertEqual(r.returncode, 1)
        self.assertIn("BACKUP_SNAPSHOT_KEEP", r.stderr)

    def test_log_levels(self) -> None:
        r = self.backup("-f")
        self.assertNotIn("Starting backup", r.stderr)
        r = self.snap("-s", str(self.src), "-d", str(self.dst), "-f", "-q", "-L", "info")
        self.assertIn("Starting backup process", r.stderr)
        self.assertNotIn("[local]", r.stderr)
        time.sleep(1.1)
        r = self.snap("-s", str(self.src), "-d", str(self.dst), "-f", "-q", "-v")
        self.assertIn("Starting backup process", r.stderr)
        time.sleep(1.1)
        r = self.snap("-s", str(self.src), "-d", str(self.dst), "-f", "-q", "-L", "debug")
        self.assertIn("[destination]", r.stderr)
        # -v does not lower debug
        time.sleep(1.1)
        r = self.snap("-s", str(self.src), "-d", str(self.dst), "-f", "-q", "-L", "debug", "-v")
        self.assertIn("[destination]", r.stderr)
        time.sleep(1.1)
        r = self.snap("-s", str(self.src), "-d", str(self.dst), "-f", "-q", "-L", "error")
        self.assertEqual(r.stderr, "")


class TestRemote(Base):
    def test_local_to_remote(self) -> None:
        r = self.snap(
            "-s", str(self.src), "-d", f"fakehost:{self.dst}", "-q", "--no-multiplex", "--port=2222"
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        (snap,) = self.snapshots()
        self.assertTrue((snap / "src" / "a.txt").exists())
        self.assertIn("local -> remote", (snap / "completed_successfully").read_text())
        self.assertTrue((snap / "rsync-log").stat().st_size > 0)  # uploaded
        self.assertFalse((self.dst / ".backup_snapshot.lock").exists())

    def test_remote_to_local_with_multiplex_and_exclude(self) -> None:
        (self.src / "x.log").write_text("x")
        r = self.snap("-s", f"u@fakehost:{self.src}", "-d", str(self.dst), "-q", "-e", "*.log")
        self.assertEqual(r.returncode, 0, r.stderr)
        data = self.snapshots()[0] / "src"
        self.assertTrue((data / "a.txt").exists())
        self.assertFalse((data / "x.log").exists())

    def test_remote_to_remote_same_host_runs_on_dst(self) -> None:
        (self.src / "x.log").write_text("x")
        r = self.snap(
            "-s", f"h:{self.src}", "-d", f"h:{self.dst}", "-q", "-e", "*.log", "-L", "info"
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("rsync executes on h", r.stderr)
        (snap,) = self.snapshots()
        self.assertFalse((snap / "src" / "x.log").exists())
        self.assertTrue((snap / "rsync-log").exists())

    def test_different_hosts_rejected(self) -> None:
        r = self.snap("-s", f"h1:{self.src}", "-d", f"h2:{self.dst}")
        self.assertEqual(r.returncode, 1)
        self.assertIn("two different remote hosts", r.stderr)

    def test_relative_and_tilde_remote_paths_resolved(self) -> None:
        (self.home / "photos").mkdir()
        (self.home / "photos" / "p.jpg").write_text("p")
        r = self.snap(
            "-s",
            "h:~/photos",
            "-d",
            "h:~/backups/photos",
            "-q",
            "-L",
            "info",
            env={"HOME": str(self.home)},
            cwd=self.home,
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn(f"resolved to: {self.home}/photos", r.stderr)
        snaps = list((self.home / "backups" / "photos").glob("20*"))
        self.assertEqual(len(snaps), 1)
        self.assertTrue((snaps[0] / "photos" / "p.jpg").exists())
        # login-relative
        r = self.snap("-s", "h:photos", "-d", "h:backups/p2", "-q", cwd=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue((self.home / "backups" / "p2").exists())

    def test_rejected_specs(self) -> None:
        for spec, text in (
            ("h:~bob/x", "~user"),
            ("[::1]:/x", "IPv6"),
            ("rsync://h/x", "daemon"),
            ("h::mod", "daemon"),
        ):
            r = self.snap("-s", spec, "-d", str(self.dst))
            self.assertEqual(r.returncode, 1, spec)
            self.assertIn(text, r.stderr)

    def test_local_path_with_colon_via_dot_slash(self) -> None:
        odd = self.root / "we:ird"
        odd.mkdir()
        (odd / "f").write_text("f")
        r = self.snap("-s", "./we:ird", "-d", str(self.dst), "-q", cwd=self.root)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue((self.snapshots()[0] / "we:ird" / "f").exists())

    def test_ssh_unreachable(self) -> None:
        bad = self.bin / "ssh"
        bad.write_text("#!/bin/sh\necho 'ssh: connect failed' >&2\nexit 255\n")
        r = self.snap("-s", "h:/x", "-d", str(self.dst), "--no-multiplex")
        self.assertEqual(r.returncode, 1)
        self.assertIn("Cannot connect to h over ssh", r.stderr)

    def test_missing_ssh_command(self) -> None:
        r = self.snap("-s", "h:/x", "-d", str(self.dst), "--ssh-command", "no-such-ssh-binary")
        self.assertEqual(r.returncode, 1)
        self.assertIn("ssh command not found", r.stderr)

    def test_ssh_command_tilde_expanded(self) -> None:
        r = self.snap(
            "-s",
            f"h:{self.src}",
            "-d",
            str(self.dst),
            "-q",
            "--no-multiplex",
            "--ssh-command",
            "ssh -i ~/.ssh/key",
            "-L",
            "info",
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn(f"-i {self.home}/.ssh/key", r.stderr)


if __name__ == "__main__":
    unittest.main()
