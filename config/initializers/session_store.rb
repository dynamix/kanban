# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bankanrails_session',
  :secret      => '6e0220ef6dbf301c21e20ddd3633e698aad43bfe46db4aff38de670dcf4d678f4e0c6d77a9392f7baf4db008670e6349215a777ed33d53a1b24be1bbf138bbe8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
