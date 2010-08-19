# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hollowdogblog_session',
  :secret      => 'c4ede2ccbb4ee2a3f0149e4c45a954a9689522dbddd579e1dabd8487a66bd8eb9b8c701e3ddd28bd6d6c47007aa7d12d193b6620e1c0b720c0df5bcdabb0679a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
