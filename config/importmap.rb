# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "loglevel", to: "loglevel.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "echarts", preload: false # @6.1.0, the single-file ESM build from dist/echarts.esm.min.js
pin "gsap" # @3.15.0, jsDelivr's +esm bundle
pin "chart_theme", to: "chart_theme.js"
pin "leaflet", preload: false
