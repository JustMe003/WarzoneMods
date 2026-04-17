local PAYLOAD_BASE = "target="

function createCardPayload(id)
    return PAYLOAD_BASE .. id;
end

function getTargetPlayerID(payload)
    local len = #PAYLOAD_BASE;
    if string.sub(payload, 1, len) == PAYLOAD_BASE then
        return tonumber(string.sub(payload, len + 1));
    end
end