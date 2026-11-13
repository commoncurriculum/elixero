defmodule CoreApiTest do
  use ExUnit.Case

  alias XeroXero.CoreApi
  alias XeroXero.CoreApi.Models

  @tenant_id "tenant-1"
  @json "application/json; charset=utf-8"

  @resources [
    {CoreApi.Accounts, "accounts", [:find, :find_one, :filter, :create, :update, :delete]},
    {CoreApi.BankTransactions, "banktransactions", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.BankTransfers, "banktransfers", [:find, :find_one, :filter, :create]},
    {CoreApi.BrandingThemes, "brandingthemes", [:find, :find_one, :filter]},
    {CoreApi.ContactGroups, "contactgroups", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Contacts, "contacts", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.CreditNotes, "creditnotes", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Currencies, "currencies", [:find, :filter]},
    {CoreApi.Employees, "employees", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.ExpenseClaims, "expenseclaims", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Invoices, "invoices", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Items, "items", [:find, :find_one, :filter, :create, :update, :delete]},
    {CoreApi.Journals, "journals", [:find, :find_one, :filter]},
    {CoreApi.LinkedTransactions, "linkedtransactions",
     [:find, :find_one, :filter, :create, :update, :delete]},
    {CoreApi.ManualJournals, "manualjournals", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Organisations, "organisations", [:find]},
    {CoreApi.Overpayments, "overpayments", [:find, :find_one, :filter]},
    {CoreApi.Payments, "payments", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Prepayments, "prepayments", [:find, :find_one, :filter]},
    {CoreApi.PurchaseOrders, "purchaseorders", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.Receipts, "receipts", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.RepeatingInvoices, "repeatinginvoices", [:find, :find_one, :filter]},
    {CoreApi.Reports, "reports", [:find]},
    {CoreApi.TaxRates, "taxrates", [:find, :find_one, :filter, :create, :update]},
    {CoreApi.TrackingCategories, "trackingcategories",
     [:find, :find_one, :filter, :create, :update, :delete]},
    {CoreApi.Users, "users", [:find, :find_one, :filter]}
  ]

  setup do
    bypass = Bypass.open()
    url = "http://localhost:#{bypass.port}"
    Application.put_env(:xeroxero, :base_url, url <> "/")
    Application.put_env(:xeroxero, :token_url, url <> "/connect")
    Application.put_env(:xeroxero, :app_type, :private)

    on_exit(fn ->
      Enum.each([:base_url, :token_url, :app_type], &Application.delete_env(:xeroxero, &1))
    end)

    client = %XeroXero.Client{
      app_type: :private,
      access_token: "access-token",
      xero_tenant_id: @tenant_id
    }

    {:ok, bypass: bypass, url: url, client: client}
  end

  defp serve(bypass, routes) do
    test = self()

    Bypass.expect(bypass, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn, length: 100_000_000)
      send(test, {:request, conn, body})

      case Map.fetch(routes, {conn.method, conn.request_path, conn.query_string}) do
        {:ok, {status, response_headers, reply}} ->
          response_headers
          |> Enum.reduce(conn, fn {name, value}, conn ->
            Plug.Conn.put_resp_header(conn, name, value)
          end)
          |> Plug.Conn.resp(status, reply)

        :error ->
          Plug.Conn.resp(conn, 418, "no route")
      end
    end)
  end

  defp route(c), do: {{c.method, c.path, c.query}, c.reply}

  defp run_cases(bypass, cases) do
    serve(bypass, Map.new(cases, &route/1))

    failures =
      Enum.flat_map(cases, fn c ->
        try do
          result = c.call.()
          assert_received {:request, conn, body}
          refute_received {:request, _, _}

          assert {conn.method, conn.request_path, conn.query_string} ==
                   {c.method, c.path, c.query}

          assert body == c.body

          assert Enum.map(c.headers, fn {name, _} ->
                   {name, Plug.Conn.get_req_header(conn, name)}
                 end) ==
                   c.headers

          c.expect.(result)
          []
        rescue
          error -> [{c.name, Exception.message(error)}]
        after
          flush_requests()
        end
      end)

    assert failures == []
  end

  defp flush_requests do
    receive do
      {:request, _, _} -> flush_requests()
    after
      0 -> :ok
    end
  end

  defp api(path), do: "/api.xro/2.0/" <> path

  defp private_headers(content_type) do
    [
      {"authorization", ["Bearer access-token"]},
      {"xero-tenant-id", [@tenant_id]},
      {"accept", ["application/json"]},
      {"content-type", content_type}
    ]
  end

  defp model_reply(model) do
    key = hd(model.__schema__(:embeds))
    {200, [{"content-type", @json}], Jason.encode!(%{key => [%{}]})}
  end

  defp expect_model(model) do
    key = hd(model.__schema__(:embeds))

    fn result ->
      assert %{__struct__: ^model} = result
      assert [%{}] = Map.fetch!(result, key)
    end
  end

  defp resource_case(module, resource, op, client) do
    model = Module.concat(Models, module |> Module.split() |> List.last())
    key = hd(model.__schema__(:embeds))
    payload = %{key => [%{"Name" => "Café ☕", "Code" => "A&B 1"}]}
    json = Jason.encode!(payload)
    filter = %{query_filters: [{"where", ~s(Name=="A B")}, {"order", "Name"}]}

    {call, method, path, query, body} =
      case op do
        :find ->
          {fn -> module.find(client) end, "GET", api(resource), "", ""}

        :find_one ->
          {fn -> module.find(client, "id-1") end, "GET", api(resource <> "/id-1"), "", ""}

        :filter ->
          {fn -> module.filter(client, filter) end, "GET", api(resource),
           "where=Name%3D%3D%22A%20B%22&order=Name", ""}

        :create ->
          {fn -> module.create(client, payload) end, "PUT", api(resource), "", json}

        :update ->
          {fn -> module.update(client, "id-1", payload) end, "POST", api(resource <> "/id-1"), "",
           json}

        :delete ->
          {fn -> module.delete(client, "id-1") end, "DELETE", api(resource <> "/id-1"), "", ""}
      end

    %{
      name: "#{inspect(module)}.#{op}",
      call: call,
      method: method,
      path: path,
      query: query,
      body: body,
      headers: private_headers(if body == "", do: [], else: ["application/octet-stream"]),
      reply: model_reply(model),
      expect: expect_model(model)
    }
  end

  test "every resource's find, filter, create, update and delete send their request and return the model",
       %{bypass: bypass, client: client} do
    cases =
      Enum.flat_map(@resources, fn {module, resource, ops} ->
        Enum.map(ops, &resource_case(module, resource, &1, client))
      end)

    run_cases(bypass, cases)
  end

  @tag :tmp_dir
  test "the resource-specific calls send their request and return their result", %{
    bypass: bypass,
    client: client,
    tmp_dir: tmp_dir
  } do
    allocations = %{Allocations: [%{Amount: 10.5, Invoice: %{InvoiceID: "inv-1"}}]}
    contacts = %{Contacts: [%{ContactID: "contact-1"}]}
    option = %{Options: [%{Name: "Café ☕"}]}
    attachment = :binary.copy(:binary.list_to_bin(Enum.to_list(0..255)), 4000)
    attachment_path = Path.join(tmp_dir, "scan.pdf")
    File.write!(attachment_path, attachment)

    filter = %{
      query_filters: [{"where", ~s(Status=="DRAFT")}],
      modified_since: "2026-11-01T00:00:00"
    }

    cases = [
      %{
        name: "Invoices.email",
        call: fn -> CoreApi.Invoices.email(client, "id-1") end,
        method: "POST",
        path: api("invoices/id-1/Email"),
        query: "",
        body: "{}",
        headers: private_headers(["application/octet-stream"]),
        reply: {204, [], ""},
        expect: &assert(&1 == %{status_code: 204, message: "No Content"})
      },
      %{
        name: "Invoices.online_invoice_url",
        call: fn -> CoreApi.Invoices.online_invoice_url(client, "id-1") end,
        method: "GET",
        path: api("invoices/id-1/OnlineInvoice"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply:
          {200, [{"content-type", @json}],
           ~s({"OnlineInvoices":[{"OnlineInvoiceUrl":"https://in.xero.com/abc"}]})},
        expect:
          &assert(
            %Models.OnlineInvoices{
              OnlineInvoices: [
                %Models.OnlineInvoices.OnlineInvoice{OnlineInvoiceUrl: "https://in.xero.com/abc"}
              ]
            } = &1
          )
      },
      %{
        name: "Invoices.filter with modified_since",
        call: fn -> CoreApi.Invoices.filter(client, filter) end,
        method: "GET",
        path: api("invoices"),
        query: "where=Status%3D%3D%22DRAFT%22",
        body: "",
        headers: private_headers([]) ++ [{"if-modified-since", ["2026-11-01T00:00:00"]}],
        reply: model_reply(Models.Invoices),
        expect: expect_model(Models.Invoices)
      },
      %{
        name: "ContactGroups.add_to_group",
        call: fn -> CoreApi.ContactGroups.add_to_group(client, "group-1", contacts) end,
        method: "PUT",
        path: api("contactgroups/group-1/contacts"),
        query: "",
        body: Jason.encode!(contacts),
        headers: private_headers(["application/octet-stream"]),
        reply: model_reply(Models.Contacts),
        expect: expect_model(Models.Contacts)
      },
      %{
        name: "ContactGroups.remove_contact",
        call: fn -> CoreApi.ContactGroups.remove_contact(client, "group-1", "contact-1") end,
        method: "DELETE",
        path: api("contactgroups/group-1/contacts/contact-1"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: {204, [], ""},
        expect: &assert(&1 == %{status_code: 204, message: "No Content"})
      },
      %{
        name: "ContactGroups.remove_all_contacts",
        call: fn -> CoreApi.ContactGroups.remove_all_contacts(client, "group-1") end,
        method: "DELETE",
        path: api("contactgroups/group-1/contacts"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: {204, [], ""},
        expect: &assert(&1 == %{status_code: 204, message: "No Content"})
      },
      %{
        name: "CreditNotes.allocate_credit_note",
        call: fn -> CoreApi.CreditNotes.allocate_credit_note(client, "id-1", allocations) end,
        method: "PUT",
        path: api("creditnotes/id-1/allocations"),
        query: "",
        body: Jason.encode!(allocations),
        headers: private_headers(["application/octet-stream"]),
        reply: model_reply(Models.Allocations),
        expect: expect_model(Models.Allocations)
      },
      %{
        name: "Overpayments.allocate_overpayment",
        call: fn -> CoreApi.Overpayments.allocate_overpayment(client, "id-1", allocations) end,
        method: "PUT",
        path: api("overpayments/id-1/allocations"),
        query: "",
        body: Jason.encode!(allocations),
        headers: private_headers(["application/octet-stream"]),
        reply: model_reply(Models.Allocations),
        expect: expect_model(Models.Allocations)
      },
      %{
        name: "Prepayments.allocate_prepayment",
        call: fn -> CoreApi.Prepayments.allocate_prepayment(client, "id-1", allocations) end,
        method: "PUT",
        path: api("prepayments/id-1/allocations"),
        query: "",
        body: Jason.encode!(allocations),
        headers: private_headers(["application/octet-stream"]),
        reply: model_reply(Models.Allocations),
        expect: expect_model(Models.Allocations)
      },
      %{
        name: "Reports.named",
        call: fn -> CoreApi.Reports.named(client, "BalanceSheet") end,
        method: "GET",
        path: api("reports/BalanceSheet"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: model_reply(Models.Reports),
        expect: expect_model(Models.Reports)
      },
      %{
        name: "Reports.named with a filter",
        call: fn ->
          CoreApi.Reports.named(client, "ProfitAndLoss", "fromDate=2026-01-01&toDate=2026-06-30")
        end,
        method: "GET",
        path: api("reports/ProfitAndLoss"),
        query: "fromDate=2026-01-01&toDate=2026-06-30",
        body: "",
        headers: private_headers([]),
        reply: model_reply(Models.Reports),
        expect: expect_model(Models.Reports)
      },
      %{
        name: "Reports.individual_report",
        call: fn -> CoreApi.Reports.individual_report(client, "report-1") end,
        method: "GET",
        path: api("reports/report-1"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: model_reply(Models.Reports),
        expect: expect_model(Models.Reports)
      },
      %{
        name: "InvoiceReminders.settings",
        call: fn -> CoreApi.InvoiceReminders.settings(client) end,
        method: "GET",
        path: api("invoicereminders/settings"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: model_reply(Models.InvoiceReminders),
        expect: expect_model(Models.InvoiceReminders)
      },
      %{
        name: "TrackingCategories.add_option",
        call: fn -> CoreApi.TrackingCategories.add_option(client, "category-1", option) end,
        method: "PUT",
        path: api("trackingcategories/category-1/options"),
        query: "",
        body: Jason.encode!(option),
        headers: private_headers(["application/octet-stream"]),
        reply: model_reply(Models.TrackingCategories.TrackingCategory.Options),
        expect: expect_model(Models.TrackingCategories.TrackingCategory.Options)
      },
      %{
        name: "TrackingCategories.update_option",
        call: fn ->
          CoreApi.TrackingCategories.update_option(client, "category-1", "option-1", option)
        end,
        method: "POST",
        path: api("trackingcategories/category-1/options/option-1"),
        query: "",
        body: Jason.encode!(option),
        headers: private_headers(["application/octet-stream"]),
        reply: model_reply(Models.TrackingCategories.TrackingCategory.Options),
        expect: expect_model(Models.TrackingCategories.TrackingCategory.Options)
      },
      %{
        name: "TrackingCategories.delete_option",
        call: fn -> CoreApi.TrackingCategories.delete_option(client, "category-1", "option-1") end,
        method: "DELETE",
        path: api("trackingcategories/category-1/options/option-1"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: model_reply(Models.TrackingCategories.TrackingCategory.Options),
        expect: expect_model(Models.TrackingCategories.TrackingCategory.Options)
      },
      %{
        name: "Attachments.find",
        call: fn -> CoreApi.Attachments.find(client, "invoices", "id-1") end,
        method: "GET",
        path: api("invoices/id-1/attachments"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: model_reply(Models.Attachments),
        expect: expect_model(Models.Attachments)
      },
      %{
        name: "Attachments.find a file",
        call: fn -> CoreApi.Attachments.find(client, "invoices", "id-1", "scan.pdf") end,
        method: "GET",
        path: api("invoices/id-1/attachments/scan.pdf"),
        query: "",
        body: "",
        headers: private_headers([]),
        reply: {200, [{"content-type", "application/pdf"}], attachment},
        expect: &assert(&1 == %{"data" => attachment, "http_status_code" => 200})
      },
      %{
        name: "Attachments.upload_attachment",
        call: fn ->
          CoreApi.Attachments.upload_attachment(
            client,
            "invoices",
            "id-1",
            "a b.pdf",
            attachment_path,
            true
          )
        end,
        method: "POST",
        path: api("invoices/id-1/attachments/a%20b.pdf"),
        query: "includeonline=true",
        body: attachment,
        headers:
          private_headers(["application/pdf"]) ++
            [
              {"content-length", [Integer.to_string(byte_size(attachment))]},
              {"transfer-encoding", []}
            ],
        reply: model_reply(Models.Attachments),
        expect: expect_model(Models.Attachments)
      },
      %{
        name: "Tokens.refresh_token",
        call: fn -> CoreApi.Tokens.refresh_token("old-refresh", "client-id", "client-secret") end,
        method: "POST",
        path: "/connect/token",
        query: "",
        body: "grant_type=refresh_token&refresh_token=old-refresh",
        headers: [
          {"authorization", ["Basic " <> Base.encode64("client-id:client-secret")]},
          {"accept", ["application/json"]},
          {"content-type", ["application/x-www-form-urlencoded"]}
        ],
        reply:
          {200, [{"content-type", @json}],
           ~s({"access_token":"new-access","refresh_token":"new-refresh","expires_in":1800,"token_type":"Bearer","scope":"accounting.transactions offline_access"})},
        expect:
          &assert(
            %Models.Tokens.Token{
              access_token: "new-access",
              refresh_token: "new-refresh",
              expires_in: 1800,
              token_type: "Bearer",
              scope: "accounting.transactions offline_access"
            } = &1
          )
      }
    ]

    run_cases(bypass, cases)
  end

  @tag :tmp_dir
  test "a file upload sends the file as a named multipart part and decodes the reply", %{
    bypass: bypass,
    client: client,
    tmp_dir: tmp_dir
  } do
    upload = :binary.copy(:binary.list_to_bin(Enum.to_list(0..255)), 4000)
    upload_path = Path.join(tmp_dir, "upload.png")
    File.write!(upload_path, upload)

    serve(bypass, %{
      {"POST", "/files.xro/1.0/files", ""} =>
        {201, [{"Content-Type", @json}], ~s({"Id":"file-1","Name":"report.png"})}
    })

    assert XeroXero.FilesApi.Files.upload(client, upload_path, "report.png") ==
             %{"Id" => "file-1", "Name" => "report.png", "http_status_code" => 201}

    assert_received {:request, conn, body}
    assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer access-token"]
    assert Plug.Conn.get_req_header(conn, "xero-tenant-id") == [@tenant_id]

    assert ["multipart/form-data; boundary=" <> boundary] =
             Plug.Conn.get_req_header(conn, "content-type")

    assert Plug.Conn.get_req_header(conn, "content-length") == [
             Integer.to_string(byte_size(body))
           ]

    assert [_preamble, part, "--\r\n"] = String.split(body, "--" <> boundary)
    [part_headers, part_body] = String.split(part, "\r\n\r\n", parts: 2)
    part_headers = part_headers |> String.downcase() |> String.split("\r\n", trim: true)
    assert "content-type: image/png" in part_headers

    assert Enum.any?(
             part_headers,
             &(&1 =~ ~r/^content-disposition: form-data;.*filename="report.png"/)
           )

    assert part_body == upload <> "\r\n"
  end

  test "each status Xero replies with comes back as its model, exception or message, without retries or redirects",
       %{bypass: bypass, url: url, client: client} do
    invoice_id = "0032a5a7-1a8c-4a0f-a6a2-6b5c3c1d0e11"

    invoices =
      Jason.encode!(%{
        Invoices: [
          %{
            InvoiceID: invoice_id,
            InvoiceNumber: "INV-0042",
            Status: "AUTHORISED",
            Total: 1250.5,
            Reference: "Café ☕",
            Contact: %{Name: "Lincoln High"},
            LineItems: [%{Description: "Planbook", Quantity: 1.0, UnitAmount: 1250.5}]
          }
        ]
      })

    many =
      Jason.encode!(%{
        Invoices: Enum.map(1..20_000, &%{InvoiceNumber: "INV-#{&1}", Reference: "Café ☕"})
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
      "ok" => {200, [{"content-type", @json}], invoices},
      "many" => {200, [{"content-type", "application/json"}], many},
      "validation" => {400, [{"content-type", @json}], validation},
      "bad-request" =>
        {400, [{"content-type", @json}],
         ~s({"ErrorNumber":14,"Type":"PostDataInvalidException","Message":"bad"})},
      "error" =>
        {500, [{"content-type", @json}],
         ~s({"ErrorNumber":500,"Type":"UnknownErrorException","Message":"An error occurred"})},
      "empty" => {204, [], ""},
      "unauthorized" =>
        {401, [{"content-type", "text/html"}],
         "oauth_problem=token_expired&oauth_problem_advice=Expired"},
      "missing" => {404, [], ""},
      "rate-limited" => {429, [{"retry-after", "1"}], "oauth_problem=rate%20limit%20exceeded"},
      "unavailable" => {503, [{"retry-after", "1"}], "down"},
      "moved" => {301, [{"location", url <> "/elsewhere"}], ""},
      "found" => {302, [{"location", url <> "/elsewhere"}], ""},
      "temporary" => {307, [{"location", url <> "/elsewhere"}], ""}
    }

    serve(
      bypass,
      Map.new(replies, fn {id, reply} -> {{"GET", api("invoices/" <> id), ""}, reply} end)
    )

    find = fn id ->
      result = CoreApi.Invoices.find(client, id)
      assert_received {:request, %{request_path: path}, _}
      assert path == api("invoices/" <> id)
      refute_received {:request, _, _}
      result
    end

    assert %Models.Invoices{
             Invoices: [
               %Models.Invoices.Invoice{
                 InvoiceID: ^invoice_id,
                 InvoiceNumber: "INV-0042",
                 Status: "AUTHORISED",
                 Reference: "Café ☕",
                 Contact: %Models.Contacts.Contact{Name: "Lincoln High"},
                 LineItems: [%Models.Common.LineItem{Description: "Planbook"}]
               } = invoice
             ]
           } = find.("ok")

    assert Decimal.equal?(invoice."Total", Decimal.new("1250.5"))

    assert %Models.Invoices{Invoices: all} = find.("many")
    assert length(all) == 20_000
    assert List.last(all)."InvoiceNumber" == "INV-20000"

    assert %Models.Invoices{
             Invoices: [
               %Models.Invoices.Invoice{
                 InvoiceNumber: "INV-0042",
                 ValidationErrors: [%Models.Common.Error{Message: "Invoice # must be unique."}]
               }
             ]
           } = find.("validation")

    assert find.("bad-request") == %{
             ErrorNumber: 14,
             Type: "PostDataInvalidException",
             Message: "bad"
           }

    assert %Models.Exceptions.ApiException{
             ErrorNumber: 500,
             Type: "UnknownErrorException",
             Message: "An error occurred"
           } = find.("error")

    assert find.("empty") == %{status_code: 204, message: "No Content"}

    assert find.("unauthorized") == %{
             status_code: 401,
             message: %{"oauth_problem" => "token_expired", "oauth_problem_advice" => "Expired"}
           }

    assert find.("missing") == %{status_code: 404, message: %{}}

    assert find.("rate-limited") == %{
             status_code: 429,
             message: %{"oauth_problem" => "rate limit exceeded"}
           }

    assert find.("unavailable") == %{status_code: 503, message: %{"down" => ""}}
    assert find.("moved") == %{status_code: 301, message: %{}}
    assert find.("found") == %{status_code: 302, message: %{}}
    assert find.("temporary") == %{status_code: 307, message: %{}}
  end

  test "a chunked reply is read whole", %{bypass: bypass, client: client} do
    Bypass.expect_once(bypass, "GET", api("invoices"), fn conn ->
      conn = Plug.Conn.send_chunked(conn, 200)
      {:ok, conn} = Plug.Conn.chunk(conn, ~s|{"Invoices":[|)
      {:ok, conn} = Plug.Conn.chunk(conn, ~s|{"InvoiceNumber":"INV-1"}]}|)
      conn
    end)

    assert %Models.Invoices{Invoices: [%{InvoiceNumber: "INV-1"}]} = CoreApi.Invoices.find(client)
  end

  test "a call to a Xero that isn't there raises", %{bypass: bypass, client: client} do
    Bypass.down(bypass)

    raised =
      try do
        CoreApi.Invoices.find(client)
        :returned
      rescue
        _ -> :raised
      end

    assert raised == :raised
  end
end
