  function startTime() {
    var today=new Date();
    var h=today.getHours();
    var m=today.getMinutes();
    var s=today.getSeconds();
    m=pad_zero(m);
    s=pad_zero(s);
    try {
      document.getElementById('your_time').innerHTML=["<b>current_time</b>", h+":"+m+":"+s].join(': ');
    } catch(e) {
      //
    }

    t=setTimeout('startTime()', 5000);
  }

  function pad_zero(i) {
    return (i<10)?  i="0" + i : i;
  }

  $(document).ready(function() {
    startTime();
  });
