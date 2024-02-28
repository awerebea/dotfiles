import shutil
import sys


def clear_previous_lines(num_lines: int) -> None:
    """Clear the previous lines in the console."""
    go_up_one_line = "\033[F"
    clear_current_line = "\r" + " " * shutil.get_terminal_size((100, 20)).columns + "\r"
    for _ in range(num_lines):
        sys.stdout.write(go_up_one_line + clear_current_line)
        sys.stdout.flush()


def print_progress_bar(
    part_num: int,
    parts_total: int,
    desc: str = "",
) -> str:
    """Print a progress bar to the console."""
    terminal_width = shutil.get_terminal_size((100, 20)).columns
    # Calculate dynamic length for the progress bar
    info_len = len(str(parts_total)) * 2 + 16  # ' xx/yy (zzz.zz%)'
    if desc:
        info_len += len(desc) + 1
    # Calculate progress bar length
    bar_len = min(100, terminal_width) - info_len
    progress = int(bar_len * part_num / parts_total)
    remaining = bar_len - progress
    # Format the counter part
    parts_total_str_len = len(str(parts_total))
    counter_str = (
        f"{part_num:>{parts_total_str_len}}/{parts_total:<{parts_total_str_len}}"
    )
    # Format the percentage part without extra leading space
    percentage_str = f"{(part_num / parts_total * 100):.2f}%"
    # Format the progress bar for the current element
    progress_bar = f"[{progress * '#'}{'-' * remaining}]"
    if desc:
        progress_bar += " " + desc
    progress_bar += f" {counter_str} ({percentage_str:>7})"

    # Print the progress bar for the current element on the second line
    print(progress_bar)
    return progress_bar


if __name__ == "__main__":
    import time

    # Example usage in a nested loop
    total_elements = 5
    total_parts = 20
    progress_bar = ""
    total_progress_bar = ""

    print("Progress bar example: Start")
    progress_bar = ""
    for part in range(1, total_parts + 1):
        if progress_bar:
            clear_previous_lines(1)
        progress_bar = print_progress_bar(part, total_parts)
        time.sleep(0.05)
    print("Progress bar example: Finish")

    print("Multiple elements progress bar example: Start")
    total_progress_bar = ""
    for elem in range(1, total_elements + 1):
        if total_progress_bar:
            if progress_bar:
                clear_previous_lines(2)
            else:
                clear_previous_lines(1)
        total_progress_bar = print_progress_bar(
            elem,
            total_elements,
            desc="TOTAL PROGRESS:",
        )
        progress_bar = ""
        for part in range(1, total_parts + 1):
            if progress_bar:
                clear_previous_lines(1)
            progress_bar = print_progress_bar(part, total_parts)
            time.sleep(0.05)
            if part == total_parts:
                clear_previous_lines(2)
                print(f"Processing of element {elem} finished")
                print(total_progress_bar)
                print(progress_bar)
    print("Multiple elements progress bar example: Finish")

    print("Progress bar example with clear on finish: Start")
    progress_bar = ""
    for part in range(1, total_parts + 1):
        if progress_bar:
            clear_previous_lines(1)
        progress_bar = print_progress_bar(part, total_parts)
        time.sleep(0.05)
        if part == total_parts:
            time.sleep(1)
            clear_previous_lines(1)
    print("Progress bar example with clear on finish: Finish")

    print("Multiple elements progress bar example with clear on finish: Start")
    total_progress_bar = ""
    for elem in range(1, total_elements + 1):
        if total_progress_bar:
            if progress_bar:
                clear_previous_lines(2)
            else:
                clear_previous_lines(1)
        total_progress_bar = print_progress_bar(
            elem,
            total_elements,
            desc="TOTAL PROGRESS:",
        )
        progress_bar = ""
        for part in range(1, total_parts + 1):
            if progress_bar:
                clear_previous_lines(1)
            progress_bar = print_progress_bar(part, total_parts)
            time.sleep(0.05)
            if part == total_parts:
                time.sleep(0.5)
                clear_previous_lines(2)
                print(f"Processing of element {elem} finished")
                if elem != total_elements:
                    print(total_progress_bar)
                    print(progress_bar)
    print("Multiple elements progress bar example with clear on finish: Finish")
