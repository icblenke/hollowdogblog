# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tiny_ds}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Takeru Sasaki"]
  s.date = %q{2010-01-05}
  s.description = %q{Tiny datastore library for Google App Engine with JRuby}
  s.email = %q{sasaki.takeru@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "spec/basic_spec.rb", "spec/spec_helper.rb", "spec/spec_helper.rb~", "lib/tiny_ds/base.rb", "lib/tiny_ds/base.rb~", "lib/tiny_ds/base_tx.rb", "lib/tiny_ds/base_tx.rb~", "lib/tiny_ds/low_ds.rb", "lib/tiny_ds/low_ds.rb~", "lib/tiny_ds/property_definition.rb", "lib/tiny_ds/property_definition.rb~", "lib/tiny_ds/query.rb", "lib/tiny_ds/query.rb~", "lib/tiny_ds/validations.rb", "lib/tiny_ds/validations.rb~", "lib/tiny_ds/version.rb", "lib/tiny_ds.rb", "lib/tiny_ds.rb~", "lib/tinyds.rb~"]
  s.homepage = %q{http://github.com/takeru/tiny_ds}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Supports CRUD like a ActiveRecord or DataMapepr but with parent/child and entity-group-transaction}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<appengine-apis>, [">= 0"])
    else
      s.add_dependency(%q<appengine-apis>, [">= 0"])
    end
  else
    s.add_dependency(%q<appengine-apis>, [">= 0"])
  end
end
