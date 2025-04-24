require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'

# added to use sessions within Sinatra
configure do
  enable :sessions
  set :session_secret, 'secret' # used to be able to access data after Sinatra restarts
  set :erb, :escape_html => true
end

helpers do

  def get_todo_status(todos)
    num_completed = todos.count { |todo| todo[:completed] == true }
    { detail: "#{num_completed} / #{todos.size}", completed: list_complete?(todos) }
  end

  def list_complete?(todos)
    todos.all? { |todo| todo[:completed] == true } && todos.size >= 1
  end

  # returns a class name for html list_name elements
  def list_class(list)
    "complete" if list_complete?(list[:todos])
  end

  # Orders lists for display (yields incomplete then complete lists with idx)
  def sort_lists(lists, &block)
    complete_lists, incomplete_lists = lists.partition { |list| list_complete?(list[:todos]) }
    
    incomplete_lists.each(&block)
    complete_lists.each(&block)

    # incomplete_lists = {}
    # complete_lists = {}

    # lists.each_with_index do |list, idx|
    #   if list_complete?(list[:todos])
    #     complete_lists[list] = idx
    #   else
    #     incomplete_lists[list] = idx
    #   end
    # end

    # incomplete_lists.each(&block)
    # complete_lists.each(&block)

    # ==== my method requires updating the template code ====
    # lists_view = []
    # lists.each_with_index { |list, idx| lists_view << { idx: idx, list: list } }
    # sorted = lists_view.sort_by do |hash| 
    #   list_complete?(hash[:list][:todos]) ? 1 : 0
    # end
    # sorted
  end

  # creates new (ordered) array of hash (todo) objects for display
  def sort_todos(todos, &block)
    complete_todos, incomplete_todos = todos.partition { |todo| todo[:completed] }
    
    incomplete_todos.each(&block)
    complete_todos.each(&block)
  end

end

def load_list(id)
  list = session[:lists].find { |list| list[:id] == id }
  return list if list

  session[:error] = "The specified list was not found."
  redirect "/lists"
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# View all lists
get '/lists' do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render the new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# View a single list
get '/lists/:id' do
  @list_id = params['id'].to_i
  @list = load_list(@list_id)
  erb :list, layout: :layout
end

# Return an error message if the name is invalid. Return nil if name is valid
def error_for_list_name(list_name)
  if !(1..100).cover? list_name.size
    'List name must be between 1 and 100 characters.'
  elsif session[:lists].any? { |list| list[:name] == list_name }
    'List name must be unique.'
  end
end

# Return next valid id
def next_valid_id(elements)
  max = elements.map { |element| element[:id] }.max || 0
  max + 1
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { id: next_valid_id(session[:lists]), name: list_name, todos: [] }
    session[:success] = 'The list has been created.'
    redirect '/lists'
  end
end

# Edit list (name) page
get '/lists/:id/edit' do
  @list_id = params['id'].to_i
  @list = load_list(@list_id)
  erb :edit_list, layout: :layout
end

# Update list_name
post '/lists/:id' do
  list_name = params[:list_name].strip
  @list_id = params['id'].to_i
  @list = load_list(@list_id)
  
  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :list, layout: :layout
    # redirect "/lists/#{@id}"
  else
    @list[:name] = list_name
    session[:success] = "List name updated to '#{list_name}'."
    redirect "/lists/#{@list_id}"
  end
end

# Delete list
post '/lists/:id/delete' do
  id = params['id'].to_i
  list_name = load_list(id)[:name]
  session[:lists] = session[:lists].select { |list| list[:name] != list_name }

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/lists"
  else
    session[:success] = "'#{list_name}' deleted."
    redirect "/lists"
  end
end

# Return an error message if the name is invalid. Return nil if name is valid
def error_for_todo_name(todo_name, list_id)
  if !(1..100).cover? todo_name.size
    'Todo name must be between 1 and 100 characters.'
  elsif load_list(list_id)[:todos].any? { |todo| todo[:name] == todo_name }
    'Todo name must be unique.'
  end
end

# Add a todo to list
post '/lists/:list_id/todos' do
  @list_id = params['list_id'].to_i
  @list = load_list(@list_id)
  todo_name = params['todo_name'].strip

  error = error_for_todo_name(todo_name, @list_id)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    id = next_valid_id(@list[:todos])
    @list[:todos] << { id: id, name: todo_name, completed: false }
    session[:success] = "'#{todo_name}' added to list '#{@list[:name]}'"
    redirect "/lists/#{params['list_id']}"
  end
end

# Delete a todo from list
post '/lists/:list_id/todos/:todo_id/delete' do
  list_id = params['list_id'].to_i
  @todo_id = params['todo_id'].to_i
  todo_name = load_list(list_id)[:todos].find { |todo| todo[:id] == @todo_id }[:name]
  load_list(list_id)[:todos].reject! { |todo| todo[:id] == @todo_id }

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    status 204 # success with no content
  else
    session[:success] = "Todo '#{todo_name}'deleted"
    redirect "/lists/#{list_id}"
  end
end

# Change todo status (completed or not)
post '/lists/:list_id/todos/:todo_id/toggle' do
  @list_id = params['list_id'].to_i
  @todo_id = params['todo_id'].to_i
  todo = load_list(@list_id)[:todos].find { |todo| todo[:id] == @todo_id }

  is_completed = params['completed'] == 'true'
  todo[:completed] = is_completed

  session[:success] = "Todo '#{todo[:name]}' updated"
  redirect "/lists/#{@list_id}"
end

# Complete All todos
post '/lists/:list_id/todos/completeall' do
  @list_id = params['list_id'].to_i
  list = load_list(@list_id)

  list[:todos].map! { |todo| { id: todo[:id], name: todo[:name], completed: true} }
  session[:success] = "All todos in list '#{list[:name]}' marked as completed."
  redirect "/lists/#{@list_id}"
end
