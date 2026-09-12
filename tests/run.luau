--!strict
-- Lune-based unit tests for the pure-Luau shared modules.
-- Run with: lune run tests/run.luau

local process = require("@lune/process")

local Greeter = require("../src/shared/Greeter")

local passed = 0
local failed = 0

local function expectEqual(name: string, got: unknown, want: unknown)
	if got == want then
		passed += 1
		print(`ok   - {name}`)
	else
		failed += 1
		print(`FAIL - {name}: got {tostring(got)}, want {tostring(want)}`)
	end
end

expectEqual("hello formats name", Greeter.hello("World"), "Hello, World!")
expectEqual("add sums numbers", Greeter.add(2, 3), 5)
expectEqual("add handles negatives", Greeter.add(-4, 1), -3)

print(`\n{passed} passed, {failed} failed`)

if failed > 0 then
	process.exit(1)
end
