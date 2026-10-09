# PI server routes
require "./tree.cr"

module Routes

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

    get "/files" do
      File.read("www/files.html")
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

    get "/tree" do
      Tree.new.subtree(".")
    end

    get "/version" do
      "Version " + VERSION
    end
  end
end
