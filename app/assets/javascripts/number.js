
Number.prototype.day = Number.prototype.days = function() {
  return (this * 3600 * 24 * 1000);
};
Number.prototype.hour = Number.prototype.hours = function() {
  return (this * 3600 * 1000);
};
Number.prototype.minute = Number.prototype.minutes = function() {
  return (this * 60 * 1000);
};
Number.prototype.ago = function() {
  var d = new Date();
  return (d.getTime() - this); //1000.0;
};
Number.prototype.from_now = function() {
  var d = new Date();
  return (d.getTime() + this); //1000.0;
};
Number.prototype.send = function(method) {
  return this[method].call();
};

