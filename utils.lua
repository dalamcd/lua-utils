---@diagnostic disable: lowercase-global

--#region Pretty print methods
function print_table(table, idx)
	idx = idx or 1
	if idx > 20 then return end
	local tabStr = ""
	for i=1, idx-1 do tabStr = tabStr .. "|    " end
	for k, v in pairs(table) do
		--if k == "target" then -- skip the target table because it's huge when it's a class
		if type(v) == "table" then
			print(string.format("%s(table) %s:", tabStr, k))
			print_table(v, idx + 1)
		else
			print(string.format("%s%s: %s", tabStr, k, v))
		end
	end
end

-- Prints a table as a simple list without keys
function print_array(table)
	local str = "{ "
	for _, value in ipairs(table) do
		str = str .. tostring(value) .. ", "
	end
	str = str:sub(1, #str-2) .. " }"

	print(str)
end
--#endregion

--#region Stringify functions
function stringify_table(tbl, idx)
	idx = idx or 1
	if idx > 20 then return '"<table depth exceeded>",\n' end
	local tabStr = string.rep('\t', idx)
	local str = '{\n'

	-- There is probably a way to reorder this to be a little more sensible,
	-- but for now it works
	for k, v in pairs(tbl) do
		if type(v) == 'table' then
			if type(k) == 'number' then
				str = str .. tabStr .. stringify_table(v, idx + 1)
			elseif type(k) == 'string' then
				str = str .. tabStr .. k .. ' = ' .. stringify_table(v, idx + 1)
			end
		elseif type(v) == 'function' then
			if type(k) == 'number' then
					str = str .. tabStr .. '"<function value>",\n'
				elseif type(k) == 'string' then
					str = str .. tabStr .. k .. ' = "<function value>",\n'
				end
		elseif type(k) == 'number' then
			if type(v) == 'number' then
				str = str .. tabStr .. v .. ',\n'
			elseif type(v) == 'string' then
				str = str .. tabStr .. '"' .. v .. '"' .. ',\n'
			end
		elseif type(k) == 'string' then
			if type(v) == 'number' then
				str = str .. tabStr .. k .. ' = ' .. v .. ',\n'
			elseif type(v) == 'string' then
				str = str .. tabStr .. k .. ' = ' .. '"' .. v .. '"' .. ',\n'
			end
		end
	end
	str = str .. tabStr:sub(1, #tabStr-1)
	if #tabStr > 1 then str = str .. '},\n' else str = str .. '}' end
	return str
end
--#endregion

--#region Vectors and vector functions

function vector(x, y)
	return {x = x, y = y}
end

function distance(x1, y1, x2, y2) 
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function normalize(vec)
	local mag = magnitude(vec)
	return vector(vec.x/mag, vec.y/mag)
end

function magnitude(vec)
	return math.sqrt(vec.x^2 + vec.y^2)
end

function dotprod(a, b)
	return a.x*b.x + a.y*b.y
end
--#endregion

--#region String functions
function starts_with(str, start)
	return str:sub(1, #start) == start
end
--#endregion

--#region Math functions
function frexp(x)
	local abs ,floor, log = math.abs, math.floor, math.log
	local log2 = log(2)

	if x == 0 then return 0.0, 0.0 end
	local e = floor(log(abs(x)) / log2)
	if e > 0 then
		x = x * 2^-e
	else
		x = x / 2^e
	end
	if abs(x) >= 1.0 then
		x, e = x/2, e+1
	end
	return x, e
end

-- returns a table of bits, most significant first.
function toBits(num, bits)
    bits = bits or math.max(1, select(2, frexp(num)))
    local output = {}
    for b = bits, 1, -1 do
        output[b] = math.fmod(num, 2)
        num = math.floor((num - output[b]) / 2)
    end
    return output
end

function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function clamp(val, lower, upper)
    assert(val and lower and upper, "one of val, upper, lower not supplied")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function squash(val, min, max, newMin, newMax)
	local norm = (val - min)/(max - min)

	return norm*(newMax - newMin) + newMin
end

--#endregion

--#region Table functions

-- perform a function on every element of an array and return a 
-- new array composed of the modified elements
function fmap(tbl, f)
	local t = {}
	for k,v in pairs(tbl) do
		t[k] = f(v)
	end
	return t
end

function concatTables(t1, t2)
	-- TODO: I think this is faster if you use rawset()
	nt = {}
	n = 0
	for _,v in ipairs(t1) do n=n+1; nt[n]=v end
	for _,v in ipairs(t2) do n=n+1; nt[n]=v end
	return nt
end
--#endregion
