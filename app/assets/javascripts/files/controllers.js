angular.module('Directory.files.controllers', ['fileDropzone', 'Directory.alerts', 'Directory.csvImports.models', 'Directory.user'])
.controller('FilesCtrl', ['$window', '$scope', '$http', '$q', '$timeout', '$route', '$routeParams', '$modal', 'Me', 'Loader', 'CsvImport', 'Alert', 'Collection', 'Item', function FilesCtrl($window, $scope, $http, $q, $timeout, $route, $routeParams, $modal, Me, Loader, CsvImport, Alert, Collection, Item) {

  Me.authenticated(function (me) {

    Loader.page(Collection.query(), Collection.get(me.uploadsCollectionId), 'Collections', $scope).then(function (data) {
      $scope.uploadsCollection = data[1];
    });

    $scope.uploadModal = $modal({template: '/assets/items/upload.html', persist: true, show: false, backdrop: 'static', scope: $scope});

    $scope.files = [];

    // check to see if there is an upload before navigating away
    $window.onbeforeunload = function(e) {
      var warn = null;
      var alerts = Alert.getAlerts();
      angular.forEach(alerts, function (alert, i) {
        if (!alert.isComplete() && alert.category == 'upload') {
          warn = "There is an upload currently happening!";
          e.returnValue = warn;
        }
      });
      return warn;
    };

    $scope.uploadFile = function () {
      $scope.$emit('filesAdded', []);
    };

    $scope.uploadCSV = function (file) {
      var alert = new Alert();
      alert.category = 'upload';
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
    };

    $scope.uploadAudioFiles = function (item, newFiles) {
      angular.forEach(newFiles, function (file) {

        var alert = new Alert();
        alert.category = 'upload';
        alert.status   = 'Uploading';
        alert.progress = 1;
        alert.message  = file.name;
        alert.path     = item.link();
        alert.add();

        var audioFile = item.addAudioFile(file,
        {
          onComplete: function (upload) {
            // console.log('fileUploaded: addAudioFile: complete',upload, item);
            $scope.addMessage({
              'type': 'success',
              'title': 'Congratulations!',
              'content': '"' + file.name + '" upload completed. <a data-dismiss="alert" data-target=":parent" ng-href="' + item.link() + '">View and edit the item!</a>'
            });

            alert.progress = 100;
            alert.status   = "Uploaded";

            // let search results know that there is a new item
            $timeout(function () { $scope.$broadcast('datasetChanged')}, 750);
          },
          onError: function () {
            console.log('fileUploaded: addAudioFile: error', item);
            $scope.addMessage({
              'type': 'error',
              'title': 'Oops...',
              'content': '"' + file.name + '" upload failed. Hmmm... try again?'
            });

            alert.progress = 100;
            alert.status   = "Error";
          },
          onProgress: function (progress) {
            // console.log('uploadAudioFiles: onProgress', progress);
            alert.progress = progress;
          }
        });
      });
    };

    $scope.handleAudioFilesAdded = function (newFiles) {
      // console.log('handleAudioFilesAdded', newFiles);

      var newFiles = newFiles || [];

      if ($route.current.controller == 'ItemCtrl' && 
          $route.current.locals.$scope.item &&
          $route.current.locals.$scope.item.id > 0)
      {
        var item = $route.current.locals.$scope.item;
        $scope.uploadAudioFiles(item, newFiles);
      } else {

        var collectionId = parseInt($routeParams.collectionId, 10) || $scope.currentUser.uploadsCollectionId;
        $scope.item = new Item({collectionId:collectionId, title:'', audioFiles:newFiles});

        if (newFiles.length == 1)
          $scope.item.title = newFiles[0].name;

        $q.when($scope.uploadModal).then( function (modalEl) {
          modalEl.modal('show');
        });
        
      }
      // console.log('handleAudioFilesAdded done');
    };

    $scope.submit = function () {
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
        $scope.uploadAudioFiles(item, audioFiles);
      });

      // console.log('FilesCtrl submit scope: ', $scope);
    };

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
          $scope.uploadCSV(newFile);
        } else {
          newFiles.push(newFile);
        }
      }

      if (newFiles.length > 0) {
        // console.log('new files added', newFiles);
        $scope.$broadcast('filesAdded', newFiles);
      }

    });
  });
}]);
