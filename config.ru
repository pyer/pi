#\ -w -p 8080 -s webrick

require './lib/base'

class Appli < Base
  get '/' do
    File.read('www/home.html')
  end

  get '/hello' do
    'Hello World !'
  end

  get '/time' do
    Time.now.strftime("%d/%m/%Y %H:%M:%S")
  end

  get '/chart' do
    File.read('www/chart.html')
  end

  get '/files' do
    File.read('www/files.html')
  end

  get '/tree' do
    Tree.new.subtree('.')
  end

  get '/favicon.ico' do
    File.read('images/pi.ico')
  end

  get '/robots.txt' do
  '<pre style="word-wrap: break-word; white-space: pre-wrap;">User-agent: *
Disallow: /</pre>'
  end

end

run Appli.new
