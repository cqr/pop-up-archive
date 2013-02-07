angular.module('Directory.alerts', [])
.factory('Alert', function () {
  var alerts = [];

  function Alert(data) {
    data = (data || {});
    this.status   = data.status;
    this.message  = data.message;
    this.progress = data.progress;
  }

  Alert.prototype = {
    add: function () {
      alerts.push(this);
    },
    
    dismiss: function () {
      alerts.splice(alerts.indexOf(this), 1);
    }
  }

  Alert.add = function(alert) {
    var newAlert = new Alert(alert);
    alert.add();
    return alert;
  }

  Alert.getAlerts = function() {
    return alerts;
  }

  return Alert;
});