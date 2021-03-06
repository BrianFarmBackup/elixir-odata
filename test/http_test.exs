defmodule OData.HTTPTest do

  use ExUnit.Case
  alias OData.{HTTP, Query, Request}
  doctest OData.HTTP

  setup do
    bypass = Bypass.open
    {:ok, people_json} = File.read("test/support/people.json")
    url = "http://localhost:#{bypass.port}/dummy"
    {:ok, %{
      bypass: bypass,
      people_json: people_json,
      url: url
    }}
  end

  test "requests a list of people", %{
    bypass: bypass,
    people_json: people_json,
    url: url
  } do
    Bypass.expect bypass, fn conn ->
      assert "/dummy/odata/People" == conn.request_path
      assert "GET" == conn.method
      assert {"content-type", "application/json"} in conn.req_headers
      Plug.Conn.resp(conn, 200, people_json)
    end
    "People"
    |> Query.build
    |> Request.build(url)
    |> HTTP.get
  end

end
