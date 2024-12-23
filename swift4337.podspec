Pod::Spec.new do |s|
  s.name = 'swift4337'
  s.version = '0.4.4'
  s.license = 'MIT'
  s.summary = 'swift4337'
  s.homepage = 'https://github.com/a-thomas/swift4337'
  s.authors = { 'Fred' => 'fred@cometh.io' }
  s.source = { :git => 'https://github.com/cometh-hq/swift4337', :tag => s.version.to_s }
  s.module_name = 'swift4337'

  s.swift_version = '5.10'
  s.ios.deployment_target = '15.6'

  s.source_files = 'Sources/swift4337/**/*.swift'

  s.dependency 'web3.swift', '~> 1.6.1'
  s.dependency 'SwiftCBOR', '~> 0.4.7'

end
