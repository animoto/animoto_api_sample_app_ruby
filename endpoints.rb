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
  client = Animoto::Client.new
  storyboard = client.find Animoto::Storyboard, CGI.unescape(params['links']['storyboard'])
  manifest = RenderingManifest.new storyboard, :resolution => "1080p", :format => "flv", :framerate => 30
  job = client.render! manifest
  @job_url = job.url
  erb :finalize
end

get '/poll' do
  content_type :json
  client = Animoto::Client.new
  job = client.find Animoto::RenderingJob, params['job_url']
  if job.completed?
    video = client.find Animoto::Video, job.video_url
    { 'completed' => true, 'url' => "/play?links[video]=#{video.download_url}" }.to_json
  else
    { 'completed' => false }.to_json
  end
end

get '/play' do
  @video_url = params['links']['video'] 
  erb :play
end

# Displays a widget
get '/widget' do
  @params = {}

  # Set no cache headers
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
