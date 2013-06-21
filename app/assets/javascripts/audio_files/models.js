angular.module('Directory.audioFiles.models', ['RailsModel', 'S3Upload'])
.factory('AudioFile', ['Model', 'S3Upload', 'STORAGE_PROVIDER', '$http', function (Model, S3Upload, STORAGE_PROVIDER, $http) {
  var AudioFile = Model({url:'/api/items/{{itemId}}/audio_files/{{id}}', name: 'audio_file'});

  AudioFile.attrAccessible = ['url', 'filename'];

  function createKey(token, fileName) {
    var cleanFileName = fileName.replace(/[^a-z0-9\.]+/gi,'_');
    return (token + '/' + cleanFileName);
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
      options.key        = createKey(options.token, file.name);
      options.file       = file;

      self.upload = new S3Upload(options);
      self.upload.upload();
    });
  };

  return AudioFile;
}]);