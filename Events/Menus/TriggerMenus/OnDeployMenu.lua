require("Enums.TriggerEnums");

require("Triggers.OnDeploy");

require("Menus.TriggerMenus.TriggerMenu");

OnDeployMenu = {};

function OnDeployMenu.ShowMenu(trigger)
    History.AddToHistory(OnDeployMenu.ShowMenu, trigger);
    UI2.DestroyWindow();

    local inputs = {};
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    
    TriggerMenu.ShowTriggerHeader(trigger, inputs, root, OnDeployMenu.SaveTrigger);

    TriggerMenu.showTrigger(trigger, inputs, root, OnDeployMenu.SaveTrigger, OnDeployMenu.ShowMenu);
    
    TriggerMenu.ShowModifyMinimumCondition(root, trigger, inputs, "NumDeployed", "number of deployed armies", OnDeploy.Info.MinimumArmiesDeployedCondition, OnDeployMenu.SaveTrigger, OnDeployMenu.ShowMenu);
    TriggerMenu.ShowModifyMaximumCondition(root, trigger, inputs, "NumDeployed", "number of deployed armies", OnDeploy.Info.MaximumArmiesDeployedCondition, OnDeployMenu.SaveTrigger, OnDeployMenu.ShowMenu);

    TriggerMenu.ShowAddConditionsButton(trigger, inputs, root, OnDeployMenu.GenerateConditionList, OnDeployMenu.ShowMenu);
end

TriggerMenu.AddTriggerMenu(TriggerTypeEnum.ON_DEPLOY, OnDeployMenu.ShowMenu);

---Saves a OnDeploy trigger
---@param trigger OnDeploy
---@param inputs table
function OnDeployMenu.SaveTrigger(trigger, inputs)
    if inputs.NumDeployed ~= nil then
        trigger.NumDeployed = trigger.NumDeployed or {};
        if not UI2.IsDestroyed(inputs.NumDeployed.Minimum) then trigger.NumDeployed.Minimum = inputs.NumDeployed.Minimum.GetValue(); end
        if not UI2.IsDestroyed(inputs.NumDeployed.Maximum) then trigger.NumDeployed.Maximum = inputs.NumDeployed.Maximum.GetValue(); end
    end
    TriggerMenu.SaveTrigger(trigger, inputs);
end

---Generates the condition list based on the trigger type
---@param trigger OnDeploy
---@param inputs table
---@param selectFun fun(t: OnDeploy)
---@param close fun()
---@return ListItem
function OnDeployMenu.GenerateConditionList(trigger, inputs, selectFun, close)
    return mergeTables(TriggerMenu.GenerateConditionList(trigger, inputs, selectFun, close), {
        Deploy = {
            (trigger.NumDeployed == nil or trigger.NumDeployed.Minimum == nil) and {
                Name = "Min number of deployed armies";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumDeployed = trigger.NumDeployed or {};
                    trigger.NumDeployed.Minimum = 5;
                    selectFun(trigger);
                    close();
                end;
                Info = OnDeploy.Info.MinimumArmiesDeployedCondition;
            } or nil;
            (trigger.NumDeployed == nil or trigger.NumDeployed.Maximum == nil) and {
                Name = "Max number of deployed armies";
                Action = function()
                    TriggerMenu.SaveTrigger(trigger, inputs);
                    trigger.NumDeployed = trigger.NumDeployed or {};
                    trigger.NumDeployed.Maximum = 20;
                    selectFun(trigger);
                    close();
                end;
                Info = OnDeploy.Info.MaximumArmiesDeployedCondition;
            } or nil;
        }
    });
end

