defmodule DropsWeb.BasicUploadsLiveTest do
  use DropsWeb.ConnCase
  import Phoenix.LiveViewTest

  test "uploads preflight on validate", %{conn: conn} do
    # 1) Connect to LiveView
    {:ok, live_view, _html} = live(conn, Routes.basic_uploads_path(conn, :index))

    # 2) Build the upload input
    upload =
      file_input(live_view, "#basic-uploads-form", :exhibit, [
        %{name: "photo.png", content: "ok"}
      ])

    entry_ref = get_in(upload.entries, [Access.at(0), "ref"])

    # 3) Render the form change from the input
    live_view |> form("#basic-uploads-form") |> render_change(upload)

    # 4) Assert on pending upload entry
    assert live_view
           |> has_element?("section.pending-uploads #entry-#{entry_ref}")
  end

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
           |> Floki.find(~s([data-figure-group] > figure))
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
