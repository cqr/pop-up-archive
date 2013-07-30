angular.module("Directory.audioFiles.controllers", ['ngPlayer'])
.controller("AudioFileCtrl", ['$scope', '$timeout', 'Player', 'Me', 'TimedText', function($scope, $timeout, Player, Me, TimedText) {
  $scope.fileUrl = $scope.audioFile.url;
  
  $scope.play = function () {
    Player.play($scope.fileUrl);
  }

  $scope.player = Player;

  $scope.isPlaying = function () {
    return $scope.isLoaded() && !Player.paused();
  }

  $scope.isLoaded = function () {
    return Player.nowPlayingUrl() == $scope.fileUrl;
  }

  $scope.$on('transcriptSeek', function(event, time) {

    // console.log('transcriptSeek', time);

    $scope.play();
    $scope.player.seekTo(time);

  });

  Me.authenticated(function (me) {

    $scope.saveText = function() {
      this.text.text = this.editableTranscript;
      this.disableEditor();
      var tt = new TimedText(this.text);
      tt.update();
    };

  });

}])
.controller("PersistentPlayerCtrl", ["$scope", 'Player', function ($scope, Player) {
  $scope.player = Player;
  $scope.collapsed = false;

  $scope.collapse = function () {
    $scope.collapsed = true;
  }

  $scope.expand = function () {
    $scope.collapsed = false;
  }
}]);