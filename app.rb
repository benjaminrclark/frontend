require 'diplomat'
require 'json'
require 'typhoeus'
require 'sinatra'

set :bind, '0.0.0.0'

set :logging, true

  def call_backend_service
    backend = Diplomat::Service.get('backend', :first)
    puts "#{backend.Address} #{backend.Port}"
    if backend.Address.nil?
      puts "Service is DOWN"
      {:service => "DOWN"}
    else
      puts "Service is UP"
      backend_response = Typhoeus.get("http://#{backend.Address}:#{backend.ServicePort}/")
      response = {:service => "UP", :response_status => backend_response.status_code} 
      if backend_response.success? 
        message = JSON.parse(backend_response.response_body)
        response.merge(message)
      else
        response
      end
    end
  end

  get '/' do

    erb :index, :locals => {
      :backend => call_backend_service,
      :variable => ENV.fetch("VARIABLE","variable"),
      :git_short_commit => ENV.fetch("GIT_SHORT_COMMIT","git_short_commit"),
      :branch => ENV.fetch("BRANCH","branch"),
      :node => ENV.fetch("NODE","node")
    }
  end
