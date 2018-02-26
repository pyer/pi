
class Response

    def self.ok(body, mime)
      headers = { 'Content-Type' => mime + '; charset=utf-8', 'Content-Length' => body.bytesize.to_s }
      status = 200
      [status, headers, [body]]
    end
end
