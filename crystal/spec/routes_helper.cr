# IO patch to get the response body
class HTTP::Server::Response < IO
    @body : String | Nil

    def initialize
      initialize(IO::Memory.new(0), "HTTP/1.1")
    end

    def puts(obj : _) : Nil
        self << obj
        @body = obj.to_s
        puts
    end

    def body
      @body
    end

end
