angular.module("Directory.audioFiles.controllers", ['ngPlayer'])
.controller("AudioFileCtrl", ['$scope', '$timeout', 'Player', 'TimedText', function($scope, $timeout, Player, TimedText) {
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
  
  //edit transcripts
  $scope.editorEnabled = false;
  
  $scope.enableEditor = function() {
    this.editorEnabled = true;
    this.editableTranscript = this.text.text;
  };
  
  $scope.disableEditor = function() {
    this.editorEnabled = false;
  };
  
  $scope.save = function() {
    this.text.text = this.editableTranscript;
    this.disableEditor();
    var tt = new TimedText(this.text);
    console.log('save tt', tt);
    tt.update();
  };

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