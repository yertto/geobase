#!/usr/local/bin/ruby -rrubygems
require 'sinatra'
require 'helpers'
require 'map_fetcher'

MY_VERSION = File.open(File.dirname(__FILE__) + "/VERSION").read.strip


EXAMPLE_TYPES = {
  '/location/australian_state' => 'Australian State' ,
  '/location/country'          => 'Country'          ,
  '/location/us_state'         => 'US State'         ,
  '/location/us_county'        => 'US County'        ,
  '/location/fr_region'        => 'French Region'    ,
}
EXAMPLE_TYPE_IDS = EXAMPLE_TYPES.keys.sort

EXAMPLE_TOPICS = {
  '/location/australian_state' => 'Victoria'     ,
  '/location/country'          => 'Zimbabwe'     ,
  '/location/us_state'         => 'Texas'        ,
  '/location/us_county'        => 'Orange County',
  '/location/fr_region'        => 'Corsica'      ,
}


get '/location/*/path/*' do
  #response.headers['Cache-Control'] = 'public, max-age=29030400'
  location_type = params[:splat][0]
  location_id = '/'+params[:splat][1]
  MapFetcher.fetch_path(location_id, location_type)
end

get '/geosearch' do
  haml :geosearch
end

get '/' do
  redirect '/geosearch'
end



__END__


@@ _header


@@ geosearch
%h1 Geosearch
%p
  Searches for
  %a{:href=>"http://geojson.org"} GeoJSON
  data from 
  %a{:href=>"http://freebase.com"} Freebase
  , then renders it using
  %a{:href=>"http://raphaeljs.com"} Raphaël.
  %br
  Example searches:
  %ul
    - EXAMPLE_TYPE_IDS.collect do |type_id|
      %li
        %a{:href=>'#', :class=>'suggest_example', :'data-type'=>type_id, :'data-type_name'=>EXAMPLE_TYPES[type_id], :'data-topic'=>EXAMPLE_TOPICS[type_id], :title=>"Search: #{EXAMPLE_TOPICS[type_id].inspect} (filtered by #{EXAMPLE_TYPES[type_id].inspect})"}= EXAMPLE_TOPICS[type_id] 
%hr
%form
  Search:
  %input{:type=>"text", :id=>"location"}
  (filtered by 
  %a{:href=>"#", :id=>"location_type_wrapper", :title=>"/location/location"} Location
  )
#canvas
  #paper



@@ _footer
%footer
  %div.wrapper
    %p
      Powered by
      = haml :_icon, :locals=>{:url=>"http://ruby-lang.org" , :icon=>"http://ruby-lang.org/favicon.ico"           , :title=>"Ruby code"            }
      = haml :_icon, :locals=>{:url=>"http://sinatrarb.com" , :icon=>"http://www.sinatrarb.com/images/favicon.ico", :title=>"Sinatra app"          }
      = haml :_icon, :locals=>{:url=>"http://freebase.com"  , :icon=>"http://freebase.com/favicon.ico"            , :title=>"data from Freebase"   }
      = haml :_icon, :locals=>{:url=>"http://raphaeljs.com" , :icon=>"http://raphaeljs.com/favicon.ico"           , :title=>"rendered with Raphaël"}
      = haml :_icon, :locals=>{:url=>"http://heroku.com"    , :icon=>"http://heroku.com/favicon.ico"              , :title=>"hosted by Heroku"     }
      = ".  Code on"
      = haml :_icon, :locals=>{:url=>"http://github.com/yertto/geobase/blob/v#{MY_VERSION}/server.rb", :icon=>"http://github.com/favicon.ico", :title=>"v#{MY_VERSION} of code on git"}
      = ".  Created by"
      = haml :_icon, :locals=>{:url=>"http://www.google.com/profiles/109591544557457917858", :icon=> "http://www.google.com/profiles/c/photos/public/AIbEiAIAAABECKKP8ZTP3oCOhQEiC3ZjYXJkX3Bob3RvKig1NGI1M2IzZmE3ZGI0NjY3YmIyN2JlOWQwMWU3NmY5MGZlOWM5NTdmMAGH4vIz9l9R4gnwRgptLK1oY43Ufw", :title=>"yertto"}


@@ layout
%html
  %head
    %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
    %link(type="text/css" rel="stylesheet" href="http://freebaselibs.com/static/suggest/1.2.1/suggest.min.css")
    %link(type='text/css' rel ='stylesheet' href='/css/01.css' media='screen projection')
    %script(type="text/javascript" src="/javascript/raphael.js")
    %script(type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js")
    %script(type="text/javascript" src="http://freebaselibs.com/static/suggest/1.2.1/suggest.min.js")
  %body
    = haml :_header
    = yield
    = haml :_footer
    %script(type="text/javascript" src="/javascript/geobase.js")
    %script(type="text/javascript" src="/javascript/ga.js")
