
//(function() {
  /*
  Array.prototype.shuffle = function(n) {
    var max = this.length;
    var n = n || 1;
    for(var k=0; k<n; k++) {
      for(var i=0; i<max; i++) {
        var p_idx = parseInt(Math.random()*max);
        var q_idx = parseInt(Math.random()*max);
        var t = this[p_idx];
        this[p_idx] = this[q_idx];
        this[q_idx] = t;
      }
    }
    return this;
  };
  */
  var Gantt = function(canvas_id, options) {
    this.options = options || {}
    this.canvas_id = canvas_id;
    this.gantt_handler = function() {
      this.build_gantt();
      var that = this;
      var interval = setInterval(function() {
        that.build_gantt();
        that.init(); //reset vars
      }, 60000);
      setTimeout(function() {
        console.log('polling stopped');
        clearInterval(interval);
      }, 300000);
    };

    this.mock_gantt = function() {
       //var data = {"gantt":{"Archiving AHL git-repo to ahlsauce2:/data/git":[{"duration":27.0,"start_time":"2011-10-15T16:31:01-05:00"}],"cache status emailer":[{"duration":16.0,"start_time":"2011-10-15T00:00:01-05:00"},{"duration":7.0,"start_time":"2011-10-15T12:00:02-05:00"}],"Importing 30 day rollup stats for MyMedia":[{"duration":45.0,"start_time":"2011-10-15T05:55:02-05:00"}],"Archiving AHL git-repo to SAN":[{"duration":35.0,"start_time":"2011-10-15T05:00:01-05:00"}],"RentalHomesPlus Feed":[{"duration":891.0,"start_time":"2011-10-15T03:50:59-05:00"}],"Apartments Feed":[{"duration":6358.0,"start_time":"2011-10-15T02:05:00-05:00"}],"Check Availability Drip":[{"duration":409.0,"start_time":"2011-10-15T02:30:02-05:00"}]},"xtics":["Fri 06:23p", "Fri 08:41p", "Fri 10:59p", "Sat 01:17a", "Sat 03:35a", "Sat 05:53a", "Sat 08:11a", "Sat 10:29a", "Sat 12:47p", "Sat 03:05p", "Sat 05:23p"]};
       //this.duration_min = Date.parse('Fri, 14 Oct 2011 18:23:42 CDT -05:00')/1000;
       //this.duration_max = Date.parse('Sat, 15 Oct 2011 17:23:42 CDT -05:00')/1000;
       this.display(gantt_data); //defined in global scope
    };


    //really digging deep here
    this.random_gantt = function() {
      //http://blog.stevenlevithan.com/archives/date-time-format
      //http://stevenlevithan.com/assets/misc/date.format.js
      var now = new Date(),
          then = new Date(2011, now.getMonth(), now.getDate(), now.getHours() - 5, now.getMinutes(), now.getSeconds());
          var gantt = {
             "range": [then.format("isoDateTime"), now.format("isoDateTime")]
            }
          console.log(gantt);

      //this.display(gantt_data);
    };

/*  chicken/egg this object depends on this to exist upon load ...
    this.inject_gantt = function(element) {
      var html = "<div id='gantt' display=none ><canvas id=canvas width=1100 height=600></canvas></div>"
      element.innerHTML += html;
    }
*/
    this.build_gantt = function() {
      var that = this;
      //console.log('starting gantt chart');
      $.get('main/json_data', 'key=gantt', function(json_data) {
         //console.log(JSON.parse(json_data), this);
        //console.log(that.duration_max, that.duration_min, json_data);
         //$("#gantt").dialog({ opacity: 0.5, width: 1200, height: 500, title: 'Gantt Chart' });
        $("#gantt").display = 'block';
        that.display(json_data);
      });
    };

    this.now = function() {
      var d = new Date();
      return d.getTime(d)/1000; //#hour ago
      //var d = new Date();
      //return Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes())/1000;
    };

    this.ago = function(duration) {
      var d = new Date();
      //return d.setDate(d.getDate() - 1)/1000;
      //return d.setMinutes(d.getMinutes() - 5)/1000;
      //var d = new Date();
      //return Date.UTC(d.getFullYear(), d.getMonth(), d.getDate() - 1, d.getHours(), d.getMinutes())/1000;
      //return (duration).minutes().ago();
      return d.setMinutes(d.getMinutes() - duration)/1000;
    };

    this.init = function(options) {
      var options = options || {};
      this.window_min = 0;
      this.duration_min = (1).day().ago();//this.ago(this.query_options().dur || 600);
      this.duration_max = (1).day().from_now();//this.now();
      //canvas stuff
      this.canvas=document.getElementById(this.canvas_id || 'canvas');
      this.ctx=this.canvas.getContext('2d');


      this.colors = ["#00CFB4", "#FFB733", "#C9CAFF", "#7B7CB2", "#B9BF7F", "#8C693F", "#B29683", "#FFE6D5", "#9C96CC", "#49C",
                     "#EB6B00", "#A1172D", "#9BBAE0", "#B2EB3D", "#F57336", "#5849CF", "#FFFF5D", "#104D96", "#E85400", "#52610B",
                     "#A68F8F", "#9DCC8C", "#C8F5C1", "#81579E", "#996662", "#FFFF5D", "#A1172D", "#A6243D", "#83AD00", "#516B4F",
                     "#B2EB3D", "#7CA175", "#FEE293", "#C22121", "#65CF3F", "#a60075", "#00CFB4", "#047878", "#7F1637", "#380C2A",
                     "#FF9636", "#6B635F", "#FF9636"],

      //options.shuffle && this.colors.shuffle();
      //console.log(this.colors);
      this.color_index = 1;
      this.block_height = 15;
      this.Yo = 0;
      this.Yn = this.block_height;
      this.Xshift = 100; //save some room for the lables
      this.window_width = this.options.width || 1100; //- this.Xshift;
      this.window_height = 20 * this.block_height; //405; //# of series times block height
    };
    //A number in time is projected into this view port
    //The most simple approach is to note the 
    this.mapper = function(x) {
      return Math.floor((x - this.duration_min) * parseFloat(this.window_width - this.window_min - this.Xshift)/parseFloat(this.duration_max - this.duration_min)) + this.Xshift;
    };

    //add some girth if the size of the duration is litterally invisible 5 pixels is the smallest
    //otherwise it's invisible on this chart

    this.too_skinny = function(x_width) {
      //return x_width;
      return (x_width < 2)? 2 : x_width; //
    };

    this.chart_stripes = function() {
      var k = 0;
      for(var Yo = 0; Yo < this.window_height; Yo += this.block_height) {
        this.ctx.globalAlpha = 0.5;
        this.ctx.fillStyle = ((k++ & 1) == 1)? '#111' : '#222';
        this.ctx.fillRect(this.Xshift, Yo, this.window_width + this.Xshift, this.block_height);
      }
    };

    this.chart_border = function() {
      this.ctx.lineWidth = 0.5;
      this.ctx.strokeStyle = "#333"; // line color
      this.ctx.moveTo(this.Xshift,0);
      this.ctx.lineTo(this.window_width + this.Xshift, 0);
      this.ctx.moveTo(this.Xshift,this.window_height);
      this.ctx.lineTo(this.window_width + this.Xshift, this.window_height);
      this.ctx.moveTo(this.Xshift, 0);
      this.ctx.moveTo(this.Xshift,0);
      this.ctx.lineTo(this.Xshift, this.window_height);
      this.ctx.moveTo(this.Xshift + this.window_width,0);
      this.ctx.lineTo(this.Xshift + this.window_width, this.window_height);
      this.ctx.stroke();
    };

    this.setup_chart = function(start_date, end_date) {
      this.ctx.beginPath();
      this.chart_stripes();
      this.chart_border();
      var d = new Date((1).day().ago());
      for(var day = (new Date(d.getYear() + 1900, d.getMonth(), d.getDate())).getTime(); day<= (1).days().from_now(); day += (6).hours()) {
      //for(var day = start_date; day<= end_date; day += (1).day()) {
        //console.log([day, g.mapper(day)]);
        var v = this.mapper(day); //not sure about the strange math here?
        if(v >= this.Xshift && v <= this.window_width + this.Xshift) {
          this.ctx.moveTo(v, 0);
          this.ctx.lineTo(v, this.window_height); //need to compute this based on number of series ... yet another var to pass inside the ajax request

/*
          this.ctx.rotate(-Math.PI/2);
          this.ctx.font = "14pt Calibri";
          this.ctx.fillText((new Date(day)).toLocaleTimeString(), v, this.window_height + 20);
          this.ctx.rotate(Math.PI/2);
*/
        }
      }
      this.ctx.strokeStyle = "#333"; // line color
      this.ctx.stroke();
      this.xtics(start_date, end_date);
    };

    this.xtics = function(start_date, end_date) {
      this.ctx.fillStyle = '#555';
      var d = new Date((1).day().ago());
      for(var day = (new Date(d.getYear() + 1900, d.getMonth(), d.getDate())).getTime(); day<= (1).days().from_now(); day += (6).hours()) {
        var v = this.mapper(day); //not sure about the strange math here?
        if(v >= this.Xshift && v <= this.window_width + this.Xshift) {
          //this.ctx.translate(this.ctx.width / 2, this.ctx.height / 2);
          this.ctx.font = "6pt Calibri";
          //this.ctx.translate(v, this.window_height - 2);
          //this.ctx.rotate(-Math.PI/2); //turn left 90 degrees
          this.ctx.fillText([(new Date(day)).toLocaleDateString(), (new Date(day)).toLocaleTimeString()].join(' '), v, this.window_height - 2 );
          //this.ctx.rotate(Math.PI/2); //turn right 90 degrees
          //this.ctx.translate(0, 0);
        }
      }
    }

    this.vertical_lines = function(hours) {
      //this.ctx.fillStyle = '#000';
      //this.ctx.fillRect(0,0,this.window_width + this.Xshift,this.window_height);
      this.ctx.beginPath();
      this.chart_stripes();
      this.chart_border();
  /*
      for(var Xo = this.Xshift; Xo <= this.window_width + this.Xshift + 5; Xo += this.window_width/count) {
        this.ctx.strokeStyle = "#333"; // line color
        this.ctx.moveTo(Xo, 0);
        this.ctx.lineTo(Xo, this.window_height); //need to compute this based on number of series ... yet another var to pass inside the ajax request
        this.ctx.stroke();
      }
      */

      for(hour in hours) {
        //console.log(hours[hour]);
        if(!hours.hasOwnProperty(hour)) continue; //crappy Array prototypes from tabular messing things up here
        var v = this.mapper(Date.parse(hours[hour])); //not sure about the strange math here?
        //console.log(Date.parse(hours[hour]));
        if(v >= this.Xshift && v <= this.window_width + this.Xshift) {
          //console.log(v);
          //this.ctx.strokeStyle = "#411"; // line color
          this.ctx.moveTo(v, 0);
          this.ctx.lineTo(v, this.window_height); //need to compute this based on number of series ... yet another var to pass inside the ajax request
        }
      }
      this.ctx.stroke();
     //this.ctx.fillStyle = '#111';
     //this.ctx.fillRect(this.Xshift, 0, this.window_width + this.Xshift, this.block_height);
     //this.ctx.fillStyle = '#222';
    };


    this.query_options = function()  {
      var kp = window.top.location.search.replace(/\?/, '').split(/\&/);
      var params = {};
      for(i in kp) {
        if (!kp.hasOwnProperty(i)) continue;
        key_pair = kp[i].split(/=/);
        params[key_pair[0]] = key_pair[1];
      }
      return params;
    };


    this.display = function(json_data) {
      var chart_data = JSON.parse(json_data); //use getJSON request instead?
      document.chart_data = chart_data;
      var jd = chart_data.gantt;
      var xtics = chart_data.xtics;
      var hours = chart_data.hours;

      this.window_height = chart_data.size * this.block_height;
      this.canvas.height = this.window_height; //adjust canvas size to fit data
      //console.log(hours);
  /*
      //not yet passed
      var range = json_data.range
      this.duration_min = Date.parse(range[0])/1000;
      this.duraiton_max = Date.parse(range[1])/1000;
  */
      var search_params = this.query_options();
      //console.log(search_params);
      //console.log(search_params.dur);
      //this.duration_min = this.ago(search_params.dur || 600);
      //this.duration_min = this.ago(60);
      //this.duration_max = this.now();
      //console.log(this.duration_min, this.duration_max, this.duration_max - this.duration_min);

      this.ctx.clearRect(0,0,this.window_width + this.Xshift,this.window_height);
      //this.vertical_lines(hours);

      this.setup_chart((1).day().ago(), (1).day().from_now()); //#pull from range

      for (feed in jd) {
        if(!jd.hasOwnProperty(feed)) continue; //crappy Array prototypes from tabular messing things up here
        var evt = jd[feed];
        //this.ctx.fillStyle = this.colors[parseInt(Math.random() * this.colors.length)];
        this.ctx.fillStyle = this.colors[this.color_index];
        for(i in evt) {
          if(!evt.hasOwnProperty(i)) continue; //crappy Array prototypes from tabular messing things up here
          var my_event = evt[i];
          var Eo = Date.parse(my_event.start_time);
          var En = Eo + my_event.duration * 1000; //duration comes in expressed in seconds it needs to be in milliseconds in this projection
          var x_width = this.mapper(En) - this.mapper(Eo);
          this.ctx.fillRect(this.mapper(Eo), this.Yo + 1, this.too_skinny(x_width), this.Yn - 1);
          //console.log(this.mapper(Eo), this.Yo, this.too_skinny(x_width), this.Yn);
        }
        this.ctx.font = "8pt Calibri";
        //this.ctx.rotate(Math.PI*2/(i*6));
        this.ctx.fillText(feed + ':', 0, this.Yo + this.block_height);
        this.color_index++;
        this.Yo += this.block_height;
      }
      //this.ctx.fillStyle = this.colors[parseInt(Math.random() * this.colors.length)];
      this.ctx.fillStyle = this.colors[this.color_index];
      var Xo = this.Xshift;
      for(lable in xtics) {
        if(!xtics.hasOwnProperty(lable)) continue; //crappy Array prototypes from tabular messing things up here
        this.ctx.font = "8pt Calibri";
        //this.ctx.rotate(Math.PI / 2); //rotate 90 degrees?
        //this.ctx.fillText(xtics[lable], Xo, this.Yo + this.block_height);
        this.ctx.fillText(xtics[lable], Xo, this.window_height - 3);
        Xo += this.window_width/(xtics.length + 2);
      }

      //this.ctx.fillText(xtics[lable], Xo, this.window_height - 3);
      //Xo += this.window_width/xtics.length;

    };

    this.test = function() {
      g = new Gantt()
      console.log([g.mapper((1).day().ago()), g.mapper((0).minutes().from_now()), g.mapper((4).days().from_now())]);
    }
    this.init({shuffle: true}); //start with a random color pallet
  };

/*
  //$(document).ready(function() {
    $(function() { //same as above
    var g = new Gantt();
    //g.gantt_handler(); //live 
    //g.mock_gantt();  //offline testing/developing
    //g.test();
    //g.random_gantt();
//    $('.gantt').live('click', function() {
//      var g = new Gantt();
//      g.build_gantt();
//    });
    console.log("I'm alive");
    g.build_gantt();
  });
*/
//  window.Gantt = Gantt;

//})();
