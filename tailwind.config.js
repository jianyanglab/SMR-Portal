/** @type {import('tailwindcss').Config} */
// https://github.com/tailwindlabs/tailwindcss/discussions/5258
export default {
  corePlugins: {
    // preflight: false,
  },
  content: [
    './index.html',
    './src/**/*.{js,ts,vue}',
  ],
  theme: {
    extend: {
      colors: {
        gamma: {
          primary: '#0077FA',
          secondary: '#002C6B',
          hover: '#0062D6',
          active: '#004FB3',
          DEFAULT: '#003D8F',
          light: '#EAF5FF',
          lighter: '#ECEFF8',
        },
      },
      spacing: {
        18: '4.5rem',
      },
      fontFamily: {
        lexend: [
          'Lexend',
          'sans-serif',
        ],
      },
      animation: {
        breath: 'breath 6s infinite',
      },
      keyframes: {
        breath: {
          '0%': { opacity: '0' },
          '75%': { opacity: '1' },
          '100%': { opacity: '0' },
        },
      },
    },
  },
  plugins: [],
}
