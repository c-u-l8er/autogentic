#!/usr/bin/env elixir

# Autogentic Example Runner
# This script properly initializes the Autogentic system and runs examples
# Usage: mix run run_example.exs examples/basic/hello_agent.exs

defmodule AutogenticExampleRunner do
  @moduledoc """
  Runner for Autogentic examples that ensures the system is properly initialized.
  """

  def run(example_path) do
    IO.puts("🚀 Autogentic v2.0 Example Runner")
    IO.puts("Example: #{Path.basename(example_path)}")
    IO.puts(String.duplicate("=", 60))

    # Ensure the system is ready
    ensure_system_ready()

    # Run the example
    IO.puts("\n🎬 Running example...")

    try do
      # Load and execute the example file
      modules = Code.compile_file(example_path)

      # Find a module that has a run/0 function and execute it
      case Enum.find(modules, fn {module, _} -> function_exported?(module, :run, 0) end) do
        {module, _} ->
          apply(module, :run, [])
        nil ->
          IO.puts("Example loaded successfully!")
      end

      IO.puts("\n✨ Example completed successfully!")

    rescue
      error ->
        IO.puts("\n❌ Example failed with error:")
        IO.puts(inspect(error, pretty: true))
        IO.puts("\nStacktrace:")
        IO.puts(Exception.format_stacktrace(__STACKTRACE__))
    end
  end

  defp ensure_system_ready do
    IO.puts("🔧 Ensuring Autogentic system is ready...")

    # The system should already be started by Mix, but let's verify
    processes = [
      {Autogentic.Effects.Engine, "Effects Engine"},
      {Autogentic.Reasoning.Engine, "Reasoning Engine"},
      {Autogentic.Learning.Coordinator, "Learning Coordinator"}
    ]

    Enum.each(processes, fn {module, name} ->
      case Process.whereis(module) do
        nil -> IO.puts("⚠️  #{name} not running (this is normal for some examples)")
        _pid -> IO.puts("✅ #{name} is running")
      end
    end)

    IO.puts("🎯 System check complete!")
  end

  def show_available_examples do
    IO.puts("\n🎯 Available examples:")

    examples = [
      {"examples/basic/hello_agent.exs", "Your first Autogentic agent"},
      {"examples/basic/effects_showcase.exs", "Comprehensive effects demonstration"},
      {"examples/basic/learning_agent.exs", "Adaptive behavior and learning"},
      {"examples/coordination/deployment_team.exs", "Multi-agent deployment workflow"},
      {"examples/reasoning/decision_maker.exs", "Advanced reasoning capabilities"},
      {"examples/real_world/data_pipeline.exs", "Enterprise data processing pipeline"}
    ]

    Enum.each(examples, fn {path, description} ->
      IO.puts("  #{path}")
      IO.puts("    #{description}")
    end)

    IO.puts("\n💡 Example usage:")
    IO.puts("  mix run run_example.exs examples/basic/hello_agent.exs")
  end
end

# Main execution
case System.argv() do
  [example_path] ->
    if File.exists?(example_path) do
      AutogenticExampleRunner.run(example_path)
    else
      IO.puts("❌ Example file not found: #{example_path}")
      AutogenticExampleRunner.show_available_examples()
    end

  [] ->
    IO.puts("📚 Autogentic v2.0 Example Runner")
    IO.puts("Usage: mix run run_example.exs <example_path>")
    AutogenticExampleRunner.show_available_examples()

  _ ->
    IO.puts("❌ Please provide exactly one example path")
    IO.puts("Usage: mix run run_example.exs <example_path>")
end
