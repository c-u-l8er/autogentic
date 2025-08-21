defmodule Autogentic.Effects.EngineTest do
  use ExUnit.Case, async: true
  alias Autogentic.Effects.Engine

  describe "basic effects" do
    test "log effect returns success" do
      assert {:ok, :logged} = Engine.execute_effect({:log, :info, "test message"})
    end

    test "delay effect waits specified time" do
      start_time = System.monotonic_time(:millisecond)
      assert {:ok, :delayed} = Engine.execute_effect({:delay, 100})
      end_time = System.monotonic_time(:millisecond)

      assert end_time - start_time >= 100
    end

    test "put_data effect updates context" do
      assert {:ok, context} = Engine.execute_effect({:put_data, :key, "value"}, %{})
      assert context[:key] == "value"
    end

    test "get_data effect retrieves value" do
      context = %{test_key: "test_value"}
      assert {:ok, "test_value"} = Engine.execute_effect({:get_data, :test_key}, context)
    end

    test "get_data effect returns nil for missing key" do
      assert {:ok, nil} = Engine.execute_effect({:get_data, :missing_key}, %{})
    end
  end

  describe "composition effects" do
    test "sequence executes effects in order" do
      effects = [
        {:put_data, :step1, "completed"},
        {:put_data, :step2, "completed"},
        {:log, :info, "sequence complete"}
      ]

      assert {:ok, context} = Engine.execute_effect({:sequence, effects})
      assert context[:step1] == "completed"
      assert context[:step2] == "completed"
    end

    test "parallel executes effects concurrently" do
      effects = [
        {:delay, 50},
        {:delay, 50},
        {:delay, 50}
      ]

      start_time = System.monotonic_time(:millisecond)
      assert {:ok, _} = Engine.execute_effect({:parallel, effects})
      end_time = System.monotonic_time(:millisecond)

      # Should complete in roughly 50ms, not 150ms
      assert end_time - start_time < 100
    end

    test "retry succeeds on first attempt when effect works" do
      effect = {:log, :info, "test"}
      retry_effect = {:retry, effect, attempts: 3}

      assert {:ok, :logged} = Engine.execute_effect(retry_effect)
    end

    test "with_compensation executes fallback on primary failure" do
      primary = {:unknown_effect, "this will fail"}
      fallback = {:log, :info, "fallback executed"}

      effect = {:with_compensation, primary, fallback}
      assert {:ok, :logged} = Engine.execute_effect(effect)
    end

    test "timeout prevents hanging effects" do
      # This would hang without timeout
      hanging_effect = {:delay, 5000}
      timeout_effect = {:timeout, hanging_effect, 100}

      assert {:error, :execution_timeout} = Engine.execute_effect(timeout_effect)
    end
  end

  describe "AI effects" do
    test "reason_about effect returns reasoning result" do
      steps = [
        %{
          id: :test_step,
          question: "Is this a test?",
          analysis_type: :assessment,
          context_required: [],
          output_format: :boolean
        }
      ]

      assert {:ok, result} = Engine.execute_effect({:reason_about, "Should I proceed?", steps})
      assert result.result == "reasoning_complete"
    end

    test "call_llm effect returns response" do
      config = %{
        provider: :openai,
        model: "gpt-4",
        prompt: "Test prompt"
      }

      assert {:ok, result} = Engine.execute_effect({:call_llm, config})
      assert result.response == "llm_response"
    end

    test "coordinate_agents effect returns coordination result" do
      agents = [
        %{id: :agent1, role: "Test agent", model: "gpt-4"},
        %{id: :agent2, role: "Test agent", model: "claude-3"}
      ]

      opts = [type: :parallel, timeout: 30_000]

      assert {:ok, result} = Engine.execute_effect({:coordinate_agents, agents, opts})
      assert result.coordination == "complete"
    end
  end

  describe "learning effects" do
    test "learn_from_outcome effect stores learning" do
      outcome = %{success: true, confidence: 0.8}
      assert {:ok, :learning_stored} = Engine.execute_effect({:learn_from_outcome, "test_task", outcome})
    end

    test "update_behavior_model effect updates model" do
      updates = %{parameter: "new_value"}
      assert {:ok, :model_updated} = Engine.execute_effect({:update_behavior_model, "test_model", updates})
    end

    test "store_reasoning_pattern effect stores pattern" do
      steps = [%{id: :step1, question: "test"}]
      assert {:ok, :pattern_stored} = Engine.execute_effect({:store_reasoning_pattern, "test_pattern", steps})
    end
  end

  describe "coordination effects" do
    test "wait_for_consensus returns consensus result" do
      agent_ids = [:agent1, :agent2]
      opts = [threshold: 0.8, timeout: 10_000]

      assert {:ok, result} = Engine.execute_effect({:wait_for_consensus, agent_ids, opts})
      assert result.consensus == true
    end

    test "broadcast_reasoning returns success" do
      assert {:ok, :broadcasted} = Engine.execute_effect({:broadcast_reasoning, "test message", [:agent1]})
    end

    test "aggregate_insights returns insights" do
      assert {:ok, result} = Engine.execute_effect({:aggregate_insights, [:agent1, :agent2]})
      assert result.insights == []
    end

    test "escalate_to_human returns escalation result" do
      opts = [priority: :high, reason: "Test escalation"]
      assert {:ok, result} = Engine.execute_effect({:escalate_to_human, opts})
      assert result.escalated == true
    end
  end

  describe "error handling" do
    test "unknown effects return error" do
      assert {:error, {:unknown_effect, :invalid}} = Engine.execute_effect({:invalid, "unknown"})
    end

    test "effects engine handles execution failures gracefully" do
      # This should trigger an error in execution
      effect = {:invalid_structure}
      assert {:error, _} = Engine.execute_effect(effect)
    end
  end

  describe "context management" do
    test "effects can access and modify context" do
      initial_context = %{existing_key: "existing_value"}

      effects = [
        {:put_data, :new_key, "new_value"},
        {:get_data, :existing_key}
      ]

      assert {:ok, final_context} = Engine.execute_effect({:sequence, effects}, initial_context)
      assert final_context[:existing_key] == "existing_value"
      assert final_context[:new_key] == "new_value"
    end

    test "context is preserved across effect sequences" do
      effects = [
        {:put_data, :step1, "value1"},
        {:put_data, :step2, "value2"},
        {:put_data, :step3, "value3"}
      ]

      assert {:ok, context} = Engine.execute_effect({:sequence, effects})
      assert context[:step1] == "value1"
      assert context[:step2] == "value2"
      assert context[:step3] == "value3"
    end
  end
end
