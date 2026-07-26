// eslint.config.js
export default [
  {
    files: ["**/*.{js,jsx,ts,tsx}"],
    languageOptions: {
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
    rules: {
      // ترك القوانين فارغة فقط لتمرير عملية الفحص الأولي للـ JSX
    },
  },
];
