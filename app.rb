require './lib/base'

class App < Base
  get '/' do
    File.read('app/home.html')
  end

  get '/hello' do
    'Hello World !'
  end

  get '/time' do
    Time.now.strftime("%d/%m/%Y %H:%M:%S")
  end

  get '/chart' do
    File.read('app/chart.html')
  end
  get '/files' do
    File.read('app/files.html')
  end

  get '/tree' do
    Tree.new.subtree('.')
  end

  get '/favicon.ico' do
    File.read('themes/default/pi.ico')
  end
end
