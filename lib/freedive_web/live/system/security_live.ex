defmodule FreediveWeb.SystemSecurityLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Security
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>

      <.panel_block icon="hero-shield-exclamation" icon_class="has-text-danger">
        SSH: Permit password login
      </.panel_block>

      <.panel_block icon="hero-shield-exclamation" icon_class="has-text-danger">
        Firewall: Allow outgoing traffic
      </.panel_block>

      <.panel_block icon="hero-shield-check" icon_class="has-text-success">
        DNS: Queries encrypted
      </.panel_block>

      <.panel_block icon="hero-shield-check" icon_class="has-text-success">
        DNS: Blocklists enabled
      </.panel_block>

      <.panel_block icon="hero-shield-check" icon_class="has-text-success">
        Firewall: Restrict incoming traffic
      </.panel_block>

      <.panel_block icon="hero-shield-check" icon_class="has-text-success">
        OS: Up to date
      </.panel_block>

      <.panel_block icon="hero-shield-check" icon_class="has-text-success">
        SSH: Disable root login
      </.panel_block>

      <.panel_block icon="hero-shield-check" icon_class="has-text-success">
        Vuln: Heartbleed mitigation
      </.panel_block>
    </.panel>
    """
  end
end
