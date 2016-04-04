platform :ios, '8.0'
use_frameworks!

target 'Echo' do
	pod "PulsingHalo"
	pod 'AFNetworking'
	pod 'ParseFacebookUtilsV4','~>1.11.0'
	pod 'Parse'
	pod 'Bolts'
	pod 'SCWaveformView'
	pod 'Waver'
	pod 'FBSDKCoreKit'
	pod 'FBSDKShareKit'
	pod 'FBSDKLoginKit'
	pod 'PageMenu'
	pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift2'
 	pod 'SnapKit'
end

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end

