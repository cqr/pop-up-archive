angular.module('Directory.audioFiles.models', ['RailsModel', 'S3Upload'])
.factory('AudioFile', ['Model', 'S3Upload', 'STORAGE_PROVIDER', function (Model, S3Upload, STORAGE_PROVIDER) {
  var AudioFile = Model({url:'/api/items/{{itemId}}/audio_files/{{id}}', name: 'audio_file'});

  AudioFile.attrAccessible = ['url', 'filename'];

  function createKey(token, fileName) {
    var cleanFileName = fileName.replace(/[^a-z0-9\.]+/gi,'_');
    return (token + '/' + cleanFileName);
  }

  AudioFile.prototype.upload = function(file, options) {
    options = options || {};

    // options.uploader = options.uploader || "fe667054313e5098844b7b5143a183c93ad6f38d";
    options.bucket     = options.bucket       || STORAGE_PROVIDER.bucket;
    options.access_key = options.access_key   || STORAGE_PROVIDER.access_key;
    options.ajax_base  = this.$url();
    options.key        = createKey(options.token, file.name);
    options.file       = file;

    this.upload = new S3Upload(options);
    this.upload.upload();
    return this.upload;
  };

  return AudioFile;
}]);