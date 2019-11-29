require 'time'
require 'ed25519'

module Proof
  def create_proof
    {
      "type": "Ed25519Signature2018",
      "created": Time.now.utc.iso8601,
      "domain": "https://the-future.service.gov.uk",
      "proofPurpose": "authentication"
    }
  end

  def create_signature(payload, proof_options)
    tbs = hash_alg.digest(payload.to_s) + hash_alg.digest(proof_options.to_s)
    signed_payload = signing_key.sign(tbs)
    Base64.encode64(signed_payload)
  end

  def signing_key
    @_signing_key ||= Ed25519::SigningKey.generate
  end

  def hash_alg
    @_hash_alg ||= OpenSSL::Digest::SHA256.new
  end
end
