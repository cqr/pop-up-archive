angular.module('Directory.files.controllers', ['fileDropzone', 'Directory.alerts', 'Directory.csvImports.models', 'Directory.user', 'ngCookies', 'Directory.people.models'])
.controller('FilesCtrl', ['$window', '$cookies', '$scope', '$http', '$q', '$timeout', '$route', '$routeParams', '$modal', 'Me', 'Loader', 'CsvImport', 'Alert', 'Collection', 'Item', function FilesCtrl($window, $cookies, $scope, $http, $q, $timeout, $route, $routeParams, $modal, Me, Loader, CsvImport, Alert, Collection, Item) {

  Me.authenticated(function (me) {

    Loader.page(Collection.query(), Collection.get(me.uploadsCollectionId), 'Collections', $scope).then(function (data) {
      $scope.uploadsCollection = data[1];
    });

    // for uploads
    $scope.files = [];
    $scope.uploadModal = $modal({template: '/assets/items/new.html', persist: true, show: false, backdrop: 'static', scope: $scope, modalClass: 'item-modal'});

    // for exit survey
    $scope.shouldShowExitSurvey = null;
    $scope.exitSurveyModal = $modal({template: '/assets/dashboard/exit_survey.html', persist: true, show: false, backdrop: 'static', scope: $scope});

    $scope.showDetails = false;

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

    $scope.uploadFile = function () {
      $scope.initializeItem(true);
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


    $scope.initializeItem = function(force) {

      if ($route.current.controller == 'ItemCtrl' && 
          $route.current.locals.$scope.item &&
          $route.current.locals.$scope.item.id > 0) {

        $scope.item = $route.current.locals.$scope.item;

      } else {

        // start a new item if there is not one already in scope
        if(force || !$scope.item) {
          // console.log('initializeItem new item', $scope.item);
          var collectionId = parseInt($routeParams.collectionId, 10) || $scope.currentUser.uploadsCollectionId;
          $scope.item = new Item({collectionId:collectionId, title:'', audioFiles:[]});
        }
      }
      // console.log('initializeItem', $scope.item);
      return $scope.item;
    };

    $scope.handleAudioFilesAdded = function (newFiles) {
      // console.log('handleAudioFilesAdded', newFiles);

      var newFiles = newFiles || [];

      $scope.initializeItem();

      if ($scope.item.id > 0) {
        $scope.uploadAudioFiles($scope.item, newFiles);
      } else {

        // add files to the item
        angular.forEach(newFiles, function (file) {
          $scope.item.audioFiles.push(file);
        });

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
}])
.controller('NewItemFormCtrl', ['$window', '$cookies', '$scope', '$http', '$q', '$timeout', '$route', '$routeParams', '$modal', 'Me', 'Loader', 'Alert', 'Collection', 'Item', 'Contribution', function FilesCtrl($window, $cookies, $scope, $http, $q, $timeout, $route, $routeParams, $modal, Me, Loader, Alert, Collection, Item, Contribution) {

  $scope.item = {};
  $scope.$parent.$watch('item', function (is) {
    if (is && $scope.item != is) {
      angular.copy(is, $scope.item);
    }
  });
  if ($scope.$parent.item) {
    angular.copy($scope.$parent.item, $scope.item);
  }

  $scope.submit = function () {
    // console.log('NewItemFormCtrl submit: ', $scope.item);
    var saveItem = $scope.item;
    this.item = $scope.initializeItem(true);
    $scope.clear();

    var audioFiles = saveItem.audioFiles;
    var contributions = saveItem.contributions;

    Collection.get(saveItem.collectionId).then(function (collection) {
      if (angular.isArray(collection.items)) {
        collection.items.push(saveItem);
      }
    });

    var cleanTags = [];
    angular.forEach(saveItem.tags, function(v,k){ this.push(v.id); }, cleanTags);
    saveItem.tags = cleanTags;

    if (saveItem.id) {
      saveItem.update().then(function (data) {
        $scope.uploadAudioFiles(saveItem, audioFiles);
        $scope.updateContributions(saveItem, contributions);        
        $scope.item = saveItem;
        angular.copy($scope.item, $scope.$parent.item);
      });
    } else {
      saveItem.create().then(function (data) {
        // $scope.initializeItem(true);

        $scope.uploadAudioFiles(saveItem, audioFiles);
        $scope.updateContributions(saveItem, contributions);
        if (angular.isFunction($scope.itemAdded)) {
          $scope.itemAdded(saveItem);
        }
      });
    }
  };

  $scope.clear = function() {
    $scope.hideUploadModal();
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

      element[0].value = "";

    });
  };

  $scope.removeAudioFile = function(file) {
    $scope.item.audioFiles.splice($scope.item.audioFiles.indexOf(file), 1);
  }

  $scope.uploadAudioFiles = function (item, newFiles) {
    angular.forEach(newFiles, function (file) {
      $scope.uploadAudioFile(item, file);
    });
  };

  $scope.uploadAudioFile = function (item, file) {
    var item = item;
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

  $scope.addContribution = function () {
    var c = new Contribution();
    if (!$scope.item.contributions) {
      $scope.item.contributions = [];
    }
    $scope.item.contributions.push(c);
    // console.log('addContribution', $scope);
  }

  $scope.deleteContribution = function(contribution) {
    // mark it to delete later
    if (contribution.id && (contribution.id > 0)) {
      contribution._delete = true;
    } else {
      $scope.item.contributions.splice($scope.item.contributions.indexOf(contribution), 1);
    }
  }

  $scope.updateContributions = function(item, contributions) {
    item.contributions = contributions;
    item.updateContributions();
  };

  $scope.tagSelect = function() {
    return {
      placeholder: 'Tags...',
      width: '284px',
      tags: [],
      initSelection: function (element, callback) { 
        callback($scope.item.tags);
      }
    }
  };

  $scope.roleSelect = {
    placeholder:'Role...',
    width: '160px'
  };

  $scope.peopleSelect = {
    placeholder: 'Name...',
    width: '240px',
    minimumInputLength: 2,
    quietMillis: 100,
    formatSelection: function (person) { return person.name; },
    formatResult: function (result, container, query, escapeMarkup) { 
      var markup=[];
      window.Select2.util.markMatch(result.name, query.term, markup, escapeMarkup);
      return markup.join("");
    },
    createSearchChoice: function (term, data) {
      if ($(data).filter(function() {
        return this.name.toUpperCase().localeCompare(term.toUpperCase()) === 0;
      }).length === 0) {
        return { id: 'new', name: term };
      }
    },
    initSelection: function (element, callback) {
      var scope = angular.element(element).scope();
      callback(scope.contribution.person);
    },
    ajax: {
      url: '/api/collections/' + $routeParams.collectionId + '/people',
      data: function (term, page) { return { q: term }; },
      results: function (data, page) { return { results: data }; }
    }
  }

}]);
