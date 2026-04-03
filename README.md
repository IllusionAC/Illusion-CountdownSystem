# Illusion-CountdownSystem
Simple Countdown system to place in ReplicatedStorage.

Usage:
Countdown.luau inside ReplicatedStorage

ServerScript (Model using a Script with RunContext to server, inside Countdown.luau):
```luau
local Countdown = require("../Countdown")

game.Players.PlayerAdded:Connect(function(player)
	task.wait(2)
	Countdown.Start(player, 5, "Time Left")
	
	-- Force stop after 2 seconds
	-- task.wait(2)
	-- Countdown.Stop(player)
end)
```

ClientScript (Model using a Script with RunContext to client, inside Countdown.luau):
```luau
local Countdown = require("../Countdown")

-- When server starts couldown, client is ready
Countdown.ClientInit()
```
