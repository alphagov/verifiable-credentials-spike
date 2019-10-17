require 'time'
require 'jwt'
require 'ed25519'

class CredentialsController < ApplicationController

  def index
    @credential_payload = jwt_credential
    @credential_encoded_token = encode(@credential_payload)
    @credential_decoded_payload = decode(@credential_encoded_token)
    @presentation_payload = jwt_presentation
    @presentation_encoded_token = encode(@presentation_payload)
    @presentation_decoded_payload = decode(@presentation_encoded_token)
  end

private

  def encode(payload)
    JWT.encode(payload, rsa_private, "RS256")
  end

  def decode(token)
    JWT.decode(token, rsa_public, true, { algorithm: "RS256" })
  end

  def jwt_credential
    required.merge("vc": verifiable_credential.merge("proof": proof(verifiable_credential)))
  end

  def jwt_presentation
    required.merge("vp": targeted_presentation.merge("proof": proof(targeted_presentation)))
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

  def verifiable_credential
    @_verifiable_credential ||= {
      "@context": [
        "https://www.w3.org/2018/credentials/v1"
      ],
      "id": "https://example.org/credentials/1234",
      "type": "ExampleAddressCredential",
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

  def targeted_presentation
    @_targeted_presentation ||= {
      "@context": [
        "https://www.w3.org/2018/credentials/v1"
      ],
      "type": "VerifiablePresentation",
      "verifiableCredential": verifiable_credential
    }
  end

  def proof(credential)
    {
      "type": "Ed25519Signature2018",
      "created": Time.now.utc.iso8601,
      "challenge": SecureRandom.uuid,
      "domain": "https://the-future.service.gov.uk",
      "jws": Base64.encode64(signing_key.sign(credential.to_s)),
      "proofPurpose": "authentication"
    }
  end

  def rsa_private
    @_rsa_private ||= OpenSSL::PKey::RSA.generate(2048)
  end

  def rsa_public
    @_rsa_public ||= rsa_private.public_key
  end

  def signing_key
    @_signing_key ||= Ed25519::SigningKey.generate
  end

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
