string = "GET /?rolls=2&sides=6 HTTP/1.1"

array = string.split(" ")

method = array[0]
path = array[1].split("?")[0]
ver = array[2]
param_string = array[1].split("?")[1]

param_array = param_string.split("&")

params = {}
param_array.each do |pair|
  params[pair.split("=")[0]] = pair.split("=")[1]
end

p method
p path
p ver
p params

3.times { |num| p num }