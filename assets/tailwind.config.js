const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  mode: 'jit',
  purge: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'brevity-teal': '#10E0D8',
        'brevity-dark': '#1A1A1A',
        'brevity-gray': '#333435',
        'brevity-light': '#F6F8F9',
        'brevity-red': '#F94348',
        'brevity-green': '#27ae60',
        'brevity-orange': '#f2801b',
        'brevity-yellow':'#F2C94C'
      },
      boxShadow: {
        white: '0 1px 3px 0 rgba(255, 255, 255, 0.1), 0 1px 2px 0 rgba(255, 255, 255, 0.06)',
        whitelg: '0 10px 15px -3px rgba(255, 255, 255, 0.1), 0 4px 6px -2px rgba(255, 255, 255, 0.05)'
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('tailwind-caret-color')(),
  ],
}
