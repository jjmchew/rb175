require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

get "/" do
  # list files in directory
  @files = Dir.entries(".").select { |entry| !File.directory?(entry) }

  p params['sort']
  sort_order = params['sort'] ? params['sort'] : 'up' 
  p sort_order
  case sort_order
  when 'down'
    @files.sort! { |x, y| y <=> x }
  else
    @files.sort!
  end
  p @files

  erb :file_list
end

get "/:file" do
  # display contents of file
  @file = params['file']
  @content = File.readlines params['file']
  
  erb :contents
end

