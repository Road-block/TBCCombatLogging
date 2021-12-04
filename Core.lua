local addonName, TBCCL = ... -- WoW client passes addons a vararg with their name and a shared table accessible from every addon file. let's use those to avoid polluting the global namespace and potential conflicts with other addons.
local label, labelColon = string.format("|cff2cb8ff%s|r",addonName), string.format("|cff2cb8ff%s|r: ",addonName)

TBCCL.OnEvent = function(_, event, ...)
  return TBCCL[event] and TBCCL[event](TBCCL,...)
end
local eventregistry = CreateFrame("Frame")
eventregistry:SetScript("OnEvent",TBCCL.OnEvent)
eventregistry:RegisterEvent("ADDON_LOADED")

local infoLines = {
  "- This addon will allow for combat logging to start automatically without",
  "having to remember to do it manually every time.",
  " ",
  "- Raids and Heroics are controlled individually through their respective",
  "Enable/Disable buttons.",
  " ",
  "- Logging Status is indicating if combat logging is currently in progress",
  "or not.",
  " ",
  "- Note that the status only updates when the window opens.",
  "If combat logging is started or stopped while the window is open,",
  "the change will not be reflected until the window is closed and opened ",
  "again, unless it's done through the Start/Stop buttons of this addon",
  " ",
  "- The Stop Logging toggle indicates if combat logging should be stopped",
  "when exiting the raid or dungeon to prevent the log from growing.",
  "Useful when interested in logging dungeons and doing other things",
  "in between.",
  "A side effect when enabling this is that if combat logging is started",
  "manually or automatically it will stop when changing outdoor zones",
  "or entering raids/dungeons not enabled for automatic logging.",
  " ",
  "- The Raids and Heroics buttons toggle the lists of raids and dungeons",
  "in order to select specific raids/dungeons for which automatic",
  "logging should start.",
}
local raids = {
  {key = "kara",  mapid = 532, desc = (GetRealZoneText(532))},
  {key = "mag",   mapid = 544, desc = (GetRealZoneText(544))},
  {key = "gruul", mapid = 565, desc = (GetRealZoneText(565))},
  {key = "ssc",   mapid = 548, desc = (GetRealZoneText(548))},
  {key = "tk",    mapid = 550, desc = (GetRealZoneText(550))},
  {key = "hyjal", mapid = 534, desc = (GetRealZoneText(534))},
  {key = "bt",    mapid = 564, desc = (GetRealZoneText(564))},
  {key = "za",    mapid = 568, desc = (GetRealZoneText(568))},
  {key = "swp",   mapid = 580, desc = (GetRealZoneText(580))},
}
local mapidtoraid = {
  [532] = "kara", [544] = "mag", [565] = "gruul", [548] = "ssc",
  [550] = "tk", [534] = "hyjal", [564] = "bt", [568] = "za", [580] = "swp"}
local dungeons = {
  {key = "hrh",   mapid = 543, desc = (GetRealZoneText(543))},
  {key = "bfh",   mapid = 542, desc = (GetRealZoneText(542))},
  {key = "shhh",  mapid = 540, desc = (GetRealZoneText(540))},
  {key = "sph",   mapid = 547, desc = (GetRealZoneText(547))},
  {key = "ubh",   mapid = 546, desc = (GetRealZoneText(546))},
  {key = "svh",   mapid = 545, desc = (GetRealZoneText(545))},
  {key = "mth",   mapid = 557, desc = (GetRealZoneText(557))},
  {key = "ach",   mapid = 558, desc = (GetRealZoneText(558))},
  {key = "shh",   mapid = 556, desc = (GetRealZoneText(556))},
  {key = "slh",   mapid = 555, desc = (GetRealZoneText(555))},
  {key = "arch",  mapid = 552, desc = (GetRealZoneText(552))},
  {key = "both",  mapid = 553, desc = (GetRealZoneText(553))},
  {key = "mechh", mapid = 554, desc = (GetRealZoneText(554))},
  {key = "ohfh",  mapid = 560, desc = (GetRealZoneText(560))},
  {key = "bmh",   mapid = 269, desc = (GetRealZoneText(269))},
  {key = "mgth",  mapid = 585, desc = (GetRealZoneText(585))},
}
local mapidtodungeon = {
  [543] = "hrh", [542] = "bfh", [540] = "shhh", [547] = "sph", [546] = "ubh", [545] = "svh", [557] = "mth",
  [558] = "ach", [556] = "shh", [555] = "slh", [552] = "arch", [553] = "both", [554] = "mechh", [560] = "ohfh",
  [269] = "bmh", [585] = "mgth"}

TBCCombatLoggingDB = TBCCombatLoggingDB or {
  raidstatus = "Disable",
  dungeonstatus = "Disable",
  stoplogging = false,
  kara = true,
  mag = true,
  gruul = true,
  ssc = true,
  tk = true,
  hyjal = true,
  bt = true,
  za = true,
  swp = true,
  hrh = true,
  bfh = true,
  shhh = true,
  sph = true,
  ubh = true,
  svh = true,
  mth = true,
  ach = true,
  shh = true,
  slh = true,
  arch = true,
  both = true,
  mechh = true,
  ohfh = true,
  bmh = true,
  mgth = true,
}

function TBCCL:echo(txt, r, g, b)
  local out = labelColon..txt
  local chatFrame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
  chatFrame:AddMessage(out, (r or 1), (g or 1), (b or 1))
end

local loggingEvents = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD", "RAID_INSTANCE_WELCOME"}
function TBCCL:shouldWatchEvents(context)
  if TBCCombatLoggingDB.raidstatus == "Enable" or TBCCombatLoggingDB.dungeonstatus == "Enable"
    or TBCCombatLoggingDB.stoplogging == true then
    for _, event in pairs(loggingEvents) do
      eventregistry:RegisterEvent(event)
    end
  else
    for _, event in pairs(loggingEvents) do
      eventregistry:UnregisterEvent(event)
    end
  end
  if context and context == "Options" then
    self:PLAYER_ENTERING_WORLD()
  end
end

function TBCCL:shouldLog(instanceType, instanceID, difficultyID )
  if instanceType == "party" then
    if not difficultyID or difficultyID == 0 then return end
    local isHeroic = difficultyID and (difficultyID == 2 or difficultyID == 174)
    local optionKey = mapidtodungeon[instanceID]
    local should
    if optionKey then
      should = (TBCCombatLoggingDB.dungeonstatus == "Enable" and isHeroic) and TBCCombatLoggingDB[optionKey]
    end
    if should and not TBCCL._isLogging then
      TBCCL._isLogging = LoggingCombat(true)
      TBCCL:echo("Combat Logging has been started!", 255/255, 255/255, 0)
    elseif TBCCL._isLogging and not should then
      TBCCL._isLogging = LoggingCombat(false)
      TBCCL:echo("Combat Logging has been stopped!", 255/255, 255/255, 0)
    end
  elseif instanceType == "raid" then
    if not difficultyID or difficultyID == 0 then return end
    local optionKey = mapidtoraid[instanceID]
    local should
    if optionKey then
      should = (TBCCombatLoggingDB.raidstatus == "Enable") and TBCCombatLoggingDB[optionKey]
    end
    if should and not TBCCL._isLogging then
      TBCCL._isLogging = LoggingCombat(true)
      TBCCL:echo("Combat Logging has been started!", 255/255, 255/255, 0)
    elseif TBCCL._isLogging and not should then
      TBCCL._isLogging = LoggingCombat(false)
      TBCCL:echo("Combat Logging has been stopped!", 255/255, 255/255, 0)
    end
  else
    if TBCCombatLoggingDB.stoplogging == true and TBCCL._isLogging then
      TBCCL._isLogging = LoggingCombat(false)
      TBCCL:echo("Combat Logging has been stopped!", 255/255, 255/255, 0)
    end
  end
  self:RefreshOptionsFrame()
end

function TBCCL:ADDON_LOADED(...)
  if ... == addonName then
    self:shouldWatchEvents("ADDON_LOADED")

    hooksecurefunc("LoggingCombat", function(newStatus)
      if newStatus == nil then return end
      if not TBCCL.optionsFrame then return end
      TBCCL._isLogging = newStatus
      TBCCL:RefreshOptionsFrame()
    end)
  end
end
function TBCCL:PLAYER_ENTERING_WORLD(...)
  local instanceName, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
  self:shouldLog(instanceType, instanceID, difficultyID)
end
TBCCL.ZONE_CHANGED_NEW_AREA = TBCCL.PLAYER_ENTERING_WORLD
TBCCL.RAID_INSTANCE_WELCOME = TBCCL.PLAYER_ENTERING_WORLD

function TBCCL:RefreshOptionsFrame()
  if not self.optionsFrame then return end

  if (TBCCombatLoggingDB.raidstatus == "Enable") then
    self.optionsFrame.raidstatusbutton:SetText("Disable")
    self.optionsFrame.raidstatustext:SetText("Enabled")
    self.optionsFrame.raidstatustext:SetTextColor(0, 255/255, 0)
  else
    self.optionsFrame.raidstatusbutton:SetText("Enable")
    self.optionsFrame.raidstatustext:SetText("Disabled")
    self.optionsFrame.raidstatustext:SetTextColor(255/255, 0, 0)
  end
  if (TBCCombatLoggingDB.dungeonstatus == "Enable") then
    self.optionsFrame.dungeonstatusbutton:SetText("Disable")
    self.optionsFrame.dungeonstatustext:SetText("Enabled")
    self.optionsFrame.dungeonstatustext:SetTextColor(0, 255/255, 0)
  else
    self.optionsFrame.dungeonstatusbutton:SetText("Enable")
    self.optionsFrame.dungeonstatustext:SetText("Disabled")
    self.optionsFrame.dungeonstatustext:SetTextColor(255/255, 0, 0)
  end
  if TBCCL._isLogging then
    TBCCL.optionsFrame.loggingstatustext:SetText("Logging ...")
    TBCCL.optionsFrame.loggingstatustext:SetTextColor(0, 255/255, 0)
  else
    TBCCL.optionsFrame.loggingstatustext:SetText("Not Logging")
    TBCCL.optionsFrame.loggingstatustext:SetTextColor(255/255, 0, 0)
  end
  self.optionsFrame.pauselogging:SetChecked(TBCCombatLoggingDB.stoplogging)
end

function TBCCL:GetOptionsFrame()
  if self.optionsFrame then return self.optionsFrame end -- don't remake the frame if we've already made it

  self.optionsFrame = CreateFrame("Frame", addonName.."OptionsFrame", UIParent, "BasicFrameTemplateWithInset")

  self.optionsFrame:SetMovable(true)
  self.optionsFrame:EnableMouse(true)
  self.optionsFrame:RegisterForDrag("LeftButton")
  self.optionsFrame:SetScript("OnDragStart", self.optionsFrame.StartMoving)
  self.optionsFrame:SetScript("OnDragStop", self.optionsFrame.StopMovingOrSizing)

  self.optionsFrame:SetSize(210, 210)
  self.optionsFrame:SetPoint("CENTER", UIParent, "CENTER")
  self.optionsFrame:Hide()

  self.optionsFrame.title = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.title:SetFontObject("GameFontHighlight")
  self.optionsFrame.title:SetPoint("LEFT", self.optionsFrame.TitleBg, "LEFT", 5, 0)
  self.optionsFrame.title:SetText("TBC Combat Logging")

  self.optionsFrame.statustext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.statustext:SetFontObject("GameFontNormal")
  self.optionsFrame.statustext:SetPoint("CENTER", self.optionsFrame.TitleBg, "CENTER", 10, -30)
  self.optionsFrame.statustext:SetText("Automatic Logging Status", 255, 255, 0)

  --Info Button
  self.optionsFrame.infobutton = CreateFrame("Button", nil, self.optionsFrame, "UIPanelInfoButton")
  self.optionsFrame.infobutton:SetPoint("TOPRIGHT", self.optionsFrame, "TOPRIGHT", 25, -25)
  self.optionsFrame.infobutton:SetSize(50, 20)

  --Info Frame
  self.infoFrame = CreateFrame("Frame", addonName.."InfoFrame", UIParent, "BasicFrameTemplateWithInset")
  self.infoFrame:SetMovable(true)
  self.infoFrame:EnableMouse(true)
  self.infoFrame:RegisterForDrag("LeftButton")
  self.infoFrame:SetScript("OnDragStart", self.infoFrame.StartMoving)
  self.infoFrame:SetScript("OnDragStop", self.infoFrame.StopMovingOrSizing)

  self.infoFrame:SetSize(450, 415)
  self.infoFrame:SetPoint("TOPLEFT", self.optionsFrame, "TOPRIGHT", 5,0)

  self.infoFrame.title = self.infoFrame:CreateFontString(nil, "OVERLAY")
  self.infoFrame.title:SetFontObject("GameFontHighlight")
  self.infoFrame.title:SetPoint("LEFT", self.infoFrame.TitleBg, "LEFT", 5, 0)
  self.infoFrame.title:SetText("Info")

  self.infoFrame:SetFrameStrata("HIGH")
  local xOffset, yOffset = 10, -30
  for i,line in ipairs(infoLines) do
    self.infoFrame["infotext"..i] = self.infoFrame:CreateFontString(nil, "OVERLAY")
    self.infoFrame["infotext"..i]:SetFontObject("GameFontNormal")
    self.infoFrame["infotext"..i]:SetPoint("TOPLEFT", self.infoFrame.TitleBg, "TOPLEFT", xOffset, yOffset)
    self.infoFrame["infotext"..i]:SetText(line, 0, 0, 0)
    yOffset = yOffset - 15
  end
  self.infoFrame:Hide()

  self.optionsFrame.infobutton:SetScript("OnClick", function(self)
    if TBCCL.infoFrame:IsVisible() then
      TBCCL.infoFrame:Hide()
    else
      TBCCL.infoFrame:Show()
    end
  end)

  ------ Raids line
  self.optionsFrame.raidstext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.raidstext:SetFontObject("GameFontNormal")
  self.optionsFrame.raidstext:SetPoint("LEFT", self.optionsFrame.TitleBg, "LEFT", 15, -50)
  self.optionsFrame.raidstext:SetText("Raids:")

  self.optionsFrame.raidstatustext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.raidstatustext:SetFontObject("GameFontNormal")
  self.optionsFrame.raidstatustext:SetPoint("LEFT", self.optionsFrame.raidstext, "RIGHT", 2, 0)

  self.optionsFrame.raidstatusbutton = CreateFrame("Button", nil, self.optionsFrame, "GameMenuButtonTemplate")
  self.optionsFrame.raidstatusbutton:SetPoint("TOPRIGHT", self.optionsFrame, "TOPRIGHT", -15, -50)
  self.optionsFrame.raidstatusbutton:SetSize(55, 20)
  self.optionsFrame.raidstatusbutton:SetNormalFontObject("GameFontNormal")
  self.optionsFrame.raidstatusbutton:SetHighlightFontObject("GameFontHighlight")

  --------------------------------------------------------------------------
  ------ Dungeons line
  self.optionsFrame.dungeonstext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.dungeonstext:SetFontObject("GameFontNormal")
  self.optionsFrame.dungeonstext:SetPoint("LEFT", self.optionsFrame.TitleBg, "LEFT", 15, -70)
  self.optionsFrame.dungeonstext:SetText("Dungeons:")

  self.optionsFrame.dungeonstatustext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.dungeonstatustext:SetFontObject("GameFontNormal")
  self.optionsFrame.dungeonstatustext:SetPoint("LEFT", self.optionsFrame.dungeonstext, "RIGHT", 2, 0)

  self.optionsFrame.dungeonstatusbutton = CreateFrame("Button", nil, self.optionsFrame, "GameMenuButtonTemplate")
  self.optionsFrame.dungeonstatusbutton:SetPoint("TOPRIGHT", self.optionsFrame, "TOPRIGHT", -15, -70)
  self.optionsFrame.dungeonstatusbutton:SetSize(55, 20)
  self.optionsFrame.dungeonstatusbutton:SetNormalFontObject("GameFontNormal")
  self.optionsFrame.dungeonstatusbutton:SetHighlightFontObject("GameFontHighlight")

  ------------------------------------------------------------------------------
  --Logging status line
  self.optionsFrame.loggingtext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.loggingtext:SetFontObject("GameFontNormal")
  self.optionsFrame.loggingtext:SetPoint("LEFT", self.optionsFrame.TitleBg, "LEFT", 15, -100)
  self.optionsFrame.loggingtext:SetText("Logging Status:")

  self.optionsFrame.loggingstatustext = self.optionsFrame:CreateFontString(nil, "OVERLAY")
  self.optionsFrame.loggingstatustext:SetFontObject("GameFontNormal")
  self.optionsFrame.loggingstatustext:SetPoint("LEFT", self.optionsFrame.loggingtext, "RIGHT", 2, 0)

  --Start Logging Button
  self.optionsFrame.startloggingbutton = CreateFrame("Button", nil, self.optionsFrame, "GameMenuButtonTemplate")
  self.optionsFrame.startloggingbutton:SetPoint("LEFT", self.optionsFrame, "LEFT", 15, -30)
  self.optionsFrame.startloggingbutton:SetSize(90, 20)
  self.optionsFrame.startloggingbutton:SetText("Start Logging")
  self.optionsFrame.startloggingbutton:SetNormalFontObject("GameFontNormal")
  self.optionsFrame.startloggingbutton:SetHighlightFontObject("GameFontHighlight")
  self.optionsFrame.startloggingbutton:SetScript("OnClick", function(self)
    if not (LoggingCombat()) then
      TBCCL._isLogging = LoggingCombat(true)
      TBCCL:echo("Combat Logging has been started!", 255/255, 255/255, 0)
    else
      TBCCL:echo("Combat Logging already in progress!", 255/255, 255/255, 0)
    end
    TBCCL:RefreshOptionsFrame()
  end)

  --Stop Logging Button
  self.optionsFrame.stoploggingbutton = CreateFrame("Button", nil, self.optionsFrame, "GameMenuButtonTemplate")
  self.optionsFrame.stoploggingbutton:SetPoint("LEFT", self.optionsFrame.startloggingbutton, "RIGHT", 2, 0)
  self.optionsFrame.stoploggingbutton:SetSize(90, 20)
  self.optionsFrame.stoploggingbutton:SetText("Stop Logging")
  self.optionsFrame.stoploggingbutton:SetNormalFontObject("GameFontNormal")
  self.optionsFrame.stoploggingbutton:SetHighlightFontObject("GameFontHighlight")
  self.optionsFrame.stoploggingbutton:SetScript("OnClick", function(self)
    if (LoggingCombat()) then
      TBCCL._isLogging = LoggingCombat(false)
      TBCCL:echo("Combat Logging has been stopped!", 255/255, 255/255, 0)
    else
      TBCCL:echo("Combat was not being logged!", 255/255, 255/255, 0)
    end
    TBCCL:RefreshOptionsFrame()
  end)

  --Stop Logging Line
  self.optionsFrame.pauselogging = CreateFrame("CheckButton", nil, self.optionsFrame, "UICheckButtonTemplate")
  self.optionsFrame.pauselogging:SetPoint("CENTER", self.optionsFrame, "TOPLEFT", 25, -160)
  self.optionsFrame.pauselogging.text:SetText("Stop Logging When Outdoors")
  self.optionsFrame.pauselogging:SetChecked(TBCCombatLoggingDB.stoplogging)
  self.optionsFrame.pauselogging:SetScript("OnClick", function(self)
    TBCCombatLoggingDB.stoplogging = self:GetChecked()
    if (TBCCombatLoggingDB.stoplogging == true) then
      TBCCL:echo("Combat logging will now stop when leaving a dungeon, raid or when changing zones as long as Auto Logging is enabled for either raids or dungeons! This includes manually started combat logging!", 255/255, 255/255, 0)
    end
    TBCCL:shouldWatchEvents("Options")
  end)

  -- Raids Button that creates the frame with raids
  self.optionsFrame.raidsButton = CreateFrame("Button", nil, self.optionsFrame, "UIPanelButtonGrayTemplate")
  self.optionsFrame.raidsButton:SetPoint("BOTTOM", self.optionsFrame, "BOTTOM", -45, 10)
  self.optionsFrame.raidsButton:SetSize(60, 25)
  self.optionsFrame.raidsButton:SetText("Raids")
  self.optionsFrame.raidsButton:SetNormalFontObject("GameFontNormalLarge")
  self.optionsFrame.raidsButton:SetHighlightFontObject("GameFontHighlightLarge")

  self.tbcraidsFrame = CreateFrame("Frame", addonName.."TBCRaidsFrame", UIParent, "BasicFrameTemplateWithInset")
  self.tbcraidsFrame:SetMovable(true)
  self.tbcraidsFrame:EnableMouse(true)
  self.tbcraidsFrame:RegisterForDrag("LeftButton")
  self.tbcraidsFrame:SetScript("OnDragStart", self.tbcraidsFrame.StartMoving)
  self.tbcraidsFrame:SetScript("OnDragStop", self.tbcraidsFrame.StopMovingOrSizing)

  self.tbcraidsFrame:SetFrameStrata("HIGH")

  self.tbcraidsFrame:SetSize(220, 270)
  self.tbcraidsFrame:SetPoint("TOPLEFT", self.optionsFrame, "BOTTOMLEFT", 0, -5)

  self.tbcraidsFrame.title = self.tbcraidsFrame:CreateFontString(nil, "OVERLAY")
  self.tbcraidsFrame.title:SetFontObject("GameFontHighlight")
  self.tbcraidsFrame.title:SetPoint("LEFT", self.tbcraidsFrame.TitleBg, "LEFT", 5, 0)
  self.tbcraidsFrame.title:SetText("TBC Raids Logging")

  xOffset, yOffset = 25, -45
  for _, raid in ipairs(raids) do
    self.tbcraidsFrame[(raid.key)] = CreateFrame("CheckButton", nil, self.tbcraidsFrame, "UICheckButtonTemplate")
    self.tbcraidsFrame[(raid.key)]:SetPoint("CENTER", self.tbcraidsFrame, "TOPLEFT", xOffset, yOffset)
    self.tbcraidsFrame[(raid.key)].text:SetText(raid.desc)
    self.tbcraidsFrame[(raid.key)]:SetChecked(TBCCombatLoggingDB[(raid.key)])
    self.tbcraidsFrame[(raid.key)]:SetScript("OnClick", function(self)
      TBCCombatLoggingDB[(raid.key)] = self:GetChecked()
    end)
    yOffset = yOffset - 25
  end
  self.tbcraidsFrame:Hide()
  self.optionsFrame.raidsButton:SetScript("OnClick", function(self)
    if TBCCL.tbcraidsFrame:IsVisible() then
      TBCCL.tbcraidsFrame:Hide()
    else
      TBCCL.tbcraidsFrame:Show()
    end
  end)
  self.tbcraidsFrame:SetScript("OnShow", function(self)
    for _, raid in ipairs(raids) do
      TBCCL.tbcraidsFrame[(raid.key)]:SetChecked(TBCCombatLoggingDB[(raid.key)])
    end
  end)

  --Button that creates heroics frame
  self.optionsFrame.TBCheroicsButton = CreateFrame("Button", nil, self.optionsFrame, "UIPanelButtonGrayTemplate")
  self.optionsFrame.TBCheroicsButton:SetPoint("BOTTOM", self.optionsFrame, "BOTTOM", 40, 10)
  self.optionsFrame.TBCheroicsButton:SetSize(70, 25)
  self.optionsFrame.TBCheroicsButton:SetText("Heroics")
  self.optionsFrame.TBCheroicsButton:SetNormalFontObject("GameFontNormalLarge")
  self.optionsFrame.TBCheroicsButton:SetHighlightFontObject("GameFontHighlightLarge")

  self.tbcheroicsFrame = CreateFrame("Frame", addonName.."TBCHeroicsFrame", UIParent, "BasicFrameTemplateWithInset")
  self.tbcheroicsFrame:SetMovable(true)
  self.tbcheroicsFrame:EnableMouse(true)
  self.tbcheroicsFrame:RegisterForDrag("LeftButton")
  self.tbcheroicsFrame:SetScript("OnDragStart", self.tbcheroicsFrame.StartMoving)
  self.tbcheroicsFrame:SetScript("OnDragStop", self.tbcheroicsFrame.StopMovingOrSizing)
  self.tbcheroicsFrame:SetFrameStrata("HIGH")

  self.tbcheroicsFrame:SetSize(240, 440)
  self.tbcheroicsFrame:SetPoint("TOPRIGHT", self.optionsFrame, "TOPLEFT", -5, 0)

  self.tbcheroicsFrame.title = self.tbcheroicsFrame:CreateFontString(nil, "OVERLAY")
  self.tbcheroicsFrame.title:SetFontObject("GameFontHighlight")
  self.tbcheroicsFrame.title:SetPoint("LEFT", self.tbcheroicsFrame.TitleBg, "LEFT", 5, 0)
  self.tbcheroicsFrame.title:SetText("TBC Heroics Logging")

  xOffset, yOffset = 25, -45
  for _, dungeon in ipairs(dungeons) do
    self.tbcheroicsFrame[(dungeon.key)] = CreateFrame("CheckButton", nil, self.tbcheroicsFrame, "UICheckButtonTemplate")
    self.tbcheroicsFrame[(dungeon.key)]:SetPoint("CENTER", self.tbcheroicsFrame, "TOPLEFT", xOffset, yOffset)
    self.tbcheroicsFrame[(dungeon.key)].text:SetText(dungeon.desc)
    self.tbcheroicsFrame[(dungeon.key)]:SetChecked(TBCCombatLoggingDB[(dungeon.key)])
    self.tbcheroicsFrame[(dungeon.key)]:SetScript("OnClick", function(self)
      TBCCombatLoggingDB[(dungeon.key)] = self:GetChecked()
    end)
    yOffset = yOffset - 25
  end
  self.tbcheroicsFrame:Hide()

  self.optionsFrame.TBCheroicsButton:SetScript("OnClick", function(self)
    if TBCCL.tbcheroicsFrame:IsVisible() then
      TBCCL.tbcheroicsFrame:Hide()
    else
      TBCCL.tbcheroicsFrame:Show()
    end
  end)
  self.tbcheroicsFrame:SetScript("OnShow", function(self)
    for _, dungeon in ipairs(dungeons) do
      TBCCL.tbcheroicsFrame[(dungeon.key)]:SetChecked(TBCCombatLoggingDB[(dungeon.key)])
    end
  end)

  self.optionsFrame.raidstatusbutton:SetScript("OnClick", function(self)
    if TBCCombatLoggingDB.raidstatus == "Enable" then
      TBCCombatLoggingDB.raidstatus = "Disable"
      TBCCL:echo("Combat Logging will NOT start automatically when entering raids!")
    else
      TBCCombatLoggingDB.raidstatus = "Enable"
      TBCCL:echo("Combat Logging will start automatically next time you enter a configured Raid!")
    end
    TBCCL:RefreshOptionsFrame()
    TBCCL:shouldWatchEvents("Options")
  end)

  self.optionsFrame.dungeonstatusbutton:SetScript("OnClick", function(self)
    if TBCCombatLoggingDB.dungeonstatus == "Enable" then
      TBCCombatLoggingDB.dungeonstatus = "Disable"
      TBCCL:echo("Combat Logging will NOT start automatically when entering Heroics!")
    else
      TBCCombatLoggingDB.dungeonstatus = "Enable"
      TBCCL:echo("Combat Logging will start automatically next time you enter a configured Heroic!")
    end
    TBCCL:RefreshOptionsFrame()
    TBCCL:shouldWatchEvents("Options")
  end)

  self.optionsFrame:SetScript("OnShow", function(self)
    TBCCL._isLogging = LoggingCombat()
    TBCCL:RefreshOptionsFrame()
  end)

  return self.optionsFrame
end

SlashCmdList[addonName] = function(msg)
  if msg == nil or msg == "" then
    local options = TBCCL:GetOptionsFrame()
    if options:IsVisible() then
      options:Hide()
    else
      options:Show()
    end
  else -- if we ever want to add subcommands, like for example /tbccl raid on|off
    local args = {}
    for arg in string.gfind(msg,"%S+") do
      table.insert(args,string.lower(arg))
    end
    local argn = #args
    if argn > 0 then
      local cmd = args[1] -- this would be the first parameter after /tbccl
    end
  end
end
_G["SLASH_"..addonName.."1"] = "/"..string.lower(addonName)
_G["SLASH_"..addonName.."2"] = "/tbccl"
_G["SLASH_"..addonName.."3"] = "/cl"

TBCCL:echo("Loaded TBC Combat Logging. Use /cl for settings!")
_G[addonName] = TBCCL
