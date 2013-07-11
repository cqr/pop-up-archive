angular.module('Directory.files.controllers', ['fileDropzone', 'Directory.alerts', 'Directory.csvImports.models', 'Directory.user', 'ngCookies'])
.controller('FilesCtrl', ['$window', '$cookies', '$scope', '$http', '$q', '$timeout', '$route', '$routeParams', '$modal', 'Me', 'Loader', 'CsvImport', 'Alert', 'Collection', 'Item', function FilesCtrl($window, $cookies, $scope, $http, $q, $timeout, $route, $routeParams, $modal, Me, Loader, CsvImport, Alert, Collection, Item) {

  Me.authenticated(function (me) {

    Loader.page(Collection.query(), Collection.get(me.uploadsCollectionId), 'Collections', $scope).then(function (data) {
      $scope.uploadsCollection = data[1];
    });

    // for uploads
    $scope.files = [];
    $scope.uploadModal = $modal({template: '/assets/items/new.html', persist: true, show: false, backdrop: 'static', scope: $scope});

    // for exit survey
    $scope.shouldShowExitSurvey = null;
    $scope.exitSurveyModal = $modal({template: '/assets/dashboard/exit_survey.html', persist: true, show: false, backdrop: 'static', scope: $scope});

    // check to see if there is an upload before navigating away
    $window.onbeforeunload = function(e) {
      var warn = null;
      var alerts = Alert.getAlerts();
      angular.forEach(alerts, function (alert, i) {
        if (!alert.isComplete() && alert.category == 'upload') {
          warn = "Your upload will be canceled if you leave this page. Are you sure?";
          e.returnValue = warn;
        }
      });

      var show = $cookies.exitSurvey;

      if (!warn && (!show || (show != 't'))) {
        warn = "Before you go, will you please stay long enough to answer a couple of questions?";
        e.returnValue = warn;
        $scope.shouldShowExitSurvey = $timeout(function() {
          $scope.showExitSurvey();
        }, 1000);
      }

      return warn;
    };

    $window.unload = function(e) {
      $timeout.cancel($scope.shouldShowExitSurvey);
    };

    $scope.showExitSurvey = function () {
      // Retrieving a cookie
      var show = $cookies.exitSurvey;

      if(show && show == 't') {
        console.log('Already seen the survey');
      } else {

        $q.when($scope.exitSurveyModal).then( function (modalEl) {
          modalEl.modal('show');
        });
        $cookies.exitSurvey = 't';
      }
    };

    $scope.removeAudioFile = function(file) {
      $scope.item.audioFiles.splice($scope.item.audioFiles.indexOf(file), 1);
    }

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


    $scope.uploadAudioFile = function (item, file) {
      var alert = new Alert();
      alert.category = 'upload';
      alert.status   = 'Uploading';
      alert.progress = 1;
      alert.message  = file.name;
      alert.add();

      if (item.collectionId == $scope.currentUser.uploadsCollectionId) {
        alert.path = "/collections";
      } else {
        alert.path = item.link();
      }

      file.alert = alert;

      var audioFile = item.addAudioFile(file,
      {
        onComplete: function () {
          // console.log($scope.item.id, $scope.currentUser.uploadsCollectionId);
          var msg = '"' + file.name + '" upload completed.';
          if (item.collectionId == $scope.currentUser.uploadsCollectionId) {
            msg = msg + 'To see transcripts and tags, <a href="/collections">move the item from My Uploads to a collection</a>';
          } else {
            msg = msg + '<a data-dismiss="alert" data-target=":parent" ng-href="' + item.link() + '">View and edit the item!</a>';
          }

          $scope.addMessage({
            'type': 'success',
            'title': 'Congratulations!',
            'content': msg
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
    }

    $scope.uploadAudioFiles = function (item, newFiles) {
      angular.forEach(newFiles, function (file) {
        $scope.uploadAudioFile(item, file);
      });
    };

    $scope.handleAudioFilesAdded = function (newFiles) {
      // console.log('handleAudioFilesAdded', newFiles);

      var newFiles = newFiles || [];

      if ($route.current.controller == 'ItemCtrl' && 
          $route.current.locals.$scope.item &&
          $route.current.locals.$scope.item.id > 0)
      {

        // if there is an item, add to that item
        var item = $route.current.locals.$scope.item;
        $scope.uploadAudioFiles(item, newFiles);
      } else {

        // start a new item if there is not one already in scope
        if(!$scope.item) {
          var collectionId = parseInt($routeParams.collectionId, 10) || $scope.currentUser.uploadsCollectionId;
          $scope.item = new Item({collectionId:collectionId, title:'', audioFiles:newFiles});
        } else {

          if (!$scope.item.audioFiles) {
            $scope.item.audioFiles = [];
          }

          // add files to the item
          angular.forEach(newFiles, function (file) {
            $scope.item.audioFiles.push(file);
          });
        }

        // default title to first file if not already set
        if (newFiles.length >= 1 && (!$scope.item.title || $scope.item.title == "")) {
          $scope.item.title = newFiles[0].name;
        }

        // all set, now show that modal!
        $q.when($scope.uploadModal).then( function (modalEl) {
          modalEl.modal('show');
        });
        
      }
      // console.log('handleAudioFilesAdded done');
    };

    $scope.hideUploadModal = function() {
      $q.when($scope.uploadModal).then( function (modalEl) {
        modalEl.modal('hide');
      });
    } 

    $scope.submit = function () {
      // console.log('FilesCtrl submit: ', $scope.item);
      $scope.hideUploadModal();
      var item = $scope.item;
      $timeout(function () {$scope.item = null;}, 500);
      var audioFiles = item.audioFiles;
      item.audioFiles = [];

      Collection.get(item.collectionId).then(function (collection) {
        if (angular.isArray(collection.items)) {
          collection.items.push(item);
        }
      });

      item.create().then(function () {
        $scope.uploadAudioFiles(item, audioFiles);
      });

      // console.log('FilesCtrl submit scope: ', $scope);
    };

    $scope.clear = function() {
      $scope.hideUploadModal();
      $timeout(function () {$scope.item = null;}, 500);
    }

    // used by the upload-button callback when new files are selected
    $scope.setFiles = function(element) {
      $scope.$apply(function($scope) {

        var newFiles = element[0].files;

        // default title to first file if not already set
        if (!$scope.item.title || $scope.item.title == "") {
          $scope.item.title = newFiles[0].name;
        }

        // add files to the item
        angular.forEach(newFiles, function (file) {
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
