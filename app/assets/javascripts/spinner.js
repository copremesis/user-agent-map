

//the anonymouse idea is a good idea yet you need to hand back a callback for the ajax request gets
//a little hairy ... can test but must have wings first
//

var Spinner = function() {
  this.on = function() {
    $('#loading').css('display','block');
  };

  this.off = function() {
    $('#loading').css('display','none');
  };

  this.anonymous = function(anonymous_code) {
    this.on();
    var that = this;
    anonymous_code(function() {
      that.off();//callback passed to anonymous_code
    });
  }
};

