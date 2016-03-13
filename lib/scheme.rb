require 'xcodeproj'

module Scheme
  def self.find_scheme(source_path, scheme_name)
    pattern_path = File.join source_path, '*.{xcworkspace,xcodeproj}'
    xcscheme_paths = Dir.glob(pattern_path).map { |container_path|
      File.join container_path, 'xcshareddata', 'xcschemes', "#{scheme_name}.xcscheme"
    }.keep_if { |xcscheme_path|
      File.exists? xcscheme_path
    }
    if xcscheme_paths.count > 1
      puts "Fatal Error: Find multiple schemes named '#{scheme_name}'"
      exit 1
    elsif xcscheme_paths.count == 0
      puts "Fatal Error: Cannot find scheme named '#{scheme_name}'"
      exit 1
    else
      return xcscheme_paths[0], Xcodeproj::XCScheme.new(xcscheme_paths[0])
    end
  end
end
