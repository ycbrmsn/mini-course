rps = {
  names = { '石头', '剪刀', '布' },
  results = { '胜利', '平局', '失败' },
  index = 1
}

function rps:getResult (val)
  local curVal, result = math.random(1, 3)
  if (val == curVal) then
    result = rps.results[2]
  elseif ((val > curVal and val - 1 == curVal) or 
    (val < curVal and val + 2 == curVal)) then
    result = rps.results[3]
  else
    result = rps.results[1]
  end
  return result, curVal
end

function rps:getVal (name)
  local val
  for i, v in ipairs(rps.names) do
    if (v == name) then
      val = i
      break
    end
  end
  return val
end

-- eventobjid, content
local playerInputContent = function (event)
  local val = rps:getVal(event.content)
  if (val) then
    local result, curVal = rps:getResult(val)
    Chat:sendSystemMsg(rps.names[curVal] .. '-' .. result, event.eventobjid)
  end
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  Chat:sendSystemMsg(rps.names[rps.index + 1], event.eventobjid)
  rps.index = (rps.index + 1) % #rps.names
end

ScriptSupportEvent:registerEvent([=[Player.InputContent]=], playerInputContent)
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock)