defmodule HttpTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  test "requests carry their headers and bodies, and responses keep their raw body", %{
    bypass: bypass,
    url: url
  } do
    Bypass.expect(bypass, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]
      assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer token"]

      reply =
        case {conn.method, conn.request_path} do
          {"GET", "/invoices"} -> ""
          {"PUT", "/invoices"} -> body
          {"POST", "/invoices"} -> body
          {"DELETE", "/invoices/1"} -> ""
          {"POST", "/file"} -> body
          {"POST", "/token"} -> body
        end

      conn |> Plug.Conn.put_resp_content_type("application/json") |> Plug.Conn.resp(200, reply)
    end)

    headers = [{"Authorization", "Bearer token"}]

    assert %{status: 200, body: ""} = XeroXero.Utils.Http.get(url <> "/invoices", headers)

    assert %{status: 200, body: ~s({"Name":"a"})} =
             XeroXero.Utils.Http.put(url <> "/invoices", headers, %{Name: "a"})

    assert %{status: 200, body: ~s({"Name":"b"})} =
             XeroXero.Utils.Http.post(url <> "/invoices", headers, %{Name: "b"})

    assert %{status: 200} = XeroXero.Utils.Http.delete(url <> "/invoices/1", headers)

    path = Path.join(System.tmp_dir!(), "xeroxero_http_test.txt")
    File.write!(path, "file contents")

    assert %{status: 200, body: "file contents"} =
             XeroXero.Utils.Http.post_file(url <> "/file", headers, path)

    assert %{status: 200, body: "grant_type=refresh_token"} =
             XeroXero.Utils.Http.post_token(url <> "/token", headers, "grant_type=refresh_token")
  end

  test "a multipart upload names the file and decodes a JSON reply", %{bypass: bypass, url: url} do
    Bypass.expect_once(bypass, "POST", "/files", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      assert body =~ ~s(filename="report.pdf")
      assert body =~ "pdf bytes"

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(201, ~s({"Id":"f1"}))
    end)

    path = Path.join(System.tmp_dir!(), "xeroxero_upload.pdf")
    File.write!(path, "pdf bytes")

    assert %{"Id" => "f1", "http_status_code" => 201} =
             XeroXero.Utils.Http.post_multipart(url <> "/files", [], path, "report.pdf")
  end

  test "responses go through the response handler by status", %{bypass: bypass, url: url} do
    Bypass.expect(bypass, "GET", "/status/400", fn conn ->
      Plug.Conn.resp(conn, 400, ~s({"ErrorNumber":4,"Message":"bad"}))
    end)

    Bypass.expect(bypass, "GET", "/status/204", fn conn -> Plug.Conn.resp(conn, 204, "") end)

    Bypass.expect(bypass, "GET", "/status/401", fn conn ->
      Plug.Conn.resp(conn, 401, "oauth_problem=token_expired")
    end)

    handle = fn status ->
      (url <> "/status/#{status}")
      |> XeroXero.Utils.Http.get([])
      |> XeroXero.CoreApi.Utils.ResponseHandler.handle_response(
        XeroXero.CoreApi.Models.Tokens.Token
      )
    end

    assert %{ErrorNumber: 4, Message: "bad"} = handle.(400)
    assert %{status_code: 204, message: "No Content"} = handle.(204)
    assert %{status_code: 401, message: %{"oauth_problem" => "token_expired"}} = handle.(401)
  end
end
