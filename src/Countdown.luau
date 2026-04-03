--!strict
-- Countdown.luau

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CountdownEvent: RemoteEvent = script:FindFirstChild("CountdownEvent") :: RemoteEvent

if not CountdownEvent then
	CountdownEvent = Instance.new("RemoteEvent")
	CountdownEvent.Name = "CountdownEvent"
	CountdownEvent.Parent = script
end

local Countdown = {}

local activeServerTimers: {[Player]: number} = {}

local activeClientConnection: RBXScriptConnection? = nil

local function formatTime(seconds: number): string
	local minutes = math.floor(seconds / 60)
	local remaining = seconds % 60
	return string.format("%02d:%02d", minutes, remaining)
end

local function cleanupClient()
	if activeClientConnection then
		activeClientConnection:Disconnect()
		activeClientConnection = nil
	end
end

function Countdown.Start(player: Player, duration: number, label: string?)
	if not RunService:IsServer() then return end
	if duration <= 0 then return end

	local endTime = workspace:GetServerTimeNow() + duration
	local timerId = os.clock()

	activeServerTimers[player] = timerId

	CountdownEvent:FireClient(player, endTime, label)

	task.delay(duration, function()
		if activeServerTimers[player] == timerId then
			Countdown.Stop(player)
		end
	end)
end

function Countdown.Stop(player: Player, label: string?)
	if not RunService:IsServer() then return end

	if activeServerTimers[player] then
		CountdownEvent:FireClient(player, workspace:GetServerTimeNow(), label)
		activeServerTimers[player] = nil
	end
end

Players.PlayerRemoving:Connect(function(player)
	activeServerTimers[player] = nil
end)

function Countdown.ClientInit()
	if not RunService:IsClient() then return end

	CountdownEvent.OnClientEvent:Connect(function(endTime: number, label: string?)
		cleanupClient()

		local lastSecond = -1

		activeClientConnection = RunService.Heartbeat:Connect(function()
			local remaining = math.max(0, math.ceil(endTime - workspace:GetServerTimeNow()))

			if remaining ~= lastSecond then
				lastSecond = remaining

				print(label or "Time Left", formatTime(remaining))
			end

			if remaining <= 0 then
				cleanupClient()
			end
		end)
	end)
end

return Countdown
