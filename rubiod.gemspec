version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'rubiod'
  s.version     = version
  s.summary     = 'Work with OpenDocument.'
  s.description = 'RubiOD is intended to provide cute interface ' \
                  'to work with OASIS Open Document Format files. ' \
                  'It relies on libxml-ruby.'

  s.required_ruby_version    = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.6'

  s.author   = 'Eugen "netoctone" Okhrimenko'
  s.email    = 'netoctone@gmail.com'
  s.homepage = 'http://github.com/netoctone/rubiod'

  s.bindir       = 'bin'
  s.files        = Dir['MIT-LICENCE', 'README.rdoc', 'VERSION', 'lib/**/*']
  s.require_path = 'lib'

  s.add_dependency 'libxml-ruby', '~> 2.0'
end
