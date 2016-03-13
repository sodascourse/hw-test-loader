require_relative './injecter.rb'
require_relative './scheme.rb'

# Check arguments ------------------------------------------------------------------------------------------------------

if ARGV.count != 3
  puts 'ERROR: Arguments should be `<source_path>` `<scheme>` `<test_case_dir>`'
  exit 1
end

source_path = ARGV[0]
scheme_name = ARGV[1]
scheme_path, scheme = Scheme.find_scheme source_path, scheme_name
target_name = scheme.launch_action.buildable_product_runnable.buildable_reference.target_name
xcode_project_path = File.absolute_path(
  File.join(scheme_path, '../../../..',
    scheme.launch_action.buildable_product_runnable.buildable_reference.target_referenced_container.split(':')[-1]))

test_case_dir = File.absolute_path ARGV[2]
if !File.exists?(File.join test_case_dir, 'Info.plist')
  puts "\033[0;31mFatal error: #{test_case_dir} doesn't contain test cases ...\033[0m"
  exit 1
end

# Go -------------------------------------------------------------------------------------------------------------------

puts '=' * 80
puts "Xcode Project file: \033[0;32m#{xcode_project_path}\033[0m"
puts "Target: \033[0;32m#{target_name}\033[m"
puts "Test Cases dir: \033[0;32m#{test_case_dir}\033[m"
puts '=' * 80

project = Xcodeproj::Project.open xcode_project_path
test_target = TestInjecter.inject_ui_test(project, test_case_dir, target_name_for_testing: target_name)
if test_target.nil?
  puts "\033[0;31mERROR: Cannot inject tests\033[m"
  exit 1
end
project.save

scheme.add_test_target test_target
scheme.save!
