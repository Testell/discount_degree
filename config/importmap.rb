pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin "jquery", to: "https://code.jquery.com/jquery-3.7.1.min.js", preload: true

pin "chartkick", to: "https://cdn.jsdelivr.net/npm/chartkick@5.0.1/dist/chartkick.js", preload: true

pin "Chart.bundle",
    to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.js",
    preload: true
