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
      // Custom theme extensions will go here
      // Colors, fonts, spacing, etc. can be customized as needed
    },
  },
  plugins: [
    // Additional Tailwind plugins can be added here
    // For example: require('@tailwindcss/forms'), require('@tailwindcss/typography')
  ],
}