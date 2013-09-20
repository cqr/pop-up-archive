angular.module("Directory.audioFiles.controllers", ['ngPlayer'])
.controller("AudioFileCtrl", ['$scope', '$timeout', 'Player', 'Me', 'TimedText', 'AudioFile', function($scope, $timeout, Player, Me, TimedText, AudioFile) {
  $scope.fileUrl = $scope.audioFile.url;
  
  $scope.play = function () {
    $scope.audioFile.play();
  }

  $scope.player = Player;

  $scope.isPlaying = function () {
    return $scope.isLoaded() && !Player.paused();
  }

  $scope.isLoaded = function () {
    return Player.nowPlayingUrl() == $scope.fileUrl;
  }

  $scope.$on('transcriptSeek', function(event, time) {
    event.stopPropagation();
    $scope.play();
    $scope.player.seekTo(time);
  });

  Me.authenticated(function (me) {

    $scope.saveText = function(text) {
      var tt = new TimedText(text);
      tt.update();
    };

    $scope.orderTranscript = function (audioFile) {
      var af = new AudioFile(audioFile);
      af.itemId = $scope.item.id;
      
      console.log("order transcript for audio:", af);
      return af.orderTranscript();
    };

  });

}])
.controller("PersistentPlayerCtrl", ["$scope", 'Player', function ($scope, Player) {
  $scope.player = Player;
  $scope.collapsed = false;

  $scope.collapse = function () {
    $scope.collapsed = !$scope.collapsed;
  };

}]);