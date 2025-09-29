/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: '#0AD9E4',
        secondary: '#FFD300',
        background: '#FFFFFF',
        text: '#000000',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}