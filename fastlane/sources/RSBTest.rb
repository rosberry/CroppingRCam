require 'mkmf'
require 'fileutils'

lane :rsb_test do |options|
  is_ci = options.delete(:ci)
  if is_ci
    rsb_trigger_ci_test options
  else
    rsb_trigger_test options
  end
end

private_lane :rsb_trigger_test do |options|
  test_project_url = ENV["TEST_PROJECT_GIT_URL"]
  test_project_name = repo_name(test_project_url)
  test_project_path = Dir.chdir("..") do
    setup_repo(test_project_name, test_project_url)
  end
  Dir.chdir("../#{test_project_path}") do
    sh('./build-ios.sh')
    rsb_setup_test_env
    sh('(appium > $(mktemp appium_output_XXXX)) & mvn -q test; for pid in $(pgrep -f appium); do kill -9 $pid; done')
  end  
end  

private_lane :rsb_trigger_ci_test do |options|
  options[:env_prefix] = "CI_TEST"
  rsb_trigger_ci_if_possible options
end

private_lane :rsb_setup_test_env do
  sh('brew install mvn') if !find_executable('mvn')
  sh('brew install appium') if !find_executable('appium')
end  

def repo_name(repo_url)
  name = repo_url.rpartition('/').last
  name_without_git = name.rpartition('.git').first
  name = name_without_git if !name_without_git.empty?
  return name
end  

def setup_repo(name, url)
  path = "./tests/#{name}"
  if Dir.exist?(path)
    is_clean = sh("git -C #{path} status -s") do |ok, res|
      res.empty?
    end
    UI.user_error!("#{path} git repository is dirty") if !is_clean
    sh("git -C #{path} pull")
  else
    sh("git clone #{url} #{path}")
  end
  return path
end  
