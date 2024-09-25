MasterRotatorGui = {}

function MasterRotatorGui.CreateBaseFrame()
	MasterRotatorGui.baseFrame = CreateFrame("Frame", nil, UIParent)
end


function MasterRotatorGui.CreateExportFrame(exportFunc)
    local exportFrame = CreateFrame("Button", nil, MasterRotatorGui.baseFrame, "UIPanelButtonTemplate")
    exportFrame:SetSize(80, 30)
    exportFrame:SetPoint("LEFT", UIParent, 0, 50)
    exportFrame:SetText("Export")
    exportFrame:SetScript("OnClick", function(self)
        exportFunc()
    end)

    MasterRotatorGui.lastRotationButton = exportFrame
end

function MasterRotatorGui.CreateModeButton(text, rotationMode)
	local modeFrame = CreateFrame("Button", nil, MasterRotatorGui.baseFrame, "UIPanelButtonTemplate")
	modeFrame:SetSize(80, 30)

	if(not MasterRotatorGui.lastRotationButton) then
		modeFrame:SetPoint("LEFT", UIParent, 0, 50)
	else
		modeFrame:SetPoint("TOP", MasterRotatorGui.lastRotationButton, "BOTTOM")
	end

	modeFrame:SetText(text)
	modeFrame:SetScript("OnClick", function(self)
		MasterRotator.rotationMode = rotationMode
	end)

	MasterRotatorGui.lastRotationButton = modeFrame
end

function MasterRotatorGui.CreateOutputBar()
	MasterRotatorGui.output = UIParent:CreateLine()
	MasterRotatorGui.output:SetColorTexture(0, 0, 0)
	MasterRotatorGui.output:SetStartPoint("TOPLEFT", 0, 0)
	MasterRotatorGui.output:SetEndPoint("TOPLEFT", 5, -5)
end

function MasterRotatorGui:DisplayText(text)
	local editFrame = CreateFrame("EditBox", nil, UIParent, "InputBoxTemplate");
	editFrame:SetPoint("CENTER", UIParent, "CENTER");
	editFrame:SetWidth(400);
	editFrame:SetHeight(400);
	editFrame:SetMovable(false);
	editFrame:SetAutoFocus(false);
	editFrame:SetMultiLine(1000);
	editFrame:SetMaxLetters(32000);
	editFrame:SetText(text)

	local button = CreateFrame("button", nil, editFrame, "UIPanelButtonTemplate")
	button:SetHeight(24)
	button:SetWidth(60)
	button:SetPoint("BOTTOM", editFrame, "BOTTOM", 0, 10)
	button:SetText("Close")
	button:SetScript("OnClick", function(self) self:GetParent():Hide() end)
end


