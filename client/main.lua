local lastGrab = 0

local function trace(startCoords, endCoords, radius, ped)
    local handle = StartShapeTestCapsule(startCoords.x, startCoords.y, startCoords.z, endCoords.x, endCoords.y, endCoords.z, radius, 511, ped, 7)
    local _, hit, hitCoords, _, entity = GetShapeTestResult(handle)
    return hit == 1, hitCoords, entity
end

local function findLedge(ped)
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local wallStart = coords + vector3(0.0, 0.0, 0.45)
    local wallEnd = coords + vector3(forward.x*Config.wallDistance, forward.y*Config.wallDistance, 1.45)
    local wallHit, wallCoords = trace(wallStart, wallEnd, 0.18, ped)
    if not wallHit then
        return false
    end
    local topStart = vector3(wallCoords.x, wallCoords.y, coords.z + Config.maxReach + 0.5)
    local topEnd = vector3(wallCoords.x, wallCoords.y, coords.z - 0.2)
    local topHit, topCoords = trace(topStart, topEnd, 0.12, ped)
    local ledgeHeight = topCoords.z - coords.z
    if not topHit or ledgeHeight < Config.minReach or ledgeHeight > Config.maxReach then
        return false
    end
    return true
end

CreateThread(function()
    while true do
        if not Config.enabled then
            Wait(500)
        else
            local ped = PlayerPedId()
            local airborne = IsPedJumping(ped) or IsPedFalling(ped)
            local canGrab = GetGameTimer() - lastGrab >= Config.grabCooldown
            if airborne and canGrab and not IsPedRagdoll(ped) and not IsPedInAnyVehicle(ped, false) and findLedge(ped) then
                TaskClimb(ped, false)
                lastGrab = GetGameTimer()
                Wait(500)
            else
                Wait(0)
            end
        end
    end
end)