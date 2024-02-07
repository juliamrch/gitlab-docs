const setupFilesAfterEnv = ['<rootDir>/spec/frontend/jest.overrides.js'];
const VUE_JEST_TRANSFORMER = '@vue/vue2-jest';

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
    '^.+\\.vue$': VUE_JEST_TRANSFORMER,
    '^.+\\.svg$': VUE_JEST_TRANSFORMER,
  },
  snapshotSerializers: [
    '<rootDir>/spec/frontend/html_string_serializer.js',
    '<rootDir>/spec/frontend/clean_html_element_serializer.js',
  ],
  setupFilesAfterEnv,
  transformIgnorePatterns: ['node_modules/(?!(@gitlab/(ui|svgs)|bootstrap-vue)/)'],
};
