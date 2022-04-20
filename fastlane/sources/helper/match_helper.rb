def rsb_match_for_type(options)

  match_git_url = ENV['MATCH_GIT_URL']
  match_git_branch = ENV['MATCH_GIT_BRANCH']

  if !match_git_url || !match_git_branch
    UI.user_error!('You need to configure the match environments: MATCH_GIT_URL, MATCH_GIT_BRANCH')
  end

  app_identifier = options[:app_identifier]
  type = options[:type]
  force = options[:force]
  readonly = options[:readonly]
  clone_directly = options[:clone_directly]
  skip_validation = options[:skip_validation]
  platform = fetch_platform(options)
  skip_validation = options[:skip_validation]
  platform_options = $platform_options[platform]
  if platform_options == nil
    UI.user_error!("Invalid platform provided: `#{platform}'`. #{platforms_list_description}")
  end
  is_valid_type = platform_options[:profiles].include?(type)
  match_platform = platform_options[:match_platform]

  if !is_valid_type then
    UI.important('Skipping: `' + type + '` is not valid profile type for the platform `'+ platform + '`.')
  elsif skip_validation
    rsb_use_stored_signing_assets(options)
  else
    match(
      type: type,
      app_identifier: app_identifier,
      force: force,
      readonly: readonly,
      skip_docs: true,
      clone_branch_directly: clone_directly,
      shallow_clone: true,
      platform: match_platform
    )
  end
end

def rsb_use_stored_signing_assets(options)
  url = ENV['MATCH_GIT_URL']
  branch = ENV['MATCH_GIT_BRANCH']

  storage = Match::Storage.for_mode("git", { git_url: url, shallow_clone: false, git_branch: branch, clone_branch_directly: false})
  storage.download

  encryption = Match::Encryption.for_storage_mode("git", { git_url: url, working_directory: storage.working_directory})
  encryption.decrypt_files

  target_directory = storage.working_directory

  keys = Dir.glob(File.join(target_directory, "**", "*.p12"))
  certs = Dir.glob(File.join(target_directory, "**", "*.cer"))
  keychain = "login.keychain"

  for cert in certs
    if FastlaneCore::CertChecker.installed?(cert, in_keychain: keychain)
      UI.verbose("Certificate '#{File.basename(cert)}' is already installed on this machine")
    else
      Match::Utils.import(cert, keychain, password: nil)
    end
  end

  for key in keys
    Match::Utils.import(key, keychain, password: nil)
  end

  profiles = Dir.glob(File.join(target_directory, "**", "*.mobileprovision"))
  for profile in profiles
    FastlaneCore::ProvisioningProfile.install(profile)
  end
end

def rsb_call_before_match(options)
  begin
    before_match(options)
  rescue
    UI.important('No `before_match` hooks found, skipping')
  end
end
