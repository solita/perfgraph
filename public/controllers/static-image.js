(function() {
  define([], function() {
    var StaticImage;
    return StaticImage = (function() {
      function StaticImage(elem, src) {
        this.elem = elem;
        this.src = src;
        this.width = this.elem.width();
        this.height = this.elem.height();
      }

      StaticImage.prototype.update = function() {
        this.elem.attr('src', this.src);
        this.elem.attr('height', this.height);
        return this.elem.attr('width', this.width);
      };

      return StaticImage;

    })();
  });

}).call(this);
