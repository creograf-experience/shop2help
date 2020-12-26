module.exports = (grunt) ->
  grunt.file.defaultEncoding = 'utf8'
  require('time-grunt')(grunt)
  require('jit-grunt')(grunt,
    jasmine_node: 'grunt-jasmine-node-new'
    nggettext_extract: 'grunt-angular-gettext'
    nggettext_compile: 'grunt-angular-gettext')

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    concurrent:
      build:
        tasks: ['coffee', 'browserify:watch', 'jade:dev', 'bower']
      dev:
        tasks: ['nodemon', 'watch', 'browserify:watch']
        options:
          logConcurrentOutput: true

    browserify:
      test:
        src: 'app/client/public/env/test.coffee'
        dest: 'public/js/dist/public.js'
        options:
          transform: ['coffeeify']
          detectGlobals: true
      production:
        src: 'app/client/public/env/production.coffee'
        dest: 'public/js/dist/public.js'
        options:
          transform: ['coffeeify']
          detectGlobals: true
      build:
        src: 'app/client/public/env/dev.coffee'
        dest: 'public/js/dist/public.js'
        options:
          transform: ['coffeeify']
          detectGlobals: true
      watch:
        src: 'app/client/public/env/dev.coffee'
        dest: 'public/js/dist/public.js'
        options:
          transform: ['coffeeify']
          watch: true
          keepAlive: true
          detectGlobals: true

    shell:
      seed:
        command: 'coffee db/seed.coffee'

    bower_concat:
      cms:
        dest: 'public/js/dist/vendor-cms.js'
        exclude: ['jquery-ui', 'page', 'angular-mocks']
        dependencies:
          'angular': ['jquery', 'jquery-ui-sortable']
          'angular-route': 'angular'
          'angular-resource': 'angular'
          'angular-bootstrap': 'angular'
          'angular-ui-tinymce': ['angular', 'tinymce']
        callback: (mainFiles, component) ->
          mainFiles.map (filepath) ->
            min = filepath.replace(/\.js$/, '.min.js')
            return filepath unless grunt.file.exists(min)

            hasMap = false
            minNoMap = grunt.file.read(min).split('\n')
            .filter((line, i) ->
              hasMap = true
              !line.match /^\/\/\# sourceMappingURL.*?map$/
            ).join('\n')
            grunt.file.write min, minNoMap if hasMap
            return min

      cmsTest:
        dest: 'public/js/dist/vendor-test.js'

    coffee:
      compile:
        options:
          join: true
        files:
          'public/js/dist/cms.js':
            [
              'app/client/services.coffee'
              'app/client/directives.coffee'
              'app/client/filters.coffee'
              'app/client/controllers/application.coffee'
              'app/client/controllers/*.coffee'
              'app/client/app.coffee'
            ]

    nggettext_extract:
      pot:
        files:
          'po/templates.pot': ['public/angular-templates/**/*.html']

    nggettext_compile:
      pot:
        options:
          module: 'MeetMoreApp'
        files:
          'app/client/public/services/translation.js': ['po/*.po']

    jade:
      dev:
        options:
          doctype: 'html'
          data:
            env: 'development'
        files: [
          cwd: 'views'
          expand: true
          src: '**/*.jade'
          dest: 'public/angular-templates'
          ext: '.html'
        ]

      production:
        options:
          doctype: 'html'
          data:
            env: 'production'
        files: [
          cwd: 'views'
          expand: true
          src: '**/*.jade'
          dest: 'public/angular-templates'
          ext: '.html'
        ]

    # stylus:
    #   options:
    #     compress: false
    #     path: [
    #       'node_modules/jeet/stylus'
    #       'node_modules/rupture'
    #     ]
    #     use: [
    #       require('jeet')
    #       require('rupture')
    #     ]
    #   compile:
    #     files: [
    #       cwd: 'views/styles'
    #       src: 'style.styl'
    #       dest: 'public/css'
    #       expand: true
    #       ext: '.css'
    #     ]

    autoprefixer:
      options:
        browsers: [
          'Android >= <%= pkg.browsers.android %>'
          'Chrome >= <%= pkg.browsers.chrome %>'
          'Firefox >= <%= pkg.browsers.firefox %>'
          'Explorer >= <%= pkg.browsers.ie %>'
          'iOS >= <%= pkg.browsers.ios %>'
          'Opera >= <%= pkg.browsers.opera %>'
          'Safari >= <%= pkg.browsers.safari %>'
        ]
      dist:
        src: ['public/css/style.css']

    sprite:
      dist:
        src: 'public/resources/sprite/**/*.png'
        dest: 'public/resources/sprite.png'
        imgPath: '/resources/sprite.png'
        destCss: 'views/styles/helpers/sprite.styl'
        cssFormat: 'stylus'
        algorithm: 'binary-tree'
        padding: 8
        engine: 'pngsmith'
        imgOpts:
          format: 'png'

    imagemin:
      images:
        files: [
          expand: true,
          cwd: 'public/resources'
          src: ['**/*.{png,jpg,gif}', '!sprite/**/*']
          dest: 'public/resources'
        ]

    ngAnnotate:
      options:
        singleQuotes: true
      app:
        files:
          'public/js/dist/cms.js': ['public/js/dist/cms.js']
          'public/js/dist/public.js': ['public/js/dist/public.js']

    uglify:
      vendor:
        options:
          mangle: true
          compress: true
        files:
          'bower_components/angular-ui-tinymce/src/tinymce.min.js':
            'bower_components/angular-ui-tinymce/src/tinymce.js'
          'bower_components/page/page.min.js': 'bower_components/page/page.js'
      js:
        options:
          mangle: true
          compress: true
        files:
          'public/js/dist/public.min.js': 'public/js/dist/public.js'
          'public/js/dist/cms.min.js': 'public/js/dist/cms.js'

    nodemon:
      dev:
        script: 'app/server.coffee'
        options:
          env:
            'PRERENDER_SERVICE_URL': 'http://127.0.0.1:1337'
            'NODE_ENV': 'development'
          callback: (nodemon) ->
            nodemon.on 'log', (event) ->
              console.log(event.colour)
          cwd: __dirname
          ignore: ['app/client/']
          ext: 'js,coffee'
          watch: ['app']
          delay: 1000
      prod:
        script: 'app/server.coffee'
        options:
          env:
            'NODE_ENV': 'production'
          callback: (nodemon) ->
            nodemon.on 'log', (event) ->
              console.log(event.colour)
          cwd: __dirname
          ignore: ['app/client/**']
          ext: 'js,coffee'
          watch: ['app']
          delay: 1000

    forever:
      server:
        index: 'app/server.coffee'
        logDir: 'log'
        command: 'node_modules/coffee-script/bin/coffee'

    jasmine_node:
      options:
        forceExit: true
        coffee: true
        includeStackTrace: true
      all: ['spec/']

    karma:
      unit:
        configFile: 'config/karma.conf.coffee'
        runnerPort: 9999
        singleRun: true
        logLevel: 'INFO'

    watch:
      bower:
        files: './bower_components/*'
        tasks: ['bower']
      coffee:
        files: [
          'app/client/**/*.coffee'
          '!app/client/public/**/*.coffee']
        tasks: ['newer:coffee']
      sprite:
        files: ['public/resources/sprite/**/*.png']
        tasks: ['sprite']
      jade:
        files: 'views/**/*.jade'
        tasks: ['newer:jade']
      stylus:
        files: 'views/styles/**/*.styl'
        tasks: ['stylus', 'autoprefixer']
      imagemin:
        files: ['public/resources/**/*.{png,jpg,gif}', '!public/resources/sprite/**/*']
        tasks: ['newer:imagemin']
      # test:
      #   files: [
      #     'app/**/*.coffee'
      #     '!app/client/**/*.coffee'
      #     'spec/*'
      #   ]
      #   tasks: ['test']

    notify:
      test:
        options:
          title: 'Tests are green!'
          message: 'Roses are red, violets are blue...'

    notify_hooks:
      options:
        enabled: true
        duration: 10

  grunt.registerTask 'copyBootstrap', ->
    srcPrefix = 'bower_components/bootstrap/dist/'
    destPrefix = 'public/'
    files =
      'css/bootstrap.min.css': 'css/bootstrap.min.css'
      'fonts/glyphicons-halflings-regular.ttf':
        'fonts/glyphicons-halflings-regular.ttf'
      'fonts/glyphicons-halflings-regular.woff':
        'fonts/glyphicons-halflings-regular.woff'
      'fonts/glyphicons-halflings-regular.woff2':
        'fonts/glyphicons-halflings-regular.woff2'

    Object.keys(files).forEach (dest) ->
      src = srcPrefix + files[dest]
      if grunt.file.exists src
        console.log src
        grunt.file.copy(src, destPrefix + dest)

  grunt.registerTask 'test', ['jasmine_node', 'notify:test']
  grunt.registerTask 'coffeeProd', ['coffee', 'ngAnnotate', 'uglify:js']
  grunt.registerTask 'db:seed', 'shell:seed'
  grunt.registerTask 'bower', ['copyBootstrap', 'bower_concat']
  grunt.registerTask 'bower:production', ['copyBootstrap', 'bower_concat:cms']
  grunt.registerTask 'build:dev', ['jade:dev', 'coffee', 'browserify:build', 'bower']
  grunt.registerTask 'default', ['concurrent:dev']
  grunt.registerTask 'server:bench', ['nodemon:prod']
  grunt.registerTask 'build:test', ['jade:dev', 'coffee', 'browserify:test',
    'bower:production', 'ngAnnotate', 'uglify:js']
  grunt.registerTask 'build:production', ['jade:production', 'coffee', 'browserify:production',
    'bower:production', 'ngAnnotate', 'uglify:js']
