#!/usr/bin/env bash
echo "update-ref delete refs/tags"
log="git-update-ref-errors.log"
script="./git-update-ref-exist-tags-delete.sh"
git_command="git update-ref -d refs/tags"

echo "log errors from ${git_command} to ${log}"
${git_command} 2>&1 | > ${log}
echo "show errors to ${log}"
cat ${log}
echo create ${script}
touch ${script}
echo "add execute (+x) permissions to ${script}"
chmod +x ${script}
echo "generate ${script} from errors log ${log}"
${git_command} 2>&1 | grep 'exists' | sed -n "s:.*\: 'refs/tags/\(.*\)' exists;.*:git tag -d '\1':p" >> ${script}
echo "execute ${script}"
${script}

echo fetch
log="git-fetch-errors.log"
script="./git-fetch-exist-tags-delete.sh"
git_command="git fetch"
echo "log errors from ${git_command} to ${log}"
${git_command} 2>&1 | > ${log}
echo "show errors from ${log}"
cat ${log}
echo create ${script}
touch ${script}
echo "add execute (+x) permissions to ${script}"
chmod +x ${script}
echo "generate ${script} from errors log ${log}"
${git_command} 2>&1 | grep 'exists' | sed -n "s:.*\: 'refs/tags/\(.*\)' exists;.*:git tag -d '\1':p" >> ${script}
echo "execute ${script}"
${script}
git fetch

echo pull
log="git-pull-errors.log"
script="./git-pull-exist-tags-delete.sh"
git_command="git pull"
echo "log errors from ${git_command} to ${log}"
${git_command} 2>&1 | > ${log}
echo "show errors from ${log}"
cat ${log}
echo create ${script}
touch ${script}
echo "add execute (+x) permissions to ${script}"
chmod +x ${script}
echo "generate ${script} from errors log ${log}"
${git_command} 2>&1 | grep 'exists' | sed -n "s:.*\: 'refs/tags/\(.*\)' exists;.*:git tag -d '\1':p" >> ${script}
echo "execute ${script}"
${script}
git pull

echo push
log="git-push-errors.log"
script="./git-push-exist-tags-delete.sh"
git_command="git push"
echo "log errors from ${git_command} to ${log}"
${git_command} 2>&1 | > ${log}
echo "show errors from ${log}"
cat ${log}
echo create ${script}
touch ${script}
echo "add execute (+x) permissions to ${script}"
chmod +x ${script}
echo "generate ${script} from errors log ${log}"
${git_command} 2>&1 | grep 'exists' | sed -n "s:.*\: 'refs/tags/\(.*\)' exists;.*:git tag -d '\1':p" >> ${script}
echo "execute ${script}"
${script}
git push
