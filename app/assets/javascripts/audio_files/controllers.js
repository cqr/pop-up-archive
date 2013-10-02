angular.module("Directory.audioFiles.controllers", ['ngPlayer'])
.controller("AudioFileCtrl", ['$scope', '$timeout', '$modal', 'Player', 'Me', 'TimedText', 'AudioFile', function($scope, $timeout, $modal, Player, Me, TimedText, AudioFile) {
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
    event.stopPropagation();
    $scope.play();
    $scope.player.seekTo(time);
  });

  Me.authenticated(function (me) {

    $scope.saveText = function(text) {
      var tt = new TimedText(text);
      tt.update();
    };

    $scope.orderTranscript = function () {
      $scope.orderTranscriptModal = $modal({template: "/assets/audio_files/order_transcript.html", persist: false, show: true, backdrop: 'static', scope: $scope, modalClass: 'order-transcript-modal'});
      return;
    };

    $scope.showOrderTranscript = function () {
      return (new AudioFile($scope.audioFile)).canOrderTranscript(me);
    };

    $scope.showTranscriptInProgress = function () {
      return (new AudioFile($scope.audioFile)).isTranscriptOrdered();
    };

    $scope.showSendToAmara = function () {
      return (new AudioFile($scope.audioFile)).canSendToAmara(me);
    };

  });

}])
.controller("OrderTranscriptFormCtrl", ['$scope', '$q', 'Me', 'AudioFile', function($scope, $q, Me, AudioFile) {

  Me.authenticated(function (me) {

    $scope.length = function() {
      return "10 minutes";
    }

    $scope.price = function() {
      return "$20";
    }

    $scope.submit = function () {
      // $scope.audioFile = new AudioFile($scope.audioFile);
      // $scope.audioFile.itemId = $scope.item.id;
      // return $scope.audioFile.orderTranscript();
      $scope.close();
      return;
    }

  });

  $scope.clear = function () {
    $scope.hideOrderTranscriptModal();
  }

  $scope.hideOrderTranscriptModal = function () {
    $q.when($scope.orderTranscriptModal).then( function (modalEl) {
      modalEl.modal('hide');
    });
  } 

}])
.controller("PersistentPlayerCtrl", ["$scope", 'Player', function ($scope, Player) {
  $scope.player = Player;
  $scope.collapsed = false;

  $scope.collapse = function () {
    $scope.collapsed = !$scope.collapsed;
  };

}]);