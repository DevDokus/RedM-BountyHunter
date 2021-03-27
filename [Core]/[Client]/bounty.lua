--------------------------------------------------------------------------------
------------------------------------ Bounty ------------------------------------
--------------------------------------------------------------------------------

local Models = {
  "MP_CHU_ROB_MILLESANI_MALES_01", "AM_VALENTINEDOCTORS_FEMALES_01", "A_F_M_ARMCHOLERACORPSE_01",
  "A_F_M_ARMTOWNFOLK_01", "A_F_M_ArmTownfolk_02", "A_F_M_AsbTownfolk_01", "A_F_M_BiVFancyTravellers_01",
  "A_F_M_BlWTownfolk_01", "A_F_M_BlWTownfolk_02", "A_F_M_BlWUpperClass_01", "A_F_M_BtcHillbilly_01",
  "A_F_M_BTCObeseWomen_01", "A_F_M_GuaTownfolk_01", "A_F_M_LagTownfolk_01", "A_F_M_LowerSDTownfolk_01",
  "A_F_M_LowerSDTownfolk_02", "A_F_M_LowerSDTownfolk_03", "A_F_M_MiddleSDTownfolk_01", "A_F_M_MiddleSDTownfolk_02",
  "A_F_M_MiddleSDTownfolk_03", "A_F_M_NbxSlums_01", "A_F_M_NbxUpperClass_01", "A_F_M_NbxWhore_01",
  "A_F_M_RhdTownfolk_01", "A_F_M_RhdTownfolk_02", "A_F_M_ROUGHTRAVELLERS_01", "A_F_M_SDChinatown_01",
  "A_F_M_SDSlums_02", "A_F_M_StrTownfolk_01", "A_F_M_TumTownfolk_01", "A_F_M_TumTownfolk_02",
  "mp_dr_u_m_m_MISTAKENBOUNTIES_01"
}

local Weapons = {
  0x772C8DD6, 0x169F59F7, 0xDB21AC8C, 0x6DFA071B,
  0xF5175BA1, 0xD2718D48, 0x797FBF5, 0x772C8DD6,
  0x7BBD1FF6, 0x63F46DE6, 0xA84762EC, 0xDDF7BC1E,
  0x20D13FF, 0x1765A8F8, 0x657065D6, 0x8580C63E,
  0x95B24592, 0x31B7B9FE, 0x88A855C, 0x1C02870C,
  0x28950C71, 0x6DFA071B
}
--------------------------------------------------------------------------------
-- Core
--------------------------------------------------------------------------------
RegisterNetEvent('DevDokus:BountyHunter:C:SetUpMission')
RegisterNetEvent('DevDokus:BountyHunter:C:ResetTotalKills')
--------------------------------------------------------------------------------
TotalKilled = 0
local ArrayBounties = {}
local CreateNPC = {}
local NPCx, NPCy, NPCz = 0, 0, 0
local InMission = false
local TotalEnemies = 0
local SearchingBodies = false
local GPSToBodyIsSet = false
local SaveGuard = false

AddEventHandler('DevDokus:BountyHunter:C:SetUpMission', function(_Job)
  -- Make sure this script does not execute twice.
  SaveGuard = true
  
  -- See if any job is required.
  local HasJob = false
  local NeedJob = false
  for k,v in pairs(Jobs) do
    if v.Use == true then
      NeedJob = true
    end
  end

  -- Get all job names and check the user.
  if NeedJob then
    for k,v in pairs(Jobs) do
      if v.Job == _Job then
        HasJob = true
      end
    end
  end

  -- Stop the user if he/she does not have the correct jobs.
  if NeedJob and not HasJob then Notify(Jobs.NoJob) return end

    -- Get a random bounty ID
    local rLoc = Bounties[math.random(#Bounties)]
    -- Get all NPCs associated with this ID
    for k, v in pairs(Bounties) do
      if v.ID == rLoc.ID then
        TotalEnemies = TotalEnemies + 1
        -- Get a random model for this NPC
        local rModel = GetHashKey(Models[math.random(#Models)])
        RequestModel(rModel)
        if not HasModelLoaded(rModel) then RequestModel(rModel) end
        while not HasModelLoaded(rModel) do Wait(1) end
        -- Spawn the NPC with a random loadout
        local rWeapon = Weapons[math.random(#Weapons)]
        CreateNPC[k] = CreatePed(rModel, v.Coords.x, v.Coords.y, v.Coords.z, true, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, CreateNPC[k], true)
        Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, CreateNPC[k])
        NPCx, NPCy, NPCz = v.x, v.y, v.z
        GiveWeaponToPed_2(CreateNPC[k], rWeapon, 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        SetCurrentPedWeapon(CreateNPC[k], rWeapon, true)
        TaskCombatPed(CreateNPC[k], PlayerPedId())
        ArrayBounties[k] = CreateNPC[k]
      end
    end

    -- Start the GPS
    -- StartGpsMultiRoute(6, true, true)
    -- AddPointToGpsMultiRoute(NPCx, NPCy, NPCz)
    -- AddPointToGpsMultiRoute(NPCx, NPCy, NPCz)
    -- SetGpsMultiRouteRender(true)

    Wait(1000)
    Notify('Your Bounty is located on the map!', 5000)
    Wait(2000)
    Notify('We need them dead, not alive! But Dead!', 5000)
    Wait(1500)
    Notify('You can stack bounties, just keep in mind', 5000)
    Wait(1000)
    Notify('that you lose the bounties if you died!', 5000)
    InMission = true
    SaveGuard = false
    while InMission do Wait(1)
      for k, v in pairs(ArrayBounties) do
        if IsEntityDead(v) then
          local eCoords = GetEntityCoords(ArrayBounties[k])

          if ArrayBounties[k] ~= nil then
            TotalEnemies = TotalEnemies - 1
            TotalKilled = TotalKilled + 1
            ArrayBounties[k] = nil
            if TotalEnemies == 0 then
              TriggerEvent("vorp:TipRight", 'You managed to kill all targets', 5000)
              SearchingBodies = true
              Wait(5000)
              Notify('Search the body for evidence,', 5000)
              Notify('and bing this back to the police office!', 5000)
              local ped = PlayerPedId()
              while SearchingBodies do Wait(1)
                local ped = PlayerPedId()
                local pCoords = GetEntityCoords(ped)
                local dist = GetDistanceBetweenCoords(pCoords, eCoords)
                local E = IsControlJustReleased(1, Keys['E'])

                if not GPSToBodyIsSet then
                  GPSToBodyIsSet = true
                  StartGpsMultiRoute(6, true, true)
                  AddPointToGpsMultiRoute(eCoords)
                  SetGpsMultiRouteRender(true)
                end

                -- If close to killed bounty pick up evidence and head back.
                if (dist <= 5) and E then
                  Wait(2000)
                  StopMission()
                  Notify('Bring back the rewards to the sherrif!', 5000)
                end
              end
            end
          end
        end

        if IsPlayerDead() then
          TriggerEvent("vorp:TipRight", "You've lost your target", 4000)
          StopMission()
          TotalKilled = 0
        end
      end
    end
  end)

  function StopMission()
    InMission = false
    SetGpsMultiRouteRender(false)
    for k, v in pairs(CreateNPC) do DeletePed(v) Wait(500) end
    table.remove{CreateNPC} table.remove{ArrayBounties}
  end


  AddEventHandler('DevDokus:BountyHunter:C:ResetTotalKills', function()
    TotalKilled = 0
  end)
