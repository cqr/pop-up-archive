function parseNestedQuery(queryString, delimeters) {
  var d = d ? new RegExp('['+delimeters+'] *') : /[&;] */;
  var params = {};
  var chunks = (queryString || '').split(d);
  var split, key, value;

  for (var i=0; i<chunks.length; i++) {
    split = chunks[i].split('=', 2);
    key = unescape(split[0]);
    value = unescape(split[1]);

    normalizeParams(params, key, value);
  }

  return params;
}

function normalizeParams(params, name, value, problems) {
  if (typeof name == 'undefined') return;
  var match = name.match(/^[\[\]]*([^\[\]]+)\]*(.*)/);
  var key = (match[1] || '');
  var after = (match[2] || '');
  var childKey, shouldReturn;

  problems = (problems || []);

  if (key == '') {
    return;
  }

  if (after == '') {
    if (typeof params[key] !== 'undefined') {
      problems.push(params[key]);
    }
    params[key] = value;
  } else if (after == '[]') {
    params[key] = (params[key] || [])
    if (!(params[key] instanceof Array)) {
      throw "Expected an array, got an object for param " + key;
    }
    params[key].push(value);
  } else if ( match=(after.match(/^\[\]\[([^\[\]]+)\]$/) || after.match(/^\[\](.+)$/))) {
    childKey = match[1];
    params[key] = (params[key] || []);
    if (!(params[key] instanceof Array)) {
      throw "Expected an array, got an object for param " + key;
    }
    if (typeof params[key][params[key].length-1] === 'object' && typeof params[key][params[key].length-1][childKey] === 'undefined') {
      normalizeParams(params[key][params[key].length-1], childKey, value);
    } else {
      params[key].push(normalizeParams({}, childKey, value));
    }
  } else {
    params[key] = (params[key] || {})
    params[key] = normalizeParams(params[key], after, value);
  }

  return params;
}