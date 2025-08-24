defmodule Autogentic.Effects do
  @moduledoc """
  Declarative effects system designed for AI agent coordination and reasoning.
  Much more powerful than simple function-based approaches.

  This module defines all available effect types and provides macros for
  clean effects composition in agent definitions.

  ## Effect Types

  ### Basic Operations
  - `log/2` - Log messages with specified level
  - `delay/1` - Introduce delays for timing control
  - `emit_event/2` - Emit events to the agent system
  - `put_data/2` and `get_data/1` - Context data management

  ### AI/LLM Operations
  - `reason_about/2` - Multi-step reasoning with confidence scoring
  - `call_llm/1` - Call Language Model APIs with configuration
  - `coordinate_agents/2` - Multi-agent coordination patterns
  - `chain_of_thought/2` - Chain of thought reasoning

  ### Composition Operators
  - `sequence/1` - Execute effects in order
  - `parallel/1` - Execute effects concurrently
  - `race/1` - Execute effects in competition
  - `retry/2` - Retry effects with backoff
  - `with_compensation/2` - Saga pattern for transactions
  - `timeout/2` - Timeout protection
  - `circuit_breaker/2` - Circuit breaker pattern

  ### Learning & Adaptation
  - `learn_from_outcome/2` - Store learning outcomes
  - `update_behavior_model/2` - Update agent behavior models
  - `store_reasoning_pattern/2` - Store successful reasoning patterns

  ## Examples

      # Simple sequence
      sequence do
        log(:info, "Starting analysis")
        reason_about("Should I proceed?", reasoning_steps)
        emit_event(:analysis_complete, %{result: get_data(:analysis)})
      end

      # Advanced coordination
      coordinate([
        %{id: :expert1, role: "Security analyst", model: "gpt-4"},
        %{id: :expert2, role: "Performance analyst", model: "claude-3"}
      ], type: :consensus, threshold: 0.8)

  """

  # Core effect types
  @type effect ::
    # Basic Operations
    {:log, log_level(), String.t()} |
    {:delay, non_neg_integer()} |
    {:emit_event, atom(), map()} |
    {:put_data, atom(), any()} |
    {:increment_data, atom()} |
    {:get_data, atom()} |

    # AI/LLM Operations
    {:reason_about, String.t(), [reasoning_step()]} |
    {:call_llm, llm_config()} |
    {:coordinate_agents, [agent_spec()], coordination_opts()} |
    {:chain_of_thought, String.t(), [reasoning_step()]} |
    {:behavior_analysis, String.t(), behavior_opts()} |

    # Advanced Coordination
    {:wait_for_consensus, [agent_id()], consensus_opts()} |
    {:broadcast_reasoning, String.t(), [agent_id()]} |
    {:aggregate_insights, [agent_id()]} |
    {:escalate_to_human, escalation_opts()} |

    # Composition Operators
    {:sequence, [effect()]} |
    {:parallel, [effect()]} |
    {:race, [effect()]} |
    {:retry, effect(), retry_opts()} |
    {:with_compensation, effect(), effect()} |
    {:timeout, effect(), non_neg_integer()} |
    {:circuit_breaker, effect(), breaker_opts()} |

    # Learning & Adaptation
    {:learn_from_outcome, String.t(), outcome()} |
    {:update_behavior_model, String.t(), map()} |
    {:store_reasoning_pattern, String.t(), [reasoning_step()]} |
    {:adapt_coordination_strategy, coordination_strategy()}

  @type log_level :: :debug | :info | :warning | :error
  @type agent_id :: atom()
  @type outcome :: map()
  @type coordination_strategy :: map()

  @type reasoning_step :: %{
    id: atom(),
    question: String.t(),
    analysis_type: :assessment | :evaluation | :consideration | :synthesis | :comparison | :prediction,
    context_required: [atom()],
    output_format: :boolean | :score | :analysis | :recommendation
  }

  @type agent_spec :: %{
    id: atom(),
    role: String.t(),
    model: String.t(),
    capabilities: [atom()],
    reasoning_style: :analytical | :creative | :critical | :synthetic,
    context_window: pos_integer(),
    temperature: float()
  }

  @type llm_config :: %{
    provider: :openai | :anthropic | :google | :local,
    model: String.t(),
    role: String.t(),
    system: String.t(),
    prompt: String.t(),
    temperature: float(),
    max_tokens: pos_integer()
  }

  @type coordination_opts :: [
    type: :sequential | :parallel | :consensus | :debate | :hierarchical,
    consensus_threshold: float(),
    max_iterations: pos_integer(),
    timeout: non_neg_integer(),
    conflict_resolution: :majority | :weighted | :expert | :human
  ]

  @type consensus_opts :: [
    threshold: float(),
    max_iterations: pos_integer(),
    timeout: non_neg_integer()
  ]

  @type retry_opts :: [
    attempts: pos_integer(),
    backoff_ms: pos_integer()
  ]

  @type breaker_opts :: [
    failure_threshold: float(),
    recovery_time: pos_integer()
  ]

  @type behavior_opts :: [
    analysis_type: atom(),
    context_required: [atom()]
  ]

  @type escalation_opts :: [
    priority: :low | :medium | :high | :critical,
    reason: String.t(),
    data: map()
  ]

  # Basic effect constructors

  @doc "Log a message at the specified level"
  def log(level, message), do: {:log, level, message}

  @doc "Delay execution for specified milliseconds"
  def delay(milliseconds), do: {:delay, milliseconds}

  @doc "Emit an event with payload"
  def emit_event(event, payload), do: {:emit_event, event, payload}

  @doc "Store data in context"
  def put_data(key, value), do: {:put_data, key, value}

  @doc "Increment a counter in context (starts at 0 if not set)"
  def increment_data(key), do: {:increment_data, key}

  @doc "Retrieve data from context"
  def get_data(key), do: {:get_data, key}

  # AI/Reasoning effect constructors

  @doc "Perform multi-step reasoning about a question"
  def reason_about(question, steps), do: {:reason_about, question, steps}

  @doc "Call a Language Model with configuration"
  def call_llm(config), do: {:call_llm, config}

  @doc "Coordinate multiple agents"
  def coordinate_agents(agents, opts \\ []), do: {:coordinate_agents, agents, opts}

  @doc "Execute chain of thought reasoning"
  def chain_of_thought(prompt, steps), do: {:chain_of_thought, prompt, steps}

  # Coordination effect constructors

  @doc "Wait for consensus among agents"
  def wait_for_consensus(agent_ids, opts \\ []), do: {:wait_for_consensus, agent_ids, opts}

  @doc "Broadcast reasoning to agents"
  def broadcast_reasoning(message, agent_ids), do: {:broadcast_reasoning, message, agent_ids}

  @doc "Aggregate insights from agents"
  def aggregate_insights(agent_ids), do: {:aggregate_insights, agent_ids}

  @doc "Escalate to human operator"
  def escalate_to_human(opts), do: {:escalate_to_human, opts}

  # Composition effect constructors

  @doc "Execute effects in sequence"
  def sequence_effects(effects), do: {:sequence, effects}

  @doc "Execute effects in parallel"
  def parallel_effects(effects), do: {:parallel, effects}

  @doc "Race effects against each other"
  def race(effects), do: {:race, effects}

  @doc "Retry an effect with options"
  def retry(effect, opts \\ []), do: {:retry, effect, opts}

  @doc "Execute with compensation (saga pattern)"
  def with_compensation(primary, fallback), do: {:with_compensation, primary, fallback}

  @doc "Execute with timeout protection"
  def timeout(effect, timeout_ms), do: {:timeout, effect, timeout_ms}

  @doc "Execute with circuit breaker pattern"
  def circuit_breaker(effect, opts \\ []), do: {:circuit_breaker, effect, opts}

  # Learning effect constructors

  @doc "Learn from an outcome"
  def learn_from_outcome(subject, outcome), do: {:learn_from_outcome, subject, outcome}

  @doc "Update behavior model"
  def update_behavior_model(model_name, updates), do: {:update_behavior_model, model_name, updates}

  @doc "Store a reasoning pattern"
  def store_reasoning_pattern(pattern_name, steps), do: {:store_reasoning_pattern, pattern_name, steps}

  # DSL Macros for clean composition

  @doc "Macro for reasoning with do-block syntax"
  defmacro reason(question, do: steps) when is_binary(question) do
    quote do
      {:reason_about, unquote(question), unquote(steps)}
    end
  end

  @doc "Macro for agent coordination"
  defmacro coordinate(agents, opts \\ []) do
    quote do
      {:coordinate_agents, unquote(agents), unquote(opts)}
    end
  end

  @doc "Macro for sequential execution"
  defmacro sequence(do: block) do
    effects = extract_effects_from_block(block)
    quote do
      {:sequence, unquote(effects)}
    end
  end

  @doc "Macro for parallel execution"
  defmacro parallel(do: block) do
    effects = extract_effects_from_block(block)
    quote do
      {:parallel, unquote(effects)}
    end
  end

  @doc "Macro for retry with attempts"
  defmacro with_retry(attempts, do: block) do
    effect = extract_single_effect_from_block(block)
    quote do
      {:retry, unquote(effect), attempts: unquote(attempts)}
    end
  end

  @doc "Macro for compensation pattern"
  defmacro with_fallback(primary, do: fallback_block) do
    fallback_effect = extract_single_effect_from_block(fallback_block)
    quote do
      {:with_compensation, unquote(primary), unquote(fallback_effect)}
    end
  end

  # Helper functions for macro expansion

  defp extract_effects_from_block({:__block__, _, effects}), do: effects
  defp extract_effects_from_block(single_effect), do: [single_effect]

  defp extract_single_effect_from_block({:__block__, _, [effect]}), do: effect
  defp extract_single_effect_from_block(effect), do: effect
end
