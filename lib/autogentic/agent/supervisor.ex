defmodule Autogentic.Agent.Supervisor do
  @moduledoc """
  Supervisor for managing agent lifecycle and registry.
  """

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_agent(name, agent_module, opts \\ []) do
    child_spec = %{
      id: name,
      start: {agent_module, :start_link, [Keyword.put(opts, :name, name)]},
      restart: :temporary
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
            {:ok, pid} -> 
        Autogentic.Agent.Registry.register_agent(name, pid, agent_module)
        {:ok, pid}
      error -> error
    end
  end

  def stop_agent(name) do
    case Autogentic.Agent.Registry.lookup_agent(name) do
      {:ok, pid} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        Autogentic.Agent.Registry.unregister_agent(name)
        :ok
      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def list_agents do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_id, pid, _type, _modules} -> pid end)
    |> Enum.filter(&Process.alive?/1)
  end
end
