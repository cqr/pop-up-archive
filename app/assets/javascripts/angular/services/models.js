angular.module('Directory.models', ['RailsModel'])
.factory('CsvImport', ['Model', function (Model) {
  var CsvImport = Model({url:'/api/csv_imports', name: 'csv_import'});

  CsvImport.prototype.editButtonMessage = function () {
    return this.state == 'imported' ? 'Edit' : 'Continue';
  }

  CsvImport.prototype.cancel = function () {
    this.commit = 'cancel';
    return this.update();
  }

  CsvImport.attrAccessible = ['mappingsAttributes', 'collectionId', 'commit'];

  return CsvImport;
}])
.factory('Item', ['Model', function (Model) {
  var Item = Model({url:'/api/items', name: 'item'});

  return Item;
}])
.factory('Collection', ['Model', function (Model) {
  var Collection = Model({url:'/api/collections', name: 'collection'});
  Collection.attrAccessible = ['title', 'description'];
  
  return Collection;
}])
.factory('Search', ['Model', function (Model) {
  var Search = Model({url:'/api/search', name: 'search'});

  return Search;
}])
.factory('Schema', [function () {
  var schema = {columns: [], types: [{humanName: '---', name: '*'}], get: function () { return schema }};

  angular.forEach({
    string:      "Title / Label",
    short_text:  "Short Text",
    text:        "Longform Text",
    date:        "Date",
    number:      "Number",
    array:       "Comma Separated List",
    person:      "Person's Name",
    geolocation: "Geographic Location",
  }, function (humanName, name) {
    schema.types.push({humanName: humanName, name: name});
  });

  schema.columnize = function stringToColumnName(name) {
    return 'extra.' + name.toLowerCase().replace(/\W+/g,'_');
  }

  angular.forEach({
    "title":                           {type:"string",      display: "Title"},
    "episode_title":                   {type:"string",      display: "Episode Title"},
    "series_title":                    {type:"string",      display: "Series Title"},
    "description":                     {type:"text",        display: "Description"},
    "identifier":                      {type:"string",      display: "Identifier"},
    "date_broadcast":                  {type:"date",        display: "Date Broadcast"},
    "date_created":                    {type:"date",        display: "Date Created"},
    "rights":                          {type:"text",        display: "Rights"},
    "physical_format":                 {type:"short_text",  display: "Physical Format"},
    "digital_format":                  {type:"short_text",  display: "Digital Format"},
    "physical_location":               {type:"short_text",  display: "Physical Location"},
    "audio_files[][remote_file_url]":  {type:"array",       display: "Digital Locations"},
    "duration":                        {type:"number",      display: "Duration"},
    "music_sound_used":                {type:"short_text",  display: "Music/Sound Used"},
    "date_peg":                        {type:"short_text",  display: "Date Peg"},
    "tags":                            {type:"array",       display: "Tags"},
    "geographic_location":             {type:"geolocation", display: "Geolocation"},
    "interviewers[]":                  {type:"person",      display: "Interviewer"},
    "interviewees[]":                  {type:"person",      display: "Interviewee"},
    "producers[]":                     {type:"person",      display: "Producer"}
  }, function (metaData, columnName) {
    for (var typeIndex=0; schema.types[typeIndex].name != metaData.type; typeIndex++);
    schema.columns.push({name:columnName, humanName:metaData.display, typeId: typeIndex});
  });

  schema.appendColumns = function (thingsToAdd) {
    var clone = schema.columns.slice(0, this.columns.length);

    thingsToAdd.splice(0,0,0,0);
    clone.splice.apply(clone, thingsToAdd);
    return clone;
  };

  schema.columnsWith = function () {
    var columnNames = Array.prototype.slice.call(arguments, 0, arguments.length),
        columns = [];

    for (index in columnNames) {
      columns.push({humanName: "Extra: " + columnNames[index], name: schema.columnize(columnNames[index])});
    }

    return schema.appendColumns(columns);
  };

  schema.columnByName = function (columnName) {
    for (var i=0; i < schema.columns.length; i++) {
      if (columnName == schema.columns[i].name) {
        return schema.columns[i];
      }
    }
    return undefined;
  };

  schema.types.get = function (index) {
    return schema.types[index];
  }

  schema.getValue = function (column, mappings, row) {
    var i = schema.isMapped(column, mappings);
    if (i !== false) {
      return row[i];
    } else  {
      return undefined;
    }
  }

  schema.isMapped = function (column, mappings) {
    if (!mappings) return false;
    for (var i=0; i < mappings.length; i++) {
      var colName = (column.name || column);
      if (mappings[i].column == colName) { return i }
    }
    return false;
  }

  schema.includesExtraFields = function(mapping) {
    if (!mapping) return false;
    for (var i=0; i < mapping.length; i++) {
      var match = false;
      angular.forEach(schema.columns, function (column) {
        if (column.name == mapping[i].column) {
          match = true;
        }
      });
      if (!match) {
        return true;
      }
    }
    return false;
  }

  return schema;
}]);
