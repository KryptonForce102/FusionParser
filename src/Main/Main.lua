local FluidParser = {}
FluidParser.GlobalVars = {}

local Utils = require(script.Parent.Utils)
local TableKeys, ParseValue = Utils.TableKeys, Utils.ParseValue

local DataConfig = require(script.Parent.Parent.DataConfig.Config)
local DatatypesConfig, DatafragsConfig, DatagroupsConfig = DataConfig.Datatypes, DataConfig.Datafrags, DataConfig.Datagroups
local DatatypesConfigKeys, DatafragsConfigKeys, DatagroupsConfigKeys = TableKeys(DatatypesConfig), TableKeys(DatafragsConfig), TableKeys(DatagroupsConfig)

local function parseDatatype(key,val, unparsedData,parsedData)
	local config = DatatypesConfig[key]; local datatypeID = config.ID

	local parsedValue, overwrites = ParseValue(key,val, config, unparsedData,parsedData)
	local subInst = overwrites.SubInstance or config.SubInstance

	-- If "parsedValue" Is Part of a SubInstance.
	if subInst then
		if not parsedData[subInst] then parsedData[subInst] = {} end
		if datatypeID then parsedData[subInst][datatypeID] = parsedValue end

		-- If "parsedValue" Is Not Part of a SubInstance.
	else parsedData[datatypeID] = parsedValue end
end

local function parseDatafrag(key,val, unparsedData,parsedData, datafrags)
	local config = DatafragsConfig[key]; local datafragID = config.ID
	if not datafrags[datafragID] then datafrags[datafragID] = {} end

	table.insert(
		datafrags[datafragID],
		{Name=key, Value=ParseValue(key,val, config, unparsedData,parsedData) or config.DefaultValue, Order=config.Order}
	)
end

local function parseDatagroup(key,val, unparsedData,parsedData)
	local config = DatagroupsConfig[key]; local datatypeID = config.ID

	local separated = tostring(val):split(" ")
	
	local chosenCombination
	for _,currCombination in config.Combinations do
		if #currCombination ~= #separated then continue end
		chosenCombination = currCombination
		break  
	end

	for sepKey,sepVal in separated do
		local sepCombinations = chosenCombination[sepKey]
		
		for _,name in sepCombinations do
			parseDatatype(name,sepVal, unparsedData, parsedData)
		end


	end
end

function FluidParser.Parse(unparsedData)
	local parsedData, datafrags, variables = {}, {}, {}
	
	-- Gets All Of The Variables From "unparsedData".
	for key,val in unparsedData do
		if typeof(key) ~= "string" then continue end
		if not key:match("^__%a+") then continue end
		variables[key:gsub("^__", "")] = val
	end
	
	for key,val in unparsedData do
		if typeof(key) == "string" then
			-- Continues If A Variable.
			if key:match("^__%a+") then continue
				
			-- Continues And Adds "key" And "val" To "rawDara" If Raw Data.
			elseif key:match("^%$") then parsedData[key:gsub("^%$", "")] = val; continue end
		end
		
		-- Replaces All Variables With Their Values.
		if type(val) == "string" then
			for _,match in val:gmatch("(__)(%a+)") do
				local replacement = variables[match] or FluidParser.GlobalVars[match] or `__{match}`
				if typeof(replacement) ~= "string" then val = replacement break end
				
				replacement = replacement:gsub("%%", "%%%%")
				val = val:gsub(`__{match}`, replacement)
			end
		end
		
		-- If A Datatype.
		if table.find(DatatypesConfigKeys, key) then
			parseDatatype(key,val, unparsedData, parsedData)
			continue
		end
		
		-- If A Datafrag.
		if table.find(DatafragsConfigKeys, key) then
			parseDatafrag(key,val, unparsedData,parsedData, datafrags)
			continue
		end
		
		-- If A Datagroup.
		if table.find(DatagroupsConfigKeys, key) then
			parseDatagroup(key,val, unparsedData,parsedData)
		end
		
	end
	
	-- Combines All Datafrags Together.
	for datafragID, datafragVals in datafrags do
		-- Gets All Datafrags With The ID Of "datafragID" From "DatafragsConfig".
		local datafragsWithIDConfig = Utils.TableFilterByKeyEqualsVal(DatafragsConfig, "ID", datafragID)
		local datafragsWithIDConfigKeys = Utils.TableKeys(datafragsWithIDConfig)
		
		-- Gets A List Of The Current Datafrags.
		local currentDatafrags = table.create(#datafrags)
		for _,val in datafragVals do table.insert(currentDatafrags, val.Name) end
		
		-- Inserts The Missing Datafrags (With Their Default Value) Into "datafragVals".
		for key,config in datafragsWithIDConfig do
			if table.find(currentDatafrags, key) then continue end
			table.insert(
				datafragVals,
				{Name=key, Value=config.DefaultValue, Order=config.Order}
			)
		end
		
		-- Combines All Of The Datafrags Together
		parsedData[datafragID] = Utils.CombineFrags(datafragVals)
	end
	
	return parsedData
end

FluidParser.ApplyProps = function(inst, props)

	local parsedProps = FluidParser.Parse(props)

	for key,val in parsedProps do
		if typeof(val) == "table" then -- if a sub inst
			local subInst = inst:FindFirstChildOfClass(key)
			if not subInst then subInst = Instance.new(key) end 

			for key2,val2 in val do  subInst[key2] = val2 end
			subInst.Parent = inst

		else -- if not a sub inst
			inst[key] = val
		end
	end
end

FluidParser.ParseFusion = function(unparsedData)
	local fusionChildrenKey, fusionChildrenVal = FluidParser.Fusion.Children, {}
	local fusionRefKey, fusionRefVal
	local fusionOnEvents = {}

	for key,val in unparsedData do
		if typeof(key) ~= "table" then continue end
		if key.kind == "Children" then
			fusionChildrenKey, fusionChildrenVal = key, val
		elseif key.kind == "Ref"  then
			fusionRefKey, fusionRefVal = key, val
		else
			fusionOnEvents[key] = val
		end
	end

	local parsedData = FluidParser.Parse(unparsedData)

	-- replaces incorrect property keys with the correct ones
	for key,val in parsedData do
		if key=="AutomaticCanvasSize" then
			parsedData["CanvasSize"] = UDim2.fromScale(0,0)
		end

		if typeof(val) ~= "table" then continue end
		if key == "UIStroke" then
			for key2,val2 in val do
				if key2 == "BackgroundTransparency" then
					val["Transparency"] = val2
					val[key2] = nil
				end
			end
		end

	end

	for key,val in parsedData do
		if typeof(val) ~= "table" then continue end
		table.insert(fusionChildrenVal, FluidParser.Fusion.New(key)(val))
		parsedData[key] = nil
	end

	if fusionChildrenKey then parsedData[fusionChildrenKey] = fusionChildrenVal end
	if fusionRefKey then parsedData[fusionRefKey] = fusionRefVal end
	for key,val in fusionOnEvents do parsedData[key] = val end

	return parsedData
end

return FluidParser
