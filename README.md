# gitxxx

[![Code Style: Black](https://github.com/sambacha/gitxxx/actions/workflows/black.yml/badge.svg)](https://github.com/sambacha/gitxxx/actions/workflows/black.yml)

> [docs](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-fast-import.html)

### cheatsheet

` GIT_SEQUENCE_EDITOR=: git rebase -i HEAD~3`
` git -c sequence.editor=: rebase --autosquash --interactive origin/master `

[source for non-interactive rebase](https://stackoverflow.com/questions/29094595/git-interactive-rebase-without-opening-the-editor/29094904#29094904)

`/info/refs?service=git-receive-pack`

### Git Absorb

[https://github.com/tummychow/git-absorb](https://github.com/tummychow/git-absorb)

You have a feature branch with a few commits. Your teammate reviewed the branch and pointed out a few bugs. You have fixes for the bugs, but you don't want to shove them all into an opaque commit that says fixes, because you believe in atomic commits. Instead of manually finding commit SHAs for git commit --fixup, or running a manual interactive rebase, do this:

```sh
git add $FILES_YOU_FIXED
git absorb
git rebase -i --autosquash master
```

git absorb will automatically identify which commits are safe to modify, and which indexed changes belong to each of those commits. It will then write fixup! commits for each of those changes. You can check its output manually if you don't trust it, and then fold the fixups into your feature branch with git's built-in autosquash functionality.


### `git filter-base`

> How to reword (edit the message of) multiple commits with Git interactive rebase,
> without the repetitive routine of manually editing the message in the configured text editor for each commit?.md

Instead of `git-rebase`, [install and use
`git-filter-repo`](https://gist.github.com/ugultopu/120e87adbecfbb25084a348e70aa6cef) as follows:

    git filter-repo --commit-callback '
    new_messages = {
      b"0000000000000000000000000000000000000000": b"Some commit

message",
b"0000000000000000000000000000000000000001": b"Another commit
message",
b"0000000000000000000000000000000000000002": b"Yet another commit
message",
b"0000000000000000000000000000000000000003": b"Still another
commit message",
}
try:
commit.message = new_messages[commit.original_id]
except KeyError:
pass
'

Where `0000000000000000000000000000000000000000`,
`0000000000000000000000000000000000000001`, etc. should be replaced by
the commit IDs (hashes) that you want to edit, and the values
corresponding to them should be replaced with the new commit messages.

# Details

Let's say that we want to edit the commit messages of multiple
(previous) commits. We know the commit IDs, and we know what the new
messages should be. To edit the commit messages, we can use the `reword`
option in the "TODO list" of the interactive mode of `git-rebase` and
replace the commit messages of those commits with their respective new
values.

When it reaches a commit that declares the `reword` option, `git-rebase`
opens the configured editor. As a side note, [Git finds the configured
editor
by](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration#_core_editor):

- Using the value of the `core.editor` configuration of the current
  repository's Git config, if it is set.
- If not set, using the value of the `core.editor` configuration of the
  global Git config.
- If not set, using the value of the `VISUAL` environment variable.
- If not set, using the value of the `EDITOR` environment variable.
- If not set, using `vi`.

After the configured editor is opened, we need to manually edit the
commit message and close the editor so that the rebase will continue.
However, manually doing this for every single commit becomes a hassle.
Being able to specify which commits should have which messages and
providing this "commit ID to commit message" mapping to `git-rebase`
once, so that we won't have to manually edit the message each time would
have been much more convenient.

As far as I can tell, there is no way of doing this using `git-rebase`,
but we can do this elegantly using the `commit-callback` of
`git-filter-repo`:

    git filter-repo --commit-callback '
    new_messages = {
      b"0000000000000000000000000000000000000000": b"Some commit

message",
b"0000000000000000000000000000000000000001": b"Another commit
message",
b"0000000000000000000000000000000000000002": b"Yet another commit
message",
b"0000000000000000000000000000000000000003": b"Still another
commit message",
}
try:
commit.message = new_messages[commit.original_id]
except KeyError:
pass
'

The value of the `--commit-callback` argument is the function _body_ of
the function that will be run for each commit. "The function that will
be run for each commit" is the definition of a "commit callback". The
syntax is Python 3 syntax. This callback function has a parameter named
`commit`. What we are doing here is, we are first defining a Python
dictionary that holds a mapping of the commit IDs to the new commit
messages that we want:

```python
new_messages = {
  b"0000000000000000000000000000000000000000": b"Some commit message",
  b"0000000000000000000000000000000000000001": b"Another commit
message",
  b"0000000000000000000000000000000000000002": b"Yet another commit
message",
  b"0000000000000000000000000000000000000003": b"Still another commit
message",
}
```

Here, `0000000000000000000000000000000000000000`,
`0000000000000000000000000000000000000001`, etc. represent the commit
IDs (hashes) whose messages that we want to replace. The value
corresponding to a key is the new commit message that we want that
commit to have.

The rest of the function:

```python
try:
  commit.message = new_messages[commit.original_id]
except KeyError:
  pass
```

checks if a commit ID exists in this dictionary and if it does, it gets
the commit message, which is the value that corresponds to that key in
the `new_messages` dictionary, and assigns it to the `message` property
of the `commit` argument.

If, on the other hand, the commit ID does not exist in the dictionary,
this will result in a `KeyError`, which will be caught by the `except KeyError` clause of our exception handler and will simply be ignored,
since this means that we should keep the message of that commit as is
(that is, we shouldn't do anything at all).

You might think, "why are all the strings in this Python program have a
leading `b`"? In Python, a `b` before a string literal means that we are
actually defining a _byte literal_, which results in creation of an
array of bytes.

The reason we are defining arrays of bytes, instead of just strings is
because (almost) everything in `git-filter-repo` are expressed as byte
arrays, instead of the "regular" data structures such as strings,
integers, etc. That is, for example both `commit.original_id` and
`commit.message` are byte arrays, instead of strings. Hence, if we
defined the keys of the `new_messages` dictionary (which correspond to
commit IDs) as strings, `new_messages[commit.original_id]` would always
result in a `KeyError`, because in Python, `"some string"` is not equal
to `b"some string"`.

In other words, if you don't want the leading `b`, you can use the
following code:

    git filter-repo --commit-callback '
    new_messages = {
      "0000000000000000000000000000000000000000": "Some commit message",
      "0000000000000000000000000000000000000001": "Another commit

message",
"0000000000000000000000000000000000000002": "Yet another commit
message",
"0000000000000000000000000000000000000003": b"Still another commit
message",
}
try:
commit.message =
new_messages[commit.original_id.decode()].encode()
except KeyError:
pass
'

As we stated above, both `commit.original_id` and `commit.message` are
byte arrays (instead of strings). However both the keys and the values
in our `new_messages` dictionary are strings. Hence, when looking up a
key in `new_messages`, we need to convert the `commit.original_id` (from
byte array) to string. Similarly, when assigning a value to
`commit.message`, we need to convert the value coming from
`new_messages` (from string) to byte array. For these purposes, we need
to use the `decode` and `encode` methods respectively.

However, I believe that doing it this way results in a less robust
program, because compared to forgetting to prepend a string literal with
`b` (which makes that "string literal" actually a "byte literal"), I
think forgetting to add a call to `encode` or `decode` is more likely.
