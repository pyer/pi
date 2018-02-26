
class Favicon

    def self.body(filename)
      ['image/vnd.microsoft.icon', File.read(filename)]
    end
end
