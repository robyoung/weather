require 'twitter'
require 'mongo'
require 'open-uri'

conn     = Mongo::Connection.new
db       = conn['weathertrumps']
checkins = db['checkins']
stations = db['stations']

def get_station(status)
  stations.find_one({"loc" => {"$near" => [status.geo.latitude, status.geo.longitude]}})
end

def get_stats(status, station)
  url = "http://partner.metoffice.gov.uk/public/val/wxobs/all/json/#{station['_id']}?res=hourly&key=56b621fb-4298-4631-88eb-2c380b914330"
  raw_data = JSON.parse(open(url).read)
  rep = raw_data['SiteRep']['DV']['Location']['Period'][1]['Rep']
  rep.last
end


Twitter.search("to:roryoung", :rpp => 50, :result_type => "recent").map do |status|
  unless status.geo.nil?
    station = get_station(status)
    datum   = get_stats(status, station)
    checkins.save({
      "_id" => status.id,
      "username" => status.from_user,
      "geo" => [status.geo.latitude, status.geo.longitude],
      "stats" => {
        "wind_speed" => datum['@S'],
        "temperature" => datum['@T'],
        "gust_speed" => datum['@G']
      }
    }
    )
  end
end