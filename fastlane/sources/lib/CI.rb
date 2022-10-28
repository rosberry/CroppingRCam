require_relative '../helper/git_helper.rb'
require 'json'

private_lane :rsb_trigger_ci_if_possible do |options|
  env_prefix = options.delete(:env_prefix)
  options[:env] = make_env(env_prefix)
  if !options[:env]
    UI.user_error!("You need to configure #{env_prefix} environments: APP_TOKEN, JOB_NAME, JENKINS_USER, JENKINS_USER_TOKEN")
    next
  end
  rsb_trigger_ci options
end  

private_lane :rsb_trigger_ci do |options|
  env = options.delete(:env)
  parameters = parameters(options).to_json

  url = 'http://' + env.jenkins_user + ':' + env.jenkins_user_token + '@' + env.domain + '/job/' + env.job_name + '/build'
  token_part = "--data-urlencode \"token=#{env.app_token}\""
  parameters_part = "--data-urlencode json='#{parameters}'"

  sh('curl -X POST ' + token_part + ' ' + parameters_part + ' ' + url)
end

def parameters(options)
  return {
    :parameter => options.map { |key, value|
      {:name => "#{key}", :value => value}
    }
  }
end

CIEnv = Struct.new(:app_token, :job_name, :jenkins_user, :jenkins_user_token, :domain)

def make_env(env_prefix)
  env = CIEnv.new(ENV["#{env_prefix}_JOB_AUTH_TOKEN"],
                  ENV["#{env_prefix}_JOB_NAME"],
                  ENV["#{env_prefix}_JENKINS_USER"],
                  ENV["#{env_prefix}_JENKINS_USER_TOKEN"],
                  ENV["#{env_prefix}_DOMAIN"] || 'cis.local:9090')

  all_fields_are_valid = env.app_token &&
                         env.job_name &&
                         env.jenkins_user &&
                         env.jenkins_user_token
  return env if all_fields_are_valid
end  
