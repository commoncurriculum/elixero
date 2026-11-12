defmodule XeroXero do
  def get_request_token do
    response =
      case(Application.get_env(:xeroxero, :app_type)) do
        :private -> raise "Getting a request token is not applicable with Private applications."
        :public -> XeroXero.Public.get_request_token
        :partner -> XeroXero.Partner.get_request_token
      end

    case response do
      %{"http_status_code" => 200}  -> Map.merge(response, %{"auth_url" => XeroXero.Utils.Urls.authorise(response["oauth_token"])})
      _                             -> response
    end
  end

  def create_client do
    case(Application.get_env(:xeroxero, :app_type)) do
      :private -> %XeroXero.Client{app_type: :private, access_token: %{"oauth_token" => Application.get_env(:xeroxero, :consumer_key)}}
      :public -> raise "Nope. Access token required"
      :partner -> raise "Nope. Access token required"
    end
  end

  def create_client(token) do
    case(Application.get_env(:xeroxero, :app_type)) do
        :private -> %XeroXero.Client{app_type: :private, access_token: token.access_token}
        :public -> %XeroXero.Client{app_type: :public, access_token: token.access_token}
        :partner -> %XeroXero.Client{app_type: :partner, access_token: token.access_token}
      end
  end

  def create_client(request_token, verifier) do
    response =
      case(Application.get_env(:xeroxero, :app_type)) do
        :private -> raise "Approving an access token is not applicable with Private applications"
        :public -> XeroXero.Public.approve_access_token(request_token, verifier)
        :partner -> XeroXero.Partner.approve_access_token(request_token, verifier)
      end

    case response do
      %{"http_status_code" => 200}  -> create_client response
      _                             -> response
    end
  end

  def renew_client(client) do
    response =
      case(Application.get_env(:xeroxero, :app_type)) do
        :private -> raise "Renewing an access token is not applicable with Private applications"
        :public -> raise "Renewing an access token is not applicable with Public applications"
        :partner -> XeroXero.Partner.renew_access_token(client.access_token)
      end

    case response do
      %{"http_status_code" => 200}  -> create_client response
      _                             -> response
    end
  end
end
