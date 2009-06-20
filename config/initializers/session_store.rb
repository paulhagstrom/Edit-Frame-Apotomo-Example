# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_editframe_session',
  :secret      => 'dcff9d055b3f70119687ee1ef35d53f2f74a20a39a72b9500a53ce3abe451ca91adaa01d58d20bd844fa1327d8951843bdd1d34b851119411a4cdb7dc3d0da00'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
