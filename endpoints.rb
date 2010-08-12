# Sanity method
get '/ping' do
  erb :pong
end

# Displays a faux photo album page
get '/' do
  erb :index 
end

post '/callbacks' do
  PartnerApp.add_callback Callback.new(request.body.read, params[:transactionToken])
end

get '/callbacks' do
  erb :callbacks
end

get '/play' do
  @video_url = params['links']['video'] 
  erb :play
end

# Displays a widget
get '/widget' do
  @params = {}
  
  # Parameters must be sorted in alphabetical order by key.
  @params['appId'] = PartnerApp::Constants::Widget::APP_ID
  @params['nonce'] = Time.now.to_f
  @params['partnerId'] = PartnerApp::Constants::Partner::PARTNER_ID
  @params['partnerSecret'] = PartnerApp::Constants::Partner::PARTNER_SECRET
  source = @params.keys.sort.map { |i| "#{i}=#{@params[i]}" }.join('&')

  # Let's generate the signature for our widget
  @params['signature'] = Digest::MD5.hexdigest(source)

  # We don't need the partner secret once the signature is calculated. We also don't want to pass it over HTTP.
  @params.delete('partnerSecret')

  erb :widget
end
