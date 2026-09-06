--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Greeter = require(ReplicatedStorage.Shared.Greeter)

print(Greeter.hello("Roblox server"))
print(`2 + 3 = {Greeter.add(2, 3)}`)
