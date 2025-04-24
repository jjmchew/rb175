ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative '../cms.rb'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_document(name, content='')
    File.open(File.join(data_path, name), 'w') do |file|
      file.write(content)
    end
  end

  def session
    last_request.env['rack.session']
  end

  def admin_session
    { "rack.session" => {username: "admin"} }
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def test_index
    create_document('about.md')
    create_document('changes.txt')

    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_match /about.md/, last_response.body
    assert_match /changes.txt/, last_response.body
  end

  def test_view_document
    create_document('changes.txt', 'Start of changes:')

    get '/changes.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_match /Start of changes:/, last_response.body
  end

  def test_no_file
    get '/notafile.ha'
    assert_equal 302, last_response.status
    assert_equal 'notafile.ha does not exist.', session[:message] # tests session[:message] directly
    
    get last_response['Location']
    assert_match /notafile.ha does not exist./, last_response.body

    get '/'
    refute_includes last_response.body, 'notafile.ha does not exist.'
  end

  def test_markdown
    create_document('about.md', '# This is a heading')

    get '/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response["Content-Type"]
    assert_includes last_response.body, "<h1>This is a heading</h1>"
  end

  def test_edit_page_admin
    create_document('changes.txt', 'Start of changes:')
    
    get '/changes.txt/edit', {}, admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Edit content of changes.txt:'
    assert_includes last_response.body, '<textarea'
    assert_includes last_response.body, '<input type="submit" value="Save Changes">'
  end

  def test_edit_page_not_admin
    create_document('changes.txt', 'Start of changes:')

    get '/changes.txt/edit'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_edit_post_admin
    create_document('changes.txt', 'Start of changes:')
    content = File.read(get_filepath('changes.txt'))

    post '/changes.txt', {text_area: content + "\ntest content\n"}, admin_session
    assert_equal 302, last_response.status
    assert_equal 'changes.txt has been updated.', session[:message] # tests session[:message] directly
    
    # get last_response['Location']
    # assert_includes last_response.body, 'changes.txt has been updated.'

    get '/changes.txt'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'test content'
  end

  def test_edit_post_not_admin
    create_document('changes.txt', 'Start of changes:')

    content = File.read(get_filepath('changes.txt'))

    post '/changes.txt', text_area: content + "\ntest content\n"
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_get_create_admin
    get '/create', {}, admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Add a new document:'
    assert_includes last_response.body, "<input type='text'"
    assert_includes last_response.body, "<input type='submit'"
  end

  def test_get_create_not_admin
    get '/create'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_post_create_existing_filename
    create_document('changes.txt', 'Start of changes:')
    post '/create', {filename: 'changes.txt'}, admin_session
    assert_equal 422, last_response.status
    # assert_match /unique filename/, session[:message] # cannot use this since message is display/deleted immediately
    assert_includes last_response.body, "A unique filename with a '.txt' or '.md' extension is required."
  end

  def test_post_create_empty_filename
    post '/create', {filename: ''}, admin_session
    assert_equal 422, last_response.status
    # assert_match /A unique filename/, session[:message] # cannot use this since message is display/deleted immediately
    assert_includes last_response.body, "A unique filename with a '.txt' or '.md' extension is required."
  end

  def test_post_create_new_file_admin
    post '/create', {filename: 'test.txt'}, admin_session
    assert_equal 302, last_response.status

    assert_equal 'test.txt was created.', session[:message] # tests session[:message] directly

    get last_response['Location']
    assert_includes last_response.body, 'test.txt was created.'

    get '/'
    assert_includes last_response.body, '<a href="/test.txt">'
  end

  def test_post_create_new_file_not_admin
    post '/create', filename: 'test.txt'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_delete_file_admin
    create_document('changes.txt', 'Start of changes:')

    post '/changes.txt/delete', {}, admin_session
    assert_equal 302, last_response.status

    assert_equal "'changes.txt' was deleted.", session[:message] # tests session[:message] directly
    
    get last_response['Location']
    assert_includes last_response.body, "'changes.txt' was deleted."

    get '/'
    refute_includes last_response.body, 'changes.txt'
  end

  def test_delete_file_not_admin
    create_document('changes.txt', 'Start of changes:')
    post '/changes.txt/delete'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_show_signin_page
    get '/users/signin'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Username:'
    assert_includes last_response.body, 'Password:'
    assert_includes last_response.body, 'Sign In'
    assert_includes last_response.body, "<input" 
    assert_includes last_response.body, "type='submit'"

    refute_includes session.keys, :username # tests session[:username] directly
  end

  def test_invalid_credentials
    post '/users/signin', username: 'james', pw: 'pizzad'
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'Invalid credentials'
    assert_includes last_response.body, 'Username:'
    assert_includes last_response.body, 'james' # invalid username should still be displayed
    assert_includes last_response.body, 'Password:'
    assert_includes last_response.body, 'Sign In'
    assert_includes last_response.body, "<input" 
    assert_includes last_response.body, "type='submit'"

    refute_includes session.keys, :username# tests session[:username] directly
  end

  def test_valid_credentials
    post '/users/signin', username: 'admin', pw: 'secret'
    assert_equal 302, last_response.status
    assert_equal 'Welcome!', session[:message] # tests session[:message] directly

    get last_response['Location']
    assert_includes last_response.body, 'Welcome'
    assert_includes last_response.body, 'Signed in as admin'
    assert_includes last_response.body, 'Sign Out'
    
    assert_equal 'admin', session[:username] # tests session[:username] directly
  end

  def test_sign_out
    post '/users/signin', username: 'admin', pw: 'secret'
    post '/users/signout'
    assert_equal 'You have been signed out.', session[:message] # tests session[:message] directly

    get '/'
    assert_includes last_response.body, "<a href='/users/signin'>Sign In</a>"

    refute_includes session.keys, :username # tests session[:username] directly
  end
end
