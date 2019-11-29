require 'time'

class VerifiableCredential
  include Proof

  def build
    {
      "@context": [
        "https://www.w3.org/2018/credentials/v1"
      ],
      "type": ["VerifiableCredential", "ExampleAddressCredential"],
      "id": "https://example.org/credentials/1234",
      "issuer": "https://example.org/people#me",
      "issuanceDate": Time.now.utc.iso8601,
      "credentialSubject": {
        "id": "did:gov:#{SecureRandom.uuid}",
        "type": "Person",
        "address": {
          "type": "PostalAddress",
          "streetAddress": "123 Main St.",
          "addressLocality": "Blacksburg",
          "addressRegion": "VA",
          "postalCode": "24060",
          "addressCountry": "US"
        }
      }
    }
  end

  def attach_proof(payload)
    proof_options = create_proof
    proof_options.merge!("challenge": create_signature(payload, proof_options))
    payload.merge("proof": proof_options)
  end

private

  def example_address_context
    {
      "version": 1.1,
      "@protected": true,
      "ExampleAddressCredential": "https://example.org/ExampleAddressCredential", # could have also chosen a URI like urn:private-example:ExampleAddressCredential
      "Person": {
        "@id": "http://schema.org/Person",
        "@context": {
          "@version": 1.1,
          "@protected": true,
          "address": "http://schema.org/address"
        }
      },
      "PostalAddress": {
        "@id": "http://schema.org/PostalAddress",
        "@context": {
          "@version": 1.1,
          "@protected": true,
          "streetAddress": "http://schema.org/streetAddress",
          "addressLocality": "http://schema.org/addressLocality",
          "addressRegion": "http://schema.org/addressRegion",
          "postalCode": "http://schema.org/postalCode",
          "addressCountry": "http://schema.org/addressCountry"
        }
      }
    }
  end
end
