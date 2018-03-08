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
  get '/dist/jquery.min.js' do
    File.read('dist/jquery-3.3.1.min.js')
  end
  get '/dist/jstree.min.js' do
    File.read('dist/jstree.min.js')
  end
  get '/dist/themes/default/style.min.css' do
    File.read('dist/themes/default/style.min.css')
  end
  get '/dist/themes/default/throbber.gif' do
    File.read('dist/themes/default/throbber.gif')
  end
  get '/dist/themes/default/32px.png' do
    File.read('dist/themes/default/32px.png')
  end

  get '/dist/d3.min.js' do
    File.read('dist/d3.min.js')
  end
  get '/dist/c3.min.js' do
    File.read('dist/c3.min.js')
  end
  get '/dist/themes/c3.min.css' do
    File.read('dist/themes/c3.min.css')
  end

  get '/themes/default/style.css' do
    File.read('themes/default/style.css')
  end

  get '/tree' do
    Tree.new.subtree('.')
  end

  get '/favicon.ico' do
    File.read('themes/default/pi.ico')
  end
end
