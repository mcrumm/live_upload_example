defmodule DropsWeb.UploaderLive.Demo do
  use DropsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> reset_file()
     |> allow_upload(:file, accept: ~w(image/*), chunk_size: 256 * 1_024)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    apply_action(socket, socket.assigns.live_action, params)
  end

  defp apply_action(socket, :index, _params) do
    {:noreply, socket |> reset_file() |> assign(:page_title, "Uploader Demo")}
  end

  defp apply_action(socket, :start, _params) do
    {:noreply, socket |> reset_file() |> assign(:page_title, "Start Upload")}
  end

  defp apply_action(socket, :done, params) do
    if socket.assigns.file do
      {:noreply, assign(socket, :page_title, "YAY")}
    else
      apply_action(socket, :continue, params)
    end
  end

  defp apply_action(socket, :continue, _params) do
    {:noreply, push_redirect(socket, to: Routes.uploader_demo_path(socket, :start))}
  end

  defp reset_file(socket), do: assign(socket, :file, nil)

  @impl true
  def handle_info({DropsWeb.UploadComponent, :file, path}, socket) do
    {:noreply,
     socket
     |> assign(:file, path)
     |> push_patch(to: Routes.uploader_demo_path(socket, :done))}
  end
end
