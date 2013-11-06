exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  modules:
    wrapper: (path, data, xx) ->
      if [_, name]? = path.match /"config"$/
        console.log path
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
  #{data}
  ;\n\n
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
          'vendor/scripts/angular/angular.js'
        after: <[ app/app/controllers.ls ]>

    stylesheets:
      joinTo:
        'css/app.css': /^(app|vendor)/

    templates:
      joinTo:
        # this name is required for jade_angular plugin to work
        'js/dontUseMe': /^app(?!\/view)/

  # Enable or disable minifying of result js / css files.
  # minify: true
  plugins:
    jade:
      options:
        pretty: yes
      locals:
        googleAnalytics: 'UA-41326468-1'
    static_jade:
      extension: '.static.jade'
      path: [ /^app/ ]
    jade_angular:
      modules_folder: \partials
      locals: {}
