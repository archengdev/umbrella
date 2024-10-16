require "http"
require "json"

# get user loc
pp "where are you"
user_loc = gets

# get lat and long from google maps API
gmaps_key = "AIzaSyDKz4Y3bvrTsWpPRNn9ab55OkmcwZxLOHI"
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_loc + "&key=" + gmaps_key
gmaps_response = JSON.parse(HTTP.get(gmaps_url))
loc = gmaps_response.fetch("results")[0].fetch("geometry").fetch("location")
lat = loc.fetch("lat")
long = loc.fetch("lng")
latlong = lat.to_s + "," + long.to_s
# get weather info from pirate weather
pweather_key = "3RrQrvLmiUayQ84JSxL8D2aXw99yRKlx1N4qFDUE"
pweather_url = "https://api.pirateweather.net/forecast/" + pweather_key + "/" + latlong
pweather_response = JSON.parse(HTTP.get(pweather_url))
currently = pweather_response.fetch("currently")
puts "The current temperature is " + currently.fetch("temperature").to_s + "."
minutely = pweather_response.fetch("minutely", false)
if minutely
  next_hour_summary = minutely.fetch("summary")
  puts "Next hour: #{next_hour_summary.downcase}."
end
hourly = pweather_response.fetch("hourly").fetch("data")
next_twelve = hourly[1..12]
hours = 1
umbrella = true
probs = []
next_twelve.each do |info|
  if hours > 1
    hr = "hours"
  else
    hr = "hour"
  end
  prob = info.fetch("precipProbability")
  puts "Chance of raining in #{hours} #{hr} is: #{prob}"
  probs.append([hours, prob])
  if prob > 0.1
    umbrella = true
  end
  hours += 1
end

if umbrella
  puts "need umbrella"
end

# pp probs
require "ascii_charts"

puts AsciiCharts::Cartesian.new(probs, :bar => true, :hide_zero => true).draw
# ## as a histogram
# puts AsciiCharts::Cartesian.new([[0, 1], [1, 3], [2, 7], [3, 15], [4, 4]], :bar => true, :hide_zero => true).draw
