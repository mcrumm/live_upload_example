defmodule DropsWeb.FileComponent do
  use DropsWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="file-component">
      <%= for entry <- @file.entries do %>
        <div class="upload-entry">
          <progress
            value={entry.progress}
            class="upload-entry__progress"
            id={"#{entry.ref}-progress"}
            max="100"
          >
            <%= entry.progress %>%
          </progress>
        </div>
      <% end %>
      <.live_file_input upload={@file} />
    </div>
    """
  end
end
