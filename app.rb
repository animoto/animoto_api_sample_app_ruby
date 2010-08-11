require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'animoto/client'
require 'erb'
require 'cgi'

class PartnerApp < Sinatra::Base
  @@callbacks = []
  @@images = []

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

    def add_image(image)
      @@images << image
    end

    def images
      @@images
    end

    def generate_transaction_token
      Time.now.to_f.to_s.gsub('.', '')
    end
  end

  require 'configuration'
  require 'constants'
  require 'endpoints'
  require 'templates'

  Dir["#{PartnerApp.root}/lib/**/*.rb"].sort.each do |file|
    require file
  end
end
