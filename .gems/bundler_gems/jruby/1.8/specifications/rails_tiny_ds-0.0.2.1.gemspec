# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails_tiny_ds}
  s.version = "0.0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Woodell", "Takeru Sasaki"]
  s.date = %q{2010-08-05}
  s.description = %q{A Rails integration plugin for TinyDS}
  s.email = ["woodie@netpress.com", "sasaki.takeru@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "generators/rspec_td_model/td_dm_model_generator.rb", "generators/rspec_td_model/templates/model_spec.rb", "generators/td_model/td_model_generator.rb", "generators/td_model/templates/model.rb", "generators/td_model/templates/unit_test.rb", "lib/rails_tiny_ds.rb"]
  s.homepage = %q{http://github.com/woodie/tiny_ds/tree/master/adapters/rails_tiny_ds}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{This is an integration plugin for TinyDS, that provides ActiveRecord method calls for Rails 2.3.8 generated scaffold}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tiny_ds>, ["= 0.0.2"])
      s.add_runtime_dependency(%q<rails>, ["= 2.3.8"])
    else
      s.add_dependency(%q<tiny_ds>, ["= 0.0.2"])
      s.add_dependency(%q<rails>, ["= 2.3.8"])
    end
  else
    s.add_dependency(%q<tiny_ds>, ["= 0.0.2"])
    s.add_dependency(%q<rails>, ["= 2.3.8"])
  end
end
