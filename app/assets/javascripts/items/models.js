angular.module('Directory.items.models', ['RailsModel'])
.factory('Item', ['Model', '$http', '$q', 'Contribution', 'Person', function (Model, $http, $q, Contribution, Person) {
  var Item = Model({url:'/api/collections/{{collectionId}}/items/{{id}}', name: 'item'});

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
      return "icon-music";
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

  Item.prototype.addAudioFile = function (file) {
    var promise = $q.defer();
    var fData = new FormData();
    fData.append('file', file);
    fData.append('file', file);
    $http({
      method: 'POST',
      url: '/api/items/' + this.id + '/audio_files',
      data: fData,
      headers: { "Content-Type": undefined },
      transformRequest: angular.identity
    })
    .success(function(data, status, headers, config) {promise.resolve(data)})
    .error(function() { promise.reject();});
    return promise.promise;
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

        var p = new Person({'name': c.person.name, 'collectionId':item.collectionId});

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

  Item.attrAccessible = "dateBroadcast datePeg description digitalFormat digitalLocation episodeTitle identifier musicSoundUsed notes physicalFormat physicalLocation rights seriesTitle tags title transcription".split(' ');

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
