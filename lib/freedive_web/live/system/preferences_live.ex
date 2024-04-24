defmodule FreediveWeb.SystemPreferencesLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        System Preferences
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Changed</.link>
        <.link href="#">Default</.link>
      </:tabs>

      <.panel_block icon="hero-clock">
        Date & Time Sync
      </.panel_block>

      <.panel_block icon="hero-at-symbol">
        DNS Resolvers
      </.panel_block>

      <.panel_block icon="hero-bolt">
        Power Management
      </.panel_block>

      <.panel_block icon="hero-globe-alt">
        Timezone
      </.panel_block>
    </.panel>
    """
  end
end
