# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin_all_from "app/javascript/edit/", under: "edit"

pin "selection", to: "https://unpkg.com/gridjs/plugins/selection/dist/selection.umd.js"
pin "gridjs", to: "https://ga.jspm.io/npm:gridjs@6.0.6/dist/gridjs.module.js"
