--[[ 封装生物API v1.0.0
  create by 莫小仙 on 2023-01-17
]]
CreatureAPI = {}

--[[
  获取生物属性
  @param  {integer} objid 生物id
  @param  {integer} attrtype 属性
  @return {number | nil} 属性值，nil表示获取失败
]]
function CreatureAPI.getAttr (objid, attrtype)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getAttr(objid, attrtype)
  end, '获取生物属性', 'objid=', objid, ',attrtype=', attrtype)
end

--[[
  设置生物属性
  @param  {integer} objid 生物id
  @param  {integer} attrtype 属性
  @param  {number} val 属性值
  @return {boolean} 是否成功
]]
function CreatureAPI.setAttr (objid, attrtype, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setAttr(objid, attrtype, val)
  end, '设置生物属性', 'objid=', objid, ',attrtype=', attrtype, ',val=', val)
end

--[[
  判断生物是否成年
  @param  {integer} objid 生物id
  @return {boolean} 是否成年
]]
function CreatureAPI.isAdult (objid)
  return Creature:isAdult(objid) == ErrorCode.OK
end

--[[
  设置生物是否依赖氧气
  @param  {integer} objid 生物id
  @param  {boolean} isActive 是否需要氧气
  @return {boolean} 是否成功
]]
function CreatureAPI.setOxygenNeed (objid, isActive)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setOxygenNeed(objid, isActive)
  end, '设置是否依赖氧气', 'objid=', objid, ',isActive=', isActive)
end

--[[
  获取驯养主ID
  @param  {integer} objid 生物id
  @return {integer | nil} 驯养主id，nil表示获取失败
]]
function CreatureAPI.getTamedOwnerID (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getTamedOwnerID(objid)
  end, '获取驯养主ID', 'objid=', objid)
end

--[[
  设置生物是否正在惊慌
  @param  {integer} objid 生物id
  @param  {boolean} isActive 是否正在惊慌
  @return {boolean} 是否成功
]]
function CreatureAPI.setPanic (objid, isActive)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setPanic(objid, isActive)
  end, '设置生物是否正在惊慌', 'objid=', objid, ',isActive=', isActive)
end

--[[
  设置生物AI是否生效
  @param  {integer} objid 生物id
  @param  {boolean} isActive AI是否生效
  @return {boolean} 是否成功
]]
function CreatureAPI.setAIActive (objid, isActive)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setAIActive(objid, isActive)
  end, '设置生物AI是否生效', 'objid=', objid, ',isActive=', isActive)
end

--[[
  获取生物类型id。
  比较常用，这里就不打印失败信息
  @param  {integer} objid 生物id
  @return {integer | nil} 生物类型id，nil表示获取失败
]]
function CreatureAPI.getActorID (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getActorID(objid)
  end, nil, 'objid=', objid)
end

--[[
  获取生物名称
  @param  {integer} objid 生物id
  @return {string | nil} 生物名称，nil表示获取失败
]]
function CreatureAPI.getActorName (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getActorName(objid)
  end, '获取生物名称', 'objid=', objid)
end

--[[
  增加生物模组属性
  @param  {integer} objid 生物id
  @param  {integer} attrtype 附魔属性类型
  @param  {number} val 附魔属性值
  @return {boolean} 是否成功
]]
function CreatureAPI.addModAttrib (objid, attrtype, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:addModAttrib(objid, attrtype, val)
  end, '增加模组属性', 'objid=', objid, ',attrtype=', attrtype, ',val=', val)
end

--[[
  获取生物模组属性值
  @param  {integer} objid 生物id
  @param  {integer} attrtype 附魔属性类型
  @return {number | nil} 附魔属性值，nil表示获取失败
]]
function CreatureAPI.getModAttrib (objid, attrtype)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getModAttrib(objid, attrtype)
  end, '获取模组属性', 'objid=', objid, ',attrtype=', attrtype)
end

--[[
  设置生物队伍
  @param  {integer} objid 生物id
  @param  {integer} teamid 队伍id
  @return {boolean} 是否成功
]]
function CreatureAPI.setTeam (objid, teamid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setTeam(objid, teamid)
  end, '设置生物队伍', 'objid=', objid, ',teamid=', teamid)
end

--[[
  获取生物队伍
  @param  {integer} objid 生物id
  @return {integer | nil} 队伍id，nil表示获取失败
]]
function CreatureAPI.getTeam (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getTeam(objid)
  end, '获取生物队伍', 'objid=', objid)
end

--[[
  获取生物最大饥饿度
  @param  {integer} objid 生物id
  @return {number | nil} 最大饥饿度，nil表示获取失败
]]
function CreatureAPI.getMaxFood (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getMaxFood(objid)
  end, '获取生物最大饥饿度', 'objid=', objid)
end

--[[
  获取生物饥饿度
  @param  {integer} objid 生物id
  @return {number | nil} 饥饿度，nil表示获取失败
]]
function CreatureAPI.getFood (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getFood(objid)
  end, '获取生物饥饿度', 'objid=', objid)
end

--[[
  设置生物饥饿度
  @param  {integer} objid 生物id
  @param  {number} val 饥饿度
  @return {boolean} 是否成功
]]
function CreatureAPI.setFood (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setFood(objid, val)
  end, '设置饥饿度', 'objid=', objid, ',val=', val)
end

--[[
  获取生物HP恢复
  @param  {integer} objid 生物id
  @return {number | nil} HP恢复，nil表示获取失败
]]
function CreatureAPI.getHpRecover (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getHpRecover(objid)
  end, '获取生物HP恢复', 'objid=', objid)
end

--[[
  获取生物最大氧气值
  @param  {integer} objid 生物id
  @return {number | nil} 最大氧气值，nil表示获取失败
]]
function CreatureAPI.getMaxOxygen (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getMaxOxygen(objid)
  end, '获取生物最大氧气值', 'objid=', objid)
end

--[[
  获取生物行走速度
  原始速度是-1，一般是10
  @param  {integer} objid 生物id
  @return {number | nil} 行走速度，nil表示获取失败
]]
function CreatureAPI.getWalkSpeed (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getWalkSpeed(objid)
  end, '获取生物行走速度', 'objid=', objid)
end

--[[
  获取生物游泳速度
  @param  {integer} objid 生物id
  @return {number | nil} 游泳速度，nil表示获取失败
]]
function CreatureAPI.getSwimSpeed (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getSwimSpeed(objid)
  end, '获取生物游泳速度', 'objid=', objid)
end

--[[
  获取生物跳跃力
  @param  {integer} objid 生物id
  @return {number | nil} 跳跃力，nil表示获取失败
]]
function CreatureAPI.getJumpPower (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getJumpPower(objid)
  end, '获取生物跳跃力', 'objid=', objid)
end

--[[
  获取生物重量
  @param  {integer} objid 生物id
  @return {number | nil} 重量，nil表示获取失败
]]
function CreatureAPI.getMass (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getMass(objid)
  end, '获取生物重量', 'objid=', objid)
end

--[[
  获取生物闪避
  @param  {integer} objid 生物id
  @return {number | nil} 闪避，nil表示获取失败
]]
function CreatureAPI.getDodge (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getDodge(objid)
  end, '获取生物闪避', 'objid=', objid)
end

--[[
  获取生物近战攻击
  @param  {integer} objid 生物id
  @return {number | nil} 近战攻击，nil表示获取失败
]]
function CreatureAPI.getPunchAttack (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getPunchAttack(objid)
  end, '获取生物近战攻击', 'objid=', objid)
end

--[[
  获取生物远程攻击
  @param  {integer} objid 生物id
  @return {number | nil} 远程攻击，nil表示获取失败
]]
function CreatureAPI.getRangeAttack (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getRangeAttack(objid)
  end, '获取生物远程攻击', 'objid=', objid)
end

--[[
  获取生物近战防御
  @param  {integer} objid 生物id
  @return {number | nil} 近战防御，nil表示获取失败
]]
function CreatureAPI.getPunchDefense (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getPunchDefense(objid)
  end, '获取生物近战防御', 'objid=', objid)
end

--[[
  获取生物远程防御
  @param  {integer} objid 生物id
  @return {number | nil} 远程防御，nil表示获取失败
]]
function CreatureAPI.getRangeDefense (objid)
  return YcApiHelper.callResultMethod(function ()
    return Creature:getRangeDefense(objid)
  end, '获取生物远程防御', 'objid=', objid)
end

--[[
  设置生物血量上限
  @param  {integer} objid 生物id
  @param  {number} val 血量上限
  @return {boolean} 是否成功
]]
function CreatureAPI.setMaxHp (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setMaxHp(objid, val)
  end, '设置生物血量上限', 'objid=', objid, ',val=', val)
end

--[[
  设置生物血量
  @param  {integer} objid 生物id
  @param  {number} val 血量
  @return {boolean} 是否成功
]]
function CreatureAPI.setHP (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setHP(objid, val)
  end, '设置生物血量', 'objid=', objid, ',val=', val)
end

--[[
  设置生物HP恢复
  @param  {integer} objid 生物id
  @param  {number} val HP恢复
  @return {boolean} 是否成功
]]
function CreatureAPI.setHpRecover (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setHpRecover(objid, val)
  end, '设置生物HP恢复', 'objid=', objid, ',val=', val)
end

--[[
  设置生物现有氧气
  @param  {integer} objid 生物id
  @param  {number} val 现有氧气
  @return {boolean} 是否成功
]]
function CreatureAPI.setOxygen (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setOxygen(objid, val)
  end, '设置生物现有氧气', 'objid=', objid, ',val=', val)
end

--[[
  设置生物行走速度
  @param  {integer} objid 生物id
  @param  {number} val 行走速度
  @return {boolean} 是否成功
]]
function CreatureAPI.setWalkSpeed (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setWalkSpeed(objid, val)
  end, '设置生物行走速度', 'objid=', objid, ',val=', val)
end

--[[
  设置生物游泳速度
  @param  {integer} objid 生物id
  @param  {number} val 游泳速度
  @return {boolean} 是否成功
]]
function CreatureAPI.setSwimSpeed (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setSwimSpeed(objid, val)
  end, '设置生物游泳速度', 'objid=', objid, ',val=', val)
end

--[[
  设置生物跳跃力
  @param  {integer} objid 生物id
  @param  {number} val 跳跃力
  @return {boolean} 是否成功
]]
function CreatureAPI.setJumpPower (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setJumpPower(objid, val)
  end, '设置生物跳跃力', 'objid=', objid, ',val=', val)
end

--[[
  设置生物闪避
  @param  {integer} objid 生物id
  @param  {number} val 闪避
  @return {boolean} 是否成功
]]
function CreatureAPI.setDodge (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setDodge(objid, val)
  end, '设置生物闪避', 'objid=', objid, ',val=', val)
end

--[[
  设置生物近战攻击
  @param  {integer} objid 生物id
  @param  {number} val 近战攻击
  @return {boolean} 是否成功
]]
function CreatureAPI.setPunchAttack (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setPunchAttack(objid, val)
  end, '设置生物近战攻击', 'objid=', objid, ',val=', val)
end

--[[
  设置生物远程攻击
  @param  {integer} objid 生物id
  @param  {number} val 远程攻击
  @return {boolean} 是否成功
]]
function CreatureAPI.setRangeAttack (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setRangeAttack(objid, val)
  end, '设置生物远程攻击', 'objid=', objid, ',val=', val)
end

--[[
  设置生物近战防御
  @param  {integer} objid 生物id
  @param  {number} val 近战防御
  @return {boolean} 是否成功
]]
function CreatureAPI.setPunchDefense (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setPunchDefense(objid, val)
  end, '设置生物近战防御', 'objid=', objid, ',val=', val)
end

--[[
  设置生物远程防御
  @param  {integer} objid 生物id
  @param  {number} val 远程防御
  @return {boolean} 是否成功
]]
function CreatureAPI.setRangeDefense (objid, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:setRangeDefense(objid, val)
  end, '设置生物远程防御', 'objid=', objid, ',val=', val)
end

--[[
  替换生物
  @param  {integer} objid 生物id
  @param  {integer} actorid 替换后的生物类型id
  @param  {number} hppercent 替换后的血量百分比
  @return {boolean} 是否成功
]]
function CreatureAPI.replaceActor (objid, actorid, hppercent)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Creature:replaceActor(objid, actorid, hppercent)
  end, '替换生物', 'objid=', objid, ',actorid=', actorid, ',hppercent=', hppercent)
end
