#!/usr/bin/env elixir

# Example Runner - Properly starts Autogentic system for examples
# Usage: elixir run_example.exs path/to/example.exs

defmodule ExampleRunner do
  def run(example_path) do
    IO.puts("🚀 Starting Autogentic Example Runner")
    IO.puts("Example: #{example_path}")
    IO.puts(String.duplicate("=", 50))

    # Start the necessary Autogentic components
    start_autogentic_system()

    # Load and run the example
    try do
      Code.compile_file(example_path)
      IO.puts("✅ Example completed successfully!")
    rescue
      error ->
        IO.puts("❌ Example failed: #{inspect(error)}")
    end
  end

  defp start_autogentic_system do
    IO.puts("🔧 Starting Autogentic system components...")

    # Start the effects engine
    case Autogentic.Effects.Engine.start_link([]) do
      {:ok, _pid} -> IO.puts("✅ Effects Engine started")
      {:error, {:already_started, _}} -> IO.puts("✅ Effects Engine already running")
      error -> IO.puts("❌ Failed to start Effects Engine: #{inspect(error)}")
    end

    # Start the reasoning engine
    case Autogentic.Reasoning.Engine.start_link([]) do
      {:ok, _pid} -> IO.puts("✅ Reasoning Engine started")
      {:error, {:already_started, _}} -> IO.puts("✅ Reasoning Engine already running")
      error -> IO.puts("❌ Failed to start Reasoning Engine: #{inspect(error)}")
    end

    # Start the learning coordinator
    case Autogentic.Learning.Coordinator.start_link([]) do
      {:ok, _pid} -> IO.puts("✅ Learning Coordinator started")
      {:error, {:already_started, _}} -> IO.puts("✅ Learning Coordinator already running")
      error -> IO.puts("❌ Failed to start Learning Coordinator: #{inspect(error)}")
    end

    IO.puts("🎯 Autogentic system ready!")
  end
end

# Get the example path from command line arguments
case System.argv() do
  [example_path] ->
    ExampleRunner.run(example_path)
  [] ->
    IO.puts("Usage: elixir run_example.exs path/to/example.exs")
    IO.puts("\nAvailable examples:")
    IO.puts("  basic/hello_agent.exs")
    IO.puts("  basic/effects_showcase.exs")
    IO.puts("  basic/learning_agent.exs")
    IO.puts("  coordination/deployment_team.exs")
    IO.puts("  reasoning/decision_maker.exs")
    IO.puts("  real_world/data_pipeline.exs")
  _ ->
    IO.puts("Error: Please provide exactly one example path")
end
