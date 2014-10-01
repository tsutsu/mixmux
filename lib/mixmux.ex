defmodule Mixmux do
  def start do
    Mix.start
    Mix.Local.append_archives

    File.mkdir_p!(deps_path)
    current_dep_names = (File.ls!(deps_path) -- ["mixmux_noapp", "mixmux_nofile"]) |> Enum.map(&String.to_atom/1)
    Enum.each(current_dep_names, &start/1)
  end

  def start(dep_desc) do
    dep_name = install(dep_desc)
    Application.load(dep_name)
    Application.start(dep_name)
  end
    
  @default_version_req "> 0.0.0"
  def install(dep_desc) do
    dep_desc = case dep_desc do
      x when is_tuple(x) -> x
      x when is_atom(x) -> {x, @default_version_req}
      x when is_binary(x) -> {String.to_atom(x), @default_version_req}
    end

    {dep_name, _} = dep_desc

    in_virtual_project [dep_desc], fn _ ->
      {new_lock, old_lock} = Dict.split(Mix.Dep.Lock.read, [dep_name])
      Mix.Dep.Fetcher.all(old_lock, new_lock, [])

      Mix.TasksServer.clear
      Mix.Task.run "deps.compile"
    end

    dep_name |> objects_path |> Code.append_path

    dep_name
  end

  def remove(dep_name) do
    dep_name = case dep_name do
      x when is_atom(x) -> x
      x when is_binary(x) -> String.to_atom(x)
    end

    Application.stop dep_name
    Application.unload dep_name

    dep_src_files = ["*.ex", "*.exs", "*.erl"] |> Enum.flat_map(fn(pat) -> [deps_path, to_string(dep_name), "**", pat] |> Path.join |> Path.wildcard end)
    Code.unload_files(dep_src_files)

    dep_ebin_path = try do
      [Application.app_dir(dep_name), "ebin"] |> Path.join
    rescue
      _ -> "/nowhere"
    end

    case File.ls(dep_ebin_path) do
      {:ok, module_files} -> 
        module_names = Enum.map(module_files, fn(module_file) -> String.to_atom(Regex.replace(~r/\.beam$/, module_file, "")) end)

        Enum.each(module_names, fn(module_name) ->
          :code.delete(module_name)
          :code.soft_purge(module_name)
          :timer.apply_after(2000, :code, :purge, [module_name])
        end)

      _ -> :ok
    end

    dep_name |> objects_path |> Code.delete_path

    in_virtual_project fn _ ->
      Mix.TasksServer.clear
      Mix.Task.run "deps.clean", [to_string(dep_name)]
      Mix.Task.run "deps.unlock", [to_string(dep_name)]
    end

    :ok
  end



  def in_virtual_project(new_deps \\ [], cb) do
    project = mock_project(new_deps)

    try do
      Mix.ProjectStack.push :mixmux_mockapp, project, :mixmux_mockfile

      Application.delete_env :hex, :registry_tid
      if Code.ensure_loaded?(Hex) do
        Hex.Registry.stop
      end

      cb.(project)
    after
      Mix.ProjectStack.pop
    end
  end

  defp mock_project(new_deps) do
    current_deps = (File.ls!(deps_path) -- ["mixmux_noapp", "mixmux_nofile"]) |> Enum.map(fn(dep_name) -> {String.to_atom(dep_name), "> 0.0.0"} end)
    full_deps = Enum.uniq(current_deps ++ new_deps)

    [
      app: :mixmux_mockapp,
      version: "0.1.0",

      elixir: "> 1.0.0",
      deps: full_deps,

      aliases: [],
      preferred_cli_env: [],
      default_task: "run",
      lockfile: "mixmux.lock",

      build_path: build_path,
      deps_path: deps_path,
      elixirc_paths: ["lib"],
      erlc_paths: ["src"],
      erlc_include_path: "include",
      erlc_options: [:debug_info]
    ]
  end

  defp deps_path do
    Path.expand("mixmux")
  end

  defp build_path do
    Path.expand("_build/mixmux")
  end

  defp objects_path(app_name) do
    [build_path, "lib", to_string(app_name), "ebin"] |> Path.join
  end
end
