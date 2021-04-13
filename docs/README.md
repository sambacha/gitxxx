## General Notes


```bash
git log --graph --oneline --date-order
```
If the sequence of commits matches what you expect, you can use git log to generate a rebase -i sequence script :

```bash
# --reverse   : 'rebase -i' asks for entries starting from the oldest
# --no-merges : do not mention the "merge" commits
# sed -e 's/^/pick /' : use any way you see fit to prefix each line with 'pick '
#        (another valid way is to copy paste the list of commits in an editor,
#         and add 'pick ' to each line ...)
```
```bash
git log --reverse --no-merges --oneline --date-order |\
  sed -e 's/^/pick /' > /tmp/rebase-apply.txt
```

Then rebase the complete history of your repo :

```bash
git rebase -i --root
```
In the editor, copy/paste the script you created with your first command, save & close.

> source [stackoverflow:62270074](https://stackoverflow.com/questions/62270074/can-git-filter-repo-create-a-monorepo-from-many-repos-interweaving-commits-by-da)
> 
