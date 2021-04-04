# Makefile
# installation-related paths to override
prefix = $(HOME)
bindir = $(prefix)/libexec/git-core
#localedir = $(prefix)/share/locale
#mandir = $(prefix)/share/man
#htmldir = $(prefix)/share/doc/git-doc
pythondir = $(prefix)/lib64/python3.6/site-packages


install: git-filter-repo # this is a git commit specific version of git_filter_repo we use
	cp -a git-filter-repo "$(bindir)/"
	ln -sf "$(bindir)/gitxxx" "$(pythondir)/git_filter_repo.py"
