var Bing = function(element, options) {
  this.init = function(element, options) {
    var options = options || {};
    //console.log('Initializeing Bing Maps');
    this.element = element;
    this.element.innerHTML = ''; //clear out any stuff in this element
    this.map = new Microsoft.Maps.Map(this.element,
                                 { //credentials: "Ah1Fu4Ax_1YDzLayJUadWeuoaaXTMzKKzERsUgonR85VK6ctZA2mOZRi5KRSWK3L",
                                   credentials: "AiCpHnzv6ZAcJw7O9eVf_nAM6eL6Q1EYZId3dBWMtHhA4fUE_2bOXAQnshWmzc0u",
                                   showCopyright: false,
                                   showDashboard: !!options.showDashboard,
                                   width: options.width || 375,
                                   height: options.height || 350,
        //                           disableZooming: true,
                                   disableMouseInput: false,
                                   disablePanning: false,
                                   disableBirdseye: true,
                                   enableSearchLogo: false,
                                   disableKeyboardInput: true,
                                   mapTypeId:Microsoft.Maps.MapTypeId.road,
                                   animate: false
                                 }
                                );
  };

  this.adjust_center = function(center) {
    c = new Microsoft.Maps.Location(center[0],center[1]);
    this.map.setView({center: c, zoom: 10});
  };

  this.add_push_pin = function(position) {
    var point = new Microsoft.Maps.Location(position[0], position[1]),
        //push_pin = new Microsoft.Maps.Pushpin(point, {draggable: false, zIndex: 9999, icon: 'http://img.apartmenthl.com/imgs/maps/markers/blue/marker.png'});
        //push_pin = new Microsoft.Maps.Pushpin(point, {draggable: false, zIndex: 9999, icon: 'http://www.cs.uh.edu/~rob/gb_logo.png'});
        push_pin = new Microsoft.Maps.Pushpin(point, {draggable: false, zIndex: 9999});
    //query entities if this point exists already
    this.map.entities.push(push_pin);
    //this.map.setView({center: Microsoft.Maps.Location(38.0, 97.0), zoom: 2});
    this.map.setView({center: point, zoom: 12});
    //return push_pin; //do some trouble shooting on the pin
  }

  this.visual_route = function(ip) {
    var that = this;
    (new Spinner()).on();
    $.get('/main/traceroute', ['ip=', ip].join(''), function(json) {
      var points = JSON.parse(json),
          rand = function(n) {return parseInt(Math.random()*n)},
          line_vertices = points.map(function(p) {
                            return new Microsoft.Maps.Location(p[0], p[1]);
                          }),
          line = new Microsoft.Maps.Polyline(line_vertices, {strokeColor:new Microsoft.Maps.Color(200, rand(255), 100 + rand(155), 100 + rand(155))}); 
          //line = new Microsoft.Maps.Polyline(line_vertices); 
/*
          points.map(function(i, point) {
            setTimeout(function() {
              var location = new Microsoft.Maps.Location(point[0], point[1]),
                  marker = new Microsoft.Maps.Pushpin(location, {draggable: false, zIndex: 9999, icon: 'http://www.cs.uh.edu/~rob/radial.png'});
                  that.map.entities.push(marker);
                  that.map.setView({center: marker, zoom: 8});
            }, i*3000);
          });
*/

      that.map.entities.push(line);
      (new Spinner()).off();
    });
  };

  this.visual_routes = function(list) {
    var that = this;
    list.map(function(ip) {
      that.visual_route(ip);
    });
  };

  this.geolocate = function(ip) {
    (new Spinner()).on();
    $.get('/main/geolocate', ['ip=', ip].join(''), function(json) {
      console.log(ip);
      point = JSON.parse(json);
      document.map = document.map || this; //new Bing($('.map')[0], {width: 528, height: 249});
      document.map.adjust_center(point);
      document.map.add_push_pin(point);
      (new Spinner()).off();
    });
  };

  this.list_o_ips = function(ips) {
    var that = this;
    $.each(ips, function(i, ip) { 
      setTimeout(function() {
        that.geolocate(ip);
      }, i*1000); //pause one second for each additional point
    });
  };


  this.init(element, options);
};
