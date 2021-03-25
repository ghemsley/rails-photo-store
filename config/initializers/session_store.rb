Rails.application.config.session_store :cookie_store,
                                       key: (ENV['RAILS_SESSION_SECRET'] || SecureRandom.base64(8)), expire_after: nil
