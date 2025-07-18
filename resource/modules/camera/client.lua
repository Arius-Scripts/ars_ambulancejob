-- local Camera = lib.class("camera")

-- function Camera:init()
--     print("init")
--     local rotation, mode = GetGameplayCamRot(2), GetFollowPedCamViewMode()
--     local coords = mode == 4 and GetEntityCoords(cache.ped) - (GetEntityForwardVector(cache.ped) * 1.0) or GetGameplayCamCoord()

--     self.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, rotation.xyz, 50.0, true, 2)
--     RenderScriptCams(true, true, 1000, true, true)

--     self.speed = 0.1
--     self.distance = 5.0

--     self:threadControls()
-- end

-- function Camera:remove()
--     DestroyCam(self.cam)
--     RenderScriptCams(false, true, 1000, true, true)

--     self.cam = nil
-- end

-- -- yoinked from tx admin :D
-- local _internal_rot = nil
-- local function Clamp(x, _min, _max)
--     return math.min(math.max(x, _min), _max)
-- end

-- local function ClampCameraRotation(rotX, rotY, rotZ)
--     local x = Clamp(rotX, -90.0, 90.0)
--     local y = rotY % 360
--     local z = rotZ % 360
--     return x, y, z
-- end

-- local function GetFreecamRotation()
--     if not _internal_rot then
--         local rot = GetGameplayCamRot(2)
--         return vector3(rot.x, 0.0, rot.z)
--     end
--     return _internal_rot
-- end

-- local function SetFreecamRotation(cam, x, y, z)
--     local rotX, rotY, rotZ = ClampCameraRotation(x, y, z)
--     local rot = vector3(rotX, rotY, rotZ)

--     LockMinimapAngle(math.floor(rotZ))
--     SetCamRot(cam, rotX, rotY, rotZ, 2)

--     _internal_rot = rot
-- end

-- local function CheckRotationInput(cam)
--     local rot = GetFreecamRotation()

--     local lookX = GetDisabledControlNormal(0, 1)
--     local lookY = GetDisabledControlNormal(0, 2)

--     local rotX = rot.x + (-lookY * 6)
--     local rotZ = rot.z + (-lookX * 6)
--     local rotY = rot.y


--     rot = vector3(rotX, rotY, rotZ)
--     SetFreecamRotation(cam, rot.x, rot.y, rot.z)
-- end

-- function Camera:threadControls()
--     CreateThread(function()
--         while self.cam do
--             CheckRotationInput(self.cam)
--             Wait(0)
--         end
--     end)
-- end

-- return Camera



-- REMOVED COS ADDED DEATH SCREEN :D
