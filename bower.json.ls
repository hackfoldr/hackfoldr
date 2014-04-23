name: "hackfoldr"
repo: "hackfoldr/hackfoldr"
version: "0.1.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  "commonjs-require-definition": "~0.1.2"
  jquery: "1.8.2"
  angular: "1.2.4"
  "angular-cookies": "1.2.4"
  "angular-animate": "1.2.4"
  "angular-ui-sortable": "0.12.2"
  "angular-ui-router": "0.2.0"
  "angular-ui": "0.4.0"
  "angular-mocks": "1.2.4"
  "angular-scenario": "1.2.4"
  "bootstrap-stylus": "2.3.2"
  "csv-js": "*"

overrides:
  "angular":
    dependencies: jquery: "*"
  "angular-mocks":
    main: "README.md"
  # FIX a typo in bootstrap-stylus 2.3.2
  "bootstrap-stylus":
    main:
      * "stylus/bootstrap.styl"
      * "stylus/responsive.styl"
  "angular-scenario":
    main: "README.md"
  "angular-ui":
    main:
      * "build/angular-ui.js"
