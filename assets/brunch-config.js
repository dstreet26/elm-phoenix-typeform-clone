exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: 'js/app.js',

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //   "js/app.js": /^js/,
      //   "js/vendor.js": /^(?!js)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "vendor/js/jquery-2.1.1.js",
      //     "vendor/js/bootstrap.min.js"
      //   ]
      // }
      order: {
        before: [
          'vendor/main.js'
        ]
      }
    },
    stylesheets: {
      joinTo: 'css/app.css'
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ['static', 'css', 'js', 'vendor', 'elm'],
    // Where to compile files to
    public: '../priv/static'
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    elmBrunch: {
        // (required) Set to the elm file(s) containing your "main" function `elm make`
        //            handles all elm dependencies relative to `elmFolder`
      mainModules: ['elm/Main.elm'],

        // (optional) Set to path where `elm-make` is located, relative to `elmFolder`
      // executablePath: 'node_modules/elm/binwrappers',

        // (optional) Set to path where elm-package.json is located, defaults to project root
        //            if your elm files are not in /app then make sure to configure
        //            paths.watched in main brunch config
      // elmFolder: '/assets/',
      // elmFolder: '.',

        // (optional) Defaults to 'js/' folder in paths.public
        // relative to `elmFolder`
      // outputFolder: 'some/path/',
      // outputFolder: 'js/',
      // outputFolder: '../assets/js',
      outputFolder: '../assets/vendor',

        // (optional) If specified, all mainModules will be compiled to a single file
        //            This is merged with outputFolder.
      // outputFile: 'elm.js',

        // (optional) add some parameters that are passed to elm-make
      // makeParameters: ['--warn']
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
