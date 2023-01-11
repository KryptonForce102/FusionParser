local Utils = {
	OpsBasic = {"+", "++", "--", "+-", "-"},
	OpsAdvanced = {"*", "/"},
	Ops = {"+", "-", "/", "*"},
	OpsReplace = {
		["%+"]= "",
		["%+%+"]= "",
		["%-%-"]= "",
		["%+%-"]= "-",
		["%-"]= "-"
	}
}

function Utils.GmatchCount(gmatch)
	local count = 0 for m in gmatch do count+=1 end return count
end

function Utils.Strip(str)
	return str:gsub("^%s+", ""):gsub("%s+$", "")
end

function Utils.StripNonNums(str)
	return str:gsub("%D+", "")
end

function Utils.WsConds(str)
	if type(str) ~= "string" then return str end
	return str:gsub("%s+", " ")
end

function Utils.StartsWithBasicOp(str)
	return (str:match("^+") or str:match("^-")) and true or false
end
function Utils.StartsWithAdvancedOp(str)
	return (str:match("^/") or str:match("^%*")) and true or false
end
function Utils.ContainsAdvancedOp(str)
	return (str:match(".+/.+") or str:match(".+%*.+")) and true or false
end

function Utils.ReplaceOps(str)
	for k,v in Utils.OpsReplace do str = str:gsub(k, v) end
	return str
end

function Utils.IsScaleOrOffset(str)
	if Utils.GmatchCount(str:gmatch("%%$")) >= 1 then return "scale", 100
	elseif Utils.GmatchCount(str:gmatch("px$")) >= 1 then return "offset", 1 end
end

function Utils.StripNonNumExpr(str)
	local num = tostring(str):gsub("[^%d.%-]+", ""); return num
end

return Utils
