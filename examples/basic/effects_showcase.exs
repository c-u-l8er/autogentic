#!/usr/bin/env elixir

# Effects Showcase - Demonstrating Autogentic's Powerful Effects System
# This example shows various types of effects and how to compose them

defmodule EffectsShowcase do
  def run do
    IO.puts("🎭 Autogentic Effects Showcase")
    IO.puts(String.duplicate("=", 50))

    # Basic Effects
    basic_effects_demo()

    # Sequence Effects
    sequence_effects_demo()

    # Parallel Effects
    parallel_effects_demo()

    # Error Handling
    error_handling_demo()

    IO.puts("\n✨ Effects showcase completed!")
  end

  defp basic_effects_demo do
    IO.puts("\n1. 🔹 Basic Effects Demo")
    IO.puts(String.duplicate("-", 30))

    # Simple logging effect
    IO.puts("📝 Executing log effect...")
    {:ok, result} = Autogentic.execute_effect({:log, :info, "Hello from Autogentic!"})
    IO.puts("Result: #{inspect(result)}")

    # Data storage effect
    IO.puts("\n💾 Storing data...")
    context = %{user: "Alice", session: "demo"}
    {:ok, updated_context} = Autogentic.execute_effect({:put_data, :timestamp, DateTime.utc_now()}, context)
    IO.puts("Updated context: #{inspect(updated_context, pretty: true)}")

    # Event emission
    IO.puts("\n📡 Emitting event...")
    {:ok, _} = Autogentic.execute_effect({:emit_event, :demo_completed, %{module: "EffectsShowcase"}})
  end

  defp sequence_effects_demo do
    IO.puts("\n2. 🔗 Sequence Effects Demo")
    IO.puts(String.duplicate("-", 30))

    # Create a sequence of effects that build on each other
    workflow = {:sequence, [
      {:log, :info, "Starting workflow..."},
      {:put_data, :workflow_id, "WF-001"},
      {:put_data, :status, :in_progress},
      {:delay, 50}, # Simulate processing time
      {:put_data, :processed_items, 42},
      {:put_data, :status, :completed},
      {:log, :info, "Workflow completed!"},
      {:emit_event, :workflow_finished, %{id: "WF-001", items: 42}}
    ]}

    IO.puts("⚡ Executing workflow sequence...")
    start_time = System.monotonic_time(:millisecond)
    {:ok, final_context} = Autogentic.execute_effect(workflow)
    end_time = System.monotonic_time(:millisecond)

    IO.puts("✅ Sequence completed in #{end_time - start_time}ms")
    IO.puts("Final context: #{inspect(final_context, pretty: true)}")
  end

  defp parallel_effects_demo do
    IO.puts("\n3. ⚡ Parallel Effects Demo")
    IO.puts(String.duplicate("-", 30))

    # Execute multiple independent effects simultaneously
    parallel_tasks = {:parallel, [
      {:delay, 100}, # Simulate different processing times
      {:put_data, :task_a, "completed"},
      {:put_data, :task_b, "completed"},
      {:put_data, :task_c, "completed"},
      {:log, :info, "Parallel task executed"}
    ]}

    IO.puts("🚀 Executing parallel tasks...")
    start_time = System.monotonic_time(:millisecond)
    {:ok, result_context} = Autogentic.execute_effect(parallel_tasks, %{batch_id: "BATCH-001"})
    end_time = System.monotonic_time(:millisecond)

    IO.puts("✅ Parallel execution completed in #{end_time - start_time}ms")
    IO.puts("Result: #{inspect(result_context, pretty: true)}")
  end

  defp error_handling_demo do
    IO.puts("\n4. 🚨 Error Handling Demo")
    IO.puts(String.duplicate("-", 30))

    # Try an unknown effect to see error handling
    IO.puts("🔍 Testing unknown effect...")
    result = Autogentic.execute_effect({:unknown_operation, "this will fail"})
    IO.puts("Result: #{inspect(result)}")

    # Retry mechanism
    IO.puts("\n🔄 Testing retry with compensation...")
    retry_effect = {:retry, {:unknown_effect, "will fail"}, attempts: 3}
    result = Autogentic.execute_effect(retry_effect)
    IO.puts("Retry result: #{inspect(result)}")

    # Compensation pattern
    IO.puts("\n🛡️ Testing compensation pattern...")
    compensation = {:with_compensation,
      {:invalid, "primary fails"},
      {:log, :warn, "Fallback executed"}
    }
    {:ok, _} = Autogentic.execute_effect(compensation)
    IO.puts("Compensation handled gracefully!")
  end
end

# Auto-run the example
EffectsShowcase.run()
