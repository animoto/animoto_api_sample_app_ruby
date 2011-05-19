module PartnerApp::Constants
  module Partner
    PARTNER_SECRET = ENV['ANIMOTO_PARTNER_SECRET']
    PARTNER_ID = ENV['ANIMOTO_PARTNER_ID']
  end

  module Widget
    APP_ID = ENV['ANIMOTO_APP_ID']
  end

  module WidgetService 
    HOST = 'https://widget-service-sandbox.animoto.com'
  end
   
  module Api2
    HOST = 'https://platform-sandbox.animoto.com/'
  end

  module Platform
    PLATFORM_USERNAME = ENV['ANIMOTO_PLATFORM_USERNAME']
    PLATFORM_PASSWORD = ENV['ANIMOTO_PLATFORM_PASSWORD']
  end
end
