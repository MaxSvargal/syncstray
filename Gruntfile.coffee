module.exports = (grunt) ->
  grunt.initConfig
    nodewebkit:
      options:
        build_dir: './builds'
        version: '0.8.4'
        mac_icns: './src/assets/icon.icns'
        mac: true
        win: true
        linux32: true
        linux64: true
      src: [ './src/**/*' ]

  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.registerTask 'default', ['nodewebkit']