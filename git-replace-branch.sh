#!/bin/bash
git checkout ${DELETE_BRANCH}
git gc
git merge --ff-only $(git commit-tree -m "replace branch" -p ${DELETE_BRANCH} -p ${NEW_BRANCH} ${NEW_BRANCH}^{tree})
