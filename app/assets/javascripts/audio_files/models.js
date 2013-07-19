angular.module('Directory.audioFiles.models', ['RailsModel', 'S3Upload'])
.factory('AudioFile', ['Model', 'S3Upload', '$http', function (Model, S3Upload, $http) {
  var AudioFile = Model({url:'/api/items/{{itemId}}/audio_files/{{id}}', name: 'audio_file', only: ['url', 'filename']});

  AudioFile.prototype.cleanFileName = function(fileName) {
    return fileName.replace(/[^a-z0-9\.]+/gi,'_');
  }

  AudioFile.prototype.uploadKey = function(token, fileName) {
    return (token + '/' + this.cleanFileName(fileName));
  }

  AudioFile.prototype.getStorage = function() {
    var self = this;
    return AudioFile.processResponse($http.get(self.$url() + '/upload_to')).then(function (storage) {
      self.storage = storage;
      return self.storage;
    });
  }

  AudioFile.prototype.upload = function(file, options) {
    var self = this;
    self.getStorage().then(function(storage) {
      // console.log('upload_to!', storage, self, self.storage);

      options = options || {};

      options.bucket     = options.bucket       || self.storage.bucket;
      options.access_key = options.access_key   || self.storage.key;
      options.ajax_base  = self.$url();
      options.key        = self.uploadKey(options.token, file.name);
      options.file       = file;

      self.upload = new S3Upload(options);
      self.upload.upload();
    });
  };

  return AudioFile;
}])
.factory('TimedText', ['Model', '$http', function (Model, $http) {
  var TimedText = Model({url:'/api/timed_texts/{{id}}', name: 'timed_text', only: ['text']});
  return TimedText;
}]);