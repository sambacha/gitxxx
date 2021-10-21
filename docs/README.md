## General Notes


```bash
git log --graph --oneline --date-order
```

If the sequence of commits matches what you expect, you can use git log
to generate a rebase -i sequence script :

```bash
# --reverse   : 'rebase -i' asks for entries starting from the oldest
# --no-merges : do not mention the "merge" commits
# sed -e 's/^/pick /' : use any way you see fit to prefix each line with
'pick '
#        (another valid way is to copy paste the list of commits in an editor,
#         and add 'pick ' to each line ...)
```


```bash
git log --reverse --no-merges --oneline --date-order |
  sed -e 's/^/pick /' > /tmp/rebase-apply.txt
```

Then rebase the complete history of your repo :

```bash
git rebase -i --root
```
In the editor, copy/paste the script you created with your first
command, save & close.

> source
[stackoverflow:62270074](https://stackoverflow.com/questions/62270074/can-git-filter-repo-create-a-monorepo-from-many-repos-interweaving-commits-by-da)
> 


On the off chance that the remote machine is a github repository,

First use Github’s Events API to retrieve the commit SHA.

```sh
curl https://api.github.com/repos/<user>/<repo>/events
```

Identify the SHA of the orphan commit-id that no longer exists in any
branch.


```regex
\b[0-9a-f]{5,40}\b
```

Next, use Github’s Refs API to create a new branch pointing to the
orphan commit.

```sh
curl -i -H "Accept: application/json" -H "Content-Type:
application/json" -X POST -d '{"ref":"refs/heads/D-commit",
"sha":"<orphan-commit-id>"}'
https://api.github.com/repos/<user>/<repo>/git/refs
```

Replace <orphan-commit-id> in the above command with the SHA identified
in step 2.

Finally git fetch the newly created branch into your local repository.
From there you can cherry-pick or merge the commit(s) back into your
work.

Check out this article for an actual example.
  
Rebasing copies commits, but it has limitations. The biggest one is that
it literally cannot copy any merge commits. Modern Git (within the last
year or two) has acquired the --rebase-merges flag, which gets one
closer, but it's still impossible to copy the merges. So here, Git will
re-perform merges.

This could be good enough—but there's still a hitch. Even with the new
initial commit having the desired .gitattributes in it (in which case
you can just convert that commit's contents at the same time, and hence
not need --root), when rebase does a commit-copy, it won't necessarily
normalize the line endings of every file. For instance, suppose we have
this little mini-graph:

```
A--B--C   <-- master
```

You might use git switch --orphan new-master to get ready to create a
new root commit, then read out the contents of commit A, add the
.gitattributes, normalize line endings for all working tree files and
their index copies, and commit, to get new commit A':

```
A--B--C   <-- master
```

```
A'  <-- new-master (HEAD)
```

So far, we're in good shape. Now we run git cherry-pick master~1, which
is what git rebase will do to copy commit B to a new commit B'. Between
A and B, some file is modified, so Git copies the modifications to those
files into your index and working tree and you force it to renormalize
those files' line endings to handle any fixing-up required to make the
changes fit. But B also adds one entirely-new file whose line endings
don't match up correctly. Since this new file has no corresponding file
in either A or A', Git can—and I think will, although you'd have to
test it to find out for sure—just copy it wholesale without
renormalizing its line endings.

Git would repeat this for B-vs-C; again, any all-new file might not be
renormalized. So you end up with:
  
```
A--B--C   <-- master

'A'-'B'-'C'  <-- new-master (HEAD)
```
in which files that were introduced since A might not have the right
line endings in some commits.

If the copies made by rebase are renormalized, we're down to just the
merge issues. If you don't mind the merges being re-performed—which
may require that you re-resolve any merge conflicts—then this overall
strategy should work.

There is, however, another way to do this. Instead of using rebase, you
can use git filter-branch or its modern (but not yet distributed with
Git) replacement, git filter-repo. These are both capable of taking each
original commit—including merges—and applying a "content filter" to
each file in the original commit before making a new commit.

The content filter you would want would be:

    add .gitattributes, then renormalize


The filter-branch filters are not particularly good at this but you
definitely do it (probably, the slowest filter, the --tree-filter, would
work out of the box here: a tree filter that copies /tmp/.gitattributes
to ./.gitattributes might suffice). The filter-repo command is under
active development and you could request an "add attributes and
renormalize" command-line option, since this seems like something people
want to do more these days 



## Recovering a commit from GitHub Reflog

[source, https://objectpartners.com/2014/02/11/recovering-a-commit-from-githubs-reflog/](https://objectpartners.com/2014/02/11/recovering-a-commit-from-githubs-reflog/)

```
curl https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;/events
```

This will return a JSON response which you can read through to find the commit you lost. Use the commit message and approximate times to narrow your search. Here is an example portion of the response (I’ve deleted some info, but you should get the point):

```json
{ "id": "1970551769", "type": "PushEvent", "actor": { "id": 563541, "login": "&lt;user&gt;", "gravatar_id": "&lt;id&gt;", "url": "https://api.github.com/users/&lt;user&gt;", "avatar_url": "&lt;url&gt;" }, "repo": { "id": 9652839, "name": "&lt;user&gt;/&lt;repo&gt;", "url": "https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;" }, "payload": { "push_id": 303837533, "size": 1, "distinct_size": 1, "ref": "refs/heads/&lt;branch&gt;", "head": "a973ddd28d599c9ba128de56182f8769d2b9843b", "before": "4ef3d74316c04c892d17250f0ba251b328274e5f", "commits": [ { "sha": "384f275933d5b762cdb27175aeff1263a8a7b7f7", "author": { "email": "&lt;email&gt;", "name": "&lt;author&gt;" }, "message": "&lt;commit message&gt;", "distinct": true, "url": "https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;/commits/384f275933d5b762cdb27175aeff1263a8a7b7f7" } ] }, "public": false, "created_at": "2014-02-06T14:05:17Z" }
```

Next, use Github’s Refs API to create a new branch pointing to that commit:

```sh
curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d '{"ref":"refs/heads/D-commit", "sha":"384f275933d5b762cdb27175aeff1263a8a7b7f7"}' https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;/git/refs
```


Breaking down the JSON in this request we have this:

```json
{ "ref": "refs/heads/D-commit", "sha": "384f275933d5b762cdb27175aeff1263a8a7b7f7" }
```

The "ref" in the JSON is Git ref we want to create, it MUST be of the form: refs/heads/<branch>, where <branch> is the name of the branch we want to create in Git.
The "SHA" is the commit that we want this new branch to point to.

If successful Github will respond back with something like this:

```sh
HTTP/1.1 201 Created Server: GitHub.com Date: Thu, 06 Feb 2014 14:47:02 GMT Content-Type: application/json; charset=utf-8 Status: 201 Created X-RateLimit-Limit: 5000 X-RateLimit-Remaining: 4991 X-RateLimit-Reset: 1391700034 Cache-Control: private, max-age=60, s-maxage=60 ETag: "43e54fee5cf29edd01fa8bfce094ed1b" Location: https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;/git/refs/heads/D-commit Vary: Accept, Authorization, Cookie, X-GitHub-OTP X-GitHub-Media-Type: github.beta X-Content-Type-Options: nosniff Content-Length: 339 Access-Control-Allow-Credentials: true Access-Control-Expose-Headers: ETag, Link, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval Access-Control-Allow-Origin: * X-GitHub-Request-Id: 4389B15A:3E60:1D2506F:52F3A066 { "ref": "refs/heads/D-commit", "url": "https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;/git/refs/heads/D-commit", "object": { "sha": "384f275933d5b762cdb27175aeff1263a8a7b7f7", "type": "commit", "url": "https://api.github.com/repos/&lt;user&gt;/&lt;repo&gt;/git/commits/384f275933d5b762cdb27175aeff1263a8a7b7f7" } }
```

Now if you pull up your repository in Github, you will see the new branch and doing a ‘git fetch’ will retrieve that new branch to your local repository. From there you can cherry-pick or merge the commits back into your work.
