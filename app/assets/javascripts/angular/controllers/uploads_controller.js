function UploadsCtrl($scope, $resource) {
  $scope.closeModal = function() {
    console.log($scope);
  }

  $scope.upload = function() {
    $scope.files = $resource('/api/:action', { action: 'upload' });
    console.log($scope.uploads);
  }
}

function UploadsFileCtrl ($scope) {
  $scope.removeUpload = function() {
    var i = $scope.uploads.indexOf($scope.upload);
    $scope.uploads.splice(i, 1);
  }
}
