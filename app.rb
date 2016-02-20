require 'sinatra/base'

class Rebaser < Sinatra::Application
  get '/' do
    'Hello'
  end

  get '/github/webhooks/:org/:repo' do
    "Hello World! #{params['org']} #{params['repo']}"
  end
end
