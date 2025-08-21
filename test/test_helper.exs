ExUnit.start()

# Start the PubSub system for testing
{:ok, _} = Application.ensure_all_started(:autogentic)
