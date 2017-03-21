--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
-- Modify by ZhangMinglin 2017/03/21

local log = { _version = "0.1.0" }

log.usecolor = true
log.showdate = true
log.outfile = nil
log.level = "trace"
log.fp = nil

local modes = {
  { name = "trace", color = "\27[34m", },
  { name = "debug", color = "\27[36m", },
  { name = "info",  color = "\27[32m", },
  { name = "warn",  color = "\27[33m", },
  { name = "error", color = "\27[31m", },
  { name = "fatal", color = "\27[35m", },
}


local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end


local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end


local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = round(x, .01)
    end
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end


for i, x in ipairs(modes) do
  local nameupper = x.name:upper()
  log[x.name] = function(self, ...)
    
    -- Return early if we're below the log level
    if i < levels[self.level] then
      return
    end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline
	
    -- Output to console
    print(string.format("%s[%-6s%s]%s %s: %s",
                        self.usecolor and x.color or "",
                        nameupper,
                        self.showdate and os.date("%H:%M:%S") or "",
                        self.usecolor and "\27[0m" or "",
                        lineinfo,
                        msg))

    -- Output to log file
    if self.fp then
      local str = string.format("[%-6s%s] %s: %s\n",
                                nameupper,
								self.showdate and os.date("%H:%M:%S") or "",
								lineinfo,
								 msg)
      self.fp:write(str)
	  self.fp:flush()
    end

  end
end

-- create
--@param file_name log's file path
--@param usecolor  Is use color
--@param showdate Is show date
--@return log's object
function log:new(file_name, usecolor, showdate)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	if file_name then
		o.outfile = file_name
		o.fp = io.open(o.outfile, "w+")
	end
	
	if not (usecolor == nil) then o.usecolor = usecolor end
	if not (showdate == nil) then o.showdate = showdate end
	
	return o
end

-- close
function log:close()
	if self.fp then
		self.fp:close()
	end
end

return log
