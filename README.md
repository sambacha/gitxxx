# gitxxx

[![Code Style: Black](https://github.com/sambacha/gitxxx/actions/workflows/black.yml/badge.svg)](https://github.com/sambacha/gitxxx/actions/workflows/black.yml)

> [docs](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-fast-import.html)


### cheatsheet

` GIT_SEQUENCE_EDITOR=: git rebase -i HEAD~3` <br>
` git -c sequence.editor=: rebase --autosquash --interactive origin/master `

[source for non-interactive rebase](https://stackoverflow.com/questions/29094595/git-interactive-rebase-without-opening-the-editor/29094904#29094904)

`/info/refs?service=git-receive-pack`

### Git Integrity

> [source, https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#commit-history](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#commit-history)

It is important to understand that the integrity of your repository guaranteed only if a hash collision cannot be created—that is, if an attacker were able to create the same SHA-1 hash with different data, then the child commit(s) would still be valid and the repository would have been successfully compromised. Vulnerabilities have been known in SHA-1 since 2005 that allow hashes to be computed faster than brute force, although they are not cheap to exploit. Given that, while your repository may be safe for now, there will come some point in the future where SHA-1 will be considered as crippled as MD5 is today. At that point in time, however, maybe Git will offer a secure migration solution to an algorithm like SHA-256 or better. Indeed, SHA-1 hashes were never intended to make Git cryptographically secure.



```bash
git log --show-signature \
  | grep 'key ID' \
  | grep -o '[A-Z0-9]\+$' \
  | sort \
  | uniq \
  | xargs gpg --keyserver key.server.org --recv-keys $keys
```


```bash
git log --pretty="format:^%H$t%aN$t%s$t%G?" --show-signature \
| grep '^\^\|gpg: .*not certified' \
| awk ''
```

```bash
git log --pretty="format:^%H$t%aN$t%s$t%G?" --show-signature
```

```bash
#!/bin/sh
#
# Validate signatures on only direct commits and merge commits for a particular
# branch (current branch)
##

# if a ref is provided, append range spec to include all children
chkafter="${1+$1..}"

# note: bash users may instead use $'\t'; the echo statement below is a more
# portable option (-e is unsupported with /bin/sh)
t=$( echo '\t' )

# Check every commit after chkafter (or all commits if chkafter was not
# provided) for a trusted signature, listing invalid commits. %G? will output
# "G" if the signature is trusted.
git log --pretty="format:%H$t%aN$t%s$t%G?" "${chkafter:-HEAD}" --first-parent \
  | grep -v "${t}G$"

# grep will exit with a non-zero status if no matches are found, which we
# consider a success, so invert it
[ $? -gt 0 ]
```

## Managing Large Merges

Up to this point, our discussion consisted of apply patches or merging single commits. What shall we do, then, if we receive a pull request for a certain feature or bugfix with, say, 300 commits (which I assure you is not unusual)? In such a case, we have a few options:

1.  **Request that the user squash all the commits into a single commit**, thereby avoiding the problem entirely by applying the previously discussed methods. I personally dislike this option for a few reasons:
    
    -   We can no longer follow the history of that feature/bugfix in order to learn how it was developed or see alternative solutions that were attempted but later replaced.
        
    -   It renders `git bisect` useless. If we find a bug in the software that was introduced by a single patch consisting of 300 squashed commits, we are left to dig through the code and debug ourselves, rather than having Git possibly figure out the problem for us.
        
2.  **Adopt a security policy that requires signing only the merge commit** (forcing a merge commit to be created with `--no-ff` if needed).
    
    -   This is certainly the quickest solution, allowing a reviewer to sign the merge after having reviewed the diff in its entirety.
        
    -   However, it leaves individual commits open to exploitation. For example, one commit may introduce a payload that a future commit removes, thereby hiding it from the overall diff, but introducing terrible effect should the commit be checked out individually (e.g. by `git bisect`). Squashing all commits ([option #1](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-1)), signing each commit individually ([option #3](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-3)), or simply reviewing each commit individually before performing the merge (without signing each individual commit) would prevent this problem.
        
    -   This also does not fully prevent the situation mentioned in the hypothetical story at the beginning of this article—others can still commit with you as the author, but the commit would not have been signed.
        
    -   Preserves the SHA-1 hashes of each individual commit.
        
3.  **Sign each commit to be introduced by the merge.**
    
    -   The tedium of this chore can be greatly reduced by using http://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG\_002dAGENT.html\[ `gpg-agent`\].
        
    -   Be sure to carefully review _each commit_ rather than the entire diff to ensure that no malicious commits sneak into the history (see bullets for [option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2)). If you instead decide to script the sign of each commit without reviewing each individual diff, you may as well go with [option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2).
        
    -   Also useful if one needs to cherry-pick individual commits, since that would result in all commits having been signed.
        
    -   One may argue that this option is unnecessarily redundant, considering that one can simply review the individual commits without signing them, then simply sign the merge commit to signify that all commits have been reviewed ([option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2)). The important point to note here is that this option offers _proof_ that each commit was reviewed (unless it is automated).
        
    -   This will create a new for each (the SHA-1 hash is not preserved).
        

Which of the three options you choose depends on what factors are important and feasible for your particular project. Specifically:

-   If history is not important to you, then you can avoid a lot of trouble by simply requiring the the commits be squashed ([option #1](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-1)).
    
-   If history _is_ important to you, but you do not have the time to review individual commits:
    
    -   Use [option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2) if you understand its risks.
        
    -   Otherwise, use [option #3](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-3), but _do not_ automate the signing process to avoid having to look at individual commits. If you wish to keep the history, do so responsibly.
        

Option #1 in the list above can easily be applied to the discussion in the previous section.

### (Option #2)

[Option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2) is as simple as passing the `-S` argument to `git merge`. If the merge is a fast-forward (that is, all commits can simply be applied atop of `HEAD` without any need for merging), then you would need to use the `--no-ff` option to force a merge commit.

Inspecting the log, we will see the following:

Notice how the merge commit contains the signature, but the two commits involved in the merge (`031f6ee` and `ce77088`) do not. Herein lies the problem—what if commit `031f6ee` contained the backdoor mentioned in the story at the beginning of the article? This commit is supposedly authored by you, but because it lacks a signature, it could actually be authored by anyone. Furthermore, if `ce77088` contained malicious code that was removed in `031f6ee`, then it would not show up in the diff between the two branches. That, however, is an issue that needs to be addressed by your security policy. Should you be reviewing individual commits? If so, a review would catch any potential problems with the commits and wouldn’t require signing each commit individually. The merge itself could be representative of “Yes, I have reviewed each commit individually and I see no problems with these changes.”

If the commitment to reviewing each individual commit is too large, consider [Option #1](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-1).

### (Option #3)

[Option #3](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-3) in the above list makes the review of each commit explicit and obvious; with [option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2), one could simply lazily glance through the commits or not glance through them at all. That said, one could do the same with [option #3](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-3) by automating the signing of each commit, so it could be argued that this option is completely unnecessary. Use your best judgment.

The only way to make this option remotely feasible, especially for a large number of commits, is to perform the audit in such a way that we do not have to re-enter our secret key passphrases for each and every commit. For this, we can use [`gpg-agent`](http://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html), which will safely store the passphrase in memory for the next time that it is requested. Using `gpg-agent`, [we will only be prompted for the password a single time](http://stackoverflow.com/questions/9713781/how-to-use-gpg-agent-to-bulk-sign-git-tags/10263139). Depending on how you start `gpg-agent`, _be sure to kill it after you are done!_

The process of signing each commit can be done in a variety of ways. Ultimately, since signing the commit will result in an entirely new commit, the method you choose is of little importance. For example, if you so desired, you could cherry-pick individual commits and then `-S --amend` them, but that would not be recognized as a merge and would be terribly confusing when looking through the history for a given branch (unless the merge would have been a fast-forward). Therefore, we will settle on a method that will still produce a merge commit (again, unless it is a fast-forward). One such way to do this is to interactively rebase each commit, allowing you to easily view the diff, sign it, and continue onto the next commit.

First, we create a new branch off of `bar`—`bar-audit`—to perform the rebase on (see `bar` branch created in demonstration of [option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2)). Then, in order to step through each commit that would be merged into `master`, we perform a rebase using `master` as the upstream branch. This will present every commit that is in `bar-audit` (and consequently `bar`) that is not in `master`, opening them in your preferred editor:

```
e ce77088 Added bar
e 031f6ee Modified bar

# Rebase 652f9ae..031f6ee onto 652f9ae
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#  x, exec = run command (the rest of the line) using shell
#
# If you remove a line here THAT COMMIT WILL BE LOST.
# However, if you remove everything, the rebase will be aborted.
#
```

To modify the commits, replace each `pick` with `e` (or `edit`), as shown above. (In vim you can also do the following `ex` command: `:%s/^pick/e/`; adjust regex flavor for other editors). Save and close. You will then be presented with the first (oldest) commit:

```
Stopped at ce77088... Added bar
You can amend the commit now, with

        git commit --amend

Once you are satisfied with your changes, run

        git rebase --continue

# first, review the diff (alternatively, use tig/gitk)
$ git diff HEAD^
# if everything looks good, sign it
$ git commit -S --amend
#    GPG-sign ^      ^ amend commit, preserving author, etc

You need a passphrase to unlock the secret key for
user: "Mike Gerwitz (Free Software Developer) <mike@mikegerwitz.com>"
4096-bit RSA key, ID 8EE30EAB, created 2011-06-16

[detached HEAD 5cd2d91] Added bar
 1 file changed, 1 insertion(+)
 create mode 100644 bar

# continue with next commit
$ git rebase --continue

# repeat.
$ ...
Successfully rebased and updated refs/heads/bar-audit.
```

Looking through the log, we can see that the commits have been rewritten to include the signatures (consequently, the SHA-1 hashes do not match):

We can then continue to merge into `master` as we normally would. The next consideration is whether or not to sign the merge commit as we would with [option #2](https://mikegerwitz.com/2012/05/a-git-horror-story-repository-integrity-with-signed-commits#merge-2). In the case of our example, the merge is a fast-forward, so the merge commit is unnecessary (since the commits being merged are already signed, we have no need to create a merge commit using `--no-ff` purely for the purpose of signing it). However, consider that you may perform the audit yourself and leave the actual merge process to someone else; perhaps the project has a system in place where project maintainers must review the code and sign off on it, and then other developers are responsible for merging and managing conflicts. In that case, you may want a clear record of who merged the changes in.

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
