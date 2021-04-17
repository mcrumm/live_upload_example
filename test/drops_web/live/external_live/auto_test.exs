defmodule DropsWeb.ExternalLive.AutoTest do
  use DropsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import DropsWeb.UploadSupport

  test "uploading a file", %{conn: conn} do
    {:ok, lv, html} = live(conn, Routes.external_auto_path(conn, :index))
    assert html =~ "External Uploads Example"

    file =
      [:code.priv_dir(:drops), "static", "images", "phoenix.png"]
      |> Path.join()
      |> build_upload("image/png")

    exhibit = file_input(lv, "#external-auto-form", :exhibit, [file])

    # Uploads the file and renders 100% progress
    render_upload(exhibit, file.name)

    # Render to catch the changes from the progress callback
    doc = lv |> render() |> Floki.parse_document!()

    assert doc
           |> Floki.find(~s(output[form="external-auto-form"] > p))
           |> length() == 1

    assert doc
           |> Floki.find("section.pending-uploads > .upload-entry")
           |> length() == 0
  end
end
