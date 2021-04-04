"""
gitxz

"""
from setuptools import setup
import os
for f in ['gitxz', 'git_filter_repo.py', '_gitfilter_template.py', 'git-lint.py',  'README.md']:
    try:
        os.symlink("../"+f, f)
    except FileExistsError:
        pass
setup(use_scm_version=dict(root="..", relative_to=__file__))
