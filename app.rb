require 'rubygems'
require 'sinatra'

configure :production do
end

get '/ping' do
  "pong"
end
