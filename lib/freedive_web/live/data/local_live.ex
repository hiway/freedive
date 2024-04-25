defmodule FreediveWeb.DataLocalLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Local Data
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Directories</.link>
        <.link href="#">Removable</.link>
      </:tabs>

      <.panel_block icon="hero-folder">
        /home/example/notes
      </.panel_block>

      <.panel_block icon="hero-folder">
        /home/example/src
      </.panel_block>

      <.panel_block icon="hero-server">
        /mnt/live
      </.panel_block>
    </.panel>
    """
  end
end
