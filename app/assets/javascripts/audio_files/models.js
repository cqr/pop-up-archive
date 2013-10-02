angular.module('Directory.audioFiles.models', ['RailsModel', 'S3Upload'])
.factory('AudioFile', ['Model', 'S3Upload', '$http', function (Model, S3Upload, $http) {
  var AudioFile = Model({url:'/api/items/{{itemId}}/audio_files/{{id}}', name: 'audio_file', only: ['url', 'filename']});

  AudioFile.prototype.cleanFileName = function (fileName) {
    return fileName.replace(/[^a-z0-9\.]+/gi,'_');
  }

  AudioFile.prototype.uploadKey = function (token, fileName) {
    return (token + '/' + this.cleanFileName(fileName));
  }

  AudioFile.prototype.getStorage = function () {
    var self = this;
    return AudioFile.processResponse($http.get(self.$url() + '/upload_to')).then(function (storage) {
      self.storage = storage;
      return self.storage;
    });
  }

  AudioFile.prototype.upload = function (file, options) {
    var self = this;
    self.getStorage().then(function (storage) {
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

 
  AudioFile.prototype.canOrderTranscript = function (user) {
    var self = this;
    if (!self.transcodedAt) return false;
 
    if (!user.isAdmin()) return false;

    // take this out later - AK
    if (!user.organization) return false;

    var t = self.taskForType('order_transcript');
    if (t) return false;

    return true;
  };

  AudioFile.prototype.isTranscriptOrdered = function () {
    var self = this;
    var t = self.taskForType('order_transcript');
    if (t && t.status != 'complete') {
      return true;
    }
    return false;      
  }

  AudioFile.prototype.canSendToAmara = function (user) {
    var self = this;

    if (!self.canOrderTranscript(user)) return false;

    if (!user.organization || !user.organization.amara_team) return false;

    return true;
  };

  AudioFile.prototype.taskForType = function (t) {
    for(var i = 0; i < this.tasks.length; i++) {
      if (this.tasks[i].type == t) { return this.tasks[i]; }
    }
  };

  AudioFile.prototype.orderTranscript = function () {
    var self = this;
    return AudioFile.processResponse($http.put(self.$url() + '/order_transcript')).then(function (audioFile) {
      console.log('orderTranscript result', audioFile, self);
      angular.copy(audioFile, self);
      return self;
    });
  };

  return AudioFile;
}])
.factory('TimedText', ['Model', '$http', function (Model, $http) {
  var TimedText = Model({url:'/api/timed_texts/{{id}}', name: 'timed_text', only: ['text']});
  return TimedText;
}]);