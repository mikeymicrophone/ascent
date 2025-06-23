/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim,rb}',
    './app/views/**/*.rb',
    './lib/generators/**/templates/**/*.rb'
  ],
  theme: {
    extend: {
      fontFamily: {
        'display': ['Caprasimo', 'cursive'],
        'heading': ['Kanit', 'sans-serif'],
        'body': ['Nunito', 'sans-serif'],
        'accent': ['WDXL Lubrifont JP N', 'sans-serif'],
        'serif': ['Noto Serif Dives Akuru', 'serif'],
      },
      fontWeight: {
        'light': '200',
        'normal': '400',
        'medium': '500',
        'semibold': '600',
        'bold': '700',
        'extrabold': '800',
        'black': '900',
      }
    },
  },
  plugins: [
    // Additional Tailwind plugins can be added here
    // For example: require('@tailwindcss/forms'), require('@tailwindcss/typography')
  ],
}