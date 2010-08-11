require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'erb'
require 'cgi'

class PartnerApp < Sinatra::Base
  @@callbacks = []

  require 'constants'
  require 'endpoints'
  require 'templates'

  Dir["#{PartnerApp.root}/lib/**/*.rb"].sort.each do |file|
    require file
  end

  class << self
    def root
      File.expand_path(File.join(File.dirname(__FILE__)))
    end

    def add_callback(callback)
      @@callbacks << callback
    end

    def callbacks
      @@callbacks
    end

    def generate_transaction_token
      Time.now.to_f.to_s.gsub('.', '')
    end
  end
end
