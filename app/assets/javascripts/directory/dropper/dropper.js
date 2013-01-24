function Dropper(target, modal) {
  this.node = target;
  this.modal = modal;
  this.initialize = function() {
    this.node.addEventListener('dragenter', this.dragenter, false);
    this.node.addEventListener('dragover', this.dragover, false);
    this.node.addEventListener('dragleave', this.dragleave, false);
    this.node.addEventListener('drop', this.drop, false);
  }
  this.dragenter = function(e) {
    e.stopPropagation();
    e.preventDefault();
    if (!this.modalIsVisible) {
      modal.modal('show')
      this.dragleaveCount = 0;
      this.modalIsVisible = true;
    };
  }
  this.dragover = function(e) {
    e.stopPropagation();
    e.preventDefault();
  }
  this.dragleave = function(e) {
    e.stopPropagation();
    e.preventDefault();
    this.dragleaveCount = this.dragleaveCount + 1;
    console.log(this.dragleaveCount);
    if (this.modalIsVisible && this.dragleaveCount > 1) {
      this.modalIsVisible = false;
      modal.modal('hide')
    };
  }
  this.drop = function(e) {
    e.stopPropagation();
    e.preventDefault();
    console.log('drop');
    // jQuery.each(e.dataTransfer.files, function(i, file) {
    //   var reader = new FileReader();

    //   // reader.addEventListener('loadend', function(e) {
    //   //  var track = new google.maps.Polyline({strokeColor: '#77f'});
    //   //  track.xml = (new DOMParser()).parseFromString(e.target.result,"text/xml");
    //   //  deck.tracks.push(track);
    //   // }, false)

    //   reader.onload = (function(_tracks) {
    //     return function(e) {
    //       var track = new google.maps.Polyline({strokeColor: '#77f'});
    //       track.xml = (new DOMParser()).parseFromString(e.target.result,"text/xml")
    //       _tracks.push(track);
    //     };
    //   })(deck.tracks);

    //   reader.readAsText(file);
    //   window.setTimeout(function() {deck.didLoadOrReceiveNewData()}, 20);
    // });
  }
}
