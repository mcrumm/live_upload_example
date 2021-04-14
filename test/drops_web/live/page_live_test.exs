defmodule DropsWeb.PageLiveTest do
  use DropsWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Live Upload Example"
    assert render(page_live) =~ "Live Upload Example"
  end
end
