class ApplicationController < ActionController::API

    def index
      render json: { hello: 'world' }
    end
end
