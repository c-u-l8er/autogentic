defmodule AutogenticTest do
  use ExUnit.Case, async: false
  doctest Autogentic

  # Simple test agent for integration testing
  defmodule SimpleAgent do
    use Autogentic.Agent, name: :simple_agent

    agent :simple_agent do
      capability [:testing]
      reasoning_style :analytical
      initial_state :ready
    end

    state :ready do
    end

    transition from: :ready, to: :ready, when_receives: :test_message do
      sequence do
        log(:info, "Received test message")
        put_data(:message_received, true)
      end
    end
  end

  describe "main API" do
    test "can execute simple effects" do
      effect = {:log, :info, "test message"}
      context = %{}

      assert {:ok, :logged} = Autogentic.execute_effect(effect, context)
    end

    test "can execute effect sequences" do
      effects = [
        {:put_data, :step1, "completed"},
        {:put_data, :step2, "completed"},
        {:log, :info, "sequence complete"}
      ]

      sequence_effect = {:sequence, effects}
      assert {:ok, context} = Autogentic.execute_effect(sequence_effect)
      assert context[:step1] == "completed"
      assert context[:step2] == "completed"
    end

    test "can start reasoning session" do
      context = %{task: "test analysis"}
      assert {:ok, "test_session"} = Autogentic.start_reasoning("test_session", context)
    end
  end

  describe "agent management" do
    test "can start and stop agents" do
      # Start agent
      assert {:ok, pid} = Autogentic.start_agent(:simple_test_agent, SimpleAgent)
      assert Process.alive?(pid)

      # Check agent is running
      agents = Autogentic.list_agents()
      agent_names = Enum.map(agents, & &1[:name])
      assert :simple_test_agent in agent_names

      # Stop agent
      assert :ok = Autogentic.stop_agent(:simple_test_agent)
    end

    test "can send messages to agents" do
      {:ok, pid} = Autogentic.start_agent(:message_test_agent, SimpleAgent, name: :message_test_agent)

      # Send message
      Autogentic.send_message(pid, :test_message)
      Process.sleep(100)

      # Verify agent received message (would be in context in full implementation)
      assert Process.alive?(pid)

      Autogentic.stop_agent(:message_test_agent)
    end

    test "can get agent state" do
      {:ok, pid} = Autogentic.start_agent(:state_test_agent, SimpleAgent, name: :state_test_agent)

      {state, data} = Autogentic.get_agent_state(pid)
      assert state == :ready
      assert data.agent_id == :simple_agent
      assert data.capabilities == [:testing]

      Autogentic.stop_agent(:state_test_agent)
    end
  end

  describe "integration tests" do
    test "full workflow with reasoning and effects" do
      # Start a reasoning session
      context = %{
        task: "integration_test",
        complexity: :medium,
        urgency: :normal
      }

      {:ok, session_id} = Autogentic.start_reasoning("integration_test", context)

      # Execute some effects
      effect_sequence = [
        {:put_data, :analysis_started, true},
        {:log, :info, "Starting integration test analysis"},
        {:reason_about, "Should we proceed with this integration test?", [
          %{
            id: :assess_readiness,
            question: "Are we ready for integration testing?",
            analysis_type: :assessment,
            context_required: [:task, :complexity],
            output_format: :analysis
          }
        ]},
        {:put_data, :analysis_complete, true}
      ]

      assert {:ok, final_context} = Autogentic.execute_effect({:sequence, effect_sequence}, context)

      # Verify context was updated
      assert final_context[:analysis_started] == true
      assert final_context[:analysis_complete] == true
      assert final_context[:task] == "integration_test"
    end

    test "error recovery in effect sequences" do
      # Test sequence with an error and compensation
      primary_effect = {:unknown_effect, "this will fail"}
      fallback_effect = {:put_data, :fallback_executed, true}

      compensation_effect = {:with_compensation, primary_effect, fallback_effect}

      assert {:ok, result} = Autogentic.execute_effect(compensation_effect, %{})
      assert result[:fallback_executed] == true
    end

    test "parallel effect execution" do
      effects = [
        {:delay, 50},
        {:put_data, :effect1, "completed"},
        {:put_data, :effect2, "completed"},
        {:put_data, :effect3, "completed"}
      ]

      start_time = System.monotonic_time(:millisecond)
      assert {:ok, context} = Autogentic.execute_effect({:parallel, effects})
      end_time = System.monotonic_time(:millisecond)

      # Should complete quickly due to parallel execution
      assert end_time - start_time < 200

      # All effects should have completed
      assert context[:effect1] == "completed"
      assert context[:effect2] == "completed"
      assert context[:effect3] == "completed"
    end
  end

  describe "system health" do
    test "system starts up correctly" do
      # Verify core services are available
      assert Process.whereis(Autogentic.Effects.Engine)
      assert Process.whereis(Autogentic.Reasoning.Engine)
      assert Process.whereis(Autogentic.Learning.Coordinator)
    end

    test "can handle multiple concurrent operations" do
      # Start multiple reasoning sessions
      sessions = for i <- 1..5 do
        context = %{session: i, task: "concurrent_test_#{i}"}
        {:ok, session_id} = Autogentic.start_reasoning("concurrent_#{i}", context)
        session_id
      end

      assert length(sessions) == 5
      Enum.each(sessions, fn session_id ->
        assert is_binary(session_id)
      end)

      # Execute multiple effects concurrently
      tasks = for i <- 1..10 do
        Task.async(fn ->
          effect = {:put_data, :concurrent_test, i}
          Autogentic.execute_effect(effect)
        end)
      end

      results = Task.await_many(tasks, 5000)

      # All should succeed
      Enum.each(results, fn result ->
        assert {:ok, _} = result
      end)
    end
  end
end
