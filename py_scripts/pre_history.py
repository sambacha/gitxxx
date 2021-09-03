 #!/usr/bin/env python3

"""
This is a simple program that will insert some regular file into the root
commit(s) of history, e.g. adding a file named LICENSE or COPYING to the
first commit.  It also rewrites commit hashes in commit messages to update
them based on these changes.
"""

"""
Please see the
  ***** API BACKWARD COMPATIBILITY CAVEAT *****
near the top of git-filter-repo.
"""

# Technically, this program could be replaced by a one-liner:
#    git filter-repo --force --commit-callback "if not commit.parents: commit.file_changes.append(FileChange(b'M', $RELATIVE_TO_PROJECT_ROOT_PATHNAME, b'$(git hash-object -w $FILENAME)', b'100644'))"
# but let's do it as a full-fledged program that imports git_filter_repo
# anyway...

import argparse
import os
import subprocess
try:
  import git_filter_repo as fr
except ImportError:
  raise SystemExit("Error: Couldn't find git_filter_repo.py.  Did you forget to make a symlink to git-filter-repo named git_filter_repo.py or did you forget to put the latter in your PYTHONPATH?")

parser = argparse.ArgumentParser(
          description='Add a file to the root commit(s) of history')
parser.add_argument('--file', type=os.fsencode,
        help=("Relative-path to file whose contents should be added to root commit(s)"))
args = parser.parse_args()
if not args.file:
  raise SystemExit("Error: Need to specify the --file option")

fhash = subprocess.check_output(['git', 'hash-object', '-w', args.file]).strip()
fmode = b'100755' if os.access(args.file, os.X_OK) else b'100644'
# FIXME: I've assumed the file wasn't a directory or symlink...

def fixup_commits(commit, metadata):
  if len(commit.parents) == 0:
    commit.file_changes.append(fr.FileChange(b'M', args.file, fhash, fmode))
  # FIXME: What if the history already had a file matching the given name,
  # but which didn't exist until later in history?  Is the intent for the
  # user to keep the other version that existed when it existed, or to
  # overwrite the version for all of history with the specified file?  I
  # don't know, but if it's the latter, we'd need to add an 'else' clause
  # like the following:
  #else:
  #  commit.file_changes = [x for x in commit.file_changes
  #                         if x.filename != args.file]

fr_args = fr.FilteringOptions.parse_args(['--preserve-commit-encoding',
                                          '--force',
                                          '--replace-refs', 'update-no-add'])
filter = fr.RepoFilter(fr_args, commit_callback=fixup_commits)
filter.run()
