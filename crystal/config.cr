# default mime types
DEFAULT_MIME_TYPE = "text/html"
STREAM_MIME_TYPE  = "application/octet-stream"

# get a mime from file extension
MIME_TYPE = {
  "html" =>  "text/html",
  "css"  =>  "text/css",
  "gif"  =>  "image/gif",
  "jpeg" =>  "image/jpeg",
  "jpg"  =>  "image/jpeg",
  "png"  =>  "image/png",
  "ico"  =>  "image/vnd.microsoft.icon",
  "js"   =>  "application/javascript",
  "json" =>  "application/json"
}

# PI server routes
class Router
  def routes

    get "/" do
      File.read("www/index.html")
    end

    get "/chart" do
      File.read("www/chart.html")
    end

    get "/favicon.ico" do
      File.read("www/images/pi.ico")
    end

    get "/hello" do
      "Hello World !"
    end

    get "/image" do
      File.read("www/images/apollo13.jpg")
    end

    get "/robots.txt" do
      "<pre style=\"word-wrap: break-word; white-space: pre-wrap;\">User-agent: *
Disallow: /</pre>"
    end

    get "/time" do
      Time.local.to_s("%d/%m/%Y %H:%M:%S")
    end

    get "/version" do
      "Version " + VERSION
    end

  end
end
