require 'yaml'
require 'tilt/erubis'
require 'sinatra'
require 'sinatra/reloader'
# require 'sinatra/base'

helpers do
  def each_user
    @users.keys.each do |key|
      yield(@users[key][:email], @users[key][:interests]) if block_given?
    end
  end

  def count_interests
    count = Hash.new(0)
    each_user do |_, interests| 
      count[:users] += 1
      count[:interests] += interests.length
    end
    count
  end
end

before do
  @users = Psych.load_file("users.yaml")
  @count = count_interests
end

get "/" do
  erb :home
end

get "/:name" do
  @user = params["name"]
  @info = @users[params["name"].to_sym]
  erb :user
end