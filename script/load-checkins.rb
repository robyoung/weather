require 'twitter'
require 'mongo'
require 'open-uri'
require 'json'


conn     = Mongo::Connection.new
db       = conn['weathertrumps']
checkins = db['checkins']
stations = db['stations']

def get_station(stations, status)
  stations.find_one({"loc" => {"$near" => [status.geo.latitude, status.geo.longitude]}})
end

def get_stats(status, station)
  url = "http://partner.metoffice.gov.uk/public/val/wxobs/all/json/#{station['_id']}?res=hourly&key=56b621fb-4298-4631-88eb-2c380b914330"
  raw_data = ::JSON.parse(open(url).read)
  rep = raw_data['SiteRep']['DV']['Location']['Period'][1]['Rep']
  rep.last
end


Twitter.search("to:windytrumps", :rpp => 100, :result_type => "recent").map do |status|
  unless status.geo.nil?
    puts status.from_user
    station = get_station(stations, status)
    unless station.nil?
      datum   = get_stats(status, station)
      checkins.save({
        "_id" => status.id,
        "username" => status.from_user,
        "geo" => [status.geo.latitude, status.geo.longitude],
        "created_at" => status.created_at,
        "stats" => {
          "wind_speed" => datum['@S'].to_f,
          "temperature" => datum['@T'].to_f,
          "gust_speed" => datum['@G'].to_f
        }
      }
      )
    end
  else
    puts "no geo: #{status.from_user}"
  end
end