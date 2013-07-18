angular.module('Directory.items.models', ['RailsModel', 'Directory.audioFiles.models'])
.factory('Item', ['Model', '$http', '$q', 'Contribution', 'Person', 'AudioFile', function (Model, $http, $q, Contribution, Person, AudioFile) {

  var attrAccessible = "dateBroadcast dateCreated datePeg description digitalFormat digitalLocation episodeTitle identifier musicSoundUsed notes physicalFormat physicalLocation rights seriesTitle tags title transcription adoptToCollection tagList text".split(' ');

  var Item = Model({url:'/api/collections/{{collectionId}}/items/{{id}}', name: 'item', only: attrAccessible});

  Item.beforeRequest(function(data, resource) {
    // console.log('beforeRequest: data', data);
    data.tags = [];
    angular.forEach((data.tag_list || []), function (v,k) {
      // console.log('v, k: ', v, k);
      data.tags.push(v['text']);
    });
    delete data.tag_list;

    return data;
  });

  Item.beforeResponse(function(data, resource) {
    // console.log('beforeResponse: data', data, resource);
    data.tagList = [];
    angular.forEach((data.tags || []), function (v,k) {
      // console.log('v, k: ', v, k);
      data.tagList.push({id:v, text:v});
    });

    return data;
  });

  Item.prototype.tagList2Tags = function() {
    var self = this;
    self.tags = [];
    angular.forEach((self.tagList || []), function (v,k) {
      // console.log('v, k: ', v, k);
      self.tags.push(v['text']);
    });
  };

  Item.prototype.getTitle = function () {
    if (this.title) { return this.title; }
    if (this.episodeTitle) { return this.episodeTitle + " : " + this.identifier; }
    if (this.seriesTitle) { return this.seriesTitle + " : " + this.identifier; }
  } 

  Item.prototype.getDescription = function () {
    if (this.description) { return this.description; }
    if (this.notes) { return this.notes; }
  }

  Item.prototype.getThumbClass = function () {
    if (this.audioFiles && this.audioFiles.length > 0) {
      return "icon-volume-up";
    } else {
      return "icon-file-alt"
    }
  }

  Item.prototype.link = function () {
    return "/collections/" + this.collectionId + "/items/" + this.id; 
  }

  Item.prototype.getDurationString = function () {
    var d = new Date(this.duration * 1000);
    return d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds();
  }

  Item.prototype.adopt = function (collectionId) {
    var self = this;
    this.adoptToCollection = collectionId;
    return this.update().then(function (data) {
      self.adoptToCollection = undefined;
      return data;
    });
  }

  Item.prototype.contributors = function(role) {
    var result = [];
    // console.log('contributions', this.contributions, this);
    angular.forEach(this.contributions, function (contribution) {
      if (contribution.role == role) {
        result.push(contribution.person.name);
      } else {
        // console.log('no match', contribution.role, role);
      }
    });
    return result;
  }

  Item.prototype.addAudioFile = function (file, options) {
    var options = options || {};
    var item = this;
    var audioFile = new AudioFile({itemId: item.id});
    audioFile.create().then(function(){
      // create relationships
      // audioFile.item = item;
      item.audioFiles = item.audioFiles || [];
      item.audioFiles.push(audioFile);
      options.token = item.token;
      audioFile.upload(file, options);
    });
    return audioFile;
  }

  // update existing audioFiles
  Item.prototype.updateAudioFiles = function () {
    var item = this;

    angular.forEach(this.audioFiles, function (audioFile, index) {

      var af = new AudioFile(audioFile);
      af.itemId = item.id;

      // delete c if marked for delete
      if (af._delete) {
        af.delete();
        item.audioFiles.splice(index, 1);
      }
      // else if (af.id) {
      //   af.update();
      // }
    });
  }

  // update existing contributions
  Item.prototype.updateContributions = function () {
    var item = this;

    angular.forEach(this.contributions, function (contribution, index) {

      var c = new Contribution(contribution);
      c.itemId = item.id;

      // delete c if marked for delete
      if (c._delete) {
        c.delete();
        item.contributions.splice(index, 1);
      } else if (!c.person.id  || (c.person.id == 'new')) {

        var p = new Person({'name':c.person.name, 'collectionId':item.collectionId});

        p.create().then( function() {
          c.personId = p.id;
          if (!c.id || (c.id == 'new')) {
            c.id = null;
            c.create();
          } else {
            c.update();
          }

        });
      } else if (!c.id || (c.id == 'new')) {
        c.id = null;
        c.personId = c.person.id;
        c.create();
      } else {
        c.personId = c.person.id;
        c.update();
      }
    });
  }

  Item.prototype.standardRoles = ['producer', 'interviewer', 'interviewee', 'creator', 'host'];

  // Item.attrAccessible = "dateBroadcast dateCreated datePeg description digitalFormat digitalLocation episodeTitle identifier musicSoundUsed notes physicalFormat physicalLocation rights seriesTitle tags tagList title transcription adoptToCollection".split(' ');

  return Item;
}])
.filter('titleize', function () {
  return function (value) {
    if (!angular.isString(value)) {
      return value;
    }
    return value.slice(0,1).toUpperCase() + value.slice(1).replace(/([A-Z])/g, ' $1');
  }
})
.filter('pluralize', function () {
  return function (value) {
    if (!angular.isString(value)) {
      return value;
    }
    return value + "s";
  }
});
