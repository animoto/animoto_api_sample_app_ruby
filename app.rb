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
  @images = []
  @images << 'http://s3-p.animoto.com/Image/maYvpK03IYvnihGuB0YkAg/l.jpg'
  @images << 'http://s3-p.animoto.com/Image/1bROwNFCqptsf2tYovp11g/l.jpg'
  @images << 'http://s3-p.animoto.com/Image/Pvny15tMg8w027iAx52ZFw/l.jpg'
  @images << 'http://s3-p.animoto.com/Image/a7PLsMNvwKTiphwFQTZSBQ/l.jpg'
  @images << 'http://s3-p.animoto.com/Image/47VqIpXpoEmoK3yB0MPM1Q/l.jpg'
  erb :index 
end

post '/callbacks' do
  @@callbacks ||= []
  @@callbacks << request.body.read
end

get '/callbacks' do
  @@callbacks ||= []
  "#{@@callbacks.join("\n\r\n\r")}" 
end

# Displays a widget
get '/widget' do
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

  erb :widget
end
