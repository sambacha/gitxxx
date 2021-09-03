# Git filter branch recipes

## Remove "Issue #12345: "-Prefix from commit messages

```
git filter-branch --msg-filter 'sed -e "s/Issue #[0-9]*: //"'
```

## Remove all files except those of a given name

```
git filter-branch --prune-empty -f --index-filter 'git ls-tree -r --name-only --full-tree $GIT_COMMIT | grep -v "filename" | xargs git rm -r'
```

`filename` is the value that has to be part of the file name.

## Replace git author mail

```
git filter-branch --env-filter 'if [ $GIT_AUTHOR_EMAIL = old@example.com ]; then GIT_AUTHOR_EMAIL=new@example.org; fi; export GIT_AUTHOR_EMAIL' -f
```

## Rename file names containing a given string

```
git filter-branch --tree-filter '
for file in $(find . ! -path "*.git*" ! -path "*.idea*")
do
  if [ "$file" != "${file/Result/Stat}" ]
  then
    mv "$file" "${file/Result/Stat}"
  fi
done
' --force HEAD
```

## Rename strings in commit messages

```
git filter-branch -f --msg-filter 'sed -e "s/Result/Stat/"'
```

## Rename file content

```
git filter-branch --tree-filter '
for file in $(find . -type f ! -path "*.git*" ! -path "*.idea*")
do
  sed -i "" -e s/Result/Stat/g $file;
done
' --force HEAD
```
