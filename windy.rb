require 'sinatra'
require 'mongo'
require 'time'

conn     = Mongo::Connection.new
db       = conn['weathertrumps']
checkins = db['checkins']

# def get_top(checkins, field, since)
#   query = Hash.new
#   query['created_at'] = {"$gt" => since}

#   return checkins
# end


get '/' do
  query = {"created_at" => {"$gt" => Time.now - 86400}}
  opts  = {:sort => ["stats.wind_speed", Mongo::DESCENDING]}
  results = checkins.find(query, opts)

  erb :windy, :locals => {"results" => results}
end