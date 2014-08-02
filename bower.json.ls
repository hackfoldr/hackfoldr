name: "hackfoldr"
repo: "hackfoldr/hackfoldr"
version: "0.1.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  "commonjs-require-definition": "~0.1.2"
  jquery: "1.8.2"
  angular: "1.2.21"
  "angular-cookies": "1.2.21"
  "angular-animate": "1.2.21"
  "angular-ui-sortable": "0.12.2"
  "angular-ui-router": "0.2.10"
  "angular-ui-router.stateHelper": "git://github.com/clkao/ui-router.stateHelper#patch-1"
  "angular-ui": "0.4.0"
  "angular-mocks": "1.2.21"
  "angular-scenario": "1.2.21"
  "csv-js": "*"
  "tabletop": "1.3.5"
  "semantic-ui": "~0.18.0"

overrides:
  "angular":
    dependencies: jquery: "*"
  "angular-mocks":
    main: "README.md"
  "angular-scenario":
    main: "README.md"
  "angular-ui":
    main:
      * "build/angular-ui.js"
  "semantic-ui":
    main: "build/packaged/**/*"
