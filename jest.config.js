module.exports = {
  testMatch: ['<rootDir>/spec/frontend/**/**/*_spec.js'],
  moduleFileExtensions: ['js', 'json', 'vue'],
  moduleNameMapper: {
    '^~(/.*)$': '<rootDir>/content/frontend$1',
    '\\.(css|less|sass|scss)$': '<rootDir>/spec/frontend/__mocks__/style_mock.js',
  },
  cacheDirectory: '<rootDir>/tmp/cache/jest',
  restoreMocks: true,
  transform: {
    '^.+\\.js$': 'babel-jest',
    '^.+\\.vue$': '@vue/vue2-jest',
    '^.+\\.svg$': '@vue/vue2-jest',
  },
  transformIgnorePatterns: [
    'node_modules/(?!(@gitlab/(ui|svgs)|bootstrap-vue|vue-instantsearch|instantsearch.js)/)',
  ],
  setupFilesAfterEnv: ['<rootDir>/spec/frontend/jest.overrides.js'],
};
