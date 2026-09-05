"""Shared building blocks for the photo-archive maintenance tools.

Deliberately empty of imports. Entry points must be able to run
photo_archive.bootstrap.reexec() before anything pulls in a third-party
package, and any import placed here would defeat that.
"""
