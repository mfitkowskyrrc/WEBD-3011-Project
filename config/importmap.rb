# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "rails", to: "rails.js"
pin "turbo", to: "https://cdn.jsdelivr.net/npm/@hotwired/turbo@7.0.0/dist/turbo.min.js"

pin "stripe", to: "https://js.stripe.com/v3/"
pin "stripe_checkout", to: "stripe_checkout.js"
pin "fullcalendar" # @6.1.17
