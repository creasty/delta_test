require 'mkmf'

if RUBY_VERSION < '1.9.3'
  $stderr.puts("Ruby version #{RUBY_VERSION} is no longer supported. Please upgrade to 1.9.3 or higher")
  exit 1
end

{
  'RUBY_VERSION' => RUBY_VERSION.gsub('.', '')
}.each { |k, v| $defs.push << '-D%s=%s' % [k, v] }

create_makefile('delta_test')
