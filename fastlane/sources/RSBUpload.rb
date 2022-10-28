require 'gym'
require 'fastlane_core'
require 'fileutils'

default_platform :ios

platform :ios do

  before_all do |lane, options|
    Actions.lane_context[SharedValues::FFREEZING] = options[:ffreezing]
    skip_docs
  end

  after_all do |lane|
    clean_build_artifacts
  end

  error do |lane, exception|
    clean_build_artifacts
    if $git_flow & $release_branch_name
      rsb_remove_release_branch(
        name: $release_branch_name
      )
    end
  end

  ### LANES

  lane :rsb_fabric do |options|
    rsb_upload(
      configurations: [:fabric],
      platform: options[:platform],
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci],
      is_release: false,
      skip_match_validation: options[:skip_match_validation],
      skip_match: options[:skip_match]
    )
  end

  lane :rsb_fabric_testflight do |options|
    rsb_upload(
      configurations: [:testflight, :fabric],
      platform: options[:platform],
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci],
      is_release: true,
      skip_match_validation: options[:skip_match_validation],
      skip_match: options[:skip_match]
    )
  end

  lane :rsb_testflight do |options|
    rsb_upload(
      configurations: [:testflight],
      platform: options[:platform],
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci],
      is_release: true,
      skip_match_validation: options[:skip_match_validation],
      skip_match: options[:skip_match]
    )
  end

  lane :rsb_firebase_testflight do |options|
    rsb_upload(
      configurations: [:testflight, :firebase],
      platform: options[:platform],
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci],
      is_release: true,
      skip_match_validation: options[:skip_match_validation],
      skip_match: options[:skip_match]
    )
  end

  lane :rsb_firebase do |options|
    rsb_upload(
      configurations: [:firebase],
      platform: options[:platform],
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci],
      is_release: false,
      skip_match_validation: options[:skip_match_validation],
      skip_match: options[:skip_match]
    )
  end

  lane :rsb_desktop_archive do |options|
    rsb_upload(
      configurations: [:desktop_archive],
      platform: options[:platform],
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci],
      is_release: false,
      skip_match_validation: options[:skip_match_validation],
      skip_match: options[:skip_match]
    )
  end

  lane :rsb_upload do |options|
    upload_via_ci = !!options[:ci]
    $git_flow = options[:git_flow] == nil ? true : options[:git_flow]
    git_build_branch = options[:git_build_branch] == nil ? rsb_current_git_branch : options[:git_build_branch]
    configurations = options[:configurations].kind_of?(Array) ?
      options[:configurations] :
      options[:configurations].split(",").map { |configuration| configuration.to_sym }
    is_release = options[:is_release]

    if upload_via_ci
      rsb_trigger_ci_build(
        configurations: options[:configurations].join(","),
        git_flow: options[:git_flow] == nil ? 'true' : options[:git_flow],
        git_build_branch: $git_flow ? 'develop' : git_build_branch,
        skip_match: options[:skip_match] || 'false',
        skip_match_validation: options[:skip_match_validation] || 'false',
        is_release: options[:is_release] || 'false',
        ffreezing: options[:ffreezing] || 'false'
      )
      next
    end

    if is_ci?
      setup_jenkins
    end

    ensure_git_status_clean
    $release_branch_name = rsb_release_branch_name(options[:is_release])

    ready_tickets = rsb_search_jira_tickets(
      statuses: [rsb_jira_status[:ready]]
    )

    if $git_flow
      rsb_git_checkout('develop')
      rsb_git_pull
      rsb_start_release_branch(
        name: $release_branch_name
      )
    else
      rsb_git_checkout(git_build_branch)
      rsb_git_pull
    end

    if is_release
      precheck_if_needed
      check_no_debug_code_if_needed
    end

    if need_fail_build_whith_failed_tests?
      rsb_run_tests_if_needed
      rsb_actualize_git_after_testing
    end

    slack_release_notes = rsb_slack_release_notes(ready_tickets)
    raw_release_notes = rsb_jira_tickets_description(ready_tickets)

    should_move_jira_tickets = true
    platform = fetch_platform(options)
    platform_options = $platform_options[platform]
    if platform_options == nil
      UI.user_error!("Invalid platform provided: `#{platform}`. #{platforms_list_description}")
    end
    configurations.each do |configuration_name|
      configuration = upload_configurations[configuration_name]
      if platform_options[:is_catalyst] && !configuration[:is_catalyst_suppored]
        UI.important("`#{configuration_name}` is not support catalyst app distribution")
      elsif configuration_name == "desktop_archive" && platform_options[:gym_platfrom] != "macos"
        UI.important("`#{platform}` is not desktop platform")
      else
        if !options[:skip_match] && ENV['MATCH_ENABLED'] != 'false'
          rsb_update_provisioning_profiles(
            type: configuration[:profile_type],
            skip_match_validation: options[:skip_match_validation]
          )
        end
        rsb_build_and_archive(
          configuration: configuration[:build_configuration],
          platform: platform,
          type: configuration[:export_type]
        )

        configuration[:lane].call(
          notes: raw_release_notes
        )

        if should_move_jira_tickets
          rsb_move_jira_tickets(
            tickets: ready_tickets,
            transition: rsb_jira_transition[:test_build]
          )
          should_move_jira_tickets = false
        end

        rsb_post_to_slack_channel(
          configuration: configuration[:build_configuration],
          release_notes: slack_release_notes,
          destination: configuration[:name]
        )
        if !need_fail_build_whith_failed_tests?
          rsb_run_tests_if_needed(test_without_building: true)
          rsb_actualize_git_after_testing
        end
      end

      if is_ci?
        reset_git_repo(
          force: true,
          exclude: ['Carthage/Build', 'Carthage/Checkouts']
        )
      end

      changelog_release_notes = rsb_changelog_release_notes(ready_tickets)
      rsb_update_changelog(
        release_notes: changelog_release_notes,
        commit_changes: true
      )

      rsb_update_build_number
      rsb_commit_build_number_changes

      if $git_flow
        rsb_end_release_branch(
          name: $release_branch_name
        )
      end

      rsb_add_git_tag($release_branch_name)
      rsb_git_push(tags: true)
    end
  end

  lane :rsb_add_devices do
    file_path = prompt(
      text: 'Enter the file path: '
    )

    register_devices(
      devices_file: file_path
    )
  end

  lane :rsb_changelog do |options|
    ready_tickets = rsb_search_jira_tickets(
      statuses: [rsb_jira_status[:ready]]
    )
    changelog_release_notes = rsb_changelog_release_notes(ready_tickets)
    rsb_update_changelog(
      release_notes: changelog_release_notes,
      commit_changes: false
    )
  end

  ### PRIVATE LANES

  private_lane :rsb_build_and_archive do |options|
    configuration = options[:configuration]
    type = options[:type]
    rsb_update_extensions_build_and_version_numbers_according_to_main_app
    begin
      before_gym(options)
    rescue
      UI.important('No `before_gym` hooks found, skipping')
    end

    is_adhoc = configuration == ENV['CONFIGURATION_ADHOC']
    include_bitcode = is_adhoc == false
    export_options = is_adhoc ? {
        uploadBitcode: false,
        uploadSymbols: true,
        compileBitcode: false,
        method: type
    } : {
      method: type
    }

    platform = fetch_platform(options)
    platform_options = $platform_options[platform]
    if platform_options == nil
      UI.user_error!("Invalid platform provided: `#{platform}`. #{platforms_list_description}")
    end
    skip_package = type == 'development'
    if platform_options[:is_catalyst]
      app_path = gym(
        configuration: configuration,
        include_bitcode: include_bitcode,
        export_options: export_options,
        catalyst_platform: platform_options[:gym_platfrom],
        destination: platform_options[:destination],
        skip_package_pkg: skip_package
      )
    else
      app_path = gym(
        configuration: configuration,
        include_bitcode: include_bitcode,
        export_options: export_options,
        skip_package_pkg: skip_package
      )
    end
    if skip_package
      export_zip({app_path: app_path})
    end
  end

  # It is temporarry workaround of fastlane `package_app` for macos
  # https://github.com/fastlane/fastlane/issues/15963
  private_lane :export_zip do |options|
    app_name = options[:app_path].split('/').last
    UI.error(app_name)
    archive_path = Gym.cache[:archive_path]
    command = Gym::PackageCommandGenerator.generate
    sh(command)
    unsigned_app_path = "../#{app_name}"
    FileUtils.rm_rf(unsigned_app_path) if File.exist?(unsigned_app_path)
    export_path = File.expand_path(ENV['EXPORT_PATH'] == nil ? '~/Documents' : ENV['EXPORT_PATH'])
    dir_name = archive_path.split('/').last
    dir_name[".xcarchive"] = ""
    result_dir = "#{export_path}/#{dir_name}".gsub(" ", "\ ")
    FileUtils.rm_rf(result_dir) if File.exist?(result_dir)
    FileUtils.mkdir_p(result_dir)
    signed_app_path = "#{Gym.cache[:temporary_output_path]}/#{app_name}"
    FileUtils.copy_entry(signed_app_path, "#{result_dir}/#{app_name}".gsub(" ", "\ "))
    dSYM_path = "../#{app_name}.dSYM.zip".gsub(" ", "\ ")
    FileUtils.mv(dSYM_path, "#{result_dir}/#{app_name}.dSYM.zip") if File.exist?(dSYM_path)
    FileUtils.rm(dSYM_path) if File.exist?(dSYM_path)
    FileUtils.cd(export_path) {
      sh("zip -r \"#{dir_name}.zip\" \"#{dir_name}\"")
    }
    FileUtils.rm_rf(result_dir) if File.exist?(result_dir)
    UI.important("Exported zip archive location is #{export_path}/#{dir_name}.zip")
  end

  private_lane :rsb_send_to_crashlytics do |options|
    groups = [ENV['CRASHLYTICS_GROUP']]
    crashlytics(
      groups: groups,
      notes: options[:notes]
    )
  end

  private_lane :rsb_send_to_firebase do |options|
    groups = ENV['FIREBASE_GROUP']
    firebase_cli_path = ENV['FIREBASE_CLI_PATH']
    firebase_app_distribution(
      ipa_path: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
      app: firebase_app_id,
      groups: groups,
      release_notes: options[:notes],
      firebase_cli_path: firebase_cli_path
    )
  end

  private_lane :rsb_send_to_testflight do |options|
    pilot(
      ipa: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
      skip_submission: true,
      skip_waiting_for_build_processing: true
    )
  end

  private_lane :rsb_dummy_upload do |options|
    # dummy
  end

  private_lane :rsb_upload_to_google_drive do |options|
    # TODO: Upload prepared archive to Google Drive
  end

  private_lane :rsb_trigger_ci_build do |options|
    options[:env_prefix] = "CI"
    rsb_trigger_ci_if_possible options
  end

end

module SharedValues
  FFREEZING = :FFREEZING
end

def ffreezing?
  Actions.lane_context[SharedValues::FFREEZING] == true
end

def precheck_if_needed
  precheck(app_identifier: ENV['BUNDLE_ID']) if ENV['NEED_PRECHECK'] == 'true'
end

def check_no_debug_code_if_needed
  ensure_no_debug_code(text: 'TODO|FIXME', path: 'Classes/', extension: '.swift') if ENV['CHECK_DEBUG_CODE'] == 'true'
end

def upload_configurations
  {
    :fabric => {
      name: "Fabric",
      build_configuration: ENV['CONFIGURATION_ADHOC'],
      profile_type: :adhoc,
      lane: runner.lanes[:ios][:rsb_send_to_crashlytics],
      export_type: 'ad-hoc',
      is_catalyst_suppored: false
    },
    :firebase => {
      name: "Firebase",
      build_configuration: ENV['CONFIGURATION_ADHOC'],
      profile_type: :adhoc,
      lane: runner.lanes[:ios][:rsb_send_to_firebase],
      export_type: 'ad-hoc',
      is_catalyst_suppored: false
    },
    :testflight => {
      name: "Testflight",
      build_configuration: ENV['CONFIGURATION_APPSTORE'],
      profile_type: :appstore,
      lane: runner.lanes[:ios][:rsb_send_to_testflight],
      export_type: 'app-store',
      is_catalyst_suppored: true
    },
    :desktop_archive => {
      name: "Desktop Arcive",
      build_configuration: ENV['CONFIGURATION_ADHOC'],
      profile_type: :development,
      lane: runner.lanes[:ios][:rsb_send_to_slack],
      export_type: 'development',
      is_catalyst_suppored: true
    },
    :dummy => {
      name: "Dummy",
      build_configuration: ENV['CONFIGURATION_APPSTORE'],
      profile_type: :appstore,
      lane: runner.lanes[:ios][:rsb_upload_to_google_drives],
      export_type: 'app-store',
      is_catalyst_suppored: false
    }
  }
end
