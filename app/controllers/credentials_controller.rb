class CredentialsController < ApplicationController
  include JwtAud, Proof

  def index
    render json: { hello: 'world' }
  end

  def issue
    render json: send(type).merge(create_proof(send(type)))
  rescue NoMethodError
    render json: { error: "Unknown type: #{type}" }, status: :bad_request
  end

  def issue_jwt
    render json: build_jwt(send(type), create_proof(send(type)))
  rescue NoMethodError
    render json: { error: "Unknown type: #{type}" }, status: :bad_request
  end

private

  def type
    @_type ||= params[:type]
  end

  def credential
    @_credential ||= VerifiableCredential.new.build
  end

  def presentation
    @_presentation ||= VerifiablePresentation.new(credential).build
  end
end
