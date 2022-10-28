require 'json'
$xcode_json = nil

def xcode_setting(setting_title, configuration)
  if $xcode_json != nil
    return $xcode_json[setting_title]
  end
  string = sh("xcodebuild -showBuildSettings -workspace \"../#{ENV["GYM_WORKSPACE"]}\" -scheme \"#{ENV["GYM_SCHEME"]}\" -configuration #{configuration} -json 2>/dev/null")
  $xcode_json = JSON.parse(string)
  if $xcode_json.kind_of?(Array) && !$xcode_json.empty?
    $xcode_json = $xcode_json[0]
  end
  $xcode_json = $xcode_json['buildSettings']
  return $xcode_json[setting_title]
end
