defmodule Freedive do
  @moduledoc """
  Freedive keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  require Logger

  @doas_path "/usr/local/bin/doas"
  @jexec_path "/usr/sbin/jexec"
  @env_path "/usr/bin/env"
  @env_path_var "/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

  @doc """
  Execute commands, raise error on failure.

  ## Examples

      iex> Freedive.execute!("whoami", [], doas: true)
      "root"

      iex> Freedive.execute!("whoami", [], doas: "www")
      "www"

      iex> Freedive.execute!("whoami", [], jail: "testjail")
      "root"

      iex> Freedive.execute!("whoami", [], jail: "testjail", doas: "operator")
      "operator"

      iex> Freedive.execute("hostname", [], jail: "testjail")
      {:ok, "testjail"}

      iex> Freedive.execute!("sysctl", ["-n", "security.jail.jailed"])
      "0"

      iex> Freedive.execute!("sysctl", ["-n", "security.jail.jailed"], jail: "testjail")
      "1"

      iex> Freedive.execute!("printenv", ["FOO"], jail: "testjail", env: [{"FOO", "bar"}])
      "bar"
  """
  def execute!(command, args, opts \\ []), do: raise_on_error(execute(command, args, opts))

  @doc """
  Execute commands, return {:ok, output} or {:error, {output, code}}.

  ## Examples

      iex> Freedive.execute("whoami", [], doas: true)
      {:ok, "root"}

      iex> Freedive.execute("whoami", [], doas: "www")
      {:ok, "www"}

      iex> Freedive.execute("whoami", [], jail: "testjail")
      {:ok, "root"}

      iex> Freedive.execute("whoami", [], jail: "testjail", doas: "operator")
      {:ok, "operator"}

      iex> Freedive.execute("hostname", [], jail: "testjail")
      {:ok, "testjail"}

      iex> Freedive.execute("sysctl", ["-n", "security.jail.jailed"])
      {:ok, "0"}

      iex> Freedive.execute("sysctl", ["-n", "security.jail.jailed"], jail: "testjail")
      {:ok, "1"}

      iex> Freedive.execute("printenv", ["FOO"], jail: "testjail", env: [{"FOO", "bar"}])
      {:ok, "bar"}
  """
  @spec execute(String.t(), list(String.t()), Keyword.t()) ::
          {:ok, String.t()} | {:error, {String.t(), integer()}}
  def execute(command, args, opts \\ []) do
    doas = Keyword.get(opts, :doas, false)
    jail = Keyword.get(opts, :jail, nil)

    envars =
      Keyword.get(opts, :env, [
        {"PATH", @env_path_var}
      ])

    opts =
      opts
      |> Keyword.delete(:doas)
      |> Keyword.delete(:jail)
      |> Keyword.put(:stderr_to_stdout, true)

    case {jail, doas} do
      {nil, false} ->
        cmd(command, args, opts)

      {nil, true} ->
        cmd(@doas_path, [command] ++ args, opts)

      {nil, user} ->
        cmd(@doas_path, ["-u", user, command] ++ args, opts)

      {_, false} ->
        cmd(
          @doas_path,
          ["--", @jexec_path, "-l", jail, @env_path, "-P#{@env_path_var}", env(envars), command] ++
            args,
          opts
        )

      {_, true} ->
        cmd(
          @doas_path,
          ["--", @jexec_path, "-l", jail, @env_path, "-P#{@env_path_var}", env(envars), command] ++
            args,
          opts
        )

      {_, user} ->
        cmd(
          @doas_path,
          [
            "--",
            @jexec_path,
            "-l",
            "-U",
            user,
            jail,
            @env_path,
            "-P#{@env_path_var}",
            env(envars),
            command
          ] ++ args,
          opts
        )
    end
  end

  defp cmd(command, args, opts) do
    Logger.debug("Executing command: #{command} #{inspect(args)} with opts: #{inspect(opts)}")

    case System.cmd(command, args, opts) do
      {output, 0} -> {:ok, output |> String.trim()}
      {output, code} -> {:error, {output |> String.trim(), code}}
    end
  end

  defp env(envars) do
    envars
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join(" ")
  end

  def raise_on_error(result) do
    case result do
      {:ok, output} -> output
      {:error, message} -> raise message
    end
  end
end
