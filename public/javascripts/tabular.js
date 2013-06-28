//This is a simple double array to HTML table manager
//m is a m X n table with the first row as the HEADER
//
//choose our iteration method could use home grown
//
//
//

Array.prototype.each = function(callback, parent_object) {
  var callback = callback || function() {};
  for(var i=0; i<this.length; i++) {
     if(typeof this[i] != 'function') callback(this[i], parent_object);
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

var Table = function(m) {
  this.m = m || [['f1', 'f2', 'f3'], [0, 0, 0], [0, 0, 0]]; //M X N table first row is the fields

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
    return ['<table>', this.thead(thead), this.tbody(tbody), '</table>'].join('');
  };
};

//t = new Tabular()
//t.html_table();

//example client usage
/*
$.get('/main/json_data', '', function(tasks_json) {
  var tasks = JSON.parse(tasks_json), m = [], fields = [], row = [], q = true; 
  tasks.each(function(task, that) {
    row = [];
    for(k in task) {
      q && fields.push(k);
      row.push(task[k]);
    }
    q && m.push(fields)
    m.push(row)
    q = false
  }, this);
  t = new Table(m);
  document.getElementById('test_data').innerHTML = t.html_table();
});








*/
