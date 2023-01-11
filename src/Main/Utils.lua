local Utils = {}

local PluralRblxDatatypes = {
	UDim = UDim2,
	Vector2 = Vector3
}

function Utils.TableKeys(tbl)
	if not tbl then return end
	local keys = table.create(#tbl)
	for key,_ in tbl do table.insert(keys,key) end
	return keys
end

local ParseResponse = require(script.Parent.ParseResponse)
function Utils.ParseValue(key, val, config, unparsedData, parsedData)
	local parseFuncs = config.ParseFuncs
	local selfData = {config=config, key=key}
	local response = ParseResponse()

	local parsingValue = val
	for _,parseFunc in parseFuncs do
		parsingValue = parseFunc(parsingValue, response, selfData, unparsedData, parsedData)
	end

	return parsingValue or config.DefaultValue, response.Overwrites
end
function Utils.TableIsolateValuesWhereKeys(tbl, keyName)
	local isolatedValues = table.create(#tbl)
	
	for _,_val in tbl do
		for key,val in _val do
			if key ~= keyName then continue end
			table.insert(isolatedValues, val)
		end
	end
	
	return isolatedValues
end
function Utils.TableFilterByKeyEqualsVal(tbl, keyName, valName)
	local filteredTbl = {}
	for _key,_val in tbl do
		for key,val in _val do

			if (key ~= keyName) or (val ~= valName) then continue end
			filteredTbl[_key] = _val
		end
	end
	return filteredTbl
end

function Utils.CombineFrags(datafrags)
	-- Makes Sure All Datafrags Are Of The Same Type.
	local fragsType
	for name,vals in datafrags do
		if fragsType then if fragsType ~= typeof(vals.Value) then return end
		else fragsType = typeof(vals.Value) end
	end
	
	-- Makes Sure All Of The Datafrags Are In The Correct Order.
	table.sort(datafrags, function(a, b)
		return a.Order < b.Order
	end)
	
	-- Adds The Datafrags Together
	local pluralRblxDatatype = PluralRblxDatatypes[fragsType]
	
	local datatypeValue = pluralRblxDatatype.new(
		table.unpack(Utils.TableIsolateValuesWhereKeys(datafrags, "Value"))
	)
	
	return datatypeValue
end

function Utils.QuickInsert(src: {[any]: any}, items: {[any]: any}, index: number)
	table.move(src, index, #src, index + #items)
	table.move(items, 1, #items, index, src)
end

return Utils
