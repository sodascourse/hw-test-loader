require_relative './injecter.rb'

# Check arguments ------------------------------------------------------------------------------------------------------

if ARGV.count != 2
  puts 'ERROR: Arguments should be `<xcode_project_path>` `<test_case_dir>`'
  exit 1
end

xcode_project_path = ARGV[0]
if !File.exists?(File.join xcode_project_path, 'project.pbxproj')
  # Maybe it's a folder contains *.xcodeproj
  found_xcodeproj = false
  Dir.glob File.join(xcode_project_path, '*.xcodeproj') do |xcodeproj_path|
    if !found_xcodeproj
      xcode_project_path = xcodeproj_path
      found_xcodeproj = true
    else
      puts "\033[0;31mFatal error: Found multiple xcodeproj ... Submit an issue for this ...\033[0m"
      exit 1
    end
  end
end

test_case_dir = ARGV[1]
if !File.exists?(File.join test_case_dir, 'Info.plist')
  puts "\033[0;31mFatal error: #{test_case_dir} doesn't contain test cases ...\033[0m"
  exit 1
end

# Go -------------------------------------------------------------------------------------------------------------------

puts '=' * 80
puts "Xcode Project file: \033[0;32m#{xcode_project_path}\033[0m"
puts "Test Cases dir: \033[0;32m#{test_case_dir}\033[m"
puts '=' * 80

project = Xcodeproj::Project.open xcode_project_path
TestInjecter.inject_ui_test project, test_case_dir
project.save
