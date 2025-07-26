if SERVER then return end
local currentPanel = nil
local cmd = ""
local function MakeHelp(human)
    local cmdHelp = GetConVar(cmd):GetHelpText()
    if human then
        cmdHelp = string.Replace(cmdHelp,"1","checked")
        cmdHelp = string.Replace(cmdHelp,"0","unchecked")
    end
    currentPanel:Help(cmdHelp)
end


local function DefaultsClient()
    for _,convar in pairs(CSSClientConvars) do
        RunConsoleCommand(convar:GetName(),convar:GetDefault())
    end
end
local function DefaultsServer()
    for _,convar in pairs(CSSServerConvars) do
        RunConsoleCommand(convar:GetName(),convar:GetDefault())
    end
end
concommand.Add("css_cl_reset_defaults",DefaultsClient)
concommand.Add("css_sv_reset_defaults",DefaultsServer)

hook.Add("PopulateToolMenu", "CSSWeaponsMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Counter-Strike: Source", "CSSWeaponsConfigureClient", "Client", "", "", function(panel)
        currentPanel = panel
		panel:ClearControls()
		panel:Help("Client Options")
		panel:Help(" ")
        cmd = "css_cl_weapons_lefthand"
        MakeHelp(true)
        panel:CheckBox("Left Handed",cmd)
        panel:Help(" ")
        
        cmd = "css_cl_weapons_weaponsway"
        MakeHelp()
        panel:NumSlider("Weapon Sway",cmd,0,2,0)
        panel:Help(" ")
        
        cmd = "css_cl_weapons_adjust_carms"
        MakeHelp(true)
        panel:CheckBox("Adjust C Arms",cmd)
        panel:Help(" ")

        panel:Help("W.I.P")
        cmd = "css_cl_flashbang_dark"
        MakeHelp(true)
        panel:CheckBox("Dark Flashbang",cmd)
        panel:Help(" ")
        cmd = "css_cl_drop_bind"
        panel:Help("Drop Keybind:")
        local dbinder = vgui.Create("DBinder")
        dbinder:SetValue(GetConVar("css_cl_drop_bind"):GetInt())
        dbinder.OnChange = function(self,iNum)
            RunConsoleCommand(cmd,iNum)
            print(iNum)
        end
        panel:AddItem(dbinder)
        panel:Help(" ")
        panel:Help(" ")
        
        
		local button = panel:Button("Reset to defaults","css_cl_reset_defaults",{})
        button.DoClick = function() dbinder:SetValue(KEY_G) end
	end)
	spawnmenu.AddToolMenuOption("Options", "Counter-Strike: Source", "CSSWeaponsConfigureServer", "Server", "", "", function(panel)
        currentPanel = panel
		panel:ClearControls()
		panel:Help("Server Options")
		panel:Help(" ")
        if CSS_AuthenticPackInstalled then
            cmd = "css_sv_weapon_compatibility"
            MakeHelp(true)
            panel:CheckBox("Compatibility Mode (Requires Reload)",cmd)
            panel:Help(" ")
        end
        cmd = "css_sv_weapons_use_arms"
        MakeHelp(true)
        panel:CheckBox("Use C-Arms (Requires Reload)",cmd)
        panel:Help(" ")
        cmd = "css_sv_weapons_sandbox_slots"
        MakeHelp(true)
        panel:CheckBox("Sandbox Slots (Requires Reload)",cmd)
        panel:Help(" ")
        cmd = "css_sv_weapons_pistols_automatic"
        MakeHelp(true)
        panel:CheckBox("Automatic Pistols (Requires Reload)",cmd)
        panel:Help(" ")
        panel:Help("-----")
        panel:Help(" ")
        cmd = "css_sv_weapons_drop_on_death"
        MakeHelp(true)
        panel:CheckBox("Drop Weapons",cmd)
        panel:Help(" ")
        cmd = "css_sv_sandbox_weapons_give_ammo"
        MakeHelp(true)
        panel:CheckBox("Give ammo on pickup",cmd)
        panel:Help(" ")
        cmd = "css_sv_weapons_damage_multiplier"
        MakeHelp()
        panel:NumSlider("Damage Multiplier",cmd,0,10,2)
        panel:Help(" ")
        cmd = "css_sv_weapons_alt_viewpunch"
        MakeHelp(true)
        panel:CheckBox("Alternate ViewPunch",cmd)
        panel:Help(" ")
        cmd = "css_sv_weapons_randomspraypatternflip"
        MakeHelp(true)
        panel:CheckBox("Random SprayPattern Flip",cmd)
        panel:Help(" ")
        cmd = "css_sv_weapons_sniper_unscope_aftershot"
        MakeHelp(true)
        panel:CheckBox("Un-Scope after shot (Snipers)",cmd)
        panel:Help(" ")
        
        panel:Help("W.I.P")
        cmd = "css_sv_debug_weapon_spray"
        MakeHelp(true)
        panel:CheckBox("Debug Spray (developer 1 required)",cmd)
        panel:Help(" ")
        cmd = "css_sv_weapons_infinite_grenades"
        MakeHelp(true)
        panel:CheckBox("Infinite Grenades",cmd)
        panel:Help(" ")
        cmd = "css_sv_flashbang_blindtime_multiplier"
        MakeHelp()
        panel:NumSlider("Flashbang blindtime multiplier",cmd,0.01,2,2)
        panel:Help(" ")
        cmd = "css_sv_flashbang_blind_maxalpha"
        MakeHelp()
        panel:NumSlider("Flashbang Max Alpha",cmd,0,255,0)
        panel:Help(" ")
        
        


        panel:Help(" ")


		panel:Button("Reset to defaults","css_sv_reset_defaults",{})
	end)
end)