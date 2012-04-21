## Parse the JSON file with the MetOffice data we need in it. ##

require 'rubygems'
require 'json'
require 'open-uri'
require 'mongo'

# Read the file.
url = "http://partner.metoffice.gov.uk/public/val/wxobs/all/json/sitelist?key=56b621fb-4298-4631-88eb-2c380b914330"
file = open(url)
content = file.read()
# Output the JSON file in its entirety.
weatherdatafull = JSON.parse(content)

# Database connection + collection (tables).
dbConnection = Mongo::Connection.new
db = dbConnection['weathertrumps']
collection = db['stations']

# Save data to database.
weatherdatafull['Locations']['Location'].each do|weatherstations|
  collection.save({"_id" => weatherstations['@id'],
                   "name" => weatherstations['@name'],
                   "loc" => [weatherstations['@latitude'].to_f,weatherstations['@longitude'].to_f]})
end