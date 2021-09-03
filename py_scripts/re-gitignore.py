#!/usr/bin/env python3

"""
This is a simple program that will delete files from history which match
current gitignore rules, while also:
  1) pruning commits which become empty
  2) pruning merge commits which become degenerate and have no changes
     relative to its remaining relevant parent
  3) rewriting commit hashes in commit messages to reference new commit IDs.
"""

"""
Please see the
  ***** API BACKWARD COMPATIBILITY CAVEAT *****
near the top of git-filter-repo.
"""

import argparse
import os
import subprocess

try:
    import git_filter_repo as fr
except ImportError:
    raise SystemExit(
        "Error: Couldn't find git_filter_repo.py.  Did you forget to make a symlink to git-filter-repo named git_filter_repo.py or did you forget to put the latter in your PYTHONPATH?"
    )


class CheckIgnores:
    def __init__(self):
        self.ignored = set()
        self.okay = set()

        cmd = "git check-ignore --stdin --verbose --non-matching --no-index"
        self.check_ignore_process = subprocess.Popen(
            cmd.split(), stdin=subprocess.PIPE, stdout=subprocess.PIPE
        )

    def __del__(self):
        if self.check_ignore_process:
            self.check_ignore_process.stdin.close()

    def get_ignored(self, filenames):
        ignored = set()
        for name in filenames:
            if name in self.ignored:
                ignored.add(name)
            elif name in self.okay:
                continue
            else:
                self.check_ignore_process.stdin.write(name + b"\n")
                self.check_ignore_process.stdin.flush()
                result = self.check_ignore_process.stdout.readline().rstrip(b"\n")
                (rest, pathname) = result.split(b"\t")
                if name != pathname:
                    raise SystemExit(
                        "Error: Passed {} but got {}".format(name, pathname)
                    )
                if rest == b"::":
                    self.okay.add(name)
                else:
                    self.ignored.add(name)
                    ignored.add(name)

        return ignored

    def skip_ignores(self, commit, metadata):
        filenames = [x.filename for x in commit.file_changes]
        bad = self.get_ignored(filenames)
        commit.file_changes = [x for x in commit.file_changes if x.filename not in bad]


checker = CheckIgnores()
args = fr.FilteringOptions.default_options()
filter = fr.RepoFilter(args, commit_callback=checker.skip_ignores)
filter.run()
