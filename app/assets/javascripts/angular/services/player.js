angular.module('ngPlayer', [])
.factory('Player', ['$timeout', function ($timeout) {
  var nowPlayingItem, playing = false;
  var audioElement = angular.element('<audio></audio>')[0];
  var Player = {};


  function nowPlaying() {
    return nowPlayingItem;
  }

  function loadFile(file) {
    nowPlayingItem = file;
  }

  function play(file) {
    nowPlayingItem = (file || nowPlayingItem);
    if (audioElement.src != nowPlayingItem)
      audioElement.src = nowPlayingItem;
    audioElement.play();
    scheduleUpdate();
  }

  function stop () {
    audioElement.pause();
    nowPlayingItem = null;
    audioElement.src = null;
    audioElement.currentTime = 0;
    audioElement.duration = 0;
    Player.time = 0;
    Player.duration = 0;
  }

  function pause () {
    audioElement.pause();
  }

  function paused () {
    return audioElement.paused;
  }

  function ended () {
    return audioElement.ended;
  }

  function updateTimecodes () {
    Player.time = audioElement.currentTime;
    Player.duration = audioElement.duration;
  }

  function rewind () {
    seekTo(0);
  }

  function seekTo (position) {
    audioElement.currentTime = position;
    $timeout(updateTimecodes, 0);
  }

  function scheduleUpdate () {
    updateTimecodes();
    if (!paused() && !ended()) $timeout(scheduleUpdate, 100);
  };

  Player.time = 0;
  Player.duration = 0;
  Player.pause = pause;
  Player.paused = paused;
  Player.nowPlaying = nowPlaying;
  Player.rewind = rewind;
  Player.play = play;
  Player.stop = stop;
  Player.seekTo = seekTo;
  
  return Player;
}])
.filter('timeCode', function () {
  function pad(number) {
    if (number < 10) {
      return "0" + number;
    }
    return number;
  }

  return function (data, options) {
    if (isNaN(data)) {
      return "00:00.0";
    }
    var date = new Date(data*1000);
    return [date.getHours()-19, pad(date.getMinutes()), pad(date.getSeconds())].join(':') + '.' + parseInt(date.getMilliseconds()/100);
  }
})
.directive("verticalScrubber", ["Player", '$timeout', function (Player, $timeout) {
  return {
    restrict: 'C',
    link: function(scope, el, attr) {
      scope.player = Player;
      var mouseIsDown = false;

      var barEl = angular.element("<div class='bar'></div>");
      scope.$watch('player.time', function (time) {
        barEl.css('height', time * 100 / Player.duration + "%");
      });
      el.bind('mousedown', function mouseIsDown (e) {
        var element = this;
        var $this = angular.element(this);
        var $window = angular.element(window);
        var $body = angular.element(window.document.getElementsByTagName('body'));
        
        $body.addClass('scrubbing');
        var timeoutComplete = true;

        function markTimeoutComplete() {
          timeoutComplete = true;
        }

        function mouseIsMoving (e) {
          var relativePosition = e.y - element.offsetTop;
          if (relativePosition >= 0) {
            var percentage = (relativePosition / element.offsetHeight);
            if (timeoutComplete) {
              timeoutComplete = false
              $timeout(function () { Player.seekTo(((1-percentage) * Player.duration)) }, 10).then(markTimeoutComplete, markTimeoutComplete);
            }
          }
        }

        $window.bind('mousemove', mouseIsMoving);

        function unbindAll () {
          $window.unbind('mouseup', unbindAll);
          $window.unbind('mousemove', mouseIsMoving);
          $body.removeClass('scrubbing');
        }

        $window.bind('mouseup', unbindAll);

        mouseIsMoving(e);
      });
      el.append(barEl);
    }
  }
}])
.directive("scrubber", ["Player", function (Player) {
  return {
    restrict: 'C',
    link: function (scope, el, attrs) {
      el.bind('click', function (e) {
        var relativePosition = e.x - this.offsetLeft;
        var percentage = (relativePosition / this.offsetWidth);
        Player.seekTo(percentage * Player.duration);
      });
    }
  }
}]);