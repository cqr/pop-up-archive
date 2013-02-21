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

  function pause() {
    audioElement.pause();
  }

  function paused() {
    return audioElement.paused;
  }

  function ended() {
    return audioElement.ended;
  }

  function updateTimecodes () {
    Player.time = audioElement.currentTime;
    Player.duration = audioElement.duration;
  }

  function rewind() {
    audioElement.currentTime = 0;
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
});