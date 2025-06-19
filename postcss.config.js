module.exports = {
  plugins: [
    // Enable CSS nesting syntax (must come before tailwindcss)
    require('tailwindcss/nesting'),
    
    // Process Tailwind CSS
    require('tailwindcss'),
    
    // Add vendor prefixes
    require('autoprefixer'),
  ]
}