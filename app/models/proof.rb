require 'time'
require 'ed25519'

module Proof
  def create_proof(payload)
    {
      "type": "Ed25519Signature2018",
      "created": Time.now.utc.iso8601,
      "challenge": SecureRandom.uuid,
      "domain": "https://the-future.service.gov.uk",
      "jws": Base64.encode64(signing_key.sign(payload.to_s)),
      "proofPurpose": "authentication"
    }
  end

  def signing_key
    @_signing_key ||= Ed25519::SigningKey.generate
  end
end
