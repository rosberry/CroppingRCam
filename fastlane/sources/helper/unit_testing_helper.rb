# Run unit tests.
private_lane :rsb_run_tests_if_needed do |options|
  next unless need_unit_testing?
  ENV['SCAN_WORKSPACE'] = ENV['GYM_WORKSPACE']
  ENV['SCAN_PROJECT'] = ENV['GYM_PROJECT']
  options = {
    scheme: ENV['GYM_SCHEME'],
    configuration: ENV['CONFIGURATION_ADHOC'],
    devices: ENV['UNIT_TESTING_DEVICES'],
    code_coverage: true,
    skip_slack: !need_push_test_reports_to_slack?,
    test_without_building: options[:test_without_building] || false,
    fail_build: need_fail_build_whith_failed_tests?
  }
  if need_push_test_reports_to_slack?
    options[:slack_url] = ENV['SLACK_URL']
    options[:slack_message] = "Fastlane unit testing generated with `#{ENV['GYM_SCHEME']}` sheme."
  end
  scan(options)
end

# Stashing tests output.
private_lane :rsb_stash_save_tests_output do
  next unless need_unit_testing?
  sh('git stash save ./fastlane/test_output/report.html ./fastlane/test_output/report.junit')
end

# Applying stashed tests output.
private_lane :rsb_stash_pop_tests_output do
  next unless need_unit_testing?
  sh('git stash pop')
end

# Commit test output files.
private_lane :rsb_commit_tests_output do
  next unless need_unit_testing?
  git_add(path: %w[./fastlane/test_output/report.html ./fastlane/test_output/report.junit])
  git_commit(
    path: %w[./fastlane/test_output/report.html ./fastlane/test_output/report.junit],
    message: 'Complete tests'
  )
end

# Actualize repo with tests results
private_lane :rsb_actualize_git_after_testing do
  next unless need_unit_testing?
  rsb_stash_save_tests_output
  rsb_stash_pop_tests_output
  rsb_commit_tests_output
end

def need_unit_testing?
  ENV['NEED_UNIT_TESTING'] == 'true'
end

def need_fail_build_whith_failed_tests?
  fail_build = ENV['NEED_FAIL_BUILD_WITH_FAILED_TESTS']
  return fail_build == nil ? true : fail_build == 'true'
end

def need_push_test_reports_to_slack?
  push_to_slack = ENV['PUSH_TEST_REPORT_TO_SLACK']
  return push_to_slack == nil ? false : push_to_slack == 'true'
end
