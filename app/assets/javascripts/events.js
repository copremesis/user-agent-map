
//this should be a callback
//or be deferred
///ass suspected


var Events = function() {
  //need to change clicks to default ...
  this.click_event = function(filter, options, callback) {
    var options = options || {key: 'clicks'},
        callback = callback || function() {};
    if(options.key == 'clicks') document.context = filter;
    (new Spinner).anonymous(function(hide_spinner) {
      $.get('/main/json_data', ['page=', document.page, '&key=', options.key, '&filter=', filter, '&property_id=', options.property_id, window.location.search.replace(/\?/, '&')].join(''), function(json) {
        document.getElementById(options.key).innerHTML = (new Table(json)).html_table();
        hide_spinner();
        callback();
      });
    });
  };

  this.page_down = function() {
    document.page++;
    this.click_event(document.context);
  };

  this.page_up = function() {
    document.page--;
    this.click_event(document.context);
  };

  this.init = function() {
    this.selectors = ['.click'];
    this.selectors.each(function(e, that) {
      $('.click').on('click', function(event){
        event.stopImmediatePropagation(); //avoid the double fire
        var event_type = $(this).attr('event');
        switch(event_type) {
        case 'page +':
          document.page = document.page || 0;
          if(document.page < 100000) that.page_down();
        break;
        case 'page -':
          document.page = document.page || 0;
          if(document.page != 0) that.page_up();
        break;
        case 'redo':
          that.click_event(document.context);
        break;
        case 'linked_from':
          that.click_event($(this).attr('url'), {key: 'linked_from'});
          $('tr').removeClass('selected');
          $(this).parent('td').parent('tr').addClass('selected');
        break;
        case 'hits':
          that.click_event($(this).attr('url'), {key: 'hits', property_id: $(this).attr('property_id')}, function() {
            $('#hits div.click').map(function(i, e) { 
              setTimeout(function() {
                 $(e).click(); 
              }, i*500);
            });
          });
          $('tr').removeClass('selected');
          $(this).parent('td').parent('tr').addClass('selected');
        break;
        case 'ghost_inquiry':
          document.page = document.page || 0;
          document.map = new Bing($('.map')[0], {width: 528, height: 249});
          that.click_event(event_type, {property_id: $(this).attr('property_id'), key: 'clicks'});
          $('tr').removeClass('selected');
          $(this).parent('td').parent('tr').addClass('selected');
        break;
        case 'per_day':
          document.page = document.page || 0;
          document.map = new Bing($('.map')[0], {width: 528, height: 249});
          that.click_event(event_type, {property_id: $(this).attr('property_id'), key: 'clicks'});
          $('tr').removeClass('selected');
          $(this).parent('td').parent('tr').addClass('selected');
        break;
        case 'geolocate':
          $('tr').removeClass('selected');
          $(this).parent('td').parent('tr').addClass('selected');
(new Spinner()).on();
          $.get('/main/geolocate', ['ip=',$(this).attr('ip')].join(''), function(json) {
            point = JSON.parse(json);
            document.map = document.map || new Bing($('.map')[0], {width: 528, height: 249});
            document.map.adjust_center(point);
            document.map.add_push_pin(point);
(new Spinner()).off();
          })
        break;
        default:
          document.page = 0;
          that.click_event(event_type);
        }
        document.getElementById('page_number').innerHTML = document.page;
      });
    }, this);
  };

  this.init();//just declare this when the page gets refreshed
}
