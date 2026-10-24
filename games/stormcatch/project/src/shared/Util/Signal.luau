--!strict
-- Minimal signal for module-to-module events (game-side; uses task.spawn so handlers cannot block the emitter).

local Signal = {}
Signal.__index = Signal

export type Connection = { Disconnect: (self: Connection) -> (), connected: boolean }

export type Signal<T...> = typeof(setmetatable({} :: { _handlers: { [Connection]: (T...) -> () } }, Signal))

function Signal.new<T...>(): Signal<T...>
	return setmetatable({ _handlers = {} }, Signal) :: any
end

function Signal.Connect<T...>(self: Signal<T...>, handler: (T...) -> ()): Connection
	local handlers = self._handlers
	local connection = { connected = true } :: any
	function connection.Disconnect(conn: Connection)
		conn.connected = false
		handlers[conn] = nil
	end
	handlers[connection] = handler
	return connection
end

function Signal.Fire<T...>(self: Signal<T...>, ...: T...)
	for _, handler in self._handlers do
		task.spawn(handler, ...)
	end
end

function Signal.DisconnectAll<T...>(self: Signal<T...>)
	table.clear(self._handlers)
end

return Signal
