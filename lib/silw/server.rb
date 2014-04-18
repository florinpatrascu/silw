require "sinatra/content_for"

module Silw
  class Server < Sinatra::Base
    STATIC_PATHS = ["/favicon.ico", "/img"]

    app_dir = File.dirname(File.expand_path(__FILE__))

    set :views,         "#{app_dir}/views"
    set :public_folder, "#{app_dir}/public"

    use Rack::ShowExceptions
    use Rack::MethodOverride

    use Rack::StaticCache,
      urls: STATIC_PATHS,
      root: File.expand_path('./public/', __FILE__)

    use Rack::Session::Cookie,  
      key: '<#>&wksjuIuwo!',
      domain: "localhost",
      path: '/',
      expire_after: 14400,
      secret: '*987^514('
    
    helpers Sinatra::ContentFor
    helpers Silw::Helpers

    include Rack::Utils
    
    configure do
      disable :protection
      enable  :logging
    end

    get '/' do
      # "Hello World! :#{settings.agents}:"
      haml :index
    end

    # 404
    not_found do
      haml :"404"
    end
  end
end
