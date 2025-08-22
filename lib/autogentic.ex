defmodule Autogentic do
  @moduledoc """
  Autogentic v2.0: Next-generation multi-agent system with advanced effects,
  AI reasoning, and continuous learning.

  This is the main entry point for the Autogentic system. It provides
  high-level APIs for creating and managing intelligent agents with
  sophisticated reasoning capabilities.

  ## Quick Start

      # Start an agent
      {:ok, agent} = Autogentic.start_agent(:my_agent, MyAgent)

      # Send a message to trigger reasoning
      Autogentic.send_message(agent, :analyze_request, %{data: "some data"})

  ## Core Components

  - **Effects System**: Declarative effects for complex workflows
  - **Reasoning Engine**: Multi-step AI reasoning with confidence scoring
  - **Learning Coordinator**: Cross-agent learning and adaptation
  - **Agent Framework**: Sophisticated agent lifecycle management

  """

  @doc """
  Starts a new agent with the given module and options.
  """
  def start_agent(name, agent_module, opts \\ []) do
    Autogentic.Agent.Supervisor.start_agent(name, agent_module, opts)
  end

  @doc """
  Stops an agent by name.
  """
  def stop_agent(name) do
    Autogentic.Agent.Supervisor.stop_agent(name)
  end

  @doc """
  Sends a message to an agent.
  """
  def send_message(agent, message, payload \\ %{}) do
    GenServer.cast(agent, {message, payload})
  end

  @doc """
  Gets the current state of an agent.
  """
  def get_agent_state(agent) do
    {:ok, result} = GenServer.call(agent, :get_state)
    result
  end

  @doc """
  Lists all currently running agents.
  """
  def list_agents do
    Autogentic.Agent.Registry.list_agents()
  end

  @doc """
  Executes an effect or sequence of effects.
  """
  def execute_effect(effect, context \\ %{}) do
    Autogentic.Effects.Engine.execute_effect(effect, context)
  end

  @doc """
  Starts a reasoning session.
  """
  def start_reasoning(session_id, context) do
    Autogentic.Reasoning.Engine.start_reasoning_session(session_id, context)
  end
end
