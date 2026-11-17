// ESLint の設定（Expo 公式の flat config）
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');

module.exports = defineConfig([
  expoConfig,
  {
    ignores: ['ios/', 'android/', 'supabase/', 'node_modules/', '.expo/', 'dist/'],
  },
]);
