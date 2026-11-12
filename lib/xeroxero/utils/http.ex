defmodule XeroXero.Utils.Http do
  @connection_timeout 330_000
  @default_headers [{"Accept", "application/json"}]

  def get(url, headers) do
    Req.get!(url, options(headers))
  end

  def put(url, headers, data_map) do
    Req.put!(
      url,
      [body: Jason.encode!(data_map)] ++
        options(headers ++ [{"Content-Type", "application/octet-stream"}])
    )
  end

  def post(url, headers, data_map) do
    Req.post!(
      url,
      [body: Jason.encode!(data_map)] ++
        options(headers ++ [{"Content-Type", "application/octet-stream"}])
    )
  end

  def post_token(url, headers, data_map) do
    Req.post!(url, [body: data_map] ++ options(headers))
  end

  def delete(url, headers) do
    Req.delete!(url, options(headers))
  end

  def post_multipart(url, headers, path_to_file, name) do
    # The Xero Files API grabs the filename out of the content-disposition header of the multipart file request.
    response =
      Req.post!(
        url,
        [form_multipart: [file: {File.stream!(path_to_file, 65_536), filename: name}]] ++
          options(headers)
      )

    case Req.Response.get_header(response, "content-type") do
      ["application/json" <> _ | _] ->
        response.body |> Jason.decode!() |> Map.put("http_status_code", response.status)

      _ ->
        response.body |> URI.decode_query() |> Map.put("http_status_code", response.status)
    end
  end

  def post_file(url, headers, path_to_file) do
    Req.post!(
      url,
      [body: File.read!(path_to_file)] ++
        options(headers ++ [{"Content-Type", MIME.from_path(path_to_file)}])
    )
  end

  defp options(headers) do
    [
      headers: headers ++ @default_headers,
      receive_timeout: @connection_timeout,
      decode_body: false,
      redirect: false,
      retry: false
    ]
  end
end
