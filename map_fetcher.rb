#!/usr/bin/ruby -rrubygems

require 'fetcher'
require 'json'

class MapFetcher
  extend Fetcher

  NUM_1 = 50   # TODO - figure out what to do with these numbers
  NUM_2 = 200  # TODO - figure out what to do with these numbers
  NUM_3 = 100  # TODO - figure out what to do with these numbers

  def cache_dir
    ENV['CACHE_DIR']
  end

  def self.fetch_coords(url)
    data = JSON.parse(get_data(url))
    coords = data['features'][0]['geometry']['geometries'][0]['coordinates']
    (0..coords.size).each { |i| puts "#{i}: #{coords[i].size}, #{coords[i][0].size}" if coords[i] } if ENV['DEBUG']
    max = (0..coords.size-1).max { |a,b| coords[a][0].size <=> coords[b][0].size }
    coords[max][0]
  end

  def self.fetch_path(url)
    prev_lat, prev_lng = nil
    path = "M#{NUM_2},#{NUM_3}l"+fetch_coords(url).collect { |lat,lng| 
      point = [prev_lat - lat, prev_lng - lng] if prev_lat
      prev_lat, prev_lng = lat, lng
      "#{'%0.4f' % (point[0].to_f*-NUM_1)},#{'%0.4f' % (point[1].to_f*NUM_1)}" if point
    }.compact.join('l')
  end
end

if __FILE__ == $0
  ENV['CACHE_DIR'] ||= Pathname.new('.cache')
  location_id = '/en/victoria'
  location_id = '/en/tasmania'
  location_id = '/en/queensland'
  location_id = '/en/western_australia'
  url = "http://freebase.com/api/service/geosearch?location=#{location_id}"
  p MapFetcher.fetch_path(url)
end
