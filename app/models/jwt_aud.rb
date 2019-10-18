require 'time'
require 'jwt'

module JwtAud
  def build_jwt(payload, proof)
    required.merge(payload.merge(proof))
  end

  def encode(unencoded_payload)
    JWT.encode(unencoded_payload, rsa_private, "RS256")
  end

  def decode(encoded_payload)
    JWT.decode(encoded_payload, rsa_public, true, { algorithm: "RS256" })
  end

  def required
    {
      "iss": "did:gov:#{SecureRandom.uuid}",  # issuer
      "jti": "urn:uuid:#{SecureRandom.uuid}",  # JWT ID
      "aud": "https://open-sesame.service.gov.uk",  # audience
      "nbf": Time.now.utc.to_i - 3600,  # not before
      "iat": Time.now.utc.to_i,  # issued at
      "exp": Time.now.utc.to_i + 4 * 3600,  # expiration
      "sub": SecureRandom.alphanumeric,  # subject
      "nonce": SecureRandom.uuid  # Is this needed?
    }
  end

  def rsa_private
    @_rsa_private ||= OpenSSL::PKey::RSA.generate(2048)
  end

  def rsa_public
    @_rsa_public ||= rsa_private.public_key
  end
end
