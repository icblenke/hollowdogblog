# http://gist.github.com/269075
all:
	sudo gem install google-appengine
	sudo gem install rails -v "2.3.8"
	sudo gem install rails_tiny_ds
	sudo gem install activerecord-nulldb-adapter
	mkdir hollowdogblog; cd hollowdogblog
	curl -O http://appengine-jruby.googlecode.com/hg/demos/rails2/rails238_appengine.rb
	ruby rails238_appengine.rb tiny_ds
