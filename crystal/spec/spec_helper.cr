
class Mock
  @@count = 0

  def self.increment
    @@count += 1
  end

  def self.count
    @@count
  end
end

# Mock function 'get'
def get(path : String, &block : -> String)
  Mock.increment
end

