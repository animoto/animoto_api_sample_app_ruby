# Sanity method to insure everything is working.
get '/ping' do
  erb :pong
end

# Displays a faux photo album page.
get '/' do
  erb :index 
end

# Handles callbacks from the Widget Service and stores them in a simple list.
post '/callbacks' do
  PartnerApp.add_callback Callback.new(request.body.read, params[:transactionToken])
end

# Show all callbacks received from the Widget Service
get '/callbacks' do
  erb :callbacks
end

# Handles a Storyboard from the Widget and creates a Render via the API Gem with it.
# Render a page that will AJAX Poll the status of the Render until it is completed.
get '/finalize' do
  client = Animoto::Client.new PartnerApp::Constants::Platform::PLATFORM_USERNAME, PartnerApp::Constants::Platform::PLATFORM_PASSWORD
  storyboard = client.find Animoto::Storyboard, CGI.unescape(params['links']['storyboard'])
  manifest = Animoto::RenderingManifest.new storyboard, :resolution => "480p", :format => "h264", :framerate => 30
  job = client.render! manifest
  @job_url = job.url
  erb :finalize
end


# See if our API Render is compete or not.
get '/poll' do
  content_type :json
  client = Animoto::Client.new PartnerApp::Constants::Platform::PLATFORM_USERNAME, PartnerApp::Constants::Platform::PLATFORM_PASSWORD
  job = client.find Animoto::RenderingJob, params['job_url']
  if job.completed?
    video = client.find Animoto::Video, job.video_url
    {'completed' => true, 'url' => "/play?links[file]=#{CGI::escape(video.download_url)}"}.to_json
  else
    {'completed' => false}.to_json
  end
end

# View the Animoto Video in a standard web video player.
get '/play' do
  @video_url = CGI::escape(params['links']['file'])
  erb :play
end

# Calcalates your Widget Signature and displays the widget in an iframe.
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

  # This is our transaction token to map Animoto Workflow events back to our application session.
  @params['transactionToken'] = PartnerApp.generate_transaction_token

  # We don't need the partner secret once the signature is calculated. We also don't want to pass it over HTTP.
  @params.delete('partnerSecret')

  erb :widget
end
