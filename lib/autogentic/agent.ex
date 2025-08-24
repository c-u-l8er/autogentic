defmodule Autogentic.Agent do
  @moduledoc """
  Base framework for creating intelligent agents with sophisticated reasoning,
  effects-based behavior, and learning capabilities.

  This module provides the foundation for building agents that can:
  - Execute complex effect sequences
  - Perform multi-step reasoning
  - Coordinate with other agents
  - Learn and adapt over time
  - Manage sophisticated state machines

  ## Usage

      defmodule MyAgent do
        use Autogentic.Agent, name: :my_agent

        agent :my_agent do
          capability [:analysis, :decision_making]
          reasoning_style :analytical
          initial_state :idle
        end

        state :idle do
          on_enter: fn -> IO.puts("Agent ready") end
        end

        transition from: :idle, to: :working, when_receives: :start do
          sequence do
            log(:info, "Starting work")
            reason_about("Should I proceed?", reasoning_steps)
            emit_event(:work_complete, get_data(:result))
          end
        end
      end
  """

  @type agent_id :: atom()
  @type state_name :: atom()
  @type event :: atom() | {atom(), map()}
  @type capability :: atom()
  @type reasoning_style :: :analytical | :creative | :critical | :synthetic

    defmacro __using__(opts) do
    quote do
      use GenStateMachine, callback_mode: :handle_event_function
      import Autogentic.Effects
      import Autogentic.Agent, only: [agent: 2, capability: 1, reasoning_style: 1,
                                       initial_state: 1, connects_to: 1, state: 2,
                                       transition: 2, behavior: 3]
      require Logger

      @agent_name unquote(opts[:name])
      @capabilities []
      @reasoning_style :analytical
      @initial_state :idle
      @connections []

      def start_link(opts \\ []) do
        name = opts[:name] || @agent_name
        GenStateMachine.start_link(__MODULE__, opts, name: name)
      end

      def init(opts) do
        Logger.info("🤖 Starting agent #{@agent_name}")
        config = agent_config()
        state_data = %{
          agent_id: config.name,
          capabilities: config.capabilities,
          reasoning_style: config.reasoning_style,
          connections: config.connections,
          context: %{},
          started_at: DateTime.utc_now()
        }

        {:ok, config.initial_state, state_data}
      end

      # Default handle_event implementation
      def handle_event({:call, from}, :get_state, state, data) do
        {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
      end

      def handle_event({:call, from}, {:get_data, key}, _state, data) do
        value = Map.get(data.context, key)
        {:keep_state_and_data, {:reply, from, value}}
      end

      def handle_event(:cast, {:put_data, key, value}, state, data) do
        updated_context = Map.put(data.context, key, value)
        updated_data = %{data | context: updated_context}
        {:keep_state, updated_data}
      end

      def handle_event(:cast, {:merge_context, new_context}, state, data) do
        Logger.debug("🔄 [Agent] Merging context: #{inspect(new_context)} into existing: #{inspect(data.context)}")
        updated_context = Map.merge(data.context, new_context)
        updated_data = %{data | context: updated_context}
        Logger.debug("🎯 [Agent] Final merged context: #{inspect(updated_context)}")
        {:keep_state, updated_data}
      end



      def handle_event(:cast, {:execute_effect, effect}, state, data) do
        # Execute effect asynchronously
        Task.start(fn ->
          Autogentic.Effects.Engine.execute_effect(effect, data.context)
        end)

        :keep_state_and_data
      end

      def handle_event(:cast, {:broadcast_reasoning, message, targets}, state, data) do
        Logger.info("🔗 [#{@agent_name}] Broadcasting: #{message}")

        # Broadcast to connected agents
        Enum.each(targets, fn target ->
          if Process.whereis(target) do
            GenStateMachine.cast(target, {:reasoning_shared, @agent_name, message, data.context})
          end
        end)

        :keep_state_and_data
      end

      def handle_event(:cast, {:reasoning_shared, from_agent, message, context}, state, data) do
        Logger.debug("🧠 [#{@agent_name}] Received reasoning from #{from_agent}: #{message}")

        # Store reasoning for potential use
        updated_context = Map.put(data.context, :last_shared_reasoning, %{
          from: from_agent,
          message: message,
          context: context,
          received_at: DateTime.utc_now()
        })

        updated_data = %{data | context: updated_context}
        {:keep_state, updated_data}
      end

      # Default event handler for unknown events
      def handle_event(event_type, event, state, data) do
        Logger.warning("🤖 [#{@agent_name}] Unhandled event #{inspect(event)} in state #{state}")
        :keep_state_and_data
      end

      defoverridable [handle_event: 4]
    end
  end

  # DSL Macros for agent definition

  defmacro agent(name, do: block) do
    quote do
      unquote(block)

      def agent_name, do: unquote(name)
      def agent_config do
        %{
          name: unquote(name),
          capabilities: @capabilities,
          reasoning_style: @reasoning_style,
          initial_state: @initial_state,
          connections: @connections
        }
      end
    end
  end

  defmacro capability(caps) when is_list(caps) do
    quote do
      @capabilities unquote(caps)
    end
  end

  defmacro reasoning_style(style) do
    quote do
      @reasoning_style unquote(style)
    end
  end

  defmacro initial_state(state) do
    quote do
      @initial_state unquote(state)
    end
  end

  defmacro connects_to(agents) when is_list(agents) do
    quote do
      @connections unquote(agents)
    end
  end

  # State definition macro
  defmacro state(name, do: block) do
    quote do
      def unquote(:"handle_state_#{name}")() do
        unquote(block)
      end
    end
  end

  # Transition definition macro
  defmacro transition(opts, do: effect_block) do
    from = opts[:from]
    to = opts[:to]
    when_receives = opts[:when_receives]

    quote do
      def handle_event(:cast, unquote(when_receives), unquote(from), data) do
        Logger.debug("🔄 [#{@agent_name}] Transitioning from #{unquote(from)} to #{unquote(to)}")

                # Execute the effect block
        effect = unquote(effect_block)

        # Execute effect and merge context synchronously within transition
        case Autogentic.Effects.Engine.execute_effect(effect, data.context) do
          {:ok, updated_context} when is_map(updated_context) ->
            Logger.debug("🔍 [#{@agent_name}] Transition got context: #{inspect(updated_context)}")
            # Merge updated context directly and return updated data
            merged_context = Map.merge(data.context, updated_context)
            updated_data = %{data | context: merged_context}
            Logger.debug("🎯 [#{@agent_name}] Merged context in transition: #{inspect(merged_context)}")
            {:next_state, unquote(to), updated_data}
          {:ok, result} ->
            Logger.debug("🔍 [#{@agent_name}] Transition got non-context result: #{inspect(result)}")
            {:next_state, unquote(to), data}
          {:error, reason} ->
            Logger.error("🚨 [#{@agent_name}] Effect execution failed: #{inspect(reason)}")
            {:next_state, unquote(to), data}
        end
      end
    end
  end

  # Behavior definition macro for event-driven responses
  defmacro behavior(name, opts, do: effect_block) do
    triggers = opts[:triggers_on] || []
    states = opts[:in_states] || [:any]

    quote do
      # Generate handler for each trigger event
      unquote(
        for trigger <- triggers do
          if states == [:any] do
            quote do
              def handle_event(:cast, unquote(trigger), _state, data) do
                Logger.debug("⚡ [#{@agent_name}] Executing behavior #{unquote(name)} for #{unquote(trigger)}")

                # Execute behavior effect
                effect = unquote(effect_block)

                # Execute effect and merge context within behavior (async for behaviors)
                Task.start(fn ->
                  case Autogentic.Effects.Engine.execute_effect(effect, data.context) do
                    {:ok, updated_context} when is_map(updated_context) ->
                      Logger.debug("🔍 [#{@agent_name}] Behavior got context: #{inspect(updated_context)}")
                      # Send context merge message (behaviors run async, so need message-based update)
                      GenStateMachine.cast(self(), {:merge_context, updated_context})
                      Logger.debug("🔄 [#{@agent_name}] Sent behavior context merge")
                    {:ok, result} ->
                      Logger.debug("🔍 [#{@agent_name}] Behavior got non-context result: #{inspect(result)}")
                      GenStateMachine.cast(self(), {:put_data, :behavior_result, result})
                    {:error, reason} ->
                      Logger.error("🚨 [#{@agent_name}] Behavior #{unquote(name)} failed: #{inspect(reason)}")
                  end
                end)

                :keep_state_and_data
              end
            end
          else
            for state <- states do
              quote do
                def handle_event(:cast, unquote(trigger), unquote(state), data) do
                  Logger.debug("⚡ [#{@agent_name}] Executing behavior #{unquote(name)} for #{unquote(trigger)} in #{unquote(state)}")

                  # Execute behavior effect
                  effect = unquote(effect_block)

                  # Execute effect and merge context within behavior (async for behaviors)
                  Task.start(fn ->
                    case Autogentic.Effects.Engine.execute_effect(effect, data.context) do
                      {:ok, updated_context} when is_map(updated_context) ->
                        Logger.debug("🔍 [#{@agent_name}] Behavior got context: #{inspect(updated_context)}")
                        # Send context merge message (behaviors run async, so need message-based update)
                        GenStateMachine.cast(self(), {:merge_context, updated_context})
                        Logger.debug("🔄 [#{@agent_name}] Sent behavior context merge")
                      {:ok, result} ->
                        Logger.debug("🔍 [#{@agent_name}] Behavior got non-context result: #{inspect(result)}")
                        GenStateMachine.cast(self(), {:put_data, :behavior_result, result})
                      {:error, reason} ->
                        Logger.error("🚨 [#{@agent_name}] Behavior #{unquote(name)} failed: #{inspect(reason)}")
                    end
                  end)

                  :keep_state_and_data
                end
              end
            end
          end
        end
      )
    end
  end

  # Helper functions available in agent contexts

  @doc """
  Get data from agent context
  """
  def get_data(key) do
    {:get_data, key}
  end

  @doc """
  Put data into agent context
  """
  def put_data(key, value) do
    {:put_data, key, value}
  end

  @doc """
  Get result from last executed effect
  """
  def get_result() do
    {:get_data, :effect_result}
  end

  @doc """
  Log a message (returns an effect)
  """
  def log(level, message) do
    {:log, level, message}
  end

  @doc """
  Emit an event (returns an effect)
  """
  def emit_event(event, payload) do
    {:emit_event, event, payload}
  end

  @doc """
  Broadcast reasoning to connected agents
  """
  def broadcast_reasoning(message, targets) do
    {:broadcast_reasoning, message, targets}
  end

  @doc """
  Escalate to human operator
  """
  def escalate_to_human(opts) do
    {:escalate_to_human, opts}
  end

  @doc """
  Learn from an outcome
  """
  def learn_from_outcome(subject, outcome) do
    {:learn_from_outcome, subject, outcome}
  end

  @doc """
  Execute a reasoning sequence
  """
  def reason(question, do: steps) do
    {:reason_about, question, steps}
  end

  @doc """
  Coordinate with other agents
  """
  def coordinate(agents, opts \\ []) do
    {:coordinate_agents, agents, opts}
  end

  @doc """
  Execute effects in sequence
  """
  def sequence(do: effects) do
    {:sequence, extract_effects_from_block(effects)}
  end

  @doc """
  Execute effects in parallel
  """
  def parallel(do: effects) do
    {:parallel, extract_effects_from_block(effects)}
  end

  @doc """
  Execute with retry logic
  """
  def with_retry(attempts, do: effect) do
    {:retry, effect, attempts: attempts}
  end

  @doc """
  Execute with fallback
  """
  def with_fallback(primary, do: fallback) do
    {:with_compensation, primary, fallback}
  end

  # Helper function to extract effects from do blocks
  defp extract_effects_from_block({:__block__, _, effects}), do: effects
  defp extract_effects_from_block(single_effect), do: [single_effect]
end
