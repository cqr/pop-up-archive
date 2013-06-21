(function () {

  function getEvent (event) {
    if (typeof event.originalEvent !== 'undefined') {
      return event.originalEvent;
    } else {
      return event;
    }
  }

  angular.module('ngPlayer', [])
  .factory('Player', ['$timeout', function ($timeout) {
    var nowPlayingItem, playing = false;
    var audioElement = angular.element('<audio></audio>')[0];
    var Player = {};

    function nowPlaying() {
      return nowPlayingItem;
    }

    function loadFile(file) {
      nowPlayingItem = (file || nowPlayingItem);
      if (audioElement.src != nowPlayingItem) {
        audioElement.src = nowPlayingItem;
      }
    }

    function play(file) {
      loadFile(file);
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
      if (audioElement.duration) {
        audioElement.currentTime = position;
        $timeout(updateTimecodes, 0);
      } else {
        $timeout(function(){seekTo(position)}, 100);
      }
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
      return [date.getUTCHours(), pad(date.getMinutes()), pad(date.getUTCSeconds())].join(':') + '.' + parseInt(date.getUTCMilliseconds()/100);
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
          e = getEvent(e);

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
            e = getEvent(e);
            var relativePosition = e.y - element.offsetTop;
            if (relativePosition >= 0) {
              var percentage = (relativePosition / element.offsetHeight);
              if (timeoutComplete) {
                timeoutComplete = false
                $timeout(function () { Player.seekTo((percentage * Player.duration)) }, 10).then(markTimeoutComplete, markTimeoutComplete);
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
          e = getEvent(e);
          var relativePosition = e.x - this.offsetLeft;
          var percentage = (relativePosition / this.offsetWidth);
          Player.seekTo(percentage * Player.duration);
        });
      }
    }
  }])
  .directive("transcript", ['Player','$parse', function (Player, $parse) {
    return {
      restrict: 'C',
      replace: true,
      template: '<div class="file-transcript">' +
                  '<table class="table">' +
                    '<tr ng-class="{current: transcriptStart==text.startTime}" ng-repeat="text in transcript">' +
                      '<td style="width: 8px; text-align:left;"><a ng-click="seekTo(text.startTime)"><i class="icon-play-circle"></i></a></td>' +
                      '<td style="width: 16px; text-align:right">{{text.startTime}}</td>' +
                      '<td style="width: 8px;text-align:center">&ndash;</td>' +
                      '<td style="width: 16px; text-align:left; padding-right:10px">{{text.endTime}}</td>' +
                      '<td><div class="file-transcript-text">{{text.text}}</div></td>' +
                    '</tr>' +
                  '</table>' +
                '</div>',
      link: function (scope, el, attrs) {
        var lastSecond = -1;

        scope.transcriptStart = 0;
        scope.transcript = $parse(attrs.transcriptText)(scope);
        scope.transcriptRows = {};

        angular.forEach(scope.transcript, function(row, index) {
          scope.transcriptRows[row.startTime] = index;
        });

        scope.seekTo = function(time) {
          scope.$emit('transcriptSeek', time);
        }

        if (scope.transcript && scope.transcript.length > 0) {
          scope.$watch('player.time', function (time) {
            var second = parseInt(time, 10);
            var height = angular.element(".file-transcript table tr")[0].scrollHeight;
            if (second != lastSecond) {
              if (second in scope.transcriptRows) {
                var index = scope.transcriptRows[second];

                if (index != undefined) {
                  el[0].scrollTop = Math.max((index - 1), 0) * height;
                  scope.transcriptStart = second;
                }
              }
              lastSecond = second;
            }
          });
        }

      }
    }
  }]);
})();