(function() {

  define(['jquery'], function($) {
    return {
      init: function(name) {
        return $('h1').on('click', function() {
          return $('p').text("This might a start for a beautiful program, " + name + " <3");
        });
      }
    };
  });

}).call(this);
