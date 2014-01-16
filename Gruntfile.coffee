module.exports = (grunt) ->
  grunt.initConfig
    nodewebkit:
      options:
        build_dir: './builds'
        version: '0.8.3'
        mac: true,
        win: false,
        linux32: false,
        linux64: false
      src: [
        './src/index.html'
        './src/package.json'
        './src/assets/*'
        './src/lib/*'
        './src/node_modules/**/*'
      ]

  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.registerTask 'default', ['nodewebkit']