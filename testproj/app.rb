require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

MODE = 'DEV'
B = MODE == 'DEV' ? '' : '/ruby/testapp'

get '/' do
  erb :home
end

get '/view1' do
  erb :view1
end

get '/view2' do
  erb :view2
end

get '/:num' do
  @num = params[:num].to_i
  erb :view
end

# for dev environment (all links are sent to B+)
# get BASE + '/' do; redirect '/'; end
# get BASE + '/view1' do; redirect '/view1'; end
# get BASE + '/view2' do; redirect '/view2'; end
# get BASE + '/:num' do; redirect '/' + params[:num]; end