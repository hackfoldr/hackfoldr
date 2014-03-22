exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  modules:
    wrapper: (path, data) ->
      if [_, name]? = path.match /([^/\\]+)\.jsenv/
        """
(function() {
  var module = {};
  #{data};
  if (!window.global)
    window.global = {};
  window.global['#name'] = module.exports;
}).call(this);\n\n
        """
      else
        """
(function() {
  #{data}
}).call(this);\n\n
        """
  paths:
    public: '_public'
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^vendor/
      order:
        before:
          'vendor/scripts/console-helper.js'
          'vendor/scripts/jquery-1.8.2.js'
          'vendor/scripts/angular/angular.js'
          'vendor/scripts/angular/angular-resource.js'
          'vendor/scripts/angular/angular-cookies.js'

    stylesheets:
      joinTo:
        'css/app.css': /^(app|vendor)/

    templates:
      joinTo:
        # this name is required for jade_angular plugin to work
        'js/dontUseMe': /^app/

  # Enable or disable minifying of result js / css files.
  # minify: true
  plugins:
    jade:
      options:
        pretty: yes
      locals:
        googleAnalytics: 'UA-39804485-1'
    static_jade:
      extension: '.static.jade'
      path: [ /^app/ ]
    jade_angular:
      modules_folder: \partials
      locals: {}
