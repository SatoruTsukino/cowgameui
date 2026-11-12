-- Minimal observable key/value store shared by all HUD components.

local State = {}
State.__index = State

function State.new(initial: { [string]: any })
	return setmetatable({ _values = table.clone(initial), _listeners = {} }, State)
end

function State:get(key: string): any
	return self._values[key]
end

function State:set(key: string, value: any)
	if self._values[key] == value then
		return
	end
	self._values[key] = value
	local listeners = self._listeners[key]
	if listeners then
		for _, listener in table.clone(listeners) do
			listener(value)
		end
	end
end

function State:toggle(key: string)
	self:set(key, not self._values[key])
end

-- Calls `listener` now and on every change. Returns a disconnect function.
function State:observe(key: string, listener: (any) -> ()): () -> ()
	local listeners = self._listeners[key]
	if not listeners then
		listeners = {}
		self._listeners[key] = listeners
	end
	table.insert(listeners, listener)
	listener(self._values[key])
	return function()
		local index = table.find(listeners, listener)
		if index then
			table.remove(listeners, index)
		end
	end
end

return State
