defmodule ResponseHandlerTest do
  use ExUnit.Case

  alias XeroXero.CoreApi.Models
  alias XeroXero.CoreApi.Utils.ResponseHandler
  alias XeroXero.Utils.Http

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  test "each Xero reply becomes the model, exception or message the API returns", %{
    bypass: bypass,
    url: url
  } do
    invoice_id = "0032a5a7-1a8c-4a0f-a6a2-6b5c3c1d0e11"

    invoices =
      Jason.encode!(%{
        Id: "c0d8e8b1",
        Status: "OK",
        Invoices: [
          %{
            InvoiceID: invoice_id,
            InvoiceNumber: "INV-0042",
            Type: "ACCREC",
            Status: "AUTHORISED",
            Total: 1250.5,
            AmountDue: 1250.5,
            Reference: "Café ☕",
            Contact: %{Name: "Lincoln High"},
            LineItems: [%{Description: "Planbook", Quantity: 1.0, UnitAmount: 1250.5}]
          }
        ]
      })

    validation =
      Jason.encode!(%{
        ErrorNumber: 10,
        Type: "ValidationException",
        Message: "A validation exception occurred",
        Elements: [
          %{
            InvoiceNumber: "INV-0042",
            ValidationErrors: [%{Message: "Invoice # must be unique."}]
          }
        ]
      })

    replies = %{
      "/invoices" => {200, invoices},
      "/online" => {200, ~s({"OnlineInvoices":[{"OnlineInvoiceUrl":"https://in.xero.com/abc"}]})},
      "/token" =>
        {200,
         ~s({"access_token":"new-access","refresh_token":"new-refresh","expires_in":1800,"token_type":"Bearer","scope":"accounting.transactions offline_access"})},
      "/validation" => {400, validation},
      "/bad-request" =>
        {400, ~s({"ErrorNumber":14,"Type":"PostDataInvalidException","Message":"bad"})},
      "/error" =>
        {500,
         ~s({"ErrorNumber":500,"Type":"UnknownErrorException","Message":"An error occurred"})},
      "/empty" => {204, ""},
      "/unauthorized" => {401, "oauth_problem=token_expired&oauth_problem_advice=Expired"},
      "/missing" => {404, ""},
      "/rate-limited" => {429, "oauth_problem=rate%20limit%20exceeded"},
      "/unavailable" => {503, "down"}
    }

    Bypass.expect(bypass, fn conn ->
      {status, body} = Map.fetch!(replies, conn.request_path)
      conn |> Plug.Conn.put_resp_content_type("application/json") |> Plug.Conn.resp(status, body)
    end)

    get = fn path, model ->
      url |> Kernel.<>(path) |> Http.get([]) |> ResponseHandler.handle_response(model)
    end

    assert %Models.Invoices{
             Invoices: [
               %Models.Invoices.Invoice{
                 InvoiceID: ^invoice_id,
                 InvoiceNumber: "INV-0042",
                 Type: "ACCREC",
                 Status: "AUTHORISED",
                 Reference: "Café ☕",
                 Contact: %Models.Contacts.Contact{Name: "Lincoln High"},
                 LineItems: [%Models.Common.LineItem{Description: "Planbook"}]
               } = invoice
             ]
           } = get.("/invoices", Models.Invoices)

    assert Decimal.equal?(invoice."Total", Decimal.new("1250.5"))

    assert %Models.OnlineInvoices{
             OnlineInvoices: [
               %Models.OnlineInvoices.OnlineInvoice{OnlineInvoiceUrl: "https://in.xero.com/abc"}
             ]
           } = get.("/online", Models.OnlineInvoices)

    assert %Models.Invoices{
             Invoices: [
               %Models.Invoices.Invoice{
                 InvoiceNumber: "INV-0042",
                 ValidationErrors: [%Models.Common.Error{Message: "Invoice # must be unique."}]
               }
             ]
           } = get.("/validation", Models.Invoices)

    assert get.("/bad-request", Models.Invoices) ==
             %{ErrorNumber: 14, Type: "PostDataInvalidException", Message: "bad"}

    assert %Models.Exceptions.ApiException{
             ErrorNumber: 500,
             Type: "UnknownErrorException",
             Message: "An error occurred"
           } = get.("/error", Models.Invoices)

    assert get.("/empty", Models.Invoices) == %{status_code: 204, message: "No Content"}

    assert get.("/unauthorized", Models.Invoices) == %{
             status_code: 401,
             message: %{"oauth_problem" => "token_expired", "oauth_problem_advice" => "Expired"}
           }

    assert get.("/missing", Models.Invoices) == %{status_code: 404, message: %{}}

    assert get.("/rate-limited", Models.Invoices) == %{
             status_code: 429,
             message: %{"oauth_problem" => "rate limit exceeded"}
           }

    assert get.("/unavailable", Models.Invoices) == %{status_code: 503, message: %{"down" => ""}}

    assert %Models.Tokens.Token{
             access_token: "new-access",
             refresh_token: "new-refresh",
             expires_in: 1800,
             token_type: "Bearer"
           } =
             (url <> "/token")
             |> Http.post_token(
               [{"Content-Type", "application/x-www-form-urlencoded"}],
               "grant_type=refresh_token&refresh_token=old"
             )
             |> ResponseHandler.handle_response(Models.Tokens.Token)
  end
end
