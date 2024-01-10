platform :ios, '14.0'

inhibit_all_warnings!

target 'Ignited' do
    use_modular_headers!

    pod 'SQLite.swift', '~> 0.12.0'
    pod 'SDWebImage', '~> 3.8'
    pod 'SMCalloutView', '~> 2.1.0'
    pod 'KeychainAccess', '~> 4.2.0'

    pod 'DeltaCore', :path => 'Cores/DeltaCore'
    pod 'NESDeltaCore', :path => 'Cores/NESDeltaCore'
    pod 'SNESDeltaCore', :path => 'Cores/SNESDeltaCore'
    pod 'N64DeltaCore', :path => 'Cores/N64DeltaCore'
    pod 'GBCDeltaCore', :path => 'Cores/GBCDeltaCore'
    pod 'GBADeltaCore', :path => 'Cores/GBADeltaCore'
    pod 'DSDeltaCore', :path => 'Cores/DSDeltaCore'
    pod 'MelonDSDeltaCore', :path => 'Cores/MelonDSDeltaCore'
    pod 'Roxas', :path => 'External/Roxas'
    pod 'Harmony', :path => 'External/Harmony'
end

# Unlink DeltaCore to prevent conflicts with Systems.framework
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "Pods-Ignited"
            puts "Updating #{target.name} OTHER_LDFLAGS"
            target.build_configurations.each do |config|
		config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
                xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                new_xcconfig = xcconfig.sub('-l"DeltaCore"', '')
                File.open(xcconfig_path, "w") { |file| file << new_xcconfig }
            end
        end
    end
end
