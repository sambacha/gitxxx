#!usr/bin/bash
#
# Insert some regular file into the root commit(s) of history, e.g. adding a file named LICENSE or COPYING to the
# first commit.  It also rewrites commit hashes in commit messages to update them based on these changes.
git filter-repo --force --commit-callback "if not commit.parents: commit.file_changes.append(FileChange(b'M', $RELATIVE_TO_PROJECT_ROOT_PATHNAME, b'$(git hash-object -w $FILENAME)', b'100644'))"
