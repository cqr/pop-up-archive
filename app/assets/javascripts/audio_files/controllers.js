angular.module("Directory.audioFiles.controllers", ['ngPlayer'])
.controller("AudioFileCtrl", ['$scope', 'Player', function($scope, Player) {
  $scope.fileUrl = $scope.audioFile.url;

  $scope.play = function () {
    Player.play($scope.fileUrl);
  }

  $scope.player = Player;

  $scope.isPlaying = function () {
    return Player.nowPlaying() == $scope.fileUrl && !Player.paused();
  }

}])
.controller("PersistentPlayerCtrl", ["$scope", 'Player', function ($scope, Player) {
  $scope.player = Player;
}]);