angular.module("Directory.audioFiles.controllers", ['ngPlayer'])
.controller("AudioFileCtrl", ['$scope', 'Player', '$timeout', function($scope, Player, $timeout) {
  $scope.fileUrl = $scope.audioFile.url;
  
  $scope.play = function () {
    Player.play($scope.fileUrl);
  }

  $scope.player = Player;

  $scope.isPlaying = function () {
    return $scope.isLoaded() && !Player.paused();
  }

  $scope.isLoaded = function () {
    return Player.nowPlaying() == $scope.fileUrl;
  }

  $scope.$on('transcriptSeek', function(event, time) {

    // console.log('transcriptSeek', time);

    $scope.play();
    $scope.player.seekTo(time);

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