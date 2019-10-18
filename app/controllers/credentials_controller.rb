class CredentialsController < ApplicationController
  include JwtAud, Proof

  def index
    render json: { hello: 'world' }
  end

  def credential
    credential = VerifiableCredential.new.build
    render json: build_jwt(credential, create_proof(credential))
  end

  def presentation
    credential = VerifiableCredential.new.build
    presentation = VerifiablePresentation.new(credential).build
    render json: build_jwt(presentation, create_proof(presentation))
  end
end
