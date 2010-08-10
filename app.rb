require 'rubygems'
require 'sinatra'
require 'erb'

# These are our constants for our Animoto account and the widget we want to create.
module Constants
  module Partner
    PARTNER_SECRET = '556fcc77f4a2dac6e48a'
    PARTNER_ID = 'dfeb816403a8f5ddfdee'
  end

  module Widget
    APP_ID = 'e35c436e7ed1304cd08d'
  end

  module App
    HOST = 'http://widget-service-staging.animoto.com'
  end
end

# Sanity method
get '/ping' do
  erb :pong
end

# Displays a faux photo album page
get '/' do

end

@@callbacks = []
post '/callbacks' do
  @callbacks << request.body.read
  puts "received callback #{@callbacks.last}"
end

get '/last_callback' do
  "#{@@callback.inspect}" 
end

# Displays a widget
get '/display' do
  @params = {}
  
  # Parameters must be sorted in alphabetical order by key.
  @params['appId'] = Constants::Widget::APP_ID
  @params['nonce'] = Time.now.to_f
  @params['partnerId'] = Constants::Partner::PARTNER_ID
  @params['partnerSecret'] = Constants::Partner::PARTNER_SECRET
  source = @params.keys.sort.map { |i| "#{i}=#{@params[i]}" }.join('&')

  # Let's generate the signature for our widget
  @params['signature'] = Digest::MD5.hexdigest(source)

  # We don't need the partner secret once the signature is calculated. We also don't want to pass it over HTTP.
  @params.delete('partnerSecret')

  erb :index
end
