if Rails.env.production?
  dpn_keys = %w{
    DPN_DB_NAME
    DPN_DB_ADAPTER
    DPN_DB_PORT
    DPN_DB_HOSTNAME
    DPN_DB_USER
    DPN_DB_PASSWORD
    DPN_NAMESPACE
    DPN_API_ROOT
    DPN_STAGING_DIR
    DPN_REPO_DIR
    DPN_TRANSFER_PRIVATE_KEY
    DPN_CIPHER_KEY
    DPN_CIPHER_IV
    DPN_SECRET_KEY
    DPN_SALT
  }

  dpn_keys.each do |key|
    if ENV[key].blank?
      raise ArgumentError, "Missing environment variable #{key}, see .env.production.example"
    end
  end
end
