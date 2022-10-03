defmodule DropsWeb.ComponentUploadsLive do
  use DropsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:avatar_path, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Component Uploads Example</h1>
    <p>
      In this demo, the upload form lives within a <a href="https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html">LiveComponent</a>.
    </p>

    <section class="row upload-demo">
      <article class="column">
        <h2>Upload</h2>
        <%= live_component(DropsWeb.UploadComponent, id: :avatar) %>
      </article>
      <article class="column avatar">
        <%= if @avatar_path do %>
          <h2>Complete!</h2>
          <figure>
            <img src={@avatar_path} />
          </figure>
        <% end %>
      </article>
    </section>
    """
  end

  @impl true
  def handle_info({DropsWeb.UploadComponent, :avatar, new_path}, socket) do
    {:noreply, assign(socket, :avatar_path, new_path)}
  end
end
