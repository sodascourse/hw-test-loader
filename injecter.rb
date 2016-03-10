require 'xcodeproj'

#
# Returns a target which is either matched to the name or an app
#
# - project: Instance of Xcodeproj::Project
# - target_name_for_testing: specified target name to test, may be nil.
#
# returns: Instance of Xcodeproj::Project::Object::PBXNativeTarget.
#          The target to be test, if the name for testing is nil, then it's the first one
#
def get_target_for_testing(project, target_name_for_testing)
  project.targets.each do |target|
    if (target.product_type == 'com.apple.product-type.application' &&
        (target_name_for_testing.nil? || target_name_for_testing == target.name))
      return target
    end
  end
  return nil
end

#
# Create a target for inject test
#
# - project: Instance of Xcodeproj::Project
# - test_dir: path of directory to the test content. Must contain an Info.plist
# - test_target_name: the name of this inject test target
# - test_target_identifier: the identifier of this inject test target
#
# returns: Instance of Xcodeproj::Project::Object::PBXNativeTarget.
#
def create_inject_test_target(project, test_dir, test_target_name, test_target_identifier)
  test_target = project.new(Xcodeproj::Project::PBXNativeTarget)
  test_target.name = test_target_name
  test_target.product_name = test_target_name
  test_target.build_configuration_list = Xcodeproj::Project::ProjectHelper.configuration_list project, :ios, "9.0"

  product_ref = project.products_group.new_reference("#{test_target_name}.xctest", :built_products)
  product_ref.include_in_index = '0'
  product_ref.set_explicit_file_type
  test_target.product_reference = product_ref

  test_target_source_build_phase = project.new(Xcodeproj::Project::PBXSourcesBuildPhase)
  test_target.build_phases << test_target_source_build_phase
  test_target.build_phases << project.new(Xcodeproj::Project::PBXFrameworksBuildPhase)
  test_target.build_phases << project.new(Xcodeproj::Project::PBXResourcesBuildPhase)

  test_target.build_configuration_list.set_setting('INFOPLIST_FILE', File.join(test_dir, 'Info.plist'))
  test_target.build_configuration_list.set_setting('WRAPPER_EXTENSION', 'xctest')
  test_target.build_configuration_list.set_setting('TEST_HOST', '$(BUNDLE_LOADER)')
  test_target.build_configuration_list.set_setting('PRODUCT_BUNDLE_IDENTIFIER', test_target_identifier)
  test_target.build_configuration_list.set_setting('LD_RUNPATH_SEARCH_PATHS', [
    '$(inherited)',
    '@executable_path/Frameworks',
    '@loader_path/Frameworks',
  ])

  Dir.glob("#{test_dir.sub /\/$/, ''}/*.{swift,m}") do |test_file|
    file_ref = project.new_file test_file
    test_target_source_build_phase.add_file_reference file_ref
  end

  return test_target
end

module TestInjecter
  def self.inject_unit_test(project, test_dir,
                            test_target_name="InjectedTests", test_target_identifier='com.injected.unittest',
                            target_name_for_testing=nil, attatch_to_target=true)
    test_target = create_inject_test_target project, test_dir, test_target_name, test_target_identifier
    if test_target.nil?
      return nil
    end

    test_target.product_type = 'com.apple.product-type.bundle.unit-test'
    if attatch_to_target
      target_for_testing = get_target_for_testing project, target_name_for_testing
      if target_for_testing.nil?
        return nil
      end
      test_target.add_dependency target_for_testing
      test_target.build_configuration_list.set_setting('BUNDLE_LOADER',
        "$(BUILT_PRODUCTS_DIR)/#{target_for_testing.name}.app/#{target_for_testing.name}")
    end

    project.targets << test_target
    return test_target
  end

  def self.inject_ui_test(project, test_dir,
                          test_target_name="InjectedUITests", test_target_identifier='com.injected.uitest',
                          target_name_for_testing=nil)
    test_target = create_inject_test_target project, test_dir, test_target_name, test_target_identifier
    if test_target.nil?
      return nil
    end

    test_target.product_type = 'com.apple.product-type.bundle.ui-testing'

    target_for_testing = get_target_for_testing project, target_name_for_testing
    if target_for_testing.nil?
        return nil
      end
    test_target.add_dependency target_for_testing

    # Set target application of UI testing - I, Build settings panel
    test_target.build_configuration_list.set_setting 'TEST_TARGET_NAME', target_for_testing.name
    test_target.build_configuration_list.set_setting 'USES_XCTRUNNER', 'YES'

    # Set target application of UI testing - II, General panel
    target_attributes = project.root_object.attributes['TargetAttributes']
    if target_attributes.include? test_target.uuid
      test_target_attrs = target_attributes[test_target.uuid]
    else
      test_target_attrs = {}
      target_attributes[test_target.uuid] = test_target_attrs
    end
    test_target_attrs['TestTargetID'] = target_for_testing.uuid

    project.targets << test_target
    return test_target
  end
end
