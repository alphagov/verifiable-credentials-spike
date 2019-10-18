class VerifiablePresentation
  def initialize(credential)
    @credential = credential
  end

  def build
    {
      "verifiablePresentation": {
        "@context": [
          "https://www.w3.org/2018/credentials/v1"
        ],
        "type": "VerifiablePresentation"
      }.merge(credential)
    }
  end

private

  attr_reader :credential

end

