# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'mysql2_query_filter-plugin-casual_log'
  spec.version       = '0.0.5'
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']
  spec.summary       = %q{Plug-in that colorize the bad query for Mysql2QueryFilter.}
  spec.description   = %q{Plug-in that colorize the bad query for Mysql2QueryFilter.}
  spec.homepage      = 'https://github.com/winebarrel/mysql2_query_filter-plugin-casual_log'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mysql2_query_filter'
  spec.add_dependency 'term-ansicolor'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
