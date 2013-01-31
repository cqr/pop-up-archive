function UploadsCtrl($scope, $resource, $http) {
  $scope.closeModal = function() {
    console.log($scope);
  }

  $scope.upload = function() {
    // $scope.files = $resource('/api/:action', { action: 'upload' });
    console.log($scope.uploads);

    var file = $scope.uploads[0];

    var fData = new FormData();
    fData.append('csv_import[file]', file);

    $http({
      method: 'POST',
      url: '/api/csv_imports',
      data: fData,
      headers: { "Content-Type": undefined },
      transformRequest: angular.identity
    }).success(function(data, status, headers, config) {
      console.log(data);
    }).error(function(data, status, headers, config) {
      console.log(status);
    });
  }
}

function UploadsFileCtrl ($scope) {
  $scope.removeUpload = function() {
    var i = $scope.uploads.indexOf($scope.upload);
    $scope.uploads.splice(i, 1);
  }
}
