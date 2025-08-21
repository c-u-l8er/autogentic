defmodule Autogentic.Agent.Registry do
  @moduledoc """
  Registry for tracking active agents in the system.
  """

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register_agent(name, pid, module) do
    GenServer.cast(__MODULE__, {:register, name, pid, module})
  end

  def unregister_agent(name) do
    GenServer.cast(__MODULE__, {:unregister, name})
  end

  def lookup_agent(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def list_agents do
    GenServer.call(__MODULE__, :list_all)
  end

  # GenServer callbacks

  @impl true
  def init(_) do
    # Monitor processes so we can clean up when they die
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:register, name, pid, module}, state) do
    # Monitor the process
    Process.monitor(pid)

    updated_state = Map.put(state, name, %{
      pid: pid,
      module: module,
      started_at: DateTime.utc_now()
    })

    {:noreply, updated_state}
  end

  def handle_cast({:unregister, name}, state) do
    {:noreply, Map.delete(state, name)}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    case Map.get(state, name) do
      nil -> {:reply, {:error, :not_found}, state}
      %{pid: pid} = _agent_info ->
        if Process.alive?(pid) do
          {:reply, {:ok, pid}, state}
        else
          updated_state = Map.delete(state, name)
          {:reply, {:error, :not_found}, updated_state}
        end
    end
  end

  def handle_call(:list_all, _from, state) do
    agents = state
    |> Enum.filter(fn {_name, %{pid: pid}} -> Process.alive?(pid) end)
    |> Enum.map(fn {name, agent_info} ->
      %{
        name: name,
        pid: agent_info.pid,
        module: agent_info.module,
        started_at: agent_info.started_at
      }
    end)

    {:reply, agents, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # Remove dead processes from registry
    updated_state = state
    |> Enum.reject(fn {_name, %{pid: agent_pid}} -> agent_pid == pid end)
    |> Enum.into(%{})

    {:noreply, updated_state}
  end
end
