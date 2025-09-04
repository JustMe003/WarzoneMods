require("UI");
require("Hills")

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(400, 500);
    Init();
    colors = GetColors();
    Game = game;
    GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1);
    showMain();
end

function showMain()
    DestroyWindow();

    local root = CreateWindow(CreateVert(GlobalRoot));
    CreateLabel(root).SetText("In this game there are " .. Mod.Settings.NumHills .. " hills. You need to control all the hills (with your team) for " .. Mod.Settings.NumTurns .. " turns in order to win the game").SetColor(colors.TextColor);
    
    CreateEmpty(root).SetPreferredHeight(5);
    if Mod.PublicGameData.LastControllingPlayer ~= -1 then
        if Mod.PublicGameData.IsTeamGame then
            CreateLabel(root).SetText(getTeamName(Mod.PublicGameData.LastControllingPlayer) .. " controls all the hills for " .. Mod.PublicGameData.NumTurnsControlling .. " out of the " .. Mod.Settings.NumTurns .. " turns required to win...").SetColor(colors["Orange Red"]);
        else
            CreateLabel(root).SetText(Game.Game.Players[Mod.PublicGameData.LastControllingPlayer].DisplayName(nil, true) .. " controls all the hills for " .. Mod.PublicGameData.NumTurnsControlling .. " out of the " .. Mod.Settings.NumTurns .. " turns required to win...").SetColor(colors["Orange Red"]);
        end
    end

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Hills").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Controlled by").SetColor(colors.TextColor);
    for _, terrID in ipairs(Mod.PublicGameData.Hills) do
        local terrDetails = Game.Map.Territories[terrID]
        local line = CreateHorz(root).SetFlexibleWidth(1);
        local owner = Game.Game.Players[Game.LatestStanding.Territories[terrID].OwnerPlayerID];
        local button = CreateButton(line).SetText(getStringForButton(terrDetails.Name)).SetOnClick(function()
            Game.CreateLocatorCircle(terrDetails.MiddlePointX, terrDetails.MiddlePointY);
            Game.HighlightTerritories({terrID});
        end);
        CreateEmpty(line).SetFlexibleWidth(1);
        if Game.LatestStanding.Territories[terrID].OwnerPlayerID == WL.PlayerID.Neutral then
            CreateLabel(line).SetText("Neutral").SetColor(colors.TextColor);
        elseif owner == nil then
            if Mod.PublicGameData.LastControllingPlayer ~= -1 then
                if Mod.PublicGameData.IsTeamGame then
                    CreateLabel(line).SetText(getTeamName(Mod.PublicGameData.LastControllingPlayer) .. " [Unknown]").SetColor(colors.TextColor);
                else
                    CreateLabel(line).SetText(Game.Game.Players[Mod.PublicGameData.LastControllingPlayer].DisplayName(nil, true)).SetColor(colors.TextColor);
                end
            else
                CreateLabel(line).SetText("Unknown").SetColor(colors.TextColor);
            end
        else
            button.SetColor(getPlayerColor(owner));
            if Mod.PublicGameData.IsTeamGame then
                CreateLabel(line).SetText(getTeamName(owner.Team) .. " [" .. owner.DisplayName(nil, true) .. "]").SetColor(colors.TextColor);
            else
                CreateLabel(line).SetText(owner.DisplayName(nil, true)).SetColor(colors.TextColor);
            end
        end
    end
end

function getPlayerColor(p)
    return p.Color.HtmlColor;
end

function getStringForButton(s, limit)
    limit = limit or 30;
    if #s > limit then
        return string.sub(s, 1, limit) .. "...";
    else
        return s;
    end
end

function getTeamName(team)
	local s = "";
	team = team + 1;
    while team > 0 do
        local n = team % 26;
        if n == 0 then
            -- team % 26 == 26
            n = 26;
        end
        team = (team - n) / 26;
        s = string.char(n + 64) .. s;
    end
    return "Team " .. s;
end