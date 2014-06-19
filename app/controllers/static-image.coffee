define [], () ->

  class StaticImage
    constructor: (@elem, @src) ->
      @width  = @elem.width()
      @height = @elem.height()

    update: () ->
      @elem.attr 'src', @src
      @elem.attr 'height', @height
      @elem.attr 'width', @width