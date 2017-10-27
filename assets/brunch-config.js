exports.config = {
  files: {
    javascripts: {
      joinTo: 'js/app.js'
    },
    stylesheets: {
      joinTo: 'css/app.css'
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    assets: /^(static)/
  },

  paths: {
    watched: ['static', 'css', 'js', 'vendor', 'elm', 'compiled_elm'],
    public: '../priv/static'
  },

  plugins: {
    babel: {
      ignore: [/vendor/, /compiled_elm/]
    },
    copycat: {
      'compiled_elm': ['compiled_elm'],
      verbose: true,
      onlyChanged: true
    },
    elmBrunch: {
      mainModules: ['elm/Main.elm'],
      outputFolder: '../assets/compiled_elm',
      makeParameters: ['--debug']
    }
  },

  modules: {
    autoRequire: {
      'js/app.js': ['js/app']
    }
  },

  npm: {
    enabled: true
  }
}
