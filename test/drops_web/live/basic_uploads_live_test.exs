defmodule DropsWeb.BasicUploadsLiveTest do
  use DropsWeb.ConnCase
  import Phoenix.LiveViewTest
  import DropsWeb.UploadSupport

  test "uploading a file", %{conn: conn} do
    {:ok, lv, html} = live(conn, Routes.basic_uploads_path(conn, :index))
    assert html =~ "Basic Uploads Example"

    file =
      [:code.priv_dir(:drops), "static", "images", "phoenix.png"]
      |> Path.join()
      |> build_upload("image/png")

    exhibit = file_input(lv, "#basic-uploads-form", :exhibit, [file])

    assert render_upload(exhibit, file.name)
           |> Floki.parse_document!()
           |> Floki.find("section.pending-uploads > .upload-entry")
           |> length() == 1

    doc =
      lv
      |> form("#basic-uploads-form", [])
      |> render_submit()
      |> Floki.parse_document!()

    assert doc
           |> Floki.find(~s(output[form="basic-uploads-form"] > figure))
           |> length() == 1

    # TODO: Figure out why we need a render for the latent changes.
    # `section.pending-uploads` _should_ be devoid of entries after
    # we called render_submit().
    doc = lv |> render() |> Floki.parse_document!()

    assert doc
           |> Floki.find("section.pending-uploads > .upload-entry")
           |> length() == 0
  end
end
