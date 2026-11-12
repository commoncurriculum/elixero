defmodule HttpTest do
  use ExUnit.Case

  alias XeroXero.Utils.Http

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  defp record_requests(bypass, reply) do
    test = self()

    Bypass.expect(bypass, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn, length: 100_000_000)
      send(test, {:request, conn, body})
      reply.(conn, body)
    end)
  end

  defp status(response), do: Map.get(response, :status, Map.get(response, :status_code))

  defp headers(conn, names) do
    Enum.map(names, &{&1, Plug.Conn.get_req_header(conn, &1)})
  end

  @sent_headers ~w(accept authorization xero-tenant-id if-modified-since content-type content-length transfer-encoding accept-encoding)

  @tag :tmp_dir
  test "every verb sends its method, path, query, headers and body as given", %{
    bypass: bypass,
    url: url,
    tmp_dir: tmp_dir
  } do
    record_requests(bypass, fn conn, _body -> Plug.Conn.resp(conn, 200, "") end)

    auth = [{"Authorization", "Bearer token"}, {"xero-tenant-id", "tenant-1"}]

    invoice = %{
      Invoices: [%{Type: "ACCREC", Contact: %{Name: "Café ☕"}, LineItems: [%{Quantity: 2}]}]
    }

    json = Jason.encode!(invoice)
    form = "grant_type=refresh_token&refresh_token=abc%2Fdef"
    bytes = :binary.copy(:binary.list_to_bin(Enum.to_list(0..255)), 4)
    path = Path.join(tmp_dir, "attachment.bin")
    File.write!(path, bytes)

    query = "where=Status%3D%3D%22DRAFT%22%20AND%20Total%3E10&page=2"

    calls = [
      {fn ->
         Http.get(
           url <> "/api.xro/2.0/invoices?" <> query,
           auth ++ [{"if-modified-since", "2026-11-01T00:00:00"}]
         )
       end, "GET", "/api.xro/2.0/invoices", query, "",
       [
         {"accept", ["application/json"]},
         {"authorization", ["Bearer token"]},
         {"xero-tenant-id", ["tenant-1"]},
         {"if-modified-since", ["2026-11-01T00:00:00"]},
         {"content-type", []},
         {"content-length", []},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]},
      {fn -> Http.put(url <> "/api.xro/2.0/invoices", auth, invoice) end, "PUT",
       "/api.xro/2.0/invoices", "", json,
       [
         {"accept", ["application/json"]},
         {"authorization", ["Bearer token"]},
         {"xero-tenant-id", ["tenant-1"]},
         {"if-modified-since", []},
         {"content-type", ["application/octet-stream"]},
         {"content-length", [Integer.to_string(byte_size(json))]},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]},
      {fn -> Http.post(url <> "/api.xro/2.0/invoices/abc", auth, invoice) end, "POST",
       "/api.xro/2.0/invoices/abc", "", json,
       [
         {"accept", ["application/json"]},
         {"authorization", ["Bearer token"]},
         {"xero-tenant-id", ["tenant-1"]},
         {"if-modified-since", []},
         {"content-type", ["application/octet-stream"]},
         {"content-length", [Integer.to_string(byte_size(json))]},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]},
      {fn -> Http.post(url <> "/api.xro/2.0/invoices/abc/Email", auth, %{}) end, "POST",
       "/api.xro/2.0/invoices/abc/Email", "", "{}",
       [
         {"accept", ["application/json"]},
         {"authorization", ["Bearer token"]},
         {"xero-tenant-id", ["tenant-1"]},
         {"if-modified-since", []},
         {"content-type", ["application/octet-stream"]},
         {"content-length", ["2"]},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]},
      {fn -> Http.delete(url <> "/api.xro/2.0/items/abc", auth) end, "DELETE",
       "/api.xro/2.0/items/abc", "", "",
       [
         {"accept", ["application/json"]},
         {"authorization", ["Bearer token"]},
         {"xero-tenant-id", ["tenant-1"]},
         {"if-modified-since", []},
         {"content-type", []},
         {"content-length", []},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]},
      {fn ->
         Http.post_token(
           url <> "/connect/token",
           [
             {"Authorization", "Basic aWQ6c2VjcmV0"},
             {"Content-Type", "application/x-www-form-urlencoded"}
           ],
           form
         )
       end, "POST", "/connect/token", "", form,
       [
         {"accept", ["application/json"]},
         {"authorization", ["Basic aWQ6c2VjcmV0"]},
         {"xero-tenant-id", []},
         {"if-modified-since", []},
         {"content-type", ["application/x-www-form-urlencoded"]},
         {"content-length", [Integer.to_string(byte_size(form))]},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]},
      {fn ->
         Http.post_file(
           url <> "/api.xro/2.0/invoices/abc/Attachments/a%20b.pdf?includeonline=true",
           auth,
           path
         )
       end, "POST", "/api.xro/2.0/invoices/abc/Attachments/a%20b.pdf", "includeonline=true",
       bytes,
       [
         {"accept", ["application/json"]},
         {"authorization", ["Bearer token"]},
         {"xero-tenant-id", ["tenant-1"]},
         {"if-modified-since", []},
         {"content-type", ["application/octet-stream"]},
         {"content-length", [Integer.to_string(byte_size(bytes))]},
         {"transfer-encoding", []},
         {"accept-encoding", []}
       ]}
    ]

    Enum.each(calls, fn {call, method, request_path, query_string, body, expected_headers} ->
      assert status(call.()) == 200
      assert_received {:request, conn, ^body}

      assert {conn.method, conn.request_path, conn.query_string} ==
               {method, request_path, query_string}

      assert headers(conn, @sent_headers) == expected_headers
    end)
  end

  @tag :tmp_dir
  test "a large attachment is sent whole with its length", %{
    bypass: bypass,
    url: url,
    tmp_dir: tmp_dir
  } do
    record_requests(bypass, fn conn, _body -> Plug.Conn.resp(conn, 200, "") end)

    bytes = :crypto.strong_rand_bytes(5_000_000)
    path = Path.join(tmp_dir, "scan.pdf")
    File.write!(path, bytes)

    assert status(Http.post_file(url <> "/attachments/scan.pdf", [], path)) == 200
    assert_received {:request, conn, ^bytes}
    assert Plug.Conn.get_req_header(conn, "content-length") == ["5000000"]
    assert Plug.Conn.get_req_header(conn, "content-type") == ["application/pdf"]
    assert Plug.Conn.get_req_header(conn, "transfer-encoding") == []
  end

  test "responses come back with their status and raw body, unretried and unredirected", %{
    bypass: bypass,
    url: url
  } do
    pdf = :crypto.strong_rand_bytes(300_000)

    big_json =
      Jason.encode!(%{
        Invoices: Enum.map(1..20_000, &%{InvoiceNumber: "INV-#{&1}", Reference: "Café ☕"})
      })

    replies = %{
      "/json" =>
        {200, "application/json; charset=utf-8", ~s({"Invoices":[{"InvoiceNumber":"INV-1"}]})},
      "/xml" => {200, "text/xml", "<Response><Status>OK</Status></Response>"},
      "/pdf" => {200, "application/pdf", pdf},
      "/big" => {200, "application/json", big_json},
      "/created" => {201, "application/json", ~s({"Id":"1"})},
      "/empty" => {204, nil, ""},
      "/not-modified" => {304, nil, ""},
      "/bad" => {400, "application/json", ~s({"ErrorNumber":10})},
      "/unauthorized" =>
        {401, "text/html", "oauth_problem=token_expired&oauth_problem_advice=expired"},
      "/missing" => {404, "text/html", "The resource you're looking for cannot be found"},
      "/rate-limited" => {429, "text/html", "oauth_problem=rate%20limit%20exceeded"},
      "/error" =>
        {500, "application/json", ~s({"ErrorNumber":500,"Type":"UnknownErrorException"})},
      "/unavailable" => {503, "text/html", "<html>down</html>"},
      "/moved" => {301, nil, ""},
      "/found" => {302, nil, ""},
      "/see-other" => {303, nil, ""},
      "/temporary" => {307, nil, ""}
    }

    record_requests(bypass, fn conn, _body ->
      {status, content_type, body} = Map.fetch!(replies, conn.request_path)

      conn =
        if content_type,
          do: Plug.Conn.put_resp_header(conn, "content-type", content_type),
          else: conn

      if status in [301, 302, 303, 307] do
        conn
        |> Plug.Conn.put_resp_header("location", url <> "/elsewhere")
        |> Plug.Conn.resp(status, body)
      else
        Plug.Conn.resp(conn, status, body)
      end
    end)

    Enum.each(replies, fn {path, {status, _content_type, body}} ->
      response = Http.get(url <> path, [])
      assert {path, status(response), response.body} == {path, status, body}
      assert_received {:request, %{request_path: ^path}, _}
      refute_received {:request, _, _}
    end)
  end

  test "a chunked response is read whole", %{bypass: bypass, url: url} do
    Bypass.expect_once(bypass, "GET", "/chunked", fn conn ->
      conn = Plug.Conn.send_chunked(conn, 200)
      {:ok, conn} = Plug.Conn.chunk(conn, ~s|{"Invoices":[|)
      {:ok, conn} = Plug.Conn.chunk(conn, ~s|{"InvoiceNumber":"INV-1"}]}|)
      conn
    end)

    response = Http.get(url <> "/chunked", [])

    assert {status(response), response.body} ==
             {200, ~s({"Invoices":[{"InvoiceNumber":"INV-1"}]})}
  end

  test "a request to a server that isn't there raises", %{bypass: bypass, url: url} do
    Bypass.down(bypass)

    raised =
      try do
        Http.get(url <> "/invoices", [])
        :returned
      rescue
        _ -> :raised
      end

    assert raised == :raised
  end

  @tag :tmp_dir
  test "a multipart upload names the file, keeps its bytes, and decodes the reply", %{
    bypass: bypass,
    url: url,
    tmp_dir: tmp_dir
  } do
    bytes = :crypto.strong_rand_bytes(200_000)
    path = Path.join(tmp_dir, "scan.pdf")
    File.write!(path, bytes)

    replies = %{
      "/json" => {201, "application/json; charset=utf-8", ~s({"Id":"f1","Name":"report.pdf"})},
      "/form" => {401, "text/html", "oauth_problem=token_rejected"}
    }

    record_requests(bypass, fn conn, _body ->
      {status, content_type, body} = Map.fetch!(replies, conn.request_path)

      conn
      |> Plug.Conn.put_resp_header("content-type", content_type)
      |> Plug.Conn.resp(status, body)
    end)

    auth = [{"Authorization", "Bearer token"}]

    assert Http.post_multipart(url <> "/json", auth, path, "report.pdf") ==
             %{"Id" => "f1", "Name" => "report.pdf", "http_status_code" => 201}

    assert_received {:request, conn, body}

    assert ["multipart/form-data; boundary=" <> boundary] =
             Plug.Conn.get_req_header(conn, "content-type")

    assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer token"]

    assert Plug.Conn.get_req_header(conn, "content-length") == [
             Integer.to_string(byte_size(body))
           ]

    assert [_preamble, part, "--\r\n"] = String.split(body, "--" <> boundary)
    [part_headers, part_body] = String.split(part, "\r\n\r\n", parts: 2)
    part_headers = part_headers |> String.downcase() |> String.split("\r\n", trim: true)
    assert "content-type: application/pdf" in part_headers

    assert Enum.any?(
             part_headers,
             &(&1 =~ ~r/^content-disposition: form-data;.*filename="report.pdf"/)
           )

    assert part_body == bytes <> "\r\n"

    assert Http.post_multipart(url <> "/form", auth, path, "report.pdf") ==
             %{"oauth_problem" => "token_rejected", "http_status_code" => 401}
  end
end
