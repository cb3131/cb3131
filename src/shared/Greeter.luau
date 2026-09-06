--!strict
-- Pure-Luau module shared between the server and client.
-- Kept free of Roblox globals so it can be unit-tested with Lune outside Studio.

local Greeter = {}

function Greeter.hello(name: string): string
	return `Hello, {name}!`
end

function Greeter.add(a: number, b: number): number
	return a + b
end

return Greeter
