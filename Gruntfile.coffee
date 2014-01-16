module.exports = (grunt) ->
  grunt.initConfig
    nodewebkit:
      options:
        build_dir: './builds'
        version: '0.8.3'
        mac: true
        win: true
        linux32: false
        linux64: false
      src: [ './src/**/*' ]

  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.registerTask 'default', ['nodewebkit']