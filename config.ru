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
    File.read('www/pi.ico')
  end
end

run Appli.new
