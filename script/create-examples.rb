require 'twitter'
require 'mongo'
require 'time'
require 'open-uri'
require 'json'

conn     = Mongo::Connection.new
db       = conn['weathertrumps']
checkins = db['checkins']
stations = db['stations']

users = [
  "kukibee",
  "jourdanbqbo9",
  "KatieReillyXX",
  "chrisjrob",
  "aral",
  "WilliamDeen",
  "OutdoorsShow",
  "CPChallenge",
  "AccessCBT",
  "SMLittley",
  "ndalinton",
  "AnthonyEBurge",
  "MattDTyler",
  "flatFiveDev",
  "psd",
  "VegaprintLtd",
  "geckoluket",
  "EUSPOCS",
  "ColetteWeston",
  "ChrisMonk_oo",
  "brunogirin",
  "neilcford",
  "brooks25n",
  "PsychoMario",
  "ClaireJaneOCD",
  "suppleiylj9"
]

def get_stats(station)
  url = "http://partner.metoffice.gov.uk/public/val/wxobs/all/json/#{station['_id']}?res=hourly&key=56b621fb-4298-4631-88eb-2c380b914330"
  raw_data = ::JSON.parse(open(url).read)
  rep = raw_data['SiteRep']['DV']['Location']['Period'][1]['Rep']
  rep.last
end


(1..100).each do |num|
  begin
    station = stations.find_one({}, {:skip => Random.rand(121)})
    stats   = get_stats(station)
    user    = users.pop
    if user.nil?
      break
    end
    checkins.save({
      "_id" => num,
      "username" => user,
      "geo" => station['loc'],
      "created_at" => Time.now,
      "station" => station['name'],
      "stats" => {
        "wind_speed" => stats['@S'].to_f,
        "temperature" => stats['@T'].to_f,
        "gust_speed" => stats['@G'].to_f
      }
    })
  rescue
  end
end