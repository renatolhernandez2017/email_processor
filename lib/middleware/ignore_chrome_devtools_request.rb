class IgnoreChromeDevtoolsRequest
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/.well-known/appspecific/com.chrome.devtools.json"
      # Retorna status 204 (No Content), sem corpo nem headers extras
      [204, { "Content-Type" => "text/plain" }, []]
    else
      @app.call(env)
    end
  end
end
