name: "ly.g0v.tw"
repo: "g0v/ly.g0v.tw"
version: "0.1.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  jquery: "~2.0.3"
  angular: "1.2.4"
  "angular-cookies": "1.2.4"
  "angular-ui": "0.4.0"
  "angular-mocks": "1.2.4"
  "angular-ui-router": "0.2.0"
  "angular-scenario": "1.2.4"
  "bootstrap-stylus": "2.3.2"

overrides:
  "angular-mocks":
    main: "README.md"
