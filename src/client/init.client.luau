--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Greeter = require(ReplicatedStorage.Shared.Greeter)

local localPlayer = Players.LocalPlayer
print(Greeter.hello(localPlayer.Name))
