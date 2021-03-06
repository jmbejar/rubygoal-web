$(function(){

  var buffer = [];
  var ended = false;
  var buffering = true;

  function formatTime(secs) {
    var minutes = Math.floor(secs / 60);
    var seconds = Math.floor(secs - (minutes * 60));

    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    var time    = minutes+':'+seconds;
    return time;
  }

  function rotateAndPaintImage(context, image, angle, x, y) {
    var width = 60;
    var height = 60;

    context.translate(x, y);
    context.rotate(angle * Math.PI/180);
    context.drawImage(image, -width / 2, -height / 2, width, height);
    context.rotate(-angle * Math.PI/180);
    context.translate(-x, -y);
  }

  function drawTime(context, time) {
    context.font="48px Source Sans Pro";
    context.fillStyle = '#6d6e70';
    context.fillText(formatTime(time), 820, 60);
  }

  function drawScore(context, home, away) {
    context.font="48px Source Sans Pro";
    context.fillStyle = 'white';
    context.fillText(home, 1140, 60);
    context.fillText(away, 1210, 60);
  }

  function drawNextFrame() {
    var data = buffer.shift();
    if (data === undefined) return;

    context.drawImage(backgroundObj, 0, 0);
    context.drawImage(ballObj, data.ball.x, data.ball.y);
    for(var i = 0; i < 11; i += 1) {
      rotateAndPaintImage(context, homeObj, data.home[i].angle, data.home[i].x, data.home[i].y);
      rotateAndPaintImage(context, awayObj, data.away[i].angle, data.away[i].x, data.away[i].y);
    }
    drawScore(context, data.score_home, data.score_away);
    drawTime(context, data.time);

    debug(data.viewers);
  }

  function debug(str){ $("#debug").html("<p>"+str+"</p>"); };

  ws = new WebSocket("ws://" + window.document.location.host + "/");
  ws.onmessage = function(evt) {
    data = JSON.parse(evt.data);
    buffer.push(data);
    if (buffering && buffer.length >= 120) {
      buffering = false;
      debug("buffer ready");
    }
  }

  ws.onclose = function() {
    debug("socket closed");
    ended = true;
  };

  ws.onopen = function() {
    debug("connected...");
    ws.send("hello server");
  };

  $(window).unload(function() {
    ws.onclose = function () {};
    ws.close()
  });
  window.onbeforeunload = function() {
    ws.onclose = function () {};
    ws.close()
  };

  var canvas = document.getElementById('myCanvas');
  var context = canvas.getContext('2d');

  var backgroundObj = new Image();
  backgroundObj.src = 'assets/images/background.png';

  var ballObj = new Image();
  ballObj.src = 'assets/images/ball.png';

  var homeObj = new Image();
  homeObj.src = 'assets/images/average_home.png';

  var awayObj = new Image();
  awayObj.src = 'assets/images/average_away.png';

  var timer = setInterval(function(){
    if (ended) {
      if (buffer.length > 0) {
        drawNextFrame();
      } else {
        clearInterval(timer);
      } 
    } else {
      if (!buffering) {
        if (buffer.length < 120) {
          buffering = true;
          debug("buffering...");
        } else {
          drawNextFrame();
          debug("buffer count " + buffer.length);
        }
      }
    }
  }, 16);
});
