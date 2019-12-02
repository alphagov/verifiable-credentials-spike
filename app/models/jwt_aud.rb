require 'time'
require 'jwt'
require 'net/http'
require 'uri'

module JwtAud
  DIRECTORY_DOMAIN = 'https://directory-prototype.cloudapps.digital'.freeze

  def build_jwt(payload)
    {
      "iss": "did:gov:#{SecureRandom.uuid}",  # issuer
      "jti": payload.fetch(:id, "urn:uuid:#{SecureRandom.uuid}"),  # JWT ID
      "aud": "https://open-sesame.service.gov.uk",  # audience
      "nbf": Time.now.utc.to_i - 3600,  # not before
      "iat": Time.now.utc.to_i,  # issued at
      "exp": Time.now.utc.to_i + 4 * 3600,  # expiration
      "sub": SecureRandom.alphanumeric,  # subject
      "nonce": SecureRandom.uuid  # Is this needed?
    }.merge({ "v#{type[0].downcase}": payload.without(:id) }) # remove ID is JTI takes its' place
  end

  def encode(unencoded_payload)
    JWT.encode(unencoded_payload, rsa_private, "RS256")
  end

  def decode(encoded_payload)
    JWT.decode(encoded_payload, rsa_public, true, { algorithm: "RS256" })
  end

  def rsa_private
    @_rsa_private ||= OpenSSL::PKey::RSA.new(idp_private_key)
  end

  def rsa_public
    @_rsa_public ||= rsa_private.public_key
  end

  def idp_private_key
    @_idp_private_key || begin
      uri = URI(File.join(DIRECTORY_DOMAIN, 'keys', params['idp-name']))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if Rails.env.production?
      request = Net::HTTP::Get.new(uri.request_uri)
      res = http.request(request)
      res.code == '200' ? JSON.parse(res.body)['signing'] : nil
    end
  end
end
