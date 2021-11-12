module.exports = {
  'pre-commit': 'sh fmt-preitter-diff',
  'commit-msg': `npx commitlint -e`,
}
