angular.module('Directory.items.models', ['RailsModel'])
.factory('Item', ['Model', '$http', '$q', function (Model, $http, $q) {
  var Item = Model({url:'/api/collections/{{collectionId}}/items/{{id}}', name: 'item'});

  Item.prototype.getTitle = function () {
    if (this.title) { return this.title + (this.identifier ? ' ('+ this.identifier +')' : ''); }
    if (this.episodeTitle) { return this.episodeTitle + " : " + this.identifier; }
    if (this.seriesTitle) { return this.seriesTitle + " : " + this.identifier; }
  } 

  Item.prototype.getDescription = function () {
    if (this.description) { return this.description; }
    if (this.notes) { return this.notes; }
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
    fData.append('audio_file[file]', file);
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

  Item.attrAccessible = "dateBroadcast datePeg description digitalFormat digitalLocation episodeTitle identifier musicSoundUsed notes physicalFormat physicalLocation rights seriesTitle title transcription".split(' ');

  return Item;
}])
