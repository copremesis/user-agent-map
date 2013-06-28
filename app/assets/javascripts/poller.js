


var Poller = function(panels, options) {
  this.options = options || {};
  this.options.callback = this.options.callback || function() {}
  this.refresh_rate = this.options.refresh_rate || 5000; //very slow today
  this.panels = panels || ['times', 'bing', 'google'];
  this.duration = 3600*1000; //1 hour of polling
  this.run = function(name) {
    if(name == 'gantt') {
      (g = new Gantt()).build_gantt(); //custom for gantt since it performs it's own ajax request
      return;
    }
//console.log(window.location.search.replace(/\?/, '&'));
  var that = this;
    $.get('/main/json_data', ['page=', document.page, '&key=', name, window.location.search.replace(/\?/, '&')].join(''), function(json) {
      document.getElementById(name).innerHTML = (new Table(json)).html_table();
      (new Events()); //could pass something in here dunno or have it conditional ... proc thats passed in
      that.options.callback.call();
    });
  };

  this.run_poller = function(name) {
    document.panels.push(name); //move onto the global scope
    this.run(name);
    var that = this;
    document.jobs.push(setInterval(function() {
      that.run(name);
    }, this.refresh_rate));

    setTimeout(function() {
      document.jobs.each(function(poller) {
         clearInterval(poller);
      });
      document.jobs = [];
      console.log('polling stopped');
/*
      setTimeout(function() {
        //document.panels.each(function(widget) { $('#'+widget)[0].innerHTML = '<b>polling stopped<blink>!</blink></b> <br> refresh page to start another poll' });
      }, 10000);
*/
    }, this.duration);
  };

  this.init = function() {
    //this.panels.each(function(widget, that) { that.run_poller(widget) }, this);
    var that = this;
    $.each(this.panels, function(i, panel) {
      that.run_poller(panel);
    });
  };

  this.init();
}

$(document).ready(function() {
  document.jobs = [];
  document.panels = [];
  //new Poller(['times', 'bing', 'google']);
  //document.page = parseInt(Math.random() * 300);
  //new Poller(['google','times', 'google_stats']);
  //new Poller(['google', 'google_stats']);
  //new Poller(['times', 'gantt']);
  //new Poller(['gantt']);
  //new Poller(['ghost_summary']);
});
