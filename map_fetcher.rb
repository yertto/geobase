#!/usr/bin/ruby -rrubygems

require 'fetcher'
require 'json'

class MapFetcher
  extend Fetcher

  NUM_1 = 10   # TODO - figure out what to do with these numbers
  NUM_2 = 200  # TODO - figure out what to do with these numbers
  NUM_3 = 100  # TODO - figure out what to do with these numbers

  def self.cache_dir
    @cache_dir ||= Pathname.new(ENV['CACHE_DIR']) if ENV['CACHE_DIR']
  end

  def self.fetch_coords(url)
    data = get_data(url)
    geojson = JSON.parse(data)
    p geojson if ENV['DEBUG']
    begin
      coords = geojson['features'][0]['geometry']['geometries'][0]['coordinates']
    rescue
      raise Exception, "No geometries returned from freebase: #{url}"
    end
    coords = coords.collect { |x| x.size == 1 ? x[0] : x }  # Sometimes coords are in a array of one array
    (0..coords.size-1).each { |i| puts "#{i}: #{coords[i].size}"} if ENV['DEBUG']
    max = (0..coords.size-1).max { |a,b| coords[a].size <=> coords[b].size }
    coords[max]
  end

  def self.fetch_path(location_id, location_type='location')
    url = URI.parse(URI.encode('http://freebase.com/api/service/geosearch?mql_input=[{"id":"'+location_id+'","type":"/location/'+location_type+'"}]'))
    puts url if ENV['DEBUG']
    prev_lat, prev_lng = nil
    path = "M#{NUM_2},#{NUM_3}l"+fetch_coords(url).collect { |lat,lng| 
      p lat, lng if ENV['DEBUG']
      point = [prev_lat - lat, prev_lng - lng] if prev_lat
      prev_lat, prev_lng = lat, lng
      "#{'%0.4f' % (point[0].to_f*-NUM_1)},#{'%0.4f' % (point[1].to_f*NUM_1)}" if point
    }.compact.join('l')
  end
end

if __FILE__ == $0
  ENV['CACHE_DIR'] ||= '.cache'
  p location_id = ARGV[0] || '/en/western_australia'
  p MapFetcher.fetch_path(location_id)
end
