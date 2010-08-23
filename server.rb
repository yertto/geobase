#!/usr/local/bin/ruby -rrubygems
require 'sinatra'
require 'helpers'
require 'map_fetcher'


MY_VERSION = File.open(File.dirname(__FILE__) + "/VERSION").read.strip

get '/location/*/path/*' do
  response.headers['Cache-Control'] = 'public, max-age=29030400'
  location_type = params[:splat][0]
  location_id = '/'+params[:splat][1]
  MapFetcher.fetch_path(location_id, location_type)
end

get '/location' do
  haml :location
end

get '/' do
  redirect '/location'
end


__END__


@@ _header
%h1 GeoBase
%p
  Retrieves
  %a{:href=>"http://geojson.org"} geojson
  data from 
  %a{:href=>"http://freebase.com"} freebase
  , then renders it using
  %a{:href=>"http://raphaeljs.com"} raphael


@@ _map
:javascript
  var location_type = '/location/location';

  function start_type_suggest(str) {
    $("#location_type").val(str).data("suggest").textchange();
  }

  function start_location_suggest(str) {
    $("#location").val(str).data("suggest").textchange();
  }

  location_suggest = function(e, data) {
    xmlhttp=new XMLHttpRequest();
    document.getElementById('paper').innerHTML = "<img src='/img/ajax-loader.gif'/>";
    xmlhttp.onreadystatechange=function() {
      if (xmlhttp.readyState==4 && xmlhttp.status==200) {
        document.getElementById('paper').innerHTML = "";
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
          alert("freebase failed to return geometries for "+data.id);
        }
      }
    }
    xmlhttp.open("GET", location_type+"/path"+data.id, true);
    xmlhttp.send();
  };

  $(function() {
    $("#location_type").suggest({"type": "/type/type", "mql_filter": [{"/type/type/domain": "/location"}]})
    .bind("fb-select", function(e, data) {
      location_type = data.id;
      $("#location").suggest({"type": data.id}).bind("fb-select", location_suggest);
    });
  });

  $(function() {
    $("#location").suggest({"type": location_type}).bind("fb-select", location_suggest);
  });


@@ location
= haml :_map
- examples = {                             |
    'Country'          => 'Zimbabwe'     , |
    'Australian State' => 'Victoria'     , |
    'US State'         => 'Texas'        , |
    'US County'        => 'Orange County', |
  }                                        |
%form
  %table{:border=>1}
    %tr
      %th
      %th location
      %th{:colspan=>examples.keys.size} examples
    %tr
      %th type
      %th
        %input{:type=>"text", :id=>"location_type"}
      - examples.keys.each do |typ|
        %td
          %a{:href=>'#', :onClick=>"start_type_suggest(#{typ.inspect});"}= typ
    %tr
      %th value
      %td
        %input{:type=>"text", :id=>"location"}
      - examples.keys.each do |typ|
        %td
          - val = examples[typ]
          %a{:href=>'#', :onClick=>"start_location_suggest(#{val.inspect});"}= val
%div{:id=>'canvas'}
  %div{:id=>'paper'}


@@ _icon
%a{:href=>url}<
  %img{:src=>icon, :title=>title, :height=>16, :width=>16}


@@ _footer
%footer
  %div.wrapper
    %p
      Powered by
      = haml :_icon, :locals=>{:url=>"http://ruby-lang.org" , :icon=>"http://ruby-lang.org/favicon.ico"           , :title=>"ruby code"            }
      = haml :_icon, :locals=>{:url=>"http://sinatrarb.com" , :icon=>"http://www.sinatrarb.com/images/favicon.ico", :title=>"sinatra app"          }
      = haml :_icon, :locals=>{:url=>"http://freebase.com"  , :icon=>"http://freebase.com/favicon.ico"            , :title=>"data from freebase"   }
      = haml :_icon, :locals=>{:url=>"http://raphaeljs.com" , :icon=>"http://raphaeljs.com/favicon.ico"           , :title=>"rendered with raphael"}
      = haml :_icon, :locals=>{:url=>"http://heroku.com"    , :icon=>"http://heroku.com/favicon.ico"              , :title=>"hosted by heroku"     }
      = ".  Code on"
      = haml :_icon, :locals=>{:url=>"http://github.com/yertto/geobase/blob/v#{MY_VERSION}/server.rb", :icon=>"http://github.com/favicon.ico", :title=>"v#{MY_VERSION} of code on git"}
      = ".  Created by"
      = haml :_icon, :locals=>{:url=>"http://www.google.com/profiles/109591544557457917858", :icon=> "http://www.google.com/profiles/c/photos/public/AIbEiAIAAABECKKP8ZTP3oCOhQEiC3ZjYXJkX3Bob3RvKig1NGI1M2IzZmE3ZGI0NjY3YmIyN2JlOWQwMWU3NmY5MGZlOWM5NTdmMAGH4vIz9l9R4gnwRgptLK1oY43Ufw", :title=>"yertto"}
  :javascript
    var _gaq = _gaq || []; _gaq.push(['_setAccount', 'UA-18110397-1']); _gaq.push(['_trackPageview']); (function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s); })();


@@ layout
%html
  %head
    %script{:src=>"/javascript/raphael.js", :type=>"text/javascript", :charset=>"utf-8"}
    %link(type="text/css" rel="stylesheet" href="http://freebaselibs.com/static/suggest/1.2.1/suggest.min.css")
    %script(type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js")
    %script(type="text/javascript" src="http://freebaselibs.com/static/suggest/1.2.1/suggest.min.js")
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/css/01.css'  , :media => 'screen projection'}
  %body
    = haml :_header
    = yield
    = haml :_footer
