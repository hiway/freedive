defmodule FreediveWeb.DataShareLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Share Data
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>

      <.panel_block icon="hero-folder">
        SMB: notes
      </.panel_block>

      <.panel_block icon="hero-folder">
        SMB: misc
      </.panel_block>
    </.panel>
    """
  end
end
