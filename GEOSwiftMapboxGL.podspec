Pod::Spec.new do |s|
  s.name         = 'GEOSwiftMapboxGL'
  s.version      = '2.0.0'
  s.summary      = 'GEOSwiftMapboxGL is adds MapBoxGL to GEOSwift.'

  s.homepage     = 'https://github.com/GEOSwift/GEOSwiftMapboxGL'
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { 'GEOSwift team' => 'https://github.com/orgs/GEOSwift/people' }

  s.source       = { git: 'https://github.com/GEOSwift/GEOSwiftMapboxGL.git', tag: s.version }
  s.source_files = 'GEOSwiftMapboxGL/*.{h,m,swift}'

  s.platform     = :ios, '12.0'

  s.dependency 'GEOSwift', '7.2.0'
  s.dependency 'Mapbox-iOS-SDK'
end
