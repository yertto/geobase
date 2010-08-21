#!/usr/local/bin/ruby -rrubygems
=begin
  # Require the preresolved locked set of gems.
  require ::File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
=end

require 'sinatra'

require 'map_fetcher'


use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', ENV['SITE_PASSWORD']]
end if ENV['SITE_PASSWORD']


MY_VERSION = File.open(File.dirname(__FILE__) + "/VERSION").read.strip

get '/map/en/:location_id' do
  url = "http://freebase.com/api/service/geosearch?location=/en/#{params['location_id']}"
  haml :map, :locals => { :path =>  MapFetcher.fetch_path(url) }
end


get '/' do
  redirect '/map/en/victoria'
end


__END__


@@ map
:javascript
  window.onload = function () {
    var R = Raphael("paper", 1200, 5000);
    var attr = {
        fill: "#333",
        stroke: "#666",
        "stroke-width": 1,
        "stroke-linejoin": "round"
    };
    R.path("#{path}").attr(attr);
  };

@@ layout
%html
  %head
    %script{:src=>"/javascript/raphael.js", :type=>"text/javascript", :charset=>"utf-8"}
    = yield
  %body
    %div{:id=>'canvas'}
      %div{:id=>'paper'}
