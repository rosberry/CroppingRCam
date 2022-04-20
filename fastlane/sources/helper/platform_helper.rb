$platform_options = {
  'ios' => {
    match_platform: 'ios',
    is_catalyst: false,
    profiles: %w[appstore development adhoc],
  },
  'ios_catalyst' => {
    gym_platfrom: 'ios',
    match_platform: 'ios',
    is_catalyst: true,
    profiles: %w[appstore development adhoc],
    destination: 'generic/platform=iOS'
  },
  'tvos' => {
    match_platform: 'tvos',
    is_catalyst: false,
    profiles: %w[appstore development adhoc]
  },
  'watchos' => {
    match_platform: 'watchos',
    is_catalyst: false,
    profiles: %w[appstore development adhoc]
  },
  'macos' => {
    match_platform: 'macos',
    is_catalyst: false,
    profiles: %w[appstore development developer_id]
  },
  'mac_catalyst' => {
    gym_platfrom: 'macos',
    match_platform: 'catalyst',
    is_catalyst: true,
    profiles: %w[appstore development developer_id],
    destination: 'platform=macOS,variant=Mac Catalyst'
  }
}

def fetch_platform(options)
  return options[:platform] || ENV['PLATFORM'] || 'ios'
end

def platforms_list_description
  return "Available platforms are: #{$platform_options.keys.map { |p| "`#{p}`" }.join(', ')}."
end
