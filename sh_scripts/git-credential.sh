# see https://github.com/cli/cli/releases/tag/v2.21.0#:~:text=Internal%20git%20operations%20are%20now%20always%20authenticated
git -c credential.helper='!gh auth git-credential' clone $URL
