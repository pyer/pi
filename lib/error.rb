class Error

  def self.error404
    status = 404
    body = File.read('images/error404.jpg') 
    length = body.bytesize
    headers = { 'Content-Type' => 'image/jpeg', 'Content-Length' => length.to_s }
    return [status, headers, [body]]
  end
end
