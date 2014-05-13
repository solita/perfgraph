module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files: [
          expand: true
          cwd: "app/"
          src: ["**/*.coffee"]
          dest: "public/"
          ext: ".js"
        ]

      options:
        flatten: false
        bare: false

    jade:
      compile:
        files:
          "public/index.html": "app/**/*.jade"

    stylus:
      compile:
        files: [
          expand: true
          cwd: "app/"
          src: ["**/*.styl"]
          dest: "public/css/"
          ext: ".css"
          flatten: true
        ]
        options:
          compress: true

    watch:
      coffee:
        files: ["app/**/*.coffee"]
        tasks: ["coffee"]

      stylus:
        files: ["app/**/*.styl"]
        tasks: ["stylus"]

      jade:
        files: ["app/**/*.jade"]
        tasks: ["jade"]

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-watch"

  grunt.registerTask "default", ["coffee", "jade", "stylus", "watch"]

