module.exports = (karma) ->
  karma.set do
    basePath: "../"
    frameworks: ["mocha", "chai"]
    files:
      * "_public/js/vendor.js"
      * "_public/js/app.templates.js"
      * "_public/js/app.js"
      * "bower_components/angular-mocks/angular-mocks.js"
      * "test/unit/**/*.spec.ls"
    exclude: []
    reporters: ["progress"]
    port: 9876
    runnerPort: 9100
    colors: true
    logLevel: karma.LOG_INFO
    autoWatch: true
    browsers: <[PhantomJS]>
    captureTimeout: 60000
    plugins: <[karma-mocha karma-chai karma-live-preprocessor karma-phantomjs-launcher]>
    preprocessors:
      '**/*.ls': ['live']
    singleRun: false