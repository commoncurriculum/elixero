defmodule XeroXero do
  def create_client(token) do
    %XeroXero.Client{access_token: token.access_token}
  end
end
