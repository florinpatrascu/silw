module Silw
  module Helpers
    def h(*args)
      escape_html(*args)
    end

    def find_template(views, name, engine, &block)
      Array(views).each { |v| super(v, name, engine, &block) }
    end

    def base_url
      "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/"
    end

    def partial(thing, locals = {})
      name = case thing
        when String then thing
        else thing.class.to_s.demodulize.underscore
      end
      haml :"partials/_#{name}", :locals => { name.to_sym => thing }.merge(locals)
    end

    def url_for(thing, options = {})
      url = thing.respond_to?(:to_url) ? thing.to_url : thing.to_s
      url = "#{base_url.sub(/\/$/, '')}#{url}" if options[:absolute]
      url
    end

    def production?
      settings.environment.to_sym == :production
    end

    def user_logged_in?
      session[:auth].present?
    end

    def link_to(title, target = "", options = {})
      options[:href] = target.respond_to?(:to_url) ? target.to_url : target
      options[:data] ||= {}
      [:method, :confirm].each { |a| options[:data][a] = options.delete(a) }
      haml "%a#{options} #{title}"
    end
    
    def like_filesize(nr)
      {
        'B'  => 1024,
        'KB' => 1024 * 1024,
        'MB' => 1024 * 1024 * 1024,
        'GB' => 1024 * 1024 * 1024 * 1024,
        'TB' => 1024 * 1024 * 1024 * 1024 * 1024
      }.each_pair{|e, s| return "#{(nr.to_f / (s / 1024)).round(2)}#{e}" if nr < s }
    end
  end
end
