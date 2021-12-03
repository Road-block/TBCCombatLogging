frame = CreateFrame("Frame"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA"); -- Fired when changing zones

Messaged = 0
SettingsDisplayed = false
InfoDisplayed = false
TBCRaidDisplayed = false
TBCDungeonsDisplayed = false

SLASH_CL1 = "/CL"

SlashCmdList["CL"] = function()
local Settings = CreateFrame ("Frame", "SettingsFrame", UIParent, "BasicFrameTemplateWithInset");

Settings:SetMovable(true);
Settings:EnableMouse(true);
Settings:RegisterForDrag("LeftButton");
Settings:SetScript("OnDragStart", frame.StartMoving);
Settings:SetScript("OnDragStop", frame.StopMovingOrSizing);

Settings:SetSize (200,210);
Settings:SetPoint ("CENTER", UIParent, "CENTER");

Settings.title = Settings: CreateFontString (nil, "OVERLAY");
Settings.title:SetFontObject("GameFontHighlight")
Settings.title:SetPoint("LEFT", Settings.TitleBg, "LEFT", 5, 0);
Settings.title:SetText ("TBC Combat Logging");

Settings.statustext = Settings: CreateFontString (nil, "OVERLAY");
Settings.statustext:SetFontObject("GameFontNormal")
Settings.statustext:SetPoint("CENTER", Settings.TitleBg, "CENTER", 10, -30);
Settings.statustext:SetText ("Automatic Logging Status",255, 255, 0);

--Info Button
Settings.infobutton = CreateFrame("Button",nil,Settings,"UIPanelInfoButton");
Settings.infobutton:SetPoint ("TOPRIGHT",Settings,"TOPRIGHT",25,-25);
Settings.infobutton:SetSize (50,20);

--Info Frame
Settings.infobutton:SetScript("OnClick", function(self)

local Info = CreateFrame ("Frame", "InfoFrame", UIParent, "BasicFrameTemplateWithInset");

Info:SetMovable(true);
Info:EnableMouse(true);
Info:RegisterForDrag("LeftButton");
Info:SetScript("OnDragStart", frame.StartMoving);
Info:SetScript("OnDragStop", frame.StopMovingOrSizing);

Info:SetSize (410,400);
Info:SetPoint ("CENTER", UIParent, "CENTER");

Info.title = Info: CreateFontString (nil, "OVERLAY");
Info.title:SetFontObject("GameFontHighlight")
Info.title:SetPoint("LEFT", Info.TitleBg, "LEFT", 5, 0);
Info.title:SetText ("Info");

Info:SetFrameStrata("HIGH");

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -30);
Info.infotext1:SetText ("- This addon will allow for combat logging to start automatically without",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -45);
Info.infotext1:SetText ("having to remember to do it manually every time.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -75);
Info.infotext1:SetText ("- Raids and Heroics are controlled individually through their respective",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -90);
Info.infotext1:SetText ("Enable/Disable buttons.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -120);
Info.infotext1:SetText ("- Logging Status is indicating if combat logging is currently in progress",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -135);
Info.infotext1:SetText ("or not.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -150);
Info.infotext1:SetText ("- Note that the status only updates when the window opens.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -165);
Info.infotext1:SetText ("If combat logging is started or stopped while the window is open,",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -180);
Info.infotext1:SetText ("the change will not be reflected until the window is closed an opened ",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -195);
Info.infotext1:SetText ("again, unless it's done through the Start/Stop buttons of this addon",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -225);
Info.infotext1:SetText ("- The Stop Logging toggle indicates if combat logging should be stopped",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -240);
Info.infotext1:SetText ("when exiting the raid or dungeon to prevent the log from growing.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -255);
Info.infotext1:SetText ("Useful when interested in logging dungeons and doing other things",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -270);
Info.infotext1:SetText ("in between.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -285);
Info.infotext1:SetText ("A side effect when enabling this is that if combat logging is started",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -300);
Info.infotext1:SetText ("manually or automatically it will stop when changing outdoor zones",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -315);
Info.infotext1:SetText ("or entering raids/dungeons not enabled for automatic logging.",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -345);
Info.infotext1:SetText ("- The Raids and Heroics buttons toggle the lists of raids and dungeons",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -360);
Info.infotext1:SetText ("in order to select specific raids/dungeons for which automatic",0,0,0);

Info.infotext1 = Info: CreateFontString (nil, "OVERLAY");
Info.infotext1:SetFontObject("GameFontNormal")
Info.infotext1:SetPoint("TOPLEFT", Info.TitleBg, "TOPLEFT", 10, -375);
Info.infotext1:SetText ("loging should start.",0,0,0);

end)

------ Raids line
Settings.raidstext = Settings: CreateFontString (nil, "OVERLAY");
Settings.raidstext:SetFontObject("GameFontNormal")
Settings.raidstext:SetPoint("LEFT", Settings.TitleBg, "LEFT", 15, -50);
Settings.raidstext:SetText ("Raids:");

Settings.raidstatustext = Settings: CreateFontString (nil, "OVERLAY");
Settings.raidstatustext:SetFontObject("GameFontNormal")
Settings.raidstatustext:SetPoint("LEFT", Settings.TitleBg, "LEFT", 50, -50);

if (raidstatus == "Enable")
then
Settings.raidstatustext:SetText ("Disabled");
Settings.raidstatustext:SetTextColor(255,0,0)
else
Settings.raidstatustext:SetText ("Enabled");
Settings.raidstatustext:SetTextColor(0,255,0)
end

Settings.raidstatusbutton = CreateFrame("Button",nil,Settings,"GameMenuButtonTemplate");
Settings.raidstatusbutton:SetPoint ("TOPLEFT",Settings,"TOPLEFT",125,-50);
Settings.raidstatusbutton:SetSize (50,20);
Settings.raidstatusbutton:SetText (raidstatus);
Settings.raidstatusbutton:SetNormalFontObject ("GameFontNormal");
Settings.raidstatusbutton:SetHighlightFontObject ("GameFontHighlight");

--------------------------------------------------------------------------

------ Dungeons line
Settings.dungeonstext = Settings: CreateFontString (nil, "OVERLAY");
Settings.dungeonstext:SetFontObject("GameFontNormal")
Settings.dungeonstext:SetPoint("LEFT", Settings.TitleBg, "LEFT", 15, -70);
Settings.dungeonstext:SetText ("Dungeons:");

Settings.dungeonstatustext = Settings: CreateFontString (nil, "OVERLAY");
Settings.dungeonstatustext:SetFontObject("GameFontNormal")
Settings.dungeonstatustext:SetPoint("LEFT", Settings.TitleBg, "LEFT", 73, -70);

if (dungeonstatus == "Enable")
then
Settings.dungeonstatustext:SetText ("Disabled");
Settings.dungeonstatustext:SetTextColor(255,0,0)
else
Settings.dungeonstatustext:SetText ("Enabled");
Settings.dungeonstatustext:SetTextColor(0,255,0)
end

Settings.dungeonstatusbutton = CreateFrame("Button",nil,Settings,"GameMenuButtonTemplate");
Settings.dungeonstatusbutton:SetPoint ("TOPLEFT",Settings,"TOPLEFT",125,-70);
Settings.dungeonstatusbutton:SetSize (50,20);
Settings.dungeonstatusbutton:SetText (dungeonstatus);
Settings.dungeonstatusbutton:SetNormalFontObject ("GameFontNormal");
Settings.dungeonstatusbutton:SetHighlightFontObject ("GameFontHighlight");

------------------------------------------------------------------------------

--Logging status line
Settings.loggingtext = Settings: CreateFontString (nil, "OVERLAY");
Settings.loggingtext:SetFontObject("GameFontNormal")
Settings.loggingtext:SetPoint("LEFT", Settings.TitleBg, "LEFT", 15, -100);
Settings.loggingtext:SetText ("Logging Status:");

Settings.loggingstatustext = Settings: CreateFontString (nil, "OVERLAY");
Settings.loggingstatustext:SetFontObject("GameFontNormal")
Settings.loggingstatustext:SetPoint("LEFT", Settings.TitleBg, "LEFT", 100, -100);

if (LoggingCombat() == true)
then
Settings.loggingstatustext:SetText ("Logging ...");
Settings.loggingstatustext:SetTextColor(0,255,0)
else
Settings.loggingstatustext:SetText ("Not Logging");
Settings.loggingstatustext:SetTextColor(255,0,0);
end

--Start Logging Button
Settings.startloggingbutton = CreateFrame("Button",nil,Settings,"GameMenuButtonTemplate");
Settings.startloggingbutton:SetPoint ("LEFT",Settings,"LEFT",15,-30);
Settings.startloggingbutton:SetSize (80,20);
Settings.startloggingbutton:SetText ("Start Logging");
Settings.startloggingbutton:SetNormalFontObject ("GameFontNormal");
Settings.startloggingbutton:SetHighlightFontObject ("GameFontHighlight");
Settings.startloggingbutton:SetScript("OnClick", function(self)
if LoggingCombat() == false
then 
LoggingCombat(true);
Settings.loggingstatustext:SetText ("Logging ...");
Settings.loggingstatustext:SetTextColor(0,255,0);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging has been started!",255, 255, 0);
else
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging already in progress!",255, 255, 0);
end
end)

--Stop Logging Button
Settings.stoploggingbutton = CreateFrame("Button",nil,Settings,"GameMenuButtonTemplate");
Settings.stoploggingbutton:SetPoint ("LEFT",Settings,"LEFT",100,-30);
Settings.stoploggingbutton:SetSize (80,20);
Settings.stoploggingbutton:SetText ("Stop Logging");
Settings.stoploggingbutton:SetNormalFontObject ("GameFontNormal");
Settings.stoploggingbutton:SetHighlightFontObject ("GameFontHighlight");
Settings.stoploggingbutton:SetScript("OnClick", function(self)
if LoggingCombat() == true
then 
LoggingCombat(false);
Settings.loggingstatustext:SetText ("Not Logging");
Settings.loggingstatustext:SetTextColor(255,0,0);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging has been stopped!",255, 255, 0);
else
DEFAULT_CHAT_FRAME:AddMessage("Combat was not being logged!",255, 255, 0);
end
end)

--Stop Logging Line
Settings.pauselogging = CreateFrame("CheckButton",nil,Settings,"UICheckButtonTemplate");
Settings.pauselogging:SetPoint ("CENTER",Settings,"TOPLEFT",25,-160);
Settings.pauselogging.text:SetText ("Stop Logging When Outdoors");
Settings.pauselogging:SetChecked (stoplogging);
Settings.pauselogging:SetScript("OnClick", function(self)
stoplogging = self:GetChecked()
if (stoplogging == true) then
DEFAULT_CHAT_FRAME:AddMessage("Combat logging will now stop when leaving a dungeon, raid or when changing zones as long as Auto Logging is enabled for either raids or dungeons! This includes manually started combat logging!",255, 255, 0);
end
end)





-- Raids Button that creates the frame with raids
Settings.raidsButton = CreateFrame("Button",nil,Settings,"UIPanelButtonGrayTemplate");
Settings.raidsButton:SetPoint ("BOTTOM",Settings,"BOTTOM",-45,10);
Settings.raidsButton:SetSize (60,25);
Settings.raidsButton:SetText ("Raids");
Settings.raidsButton:SetNormalFontObject ("GameFontNormalLarge");
Settings.raidsButton:SetHighlightFontObject ("GameFontHighlightLarge");

Settings.raidsButton:SetScript("OnClick", function(self)

local TBCRaids = CreateFrame ("Frame", "TBCRaidsFrame", UIParent, "BasicFrameTemplateWithInset");

TBCRaids:SetMovable(true);
TBCRaids:EnableMouse(true);
TBCRaids:RegisterForDrag("LeftButton");
TBCRaids:SetScript("OnDragStart", frame.StartMoving);
TBCRaids:SetScript("OnDragStop", frame.StopMovingOrSizing);

TBCRaids:SetFrameStrata("HIGH");

TBCRaids:SetSize (200,270);
TBCRaids:SetPoint ("CENTER", UIParent, "CENTER");

TBCRaids.title = TBCRaids: CreateFontString (nil, "OVERLAY");
TBCRaids.title:SetFontObject("GameFontHighlight")
TBCRaids.title:SetPoint("LEFT", TBCRaidsFrame.TitleBg, "LEFT", 5, 0);
TBCRaids.title:SetText ("TBC Raids Logging");

TBCRaids.kara = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.kara:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-45);
TBCRaids.kara.text:SetText ("Karazhan");
TBCRaids.kara:SetChecked (kara);
TBCRaids.kara:SetScript("OnClick", function(self)
kara = self:GetChecked()
end)

TBCRaids.mag = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.mag:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-70);
TBCRaids.mag.text:SetText ("Magtheridon's Lair");
TBCRaids.mag:SetChecked (mag);
TBCRaids.mag:SetScript("OnClick", function(self)
mag = self:GetChecked()
end)

TBCRaids.gruul = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.gruul:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-95);
TBCRaids.gruul.text:SetText ("Gruul's Lair");
TBCRaids.gruul:SetChecked (gruul);
TBCRaids.gruul:SetScript("OnClick", function(self)
gruul = self:GetChecked()
end)

TBCRaids.ssc = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.ssc:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-120);
TBCRaids.ssc.text:SetText ("Serpentshrine Cavern");
TBCRaids.ssc:SetChecked (ssc);
TBCRaids.ssc:SetScript("OnClick", function(self)
ssc = self:GetChecked()
end)

TBCRaids.tk = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.tk:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-145);
TBCRaids.tk.text:SetText ("Tempest Keep");
TBCRaids.tk:SetChecked (tk);
TBCRaids.tk:SetScript("OnClick", function(self)
tk = self:GetChecked()
end)

TBCRaids.bt = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.bt:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-170);
TBCRaids.bt.text:SetText ("Black Temple");
TBCRaids.bt:SetChecked (bt);
TBCRaids.bt:SetScript("OnClick", function(self)
bt = self:GetChecked()
end)

TBCRaids.hyjal = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.hyjal:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-195);
TBCRaids.hyjal.text:SetText ("Hyjal Summit");
TBCRaids.hyjal:SetChecked (hyjal);
TBCRaids.hyjal:SetScript("OnClick", function(self)
hyjal = self:GetChecked()
end)

TBCRaids.za = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.za:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-220);
TBCRaids.za.text:SetText ("Zul'Aman");
TBCRaids.za:SetChecked (za);
TBCRaids.za:SetScript("OnClick", function(self)
za = self:GetChecked()
end)

TBCRaids.swp = CreateFrame("CheckButton",nil,TBCRaids,"UICheckButtonTemplate");
TBCRaids.swp:SetPoint ("CENTER",TBCRaids,"TOPLEFT",25,-245);
TBCRaids.swp.text:SetText ("Sunwell Plateau");
TBCRaids.swp:SetChecked (za);
TBCRaids.swp:SetScript("OnClick", function(self)
swp = self:GetChecked()
end)

end)

--Button that creates heroics frame
Settings.TBCheroicsButton = CreateFrame("Button",nil,Settings,"UIPanelButtonGrayTemplate");
Settings.TBCheroicsButton:SetPoint ("BOTTOM",Settings,"BOTTOM",40,10);
Settings.TBCheroicsButton:SetSize (65,25);
Settings.TBCheroicsButton:SetText ("Heroics");
Settings.TBCheroicsButton:SetNormalFontObject ("GameFontNormalLarge");
Settings.TBCheroicsButton:SetHighlightFontObject ("GameFontHighlightLarge");

Settings.TBCheroicsButton:SetScript("OnClick", function(self)

local TBCHeroics = CreateFrame ("Frame", "TBCHeroicsFrame", UIParent, "BasicFrameTemplateWithInset");

TBCHeroics:SetMovable(true);
TBCHeroics:EnableMouse(true);
TBCHeroics:RegisterForDrag("LeftButton");
TBCHeroics:SetScript("OnDragStart", frame.StartMoving);
TBCHeroics:SetScript("OnDragStop", frame.StopMovingOrSizing);

TBCHeroics:SetFrameStrata("HIGH");

TBCHeroics:SetSize (200,440);
TBCHeroics:SetPoint ("CENTER", UIParent, "CENTER");

TBCHeroics.title = TBCHeroics: CreateFontString (nil, "OVERLAY");
TBCHeroics.title:SetFontObject("GameFontHighlight")
TBCHeroics.title:SetPoint("LEFT", TBCHeroicsFrame.TitleBg, "LEFT", 5, 0);
TBCHeroics.title:SetText ("TBC Heroics Logging");

TBCHeroics.hrh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.hrh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-45);
TBCHeroics.hrh.text:SetText ("Hellfire Ramparts");
TBCHeroics.hrh:SetChecked (hrh);
TBCHeroics.hrh:SetScript("OnClick", function(self)
hrh = self:GetChecked()
end)

TBCHeroics.bfh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.bfh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-70);
TBCHeroics.bfh.text:SetText ("The Blood Furnace");
TBCHeroics.bfh:SetChecked (bfh);
TBCHeroics.bfh:SetScript("OnClick", function(self)
bfh = self:GetChecked()
end)

TBCHeroics.shhh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.shhh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-95);
TBCHeroics.shhh.text:SetText ("The Shattered Halls");
TBCHeroics.shhh:SetChecked (shhh);
TBCHeroics.shhh:SetScript("OnClick", function(self)
shhh = self:GetChecked()
end)

TBCHeroics.sph = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.sph:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-120);
TBCHeroics.sph.text:SetText ("The Slave Pens");
TBCHeroics.sph:SetChecked (sph);
TBCHeroics.sph:SetScript("OnClick", function(self)
sph = self:GetChecked()
end)

TBCHeroics.ubh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.ubh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-145);
TBCHeroics.ubh.text:SetText ("The Underbog");
TBCHeroics.ubh:SetChecked (ubh);
TBCHeroics.ubh:SetScript("OnClick", function(self)
ubh = self:GetChecked()
end)

TBCHeroics.svh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.svh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-170);
TBCHeroics.svh.text:SetText ("The Steamvalut");
TBCHeroics.svh:SetChecked (svh);
TBCHeroics.svh:SetScript("OnClick", function(self)
svh = self:GetChecked()
end)

TBCHeroics.mth = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.mth:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-195);
TBCHeroics.mth.text:SetText ("Mana-Tombs");
TBCHeroics.mth:SetChecked (mth);
TBCHeroics.mth:SetScript("OnClick", function(self)
mth = self:GetChecked()
end)

TBCHeroics.ach = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.ach:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-220);
TBCHeroics.ach.text:SetText ("Auchenai Crypts");
TBCHeroics.ach:SetChecked (ach);
TBCHeroics.ach:SetScript("OnClick", function(self)
ach = self:GetChecked()
end)

TBCHeroics.shh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.shh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-245);
TBCHeroics.shh.text:SetText ("Sethekk Halls");
TBCHeroics.shh:SetChecked (shh);
TBCHeroics.shh:SetScript("OnClick", function(self)
shh = self:GetChecked()
end)

TBCHeroics.slh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.slh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-270);
TBCHeroics.slh.text:SetText ("Shadow Labyrinth");
TBCHeroics.slh:SetChecked (slh);
TBCHeroics.slh:SetScript("OnClick", function(self)
slh = self:GetChecked()
end)

TBCHeroics.arch = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.arch:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-295);
TBCHeroics.arch.text:SetText ("The Arcatraz");
TBCHeroics.arch:SetChecked (arch);
TBCHeroics.arch:SetScript("OnClick", function(self)
arch = self:GetChecked()
end)

TBCHeroics.both = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.both:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-320);
TBCHeroics.both.text:SetText ("The Botanica");
TBCHeroics.both:SetChecked (both);
TBCHeroics.both:SetScript("OnClick", function(self)
both = self:GetChecked()
end)

TBCHeroics.mechh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.mechh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-345);
TBCHeroics.mechh.text:SetText ("The Mechanar");
TBCHeroics.mechh:SetChecked (mechh);
TBCHeroics.mechh:SetScript("OnClick", function(self)
mechh = self:GetChecked()
end)

TBCHeroics.ohfh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.ohfh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-370);
TBCHeroics.ohfh.text:SetText ("Old Hillsbrad Foothills");
TBCHeroics.ohfh:SetChecked (ohfh);
TBCHeroics.ohfh:SetScript("OnClick", function(self)
ohfh = self:GetChecked()
end)

TBCHeroics.bmh = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.bmh:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-395);
TBCHeroics.bmh.text:SetText ("The Black Morass");
TBCHeroics.bmh:SetChecked (bmh);
TBCHeroics.bmh:SetScript("OnClick", function(self)
bmh = self:GetChecked()
end)

TBCHeroics.mgth = CreateFrame("CheckButton",nil,TBCHeroics,"UICheckButtonTemplate");
TBCHeroics.mgth:SetPoint ("CENTER",TBCHeroics,"TOPLEFT",25,-420);
TBCHeroics.mgth.text:SetText ("Magister's Terrace");
TBCHeroics.mgth:SetChecked (mgth);
TBCHeroics.mgth:SetScript("OnClick", function(self)
mgth = self:GetChecked()
end)

end)


Settings.raidstatusbutton:SetScript("OnClick", function(self)
if raidstatus == "Enable" then
raidstatus = "Disable"
Settings.raidstatusbutton:SetText (raidstatus);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging will start automatically next time you enter a configured Raid!");

else
raidstatus = "Enable"
Settings.raidstatusbutton:SetText (raidstatus);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging will NOT start automatically when entering raids!");

end

if (raidstatus == "Enable")
then
Settings.raidstatustext:SetText ("Disabled");
Settings.raidstatustext:SetTextColor(255,0,0)
else
Settings.raidstatustext:SetText ("Enabled");
Settings.raidstatustext:SetTextColor(0,255,0)
end

end)

Settings.dungeonstatusbutton:SetScript("OnClick", function(self)
if dungeonstatus == "Enable" then
dungeonstatus = "Disable"
Settings.dungeonstatusbutton:SetText (dungeonstatus);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging will start automatically next time you enter a configured Heroic!");

else
dungeonstatus = "Enable"
Settings.dungeonstatusbutton:SetText (dungeonstatus);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging will NOT start automatically when entering Heroics!");

end

if (dungeonstatus == "Enable")
then
Settings.dungeonstatustext:SetText ("Disabled");
Settings.dungeonstatustext:SetTextColor(255,0,0)
else
Settings.dungeonstatustext:SetText ("Enabled");
Settings.dungeonstatustext:SetTextColor(0,255,0)
end

end)
end

function startLogging(self, event, ...)

zoneName = GetInstanceInfo()
instanceDifficulty = GetDungeonDifficultyID()

instancematch = false
raidmatch = false

if (raidstatus == "Disable") then
if (zoneName == "Karazhan" and kara == true) then raidmatch = true else
if (zoneName == "Gruul's Lair" and gruul == true) then raidmatch = true else
if (zoneName == "Black Temple" and bt == true) then raidmatch = true else
if (zoneName == "Hyjal Summit" and hyjal == true) then raidmatch = true else
if (zoneName == "Magtheridon's Lair" and mag == true) then raidmatch = true else
if (zoneName == "Coilfang: Serpentshrine Cavern" and ssc == true) then raidmatch = true else
if (zoneName == "Tempest Keep" and tk == true) then raidmatch = true else
if (zoneName == "Zul'Aman" and za == true) then raidmatch = true else
if (zoneName == "The Sunwell" and swp == true) then raidmatch = true
end
end
end
end
end
end
end
end
end
end

if (dungeonstatus == "Disable") then
if (zoneName == "Auchindoun: Auchenai Crypts" and ach == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Hellfire Citadel: Ramparts" and hrh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Magisters' Terrace" and mgth == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Auchindoun: Mana-Tombs" and mth == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "The Escape from Durnholde" and ohfh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Auchindoun: Sethekk Halls" and shh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Auchindoun: Shadow Labyrinth" and slh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Tempest Keep: The Arcatraz" and arch == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Opening of the Dark Portal" and bmh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Hellfire Citadel: The Blood Furnace" and bfh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Tempest Keep: The Botanica" and both == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Tempest Keep: The Mechanar" and mechh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Hellfire Citadel: The Shattered Halls" and shhh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Coilfang: The Slave Pens" and sph == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Coilfang: The Steamvault" and svh == true and instanceDifficulty == 2) then instancematch = true else
if (zoneName == "Coilfang: The Underbog" and ubh == true and instanceDifficulty == 2) then instancematch = true
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end
end


if (instancematch == false and raidmatch == false and stoplogging == true and LoggingCombat() == true) then
LoggingCombat(false)
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging has been stopped!",255, 255, 0);
Messaged = 1
else if (instancematch == false and raidmatch == false and stoplogging == false and LoggingCombat() == true and Messaged ~=2) then
DEFAULT_CHAT_FRAME:AddMessage("You are not in a TBC raid/dungeon but combat logging is in progress!",255, 255, 0);
Messaged = 2
else if (instancematch == true or raidmatch == true)
then startcl()
end
end
end
end

frame = CreateFrame("FRAME", "AutoCombatLog");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");


function startcl()
if LoggingCombat() then
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging is in progress!",255, 255, 0);
Messaged = 1
else
LoggingCombat(true);
DEFAULT_CHAT_FRAME:AddMessage("Combat Logging has been started!",255, 255, 0);
Messaged = 1
end
end


if kara == nil then kara = true end
if mag == nil then mag = true end
if gruul == nil then gruul = true end
if ssc == nil then ssc = true end
if tk == nil then tk = true end
if bt == nil then bt = true end
if hyjal == nil then hyjal = true end
if za == nil then za = true end
if swp == nil then swp = true end
if hrh == nil then hrh = true end
if bfh == nil then bfh = true end
if shhh == nil then shhh = true end
if sph == nil then sph = true end
if ubh == nil then ubh = true end
if svh == nil then svh = true end
if ach == nil then ach = true end
if mth == nil then mth = true end
if slh == nil then slh = true end
if shh == nil then shh = true end
if arch == nil then arch = true end
if both == nil then both = true end
if mechh == nil then mechh = true end
if ohfh == nil then ohfh = true end
if bmh == nil then bmh = true end
if mgth == nil then mgth = true end




if raidstatus == nil then raidstatus ="Disable" end
if dungeonstatus == nil then dungeonstatus = "Disable" end
if stoplogging == nil then stoplogging = false end


frame:SetScript("OnEvent", startLogging);

print ("Loaded TBC Combat Logging. Use /cl for settings!")
if LoggingCombat() then DEFAULT_CHAT_FRAME:AddMessage("Combat Logging has been started!",255, 255, 0);
end