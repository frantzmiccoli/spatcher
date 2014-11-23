module.exports = (grunt) ->
  grunt.initConfig

    watch:
      coffeelint:
        files: ['src/**/*.coffee', 'Gruntfile.coffee']
        tasks: ['coffeelint']

      test:
        files: ['src/**/*.coffee', 'Gruntfile.coffee']
        tasks: ['mochaTest']

    coffeelint:
      app: ['src/**/*.coffee', 'Gruntfile.coffee']
      options:
        configFile: 'coffeelint.json'

    mochaTest:
      test:
        options:
          reporter: 'spec',
          require: 'coffee-script/register'
          bail: true
        src: ['src/**/*Test.coffee']

    shell:
      coffee:
        command: 'node_modules/.bin/coffee --output lib src'

      publish:
        command: 'grunt shell:coffee; cp package.json lib/spatcher; ' +
          'cp README.md lib/spatcher; rm -rf lib/spatcher/test; ' +
          '(cd lib/spatcher; npm publish);'


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-shell'
