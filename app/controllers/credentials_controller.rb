class CredentialsController < ApplicationController
  include JwtAud
  include Proof

  def index
    render json: { hello: 'world' }
  end

  def issue
    payload = send(type).build
    render json: send(type).attach_proof(payload)
  rescue NoMethodError
    render json: { error: "Unknown type: #{type}" }, status: :bad_request
  end

  def issue_jwt
    jwt_credential = build_jwt(send(type).build)
    render json: { jws: encode(jwt_credential), dummy_key: rsa_public.to_s }
  rescue NoMethodError
    render json: { error: "Unknown type: #{type}" }, status: :bad_request
  rescue TypeError
    render json: { error: "#{params['idp-name']} not in directory" }, status: :not_found
  end

  def verify
    verified = verify_signature?(params[:vc].to_unsafe_h)
    response_status = verified ? :ok : :bad_request
  rescue ArgumentError => e
    puts e.message
    response_status = :bad_request
  ensure
    render status: response_status
  end

private

  def type
    @_type ||= params[:type]
  end

  def credential
    @_credential ||= VerifiableCredential.new
  end

  def presentation
    @_presentation ||= VerifiablePresentation.new(credential.build)
  end
end
