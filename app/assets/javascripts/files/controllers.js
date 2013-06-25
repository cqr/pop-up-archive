angular.module('Directory.files.controllers', ['fileDropzone', 'Directory.csvImports.models', 'Directory.alerts'])
.controller('FilesCtrl', ['$scope', '$http', 'CsvImport', '$timeout', 'Alert', '$modal', '$route', '$routeParams', 'Collection', 'Loader', 'Item', function ($scope, $http, CsvImport, $timeout, Alert, $modal, $route, $routeParams, Collection, Loader, Item) {

  $scope.files = [];

  var uploadCSV = function (file) {
    var alert = new Alert();
    alert.status = "Uploading";
    alert.progress = 1;
    alert.message = file.name;
    alert.add();

    var fData = new FormData();
    fData.append('csv_import[file]', file);

    $http({
      method: 'POST',
      url: '/api/csv_imports',
      data: fData,
      headers: { "Content-Type": undefined },
      transformRequest: angular.identity
    }).success(function(data, status, headers, config) {
      var csvImport = new CsvImport({id:data.id});
      alert.progress = 25;
      alert.status = "Waiting";
      alert.startSync(csvImport.alertSync());
    });
  }

  var uploadAudioFiles = function(item, newFiles) {

    angular.forEach(newFiles, function (file) {

      var alert = new Alert();
      alert.status = "Uploading";
      alert.progress = 1;
      alert.message = file.name;
      alert.add();

      item.addAudioFile(file).then(function(data) {
        item.audioFiles.push(data);
        $scope.addMessage({
          'type': 'success',
          'title': 'Congratulations!',
          'content': '"' + file.name + '" upload completed. <a data-dismiss="alert" data-target=":parent" ng-href="' + item.link() + '">View and edit the item!</a>'
        });

        alert.progress = 100;
        alert.status = "Uploaded";

      }, function(data){
        console.log('fileUploaded: addAudioFile: reject', data, item);
        $scope.addMessage({
          'type': 'error',
          'title': 'Oops...',
          'content': '"' + file.name + '" upload failed. Hmmm... try again?'
        });

        alert.progress = 100;
        alert.status = "Error";

      });

    });

  };

  $scope.submit = function() {
    // console.log('FilesCtrl submit: ', $scope.item);
    var item = $scope.item;
    var audioFiles = item.audioFiles;
    item.audioFiles = [];

    Collection.get($scope.item.collectionId).then(function (collection) {
      if (angular.isArray(collection.items)) {
        collection.items.push($scope.item);
      }
    });

    item.create().then(function () {
      uploadAudioFiles(item, audioFiles);
    });

    // console.log('FilesCtrl submit scope: ', $scope);
  };

  $scope.handleAudioFilesAdded = function(newFiles) {
    // console.log('handleAudioFilesAdded', newFiles);

    newFiles = newFiles || [];
    Loader(Collection.query(), $scope);

    if ($route.current.controller == 'ItemCtrl' && 
        $route.current.locals.$scope.item &&
        $route.current.locals.$scope.item.id > 0)
    {
      var item = $route.current.locals.$scope.item;
      uploadAudioFiles(item, newFiles);
    } else {

      var collectionId = parseInt($routeParams.collectionId, 10) || $scope.currentUser.uploadsCollectionId;
      $scope.item = new Item({collectionId:collectionId, title:'', audioFiles:newFiles});

      if (newFiles.length == 1)
        $scope.item.title = newFiles[0].name;

      var modal = $modal({template: '/assets/items/upload.html', show: true, backdrop: 'static', scope: $scope});
    }
  }

  // used by the upload-button callback when new files are selected
  $scope.setFiles = function(element) {
    $scope.$apply(function($scope) {
      angular.forEach(element[0].files, function (file) {
        $scope.item.audioFiles.push(file);
      });
    });
  };

  $scope.$on("filesAdded", function (e, newFiles) {
    // console.log('on filesAdded', newFiles);
    $scope.handleAudioFilesAdded(newFiles);
  });

  $scope.$watch('files', function(files) {

    //new files!
    var newFiles = [];

    var newFile;
    while (newFile = files.pop()) {
      if (newFile.name.match(/csv$/i)) {
        uploadCSV(newFile);
      } else {
        newFiles.push(newFile);
      }
    }

    if (newFiles.length > 0) {
      // console.log('new files added', newFiles);
      $scope.$broadcast('filesAdded', newFiles);
    }

  });

}]);
