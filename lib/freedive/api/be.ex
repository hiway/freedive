defmodule Freedive.Api.BE do
  alias Freedive.Api.Notification

  def list() do
    {stdout, _exitcode} = System.cmd("bectl", ["list", "-H"])
    stdout
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(
          fn line ->
            String.split(line, "\t")
          end)
      |> Enum.map(
        fn [name, flags, mountpoint, space, creation] ->
          %{
            name: name,
            flags: flags,
            mountpoint: mountpoint,
            space: space,
            creation: creation}
        end)
  end

  def be_current() do
    be_list = list()
    be_list
      |> Enum.filter(
        fn be -> String.contains?(be[:flags], "N")
      end)
      |> List.first()
  end

  def be_by_name(name) do
    list()
      |> Enum.filter(
        fn b -> String.equivalent?(b[:name], name)
      end)
      |> List.first()
  end

  def is_current?(name) do
    be = be_by_name(name)
    if String.contains?(be[:flags], "N") do
      :true
    else
      :false
    end
  end

  def is_default?(name) do
    be = be_by_name(name)
    if String.contains?(be[:flags], "R") do
      :true
    else
      :false
    end
  end

  def is_next_boot?(name) do
    be = be_by_name(name)
    if String.contains?(be[:flags], "T") do
      :true
    else
      :false
    end
  end

  def set_default_be(name) do
    {stdout, _} = System.cmd("bectl", ["activate", name])
    stdout |> String.trim()
  end

  def set_next_boot(name) do
    {stdout, _} = System.cmd("bectl", ["activate", "-t", name])
    stdout |> String.trim()
  end

  def unset_next_boot(name) do
    {stdout, _} = System.cmd("bectl", ["activate", "-T", name])
    stdout |> String.trim()
  end

  def reboot_with_be(name) do
    {stdout, _} = System.cmd("bectl", ["activate", "-t", name])
    Notification.send("Rebooting", name, 1)
    {_, _} = System.cmd("shutdown", ["-r", "now"])
    stdout |> String.trim()
  end

  def create_be(name) do
    {stdout, _} = System.cmd("bectl", ["create", "-r", name])
    stdout |> String.trim()
  end
end
