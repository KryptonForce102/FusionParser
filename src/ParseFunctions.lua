local ParseFunctions = {}

local Utils = require(script.Parent.Utils)

function ParseFunctions.ScaleAndOffset(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if type(unparsedValue) == "number" then return UDim.new(unparsedValue, 0) end
	
	local parsedListFirstPass, parsedListSecondPass = {}, {}
	local scaleVals, offsetVals = {},{}

	-- Turns "unparsedValue" into A List.
	unparsedValue = unparsedValue:gsub("[^%d px%%+-/*]", "")
	unparsedValue = Utils.WsConds(unparsedValue); local unparsedList = unparsedValue:split(" ")
	
	-- Combines "val" With The Previous Entry In "unparsedList" If It's A Basic Operator Or If It Starts With An Advanced Operator.
	for index,val in unparsedList do
		if table.find(Utils.Ops, val) then continue end
		
		if not Utils.StartsWithBasicOp(val) then
			local prevVal = unparsedList[index-1]
			if table.find(Utils.OpsBasic, prevVal) then val = prevVal..val
			elseif table.find(Utils.OpsAdvanced, prevVal) then val = `{prevVal} {val}` end
		end
		
		table.insert(parsedListFirstPass, val)
	end
	
	-- Combines "val" With The Next Entry In "parsedListFirstPass" If It Starts With An Advanced Operator.
	for index,val in parsedListFirstPass do
		if Utils.StartsWithAdvancedOp(val) then continue end
		
		local nextVal = parsedListFirstPass[index+1]
		if nextVal and Utils.StartsWithAdvancedOp(nextVal) and (not Utils.IsScaleOrOffset(nextVal)) then
			val ..= ` {nextVal}`
		end
		
		table.insert(parsedListSecondPass, val)
	end
	
	-- Performs A Calculation On "val" If It Contains An Advanced Operator
	for index,val in parsedListSecondPass do
		if not Utils.ContainsAdvancedOp(val) then continue end
		local splitVal = val:split(" ")
		local leftNum, op, rightNum = splitVal[1], splitVal[2], tonumber(splitVal[3])
		
		local scaleOrOffset = Utils.IsScaleOrOffset(leftNum)
		leftNum = tonumber(Utils.StripNonNumExpr(leftNum))
		
		if type(scaleOrOffset) ~= "string" then continue end
		
		local calcNum = (op == "/" and (leftNum / rightNum)) or (op == "*" and (leftNum * rightNum))
		calcNum ..= scaleOrOffset == "scale" and "%" or scaleOrOffset == "offset" and "px"
		
		parsedListSecondPass[index] = calcNum
	end
	
	-- Adds "val" To The Correct List ("scaleVals" or "offsetVals").
	for index,val in parsedListSecondPass do
		local isScaleOrOffset, divAmount = Utils.IsScaleOrOffset(val)
		if not isScaleOrOffset then continue end

		val = Utils.StripNonNumExpr(Utils.ReplaceOps(val))
		val = tonumber(val)/divAmount

		if isScaleOrOffset == "scale" then table.insert(scaleVals, val)
		else table.insert(offsetVals, val) end
	end

	-- Adds All Of The Scale Values Together, And All Of The Offset Values Together.
	local scale, offset = 0,0
	table.foreach(scaleVals, function(_,v) scale += v end)
	table.foreach(offsetVals, function(_,v) offset += v end)
	
	return UDim.new(scale, offset)
end

function ParseFunctions.Scale(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if typeof(unparsedValue) ~= "UDim" then return end
	return unparsedValue.Scale
end

function ParseFunctions.Offset(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if typeof(unparsedValue) ~= "UDim" then return end
	return unparsedValue.Offset
end

local autoSizeConvertors = {
	["Width"] = {
		[Enum.AutomaticSize.Y] = Enum.AutomaticSize.XY,
		Default = Enum.AutomaticSize.X
	},
	["Height"] = {
		[Enum.AutomaticSize.X] = Enum.AutomaticSize.XY,
		Default = Enum.AutomaticSize.Y
	},
	
	["CanvasWidth"] = {
		[Enum.AutomaticSize.Y] = Enum.AutomaticSize.XY,
		Default = Enum.AutomaticSize.X
	},
	["CanvasHeight"] = {
		[Enum.AutomaticSize.X] = Enum.AutomaticSize.XY,
		Default = Enum.AutomaticSize.Y
	}
}
function ParseFunctions.Size(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if string.match(unparsedValue, "auto$") then
		local autoSizeKeyName = (selfData.key == "Height" or selfData.key == "Width") and "AutomaticSize" or "AutomaticCanvasSize"
		local autoSize = autoSizeConvertors[selfData.key][parsedData[autoSizeKeyName] or "Default"]
		parsedData[autoSizeKeyName] = autoSize
	end
	return unparsedValue
end

local EmptyUDim = UDim.new()
function ParseFunctions.ContentSize(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if unparsedValue ~= "scaled" then return unparsedValue end
	parsedData["TextScaled"] = true
	return unparsedValue
end

function ParseFunctions.ContentTruncate(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return unparsedValue and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
end

function ParseFunctions.Color(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	
	if (unparsedValue == "transparent") or (unparsedValue == "tp") then
		parsedData["BackgroundTransparency"] = 1
	end
	
	if typeof(unparsedValue) == "BrickColor" then
		return unparsedValue.Color
		
	elseif typeof(unparsedValue) == "Color3" then
		return unparsedValue
		
	elseif string.match(unparsedValue, "^#") then
		return Color3.fromHex(unparsedValue)
	end
end

function ParseFunctions.Integer(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return math.round(tonumber(unparsedValue) or 0)
end
function ParseFunctions.Float(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	unparsedValue = Utils.StripNonNumExpr(unparsedValue)
	return tonumber(unparsedValue)
end

function ParseFunctions.Boolean(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return unparsedValue == true and true or false
end

function ParseFunctions.String(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return tostring(unparsedValue)
end

function ParseFunctions.ScrollBarInset(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if unparsedValue == "true" then return Enum.ScrollBarInset.Always
	elseif unparsedValue:lower() == "scrollbar" then return Enum.ScrollBarInset.ScrollBar end
	return Enum.ScrollBarInset.None
end

function ParseFunctions.Instance(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if typeof(unparsedValue) ~= "Instance" then unparsedValue = nil end
	return unparsedValue
end

function ParseFunctions.BackgroundOpacity(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return 1 - (unparsedValue or 0)
end

anchorPointConvertor = {
	["middle"] = .5,
	["center"] = .5,
	["left"] = 0,
	["right"] = 1,
	["top"] = 0,
	["bottom"] = 1,
}
function ParseFunctions.Anchor(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	-- turns the unparsed value into a list
	unparsedValue = Utils.WsConds(unparsedValue); local unparsedList = unparsedValue:split(" ")

	-- converts to a vector2
	if #unparsedList == 1 then -- if only 1 word
		local convertedValue = anchorPointConvertor[unparsedValue:lower()]
		return Vector2.new(convertedValue, convertedValue)

	elseif #unparsedList == 2 then -- if only 2 words
		return Vector2.new(
			anchorPointConvertor[unparsedList[1]:lower()],
			anchorPointConvertor[unparsedList[2]:lower()]
		)
	end
end

function ParseFunctions.Layout(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	unparsedValue = unparsedValue:lower()

	local subInstance = (unparsedValue == "list" and "UIListLayout") or (unparsedValue == "grid" and "UIGridLayout")
	parseResponse.Overwrites.SubInstance = subInstance
end
function ParseFunctions.GetLayoutSubInstance(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	local layout = (unparsedData["LayoutType"] or unparsedData["Layout"] or ""):lower():split(" ")[1]
	local subInstance = (layout == "list" and "UIListLayout") or (layout == "grid" and "UIGridLayout")
	parseResponse.Overwrites.SubInstance = subInstance
	return unparsedValue
end
local layoutAlignmentConvertor = {
	["X"] = {
		center = Enum.HorizontalAlignment.Center,
		left = Enum.HorizontalAlignment.Left,
		right = Enum.HorizontalAlignment.Right,
		[Enum.HorizontalAlignment.Center] = Enum.HorizontalAlignment.Center,
		[Enum.HorizontalAlignment.Left] = Enum.HorizontalAlignment.Left,
		[Enum.HorizontalAlignment.Right] = Enum.HorizontalAlignment.Right
	},
	["Y"] = {
		bottom = Enum.VerticalAlignment.Bottom,
		center = Enum.VerticalAlignment.Center,
		top = Enum.VerticalAlignment.Top,
		[Enum.VerticalAlignment.Bottom] = Enum.VerticalAlignment.Bottom,
		[Enum.VerticalAlignment.Center] = Enum.VerticalAlignment.Center,
		[Enum.VerticalAlignment.Top] = Enum.VerticalAlignment.Top
	}
}
function ParseFunctions.LayoutAlignment(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	local direction = selfData.key:gsub("LayoutAlignment", "")
	if type(unparsedValue) == "string" then unparsedValue = unparsedValue:lower() end
	return layoutAlignmentConvertor[direction][unparsedValue]
end
local layoutDirectionConvertor = {
	vertical = Enum.FillDirection.Vertical,
	horizontal = Enum.FillDirection.Horizontal,
	y = Enum.FillDirection.Vertical,
	x = Enum.FillDirection.Horizontal,
	[Enum.FillDirection.Vertical] = Enum.FillDirection.Vertical,
	[Enum.FillDirection.Horizontal] = Enum.FillDirection.Horizontal
}
function ParseFunctions.LayoutDirection(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	if type(unparsedValue) == "string" then unparsedValue = unparsedValue:lower() end
	return layoutDirectionConvertor[unparsedValue]
end

local contentAnchorXConvertor = {
	center=Enum.TextXAlignment.Center,
	left=Enum.TextXAlignment.Left,
	right=Enum.TextXAlignment.Right
}
local contentAnchorYConvertor = {
	center=Enum.TextYAlignment.Center,
	top=Enum.TextYAlignment.Top,
	bottom=Enum.TextYAlignment.Bottom
}
function ParseFunctions.ContentAnchor(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	local convertorTable = (selfData.key == "ContentAnchorX" and contentAnchorXConvertor) or contentAnchorYConvertor
	return convertorTable[unparsedValue:lower()]
end

function ParseFunctions.Font(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return typeof(unparsedValue) == "EnumItem" and unparsedValue or Enum.Font[unparsedValue]
end
function ParseFunctions.FontFace(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return unparsedValue
end

local borderTargetConvertor = {
	contextual = Enum.ApplyStrokeMode.Contextual,
	text = Enum.ApplyStrokeMode.Contextual,
	border = Enum.ApplyStrokeMode.Border,
	edge = Enum.ApplyStrokeMode.Border,
	[Enum.ApplyStrokeMode.Contextual] = Enum.ApplyStrokeMode.Contextual,
	[Enum.ApplyStrokeMode.Border] = Enum.ApplyStrokeMode.Border
}
function ParseFunctions.BorderTarget(unparsedValue, parseResponse, selfData, unparsedData, parsedData)
	return borderTargetConvertor[unparsedValue]
end

return ParseFunctions
