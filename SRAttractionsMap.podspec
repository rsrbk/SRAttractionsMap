Pod::Spec.new do |s|
  s.name             = 'SRAttractionsMap'
  s.version          = '1.0.1'
  s.summary          = 'This is the map which contains attractions added on it.'
 
  s.description      = <<-DESC
The map contains attractions placed on it with the abillity to click and see the full description.
                       DESC
 
  s.homepage         = 'https://github.com/rsrbk/SRAttractionsMap.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { 'Ruslan Serebriakov' => 'rsrbk1@gmail.com' }
  s.source           = { :git => 'https://github.com/rsrbk/SRAttractionsMap.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '11.0'
  s.source_files = 'SRAttractionsMap/**/*.swift'
  s.resources = 'SRAttractionsMap/**/*.{xib, png}'
end
