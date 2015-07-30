Rails.configuration.cipher = EasyCipher::Cipher.new(Rails.configuration.cipher_key,
                                                    Rails.configuration.cipher_iv)