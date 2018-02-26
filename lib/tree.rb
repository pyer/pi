
class Tree

  def subtree(root = '.')
    files = Dir.entries(root).sort!
    out = '['
    files.each do |file|
      unless file.start_with?('.')
        if File.directory?(file)
          out += '{"text":"' + file + '","children":'
          out += subtree(file)
          out += '},'
        else
          out += '{"text":"' + file + '"},'
        end
      end
    end
    out.chomp(',') + ']'
  end

end
