require "socket"

def parse_request(string)

  method, path_param, ver = string.split(" ")
  path = path_param
  params = {}
  
  if path_param.include?("?")
    path, param_string = path_param.split("?")

    param_array = [param_string]  
    param_array = param_string.split("&") if param_string.include?("&")

    param_array.each do |pair|
      params[pair.split("=")[0]] = pair.split("=")[1]
    end
  end

  return [method, path, params]
end

server = TCPServer.new("localhost", 3003)
loop do
  client = server.accept

  request_line = client.gets
  puts request_line

  next unless request_line
  
  method, path, params = parse_request(request_line)

  # http://localhost:3003/?rolls=2&sides=6
  # GET /?number=3 HTTP/1.1
  
  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html\r\n\r\n"
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts request_line
  client.puts method
  client.puts path
  client.puts params
  client.puts "</pre>"
  client.puts "<h1>Counter<h1>"
  
  number = params["number"].to_i

  client.puts "<p>The current number is #{number}."
  client.puts "<a href=\"http://localhost:3003/?number=#{number - 1}\">Decrement</a>"
  client.puts "<a href=\"http://localhost:3003/?number=#{number + 1}\">Increment</a>"
  client.puts "</body>"
  client.puts "</html>"

  client.close
end
