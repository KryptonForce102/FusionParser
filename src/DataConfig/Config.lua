local ParseFunctions = require(script.Parent.ParseFunctions)

return {
	Datatypes = {
		["CornerRadius"] = {
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			ID = "CornerRadius",
			SubInstance = "UICorner"
		},
		
		["ZIndex"] = {
			ParseFuncs = {ParseFunctions.Integer},
			ID = "ZIndex",
		},
		
		["Active"] = {
			ParseFuncs = {ParseFunctions.Boolean},
			ID = "Active"
		},
		
		["BackgroundOpacity"]= {
			ParseFuncs = {ParseFunctions.ScaleAndOffset, ParseFunctions.Scale, ParseFunctions.BackgroundOpacity},
			ID = "BackgroundTransparency"
		},
		
		["Background"] = {
			ParseFuncs = {ParseFunctions.Color},
			ID = "BackgroundColor3",
		},
		["Color"] = {
			ParseFuncs = {ParseFunctions.Color},
			ID = "TextColor3",
		},
		["PlaceholderColor"]= {
			ParseFuncs = {ParseFunctions.Color},
			ID = "PlaceholderColor3"
		},
		["ImageColor"]= {
			ParseFuncs = {ParseFunctions.Color},
			ID = "ImageColor3"
		},
		
		["Placeholder"]= {
			ParseFuncs = {ParseFunctions.String},
			ID = "PlaceholderText"
		},
		["Content"]= {
			ParseFuncs = {ParseFunctions.String},
			ID = "Text"
		},
		["ContentSize"]= {
			ParseFuncs = {ParseFunctions.ContentSize, ParseFunctions.ScaleAndOffset, ParseFunctions.Offset},
			ID = "TextSize"
		},
		["ContentWrapped"]= {
			ParseFuncs = {ParseFunctions.Boolean},
			ID = "TextWrapped"
		},
		["ContentTruncate"]= {
			ParseFuncs = {ParseFunctions.Boolean, ParseFunctions.ContentTruncate},
			ID = "TextTruncate"
		},
		["Multiline"]= {
			ParseFuncs = {ParseFunctions.Boolean},
			ID = "MultiLine"
		},
		
		["ContentAnchorX"]= {
			ParseFuncs = {ParseFunctions.String, ParseFunctions.ContentAnchor},
			ID = "TextXAlignment"
		},
		["ContentAnchorY"]= {
			ParseFuncs = {ParseFunctions.String, ParseFunctions.ContentAnchor},
			ID = "TextYAlignment"
		},
		
		["Font"]= {
			ParseFuncs = {ParseFunctions.Font},
			ID = "Font"
		},
		["FontFace"]= {
			ParseFuncs = {ParseFunctions.FontFace},
			ID = "FontFace"
		},
		
		["PaddingLeft"]= {
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			ID = "PaddingLeft",
			SubInstance= "UIPadding"
		},
		["PaddingRight"]= {
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			ID = "PaddingRight",
			SubInstance= "UIPadding"
		},
		["PaddingTop"]= {
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			ID = "PaddingTop",
			SubInstance= "UIPadding"
		},
		["PaddingBottom"]= {
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			ID = "PaddingBottom",
			SubInstance= "UIPadding"
		},
		
		["BorderColor"]= {
			ParseFuncs = {ParseFunctions.Color},
			ID = "Color",
			SubInstance = "UIStroke"
		},
		["BorderWeight"]= {
			ParseFuncs = {ParseFunctions.Float},
			ID = "Thickness",
			SubInstance = "UIStroke"
		},
		["BorderTarget"]= {
			ParseFuncs = {ParseFunctions.BorderTarget},
			ID = "ApplyStrokeMode",
			SubInstance = "UIStroke"
		},
		
		["Parent"]= {
			ParseFuncs = {ParseFunctions.Instance},
			ID = "Parent"
		},
		
		["Name"]= {
			ParseFuncs = {ParseFunctions.String},
			ID = "Name"
		},
		
		["Visible"]= {
			ParseFuncs = {ParseFunctions.Boolean},
			ID = "Visible",
			DefaultValue = false
		},
		
		["AspectRatio"]= {
			ParseFuncs = {ParseFunctions.Float},
			ID = "AspectRatio",
			SubInstance="UIAspectRatioConstraint"
		},

		["Image"]= {
			ParseFuncs = {ParseFunctions.String},
			ID = "Image"
		},
		
		["ScrollbarWidth"]= {
			ParseFuncs = {ParseFunctions.ScaleAndOffset, ParseFunctions.Offset},
			ID = "ScrollBarThickness"
		},
		["ScrollbarBackground"]= {
			ParseFuncs = {ParseFunctions.Color},
			ID = "ScrollBarImageColor3"
		},
		["ScrollbarInsetX"]= {
			ParseFuncs = {ParseFunctions.String, ParseFunctions.ScrollBarInset},
			ID = "HorizontalScrollBarInset"
		},
		["ScrollbarInsetY"]= {
			ParseFuncs = {ParseFunctions.String, ParseFunctions.ScrollBarInset},
			ID = "VerticalScrollBarInset"
		},
		
		["Anchor"]= {
			ParseFuncs = {ParseFunctions.Anchor},
			ID = "AnchorPoint"
		},
		
		["LayoutType"]= {
			ParseFuncs = {ParseFunctions.Layout},
		},
		["LayoutPadding"]= {
			ParseFuncs = {ParseFunctions.GetLayoutSubInstance, ParseFunctions.ScaleAndOffset},
			ID = "Padding",
			SubInstance = true
		},
		["LayoutAlignmentX"]= {
			ParseFuncs = {ParseFunctions.GetLayoutSubInstance, ParseFunctions.LayoutAlignment},
			ID = "HorizontalAlignment",
			SubInstance = true
		},
		["LayoutAlignmentY"]= {
			ParseFuncs = {ParseFunctions.GetLayoutSubInstance, ParseFunctions.LayoutAlignment},
			ID = "VerticalAlignment",
			SubInstance = true
		},
		["LayoutDirection"]= {
			ParseFuncs = {ParseFunctions.GetLayoutSubInstance, ParseFunctions.LayoutDirection},
			ID = "FillDirection",
			SubInstance = true
		},
		["LayoutMaxCells"]= {
			ParseFuncs = {ParseFunctions.GetLayoutSubInstance, ParseFunctions.Integer},
			ID = "FillDirectionMaxCells",
			SubInstance = true
		},
	},
	
	Datafrags = {
		["Width"] = {
			ID = "Size", Order = 1,
			ParseFuncs = {ParseFunctions.Size, ParseFunctions.ScaleAndOffset},
			DefaultValue = UDim.new(0,0)
		},
		["Height"] = {
			ID = "Size", Order = 2,
			ParseFuncs = {ParseFunctions.Size, ParseFunctions.ScaleAndOffset},
			DefaultValue = UDim.new(0,0)
		},
		
		["CanvasWidth"] = {
			ID = "CanvasSize", Order = 1,
			ParseFuncs = {ParseFunctions.Size, ParseFunctions.ScaleAndOffset},
			DefaultValue = UDim.new(0,0)
		},
		["CanvasHeight"] = {
			ID = "CanvasSize", Order = 2,
			ParseFuncs = {ParseFunctions.Size, ParseFunctions.ScaleAndOffset},
			DefaultValue = UDim.new(0,0)
		},
		
		["TranslateX"] = {
			ID = "Position", Order = 1,
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			DefaultValue = UDim.new(0,0)
		},
		["TranslateY"] = {
			ID = "Position", Order = 2,
			ParseFuncs = {ParseFunctions.ScaleAndOffset},
			DefaultValue = UDim.new(0,0)
		}
	},
	
	Datagroups = {
		["Padding"]= {
			Combinations={
				{{"PaddingLeft"}, {"PaddingRight"}, {"PaddingTop"}, {"PaddingBottom"}},
				{{"PaddingLeft", "PaddingRight", "PaddingTop", "PaddingBottom"}},
				{{"PaddingLeft", "PaddingRight"}, {"PaddingTop", "PaddingBottom"}}
			}
		},
		
		["LayoutAlignment"]= {
			Combinations={
				{{"LayoutAlignmentX"}, {"LayoutAlignmentY"}},
				{{"LayoutAlignmentX", "LayoutAlignmentY"}},
			}
		},
		
		["Layout"]= {
			Combinations={
				{{"LayoutType"}},
				{{"LayoutType"}, {"LayoutAlignmentX"}, {"LayoutAlignmentY"}},
				{{"LayoutType"}, {"LayoutAlignmentX"}, {"LayoutAlignmentY"}, {"LayoutDirection"}},
				{{"LayoutType"}, {"LayoutAlignmentX"}, {"LayoutAlignmentY"}, {"LayoutDirection"}, {"LayoutMaxCells"}}
			}
		},
		
		["Text"]= {
			Combinations={
				{{"Content"}},
				{{"Content"}, {"ContentSize"}},
			}
		},
		["TextSize"]= {
			Combinations={
				{{"ContentSize"}},
			}
		},
		
		["Border"]= {
			Combinations={
				{{"BorderWeight"}},
				{{"BorderWeight"}, {"BorderTarget"}},
			}
		}
	}
}
