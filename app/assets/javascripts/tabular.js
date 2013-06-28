//This is a simple double array to HTML table manager
//m is a m X n table with the first row as the HEADER
//
//choose our iteration method could use home grown
//
//
//

//(function() {
Array.prototype.each = function(callback, parent_object) {
  var callback = callback || function() {};
  for(var i=0; i<this.length; i++) {
    callback(this[i], parent_object, i);
  }
};

Array.prototype.collect = function(callback, parent_object) {
  var c = []; //static object
  this.each(function(e) {
    return c.push(callback(e, parent_object));
  });
  return c;
};

//facier dup than just a 1-dimensional dup

Array.prototype.dup = function() {
  var other = (this instanceof Array) ? [] : {};
  for (i in this) {
    if(!this.hasOwnProperty(i)) continue;
    if (this[i] && typeof this[i] == "object") {
      other[i] = this[i].dup();
    } else other[i] = this[i]
  } return other;
};

var Table = function(json) {
  //this.m = [['f1', 'f2', 'f3'], [0, 0, 0], [0, 0, 0]]; //M X N table first row is the fields

  this.trow = function(row) {
    return ['<tr>', row.collect(function(e) { return ['<td>', e, '</td>'].join(''); }, null).join(''), '</tr>'].join('');
  };

  this.thead = function(row) {
    return ['<thead><tr>', row.collect(function(e) { return ['<th>', e, '</th>'].join(''); }, null).join(''), '</tr></thead>'].join('');
  };

  this.tbody = function(tbody) {
   return ['<tbody>', tbody.collect(function(row, that) {
     return that.trow(row);
   }, this).join(''), '</tbody>'].join('');
  };

  this.html_table = function(options) {
    var thead = [], trow = [], tbody = [];
    this.first_row = true;
    this.m.each(function(row, that) {
      if (that.first_row) {
        thead = row.dup()
        that.first_row = false;
      } else {
        tbody.push(row.dup());
      }
    },this);
    return ['<table id="foo" class="table">', this.thead(thead), this.tbody(tbody), '</table>'].join('');
  };

  this.init = function(json) {
    var items = JSON.parse(json), m = [], fields = [], row = [], q = true;
    items.each(function(item, that) {
      row = [];
      for(k in item) {
        q && fields.push(k);
        row.push(item[k]);
      }
      q && m.push(fields);
      m.push(row);
      q = false;
    }, this);
    return m;
  };

  this.m = this.init(json); //get 2d array from json data
};

