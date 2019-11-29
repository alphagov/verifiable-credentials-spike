require 'time'
require 'ed25519'

module Proof
  def create_proof
    {
      "type": "Ed25519Signature2018",
      "created": Time.now.utc.iso8601,
      "domain": "https://the-future.service.gov.uk",
      "verify_key": Base64.encode64(signing_key.verify_key.to_bytes),
      "proofPurpose": "authentication"
    }
  end

  def create_tbs(payload, proof_options)
    hash_alg.digest(payload) + hash_alg.digest(proof_options)
  end

  def create_signature(payload, proof_options, key=signing_key)
    tbs = create_tbs(payload, proof_options)
    signature = key.sign(tbs)
    Base64.encode64(signature)
  end

  def verify_signature?(payload)
    proof_options = payload["proof"]
    payload.delete("proof")
    signature = Base64.decode64(proof_options["challenge"])
    proof_options.delete("challenge")
    key = Ed25519::VerifyKey.new(Base64.decode64(proof_options["verify_key"]))
    tbs = create_tbs(payload.to_json, proof_options.to_json)
    key.verify(signature, tbs)
  end

  def signing_key
    @_signing_key ||= Ed25519::SigningKey.generate
  end

  def hash_alg
    @_hash_alg ||= OpenSSL::Digest::SHA256.new
  end
end
