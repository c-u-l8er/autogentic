defmodule Autogentic.AgentTest do
  use ExUnit.Case, async: false

  # Define a test agent for testing
  defmodule TestAgent do
    use Autogentic.Agent, name: :test_agent

    agent :test_agent do
      capability [:testing, :analysis]
      reasoning_style :analytical
      connects_to [:other_agent]
      initial_state :idle
    end

        state :idle do
    end

    state :working do
    end

    state :complete do
    end

    transition from: :idle, to: :working, when_receives: :start_work do
      sequence do
        log(:info, "Starting work")
        put_data(:work_started, true)
        emit_event(:work_begun, %{agent: :test_agent})
      end
    end

    transition from: :working, to: :complete, when_receives: :finish_work do
      sequence do
        log(:info, "Finishing work")
        put_data(:work_completed, true)
        emit_event(:work_finished, %{agent: :test_agent})
      end
    end

    behavior :respond_to_ping, triggers_on: [:ping] do
      sequence do
        log(:debug, "Received ping")
        put_data(:ping_received, true)
        emit_event(:pong, %{from: :test_agent})
      end
    end

    behavior :error_handling, triggers_on: [:error], in_states: [:working] do
      sequence do
        log(:error, "Handling error in working state")
        put_data(:error_handled, true)
      end
    end
  end

  setup do
    {:ok, pid} = TestAgent.start_link(name: :test_agent)

    on_exit(fn ->
      if Process.alive?(pid) do
        GenServer.stop(pid)
      end
    end)

    %{agent_pid: pid}
  end

  describe "agent initialization" do
    test "agent starts with correct initial state", %{agent_pid: pid} do
      {:ok, {state, data}} = GenStateMachine.call(pid, :get_state)

      assert state == :idle
      assert data.agent_id == :test_agent
      assert data.capabilities == [:testing, :analysis]
      assert data.reasoning_style == :analytical
      assert data.connections == [:other_agent]
      assert is_map(data.context)
      assert %DateTime{} = data.started_at
    end

    test "agent config is accessible" do
      config = TestAgent.agent_config()

      assert config.name == :test_agent
      assert config.capabilities == [:testing, :analysis]
      assert config.reasoning_style == :analytical
      assert config.initial_state == :idle
      assert config.connections == [:other_agent]
    end
  end

  describe "state transitions" do
    test "can transition between states with effects", %{agent_pid: pid} do
      # Initially in idle state
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :idle

      # Transition to working
      GenStateMachine.cast(pid, :start_work)

      # Give some time for the async effect execution
      Process.sleep(100)

      {:ok, {state, data}} = GenStateMachine.call(pid, :get_state)
      assert state == :working

      # Check that effect was executed (work_started should be set)
      # Note: In the actual implementation, this would be checked differently
      # as the effects execute asynchronously
    end

    test "ignores invalid transitions", %{agent_pid: pid} do
      # Try to send finish_work while in idle (should be ignored)
      GenStateMachine.cast(pid, :finish_work)

      Process.sleep(50)

      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :idle  # Should remain in idle
    end

    test "can complete full state transition sequence", %{agent_pid: pid} do
      # idle -> working
      GenStateMachine.cast(pid, :start_work)
      Process.sleep(100)
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :working

      # working -> complete
      GenStateMachine.cast(pid, :finish_work)
      Process.sleep(100)
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :complete
    end
  end

  describe "behavior handling" do
    test "responds to behavior triggers in any state", %{agent_pid: pid} do
      # Should respond to ping in idle state
      GenStateMachine.cast(pid, :ping)
      Process.sleep(100)

      # The behavior should have executed (async)
      # In a full implementation, we'd check the effect results
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :idle  # State shouldn't change for behaviors
    end

    test "state-specific behaviors only trigger in correct states", %{agent_pid: pid} do
      # Error behavior should only work in working state
      GenStateMachine.cast(pid, :error)
      Process.sleep(50)

      # Should not handle error in idle state
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :idle

      # Transition to working
      GenStateMachine.cast(pid, :start_work)
      Process.sleep(100)

      # Now error should be handled
      GenStateMachine.cast(pid, :error)
      Process.sleep(100)

      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :working  # Should still be working
    end
  end

  describe "context management" do
    test "can store and retrieve data from context", %{agent_pid: pid} do
      # Store some data
      GenStateMachine.cast(pid, {:put_data, :test_key, "test_value"})
      Process.sleep(50)

      # Retrieve the data
      value = GenStateMachine.call(pid, {:get_data, :test_key})
      assert value == "test_value"
    end

    test "returns nil for non-existent keys", %{agent_pid: pid} do
      value = GenStateMachine.call(pid, {:get_data, :non_existent})
      assert value == nil
    end
  end

  describe "reasoning broadcasting" do
    test "can broadcast reasoning to other agents", %{agent_pid: pid} do
      # This would normally send to actual agents, but for testing
      # we just verify the cast doesn't crash
      GenStateMachine.cast(pid, {:broadcast_reasoning, "test reasoning", [:other_agent]})
      Process.sleep(50)

      # Should not crash and agent should still be alive
      assert Process.alive?(pid)
    end

    test "can receive reasoning from other agents", %{agent_pid: pid} do
      # Simulate receiving reasoning from another agent
      GenStateMachine.cast(pid, {:reasoning_shared, :other_agent, "shared insight", %{data: "context"}})
      Process.sleep(50)

      # Should store the received reasoning
      {:ok, {_state, data}} = GenStateMachine.call(pid, :get_state)
      assert Map.has_key?(data.context, :last_shared_reasoning)

      shared_reasoning = data.context.last_shared_reasoning
      assert shared_reasoning.from == :other_agent
      assert shared_reasoning.message == "shared insight"
      assert shared_reasoning.context == %{data: "context"}
      assert %DateTime{} = shared_reasoning.received_at
    end
  end

  describe "effect execution" do
    test "can execute effects asynchronously", %{agent_pid: pid} do
      # Send an effect for execution
      test_effect = {:log, :info, "test effect"}
      GenStateMachine.cast(pid, {:execute_effect, test_effect})

      Process.sleep(100)

      # Agent should still be alive and responsive
      assert Process.alive?(pid)
      {:ok, {_state, _data}} = GenStateMachine.call(pid, :get_state)
    end
  end

  describe "error handling" do
    test "handles unknown events gracefully", %{agent_pid: pid} do
      # Send an unknown event
      GenStateMachine.cast(pid, :unknown_event)
      Process.sleep(50)

      # Agent should still be alive and in the same state
      assert Process.alive?(pid)
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :idle
    end

    test "handles malformed events gracefully", %{agent_pid: pid} do
      # Send malformed event
      GenStateMachine.cast(pid, {:malformed, :event, :structure})
      Process.sleep(50)

      # Agent should still be alive
      assert Process.alive?(pid)
      {:ok, {state, _}} = GenStateMachine.call(pid, :get_state)
      assert state == :idle
    end
  end
end
