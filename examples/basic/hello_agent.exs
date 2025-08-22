#!/usr/bin/env elixir

# Hello World - Your First Autogentic Agent
# This example shows how to create a simple agent that responds to messages

defmodule HelloAgent do
  use Autogentic.Agent, name: :hello_agent

  agent :hello_agent do
    capability [:greeting, :conversation]
    reasoning_style :friendly
    initial_state :waiting
  end

  state :waiting do
    # Agent is ready and waiting for interactions
  end

  state :responding do
    # Agent is actively responding to a message
  end

  # Transition: respond to greetings
  transition from: :waiting, to: :responding, when_receives: :greet do
    sequence do
      log(:info, "Received a greeting!")
      put_data(:last_greeted_at, DateTime.utc_now())
      emit_event(:greeting_received, %{agent: :hello_agent})
    end
  end

  # Transition: return to waiting after responding
  transition from: :responding, to: :waiting, when_receives: :finish_response do
    sequence do
      log(:info, "Finished responding, back to waiting")
      put_data(:ready_for_next, true)
    end
  end

  # Behavior: respond to any ping with pong
  behavior :ping_pong, triggers_on: [:ping] do
    sequence do
      log(:debug, "Ping received! Sending pong...")
      put_data(:ping_count, get_ping_count() + 1)
      emit_event(:pong, %{from: :hello_agent, count: get_ping_count()})
    end
  end

  # Helper function to get ping count
  defp get_ping_count do
    # In a real implementation, this would get from agent context
    1
  end

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end
end

# Example usage:
defmodule HelloAgentExample do
  def run do
    IO.puts("🤖 Starting Hello Agent Example")

    # Start the agent
    {:ok, pid} = HelloAgent.start_link(name: :hello_agent)
    IO.puts("✅ Agent started with PID: #{inspect(pid)}")

    # Get initial state
    {state, data} = Autogentic.get_agent_state(pid)
    IO.puts("📊 Initial state: #{state}")
    IO.puts("📋 Agent data: #{inspect(data, pretty: true)}")

    # Send a greeting
    IO.puts("\n📨 Sending greeting...")
    GenStateMachine.cast(pid, :greet)
    Process.sleep(100) # Give it time to process

    # Check state after greeting
    {state, _data} = Autogentic.get_agent_state(pid)
    IO.puts("📊 State after greeting: #{state}")

    # Send a ping
    IO.puts("\n🏓 Sending ping...")
    GenStateMachine.cast(pid, :ping)
    Process.sleep(100)

    # Finish the response cycle
    IO.puts("\n🔄 Finishing response cycle...")
    GenStateMachine.cast(pid, :finish_response)
    Process.sleep(100)

    # Final state
    {state, data} = Autogentic.get_agent_state(pid)
    IO.puts("📊 Final state: #{state}")
    IO.puts("📋 Final data: #{inspect(data.context, pretty: true)}")

    # Clean up
    GenStateMachine.stop(pid)
    IO.puts("\n✨ Example completed!")
  end
end

# Auto-run the example
HelloAgentExample.run()
