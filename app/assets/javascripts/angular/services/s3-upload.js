(function() {
  'use strict';

  angular.module('S3Upload', [])
  .factory('S3Upload', ['$rootScope', function ($rootScope) {

    function S3Upload(options) {
      var u = this;
      u.options = options || {};
      u.progress = 0;

      u.callbacks = {};
      u.callbacks.onStart    = options.onStart    || function(fileObj){ return; };
      u.callbacks.onComplete = options.onComplete || function(fileObj){ return; };
      u.callbacks.onError    = options.onError    || function(){ return; };
      u.callbacks.onProgress = options.onProgress || function(progress){ return; };
    }

    S3Upload.prototype = {
      upload:     function() {
        var u = this;
        var s = {
          bucket:       u.options.bucket,
          access_key:   u.options.access_key,
          file:         u.options.file,
          ajax_base:    u.options.ajax_base || 'upload',
          key:          u.options.key,
          content_type: u.options.file.type,
          on_start:     function(fileObj){ u.callbacks.onStart(fileObj); $rootScope.$apply(); },
          on_complete:  function(fileObj){ u.callbacks.onComplete(fileObj); $rootScope.$apply(); },
          on_error:     function(){ u.callbacks.onError(); $rootScope.$apply();},
          on_progress:  function(bytesUploaded, bytesTotal){
            var percent = bytesUploaded / bytesTotal * 100;
            // console.log("File is %f percent done (%f of %f total)", percent, bytesUploaded, bytesTotal);
            u.progress = parseInt(percent, 10);
            u.callbacks.onProgress(u.progress);
            $rootScope.$apply();
          }
        };
        u.progress = 0;
        u.s3upload = new window.mule_upload(s).upload_file(u.options.file);
      }

    }

    return S3Upload;
  }]);
})();
