require_relative 'advice'
require_relative 'monroe'

class App < Monroe
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      status = '200'
      headers = {'Content-Type'=> 'text/html'}
      response(status, headers) do
        erb(:index)
      end
    when '/advice'
      piece_of_advice = Advice.new.generate
      status = '200'
      headers = {'Content-Type'=> 'text/html'}
      response(status, headers) do
        erb(:advice, :message => piece_of_advice)
      end
    else
      content = erb(:not_found)
      status = '404'
      headers = {'Content-Type'=> 'text/html', 'Content-Length' => content.length.to_s}
      response(status, headers) do
        content
      end
    end
  end

end
