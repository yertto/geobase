var LOCATION_TYPE = '/location/location';
var AJAX_LOAD = "<img src='/img/ajax-loader.gif' alt='loading...' />";


// TODO - do this with JQuery and jsonp, using the shapes directly from freebase to draw the paths
location_suggest = function(e, data) {
  xmlhttp=new XMLHttpRequest();
  $('#paper').html(AJAX_LOAD);
  xmlhttp.onreadystatechange=function() {
    if (xmlhttp.readyState==4 && xmlhttp.status==200) {
      $('#paper').html('');
      path = xmlhttp.responseText;
      var R = Raphael("paper", 800, 500);
      var attr = {
        fill: "#333",
        stroke: "#666",
        "stroke-width": 1,
        "stroke-linejoin": "round"
      };
      R.path(path).attr(attr);
    } else {
      if (xmlhttp.status != 200) {
        $('#paper').html('');
        alert("freebase failed to return geometries for "+data.id);
      }
    }
  }
  url = LOCATION_TYPE+"/path"+data.id;
  xmlhttp.open("GET", url, true);
  xmlhttp.send();
};

// XXX
/*
geojson2paths(data) {
  try {
    coords = data['features'][0]['geometry']['geometries'][0]['coordinates'];
  } catch (e) {
    alert('oops');
  }
}
location_suggest = function(e, data) {
  json_url = 'http://freebase.com/api/service/geosearch?mql_input=[{"id":"'+data.id+'","type":"'+LOCATION_TYPE+'"}]&callback=?';
  console.log(json_url);
  $('#paper').html(AJAX_LOAD);
  $.getJSON(json_url,
    function(data){
      paths = geojson2paths(data);
      console.log(paths);
      $('#paper').html(data);
      var R = Raphael("paper", 800, 500);
      var attr = {
        fill: "#333",
        stroke: "#666",
        "stroke-width": 1,
        "stroke-linejoin": "round"
      };
      R.path(path).attr(attr);
    }
  );
};
*/


location_suggest2 = function(e, data) {
  //json_url = "http://api.flickr.com/services/feeds/photos_public.gne?tags=cat&tagmode=any&format=json&jsoncallback=?";
  json_url = "http://freebase.com/api/service/geosearch?location=/en/victoria&indent=1&callback=?";
  $.getJSON(json_url,
    function(data){
      console.log(data);
/*
      $.each(data.items, function(i,item){
        $("<img/>").attr("src", item.media.m).appendTo("#images");
        if ( i == 3 ) return false;
      });
*/
    }
  );
}


change_type = function(type_name, type_id, topic){
  $('#location_type_wrapper').html(type_name);
  $('#location_type_wrapper').attr('title', type_id);
  $("#location").suggest({"type": type_id});
  $("#location").val(topic).data("suggest").textchange();
  $("#location").focus();
};


$(document).ready(function(){
  $("#location").suggest({"type": LOCATION_TYPE}).bind("fb-select", location_suggest);

  $('a[class=suggest_example]').bind('click', function(){
    change_type(this.getAttribute('data-type_name'), this.getAttribute('data-type'), this.getAttribute('data-topic'))
    return false;
  });

  $('#location_type_wrapper').bind('click', function(){
    $('#location_type_wrapper').html('<input type="text" id="location_type">');
    $("#location_type").suggest({"type": "/type/type", "mql_filter": [{"/type/type/domain": "/location"}]})
    .bind("fb-select", function(e, data){ change_type(data.name, data.id, '');
    });
    $("#location_type").focus();
    return false;
  });
});


