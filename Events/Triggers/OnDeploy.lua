require("Triggers.Trigger");

---@class OnDeploy : Trigger # Trigger for deployment orders
---@field NumDeployed MinMaxObject? # The minimum and maximum number of armies deployed

OnDeploy = {
    Info = {
        MinimumArmiesDeployedCondition = "This condition is met when the number of armies deployed is at least a certain number.\nIf this condition is set to 5, this condition is met if the deployment order deploys 5 or more armies.\nNote that this only takes the new deployed armies into account, nothing else";
        MaximumArmiesDeployedCondition = "This condition is met when the number of armies deployed is at most a certain number.\nIf this condition is set to 15, this condition is met if the deployment order deploys 15 or less armies.\nNote that this only takes the new deployed armies into account, nothing else";
    }
}

