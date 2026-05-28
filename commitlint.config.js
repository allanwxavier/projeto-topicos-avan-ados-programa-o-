module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Escopos aceitos pelo projeto
    'scope-enum': [2, 'always', [
      'ui',
      'api',
      'infra',
      'docs',
      'deps',
      'config',
      'test',
      'ci'
    ]],

  },
};
