class VerifiablePresentation
  include Proof

  def initialize(credential)
    @credential = credential
  end

  def build
    {
      "@context": [
        "https://www.w3.org/2018/credentials/v1"
      ],
      "type": "VerifiablePresentation",
      "id": "https://example.org/credentials/1234",
      "verifiableCredential": [credential]
    }
  end

  def attach_proof(payload)
    payload.merge("proof": [create_proof(payload)])
  end

private

  attr_reader :credential

end

