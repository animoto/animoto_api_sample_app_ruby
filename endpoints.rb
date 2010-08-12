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

# Fill me in
get '/finalize' do
end

get '/play' do
  @video_url = params['links']['video'] 
  erb :play
end

# Displays a widget
get '/widget' do
  @params = {}

  # Set no cache headers
  @meta_cache = true
  response.headers["Last-Modified"] = Time.now.httpdate
  response.headers["Expires"] = "0"
  # HTTP 1.0
  response.headers["Pragma"] = "no-cache"
  # HTTP 1.1 'pre-check=0, post-check=0' (IE specific)
  response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'
  
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
