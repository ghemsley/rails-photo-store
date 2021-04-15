Rails.application.config.session_store :cookie_store,
                                       key: (Rails.application.credentials.rails_session_secret || SecureRandom.base64(8))
