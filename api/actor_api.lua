--- 封装行为者API v1.1.1
--- created by 莫小仙 on 2022-06-15
--- last modified on 2024-01-03
---@class ActorAPI 行为者API
ActorAPI = {}

--[[
  @param  {integer} objid 对象id
  @return {boolean} 对象是否是玩家
]]
function ActorAPI.isPlayer(objid)
  return Actor:isPlayer(objid) == ErrorCode.OK
end

--[[
  @param  {integer} objid 对象id
  @return {integer | nil} 对象类型OBJ_TYPE
    1玩家   OBJ_TYPE.OBJTYPE_PLAYER
    2生物   OBJ_TYPE.OBJTYPE_CREATURE
    3掉落物 OBJ_TYPE.OBJTYPE_DROPITEM
    4投掷物 OBJ_TYPE.OBJTYPE_MISSILE
    nil表示获取类型失败
]]
function ActorAPI.getObjType(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getObjType(objid)
  end, '获取对象类型', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @return {boolean} 是否在空中
]]
function ActorAPI.isInAir(objid)
  return Actor:isInAir(objid) == ErrorCode.OK
end

--[[
  获取生物位置。这个函数很容易调用失败，就不打印警告信息了
  @param  {integer} objid 对象id
  @return {number | nil} 位置的x，nil表示在玩家附近找不到对象
  @return {number | nil} 位置的y，nil表示在玩家附近找不到对象
  @return {number | nil} 位置的z，nil表示在玩家附近找不到对象
]]
function ActorAPI.getPosition(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getPosition(objid)
  end, nil, 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @param  {number} 位置的x
  @param  {number} 位置的y
  @param  {number} 位置的z
  @return {boolean} 是否成功
]]
function ActorAPI.setPosition(objid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setPosition(objid, x, y, z)
  end, '设置对象位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  @param  {integer} objid 生物id
  @return {boolean} 是否成功
]]
function ActorAPI.killSelf(objid)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:killSelf(objid)
  end, '杀死自己', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @return {integer | nil} 朝向，0东1西2北3南，nil表示获取朝向失败
]]
function ActorAPI.getCurPlaceDir(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getCurPlaceDir(objid)
  end, '获取当前朝向', 'objid=', objid)
end

--[[
  @param  {integer} objid 生物id
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @param  {number} z 位置的z
  @param  {number} speed 速度的倍数
  @return {boolean} 是否成功
]]
function ActorAPI.tryMoveToPos(objid, x, y, z, speed)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:tryMoveToPos(objid, x, y, z, speed)
  end, '向目标位置移动', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z, ',speed=', speed)
end

--[[
  @param  {integer} objid 生物id
  @param  {number} hp 生命值
  @return {boolean} 是否成功
]]
function ActorAPI.addHP(objid, hp)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:addHP(objid, hp)
  end, '增加当前生命量', 'objid=', objid, ',hp=', hp)
end

--[[
  @param  {integer} objid 生物id
  @return {number | nil} 生命值，nil表示获取失败
]]
function ActorAPI.getHP(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getHP(objid)
  end, '获取当前生命量', 'objid=', objid)
end

--[[
  @param  {integer} objid 生物id
  @return {number | nil} 最大生命值，nil表示获取失败
]]
function ActorAPI.getMaxHP(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getMaxHP(objid)
  end, '获取最大生命量', 'objid=', objid)
end

--[[
  @param  {integer} objid 生物id
  @param  {number} oxygen 氧气值
  @return {boolean} 是否成功
]]
function ActorAPI.addOxygen(objid, oxygen)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:addOxygen(objid, oxygen)
  end, '增加当前氧气值', 'objid=', objid, ',oxygen=', oxygen)
end

--[[
  @param  {integer} objid 生物id
  @return {number | nil} 氧气值，nil表示获取失败
]]
function ActorAPI.getOxygen(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getOxygen(objid)
  end, '获取当前氧气值', 'objid=', objid)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} slot 装备栏id：0头饰 1胸甲 2裤子 3鞋子 4披风 5手中持有的物品
  @param  {integer} enchantId 附魔id
  @param  {integer} enchantLevel 附魔等级
  @return {boolean} 是否成功
]]
function ActorAPI.addEnchant(objid, slot, enchantId, enchantLevel)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:addEnchant(objid, slot, enchantId, enchantLevel)
  end, '增加装备附魔', 'objid=', objid, ',slot=', slot, ',enchantId=', enchantId, ',enchantLevel=', enchantLevel)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} slot 装备栏id：0头饰 1胸甲 2裤子 3鞋子 4披风 5手中持有的物品
  @param  {integer} enchantId 附魔id
  @return {boolean} 是否成功
]]
function ActorAPI.removeEnchant(objid, slot, enchantId)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:removeEnchant(objid, slot, enchantId)
  end, '移除装备附魔', 'objid=', objid, ',slot=', slot, ',enchantId=', enchantId)
end

--- 设置actor原地旋转偏移角度
---@param objid integer 行为者id
---@param yaw number 水平角度
---@return boolean 是否成功
function ActorAPI.setFaceYaw(objid, yaw)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setFaceYaw(objid, yaw)
  end, '设置actor原地旋转偏移角度', 'objid=', objid, ',yaw=', yaw)
end

--[[
  @param  {integer} objid 对象id
  @return {number | nil} 水平角度，nil表示获取失败
]]
function ActorAPI.getFaceYaw(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getFaceYaw(objid)
  end, '获取actor原地旋转偏移角度', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @param  {number} offset 转动角度
  @return {boolean} 是否成功
]]
function ActorAPI.turnFaceYaw(objid, offset)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:turnFaceYaw(objid, offset)
  end, '转动actor横向偏移角度', 'objid=', objid, ',offset=', offset)
end

--- 设置actor视角仰望角度
---@param objid integer 行为者id
---@param pitch number 与水平方向的夹角
---@return boolean 是否成功
function ActorAPI.setFacePitch(objid, pitch)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setFacePitch(objid, pitch)
  end, '设置actor视角仰望角度', 'objid=', objid, ',pitch=', pitch)
end

--[[
  @param  {integer} objid 对象id
  @return {number | nil} 与水平方向的夹角，nil表示获取失败
]]
function ActorAPI.getFacePitch(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getFacePitch(objid)
  end, '获取actor视角仰望角度', 'objid=', objid)
end

--- 转动actor仰望偏移角度
---@param objid integer 行为者id
---@param offset number 转动角度
---@return boolean 是否成功
function ActorAPI.turnFacePitch(objid, offset)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:turnFacePitch(objid, offset)
  end, '转动actor仰望偏移角度', 'objid=', objid, ',offset=', offset)
end

--[[
  @param  {integer} objid 对象id
  @param  {integer} particleId 特效id
  @return {boolean} 是否成功
]]
function ActorAPI.playBodyEffect(objid, particleId)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:playBodyEffect(objid, particleId)
  end, '播放特效', 'objid=', objid, ',particleId=', particleId)
end

--[[
  @param  {integer} objid 对象id
  @param  {integer} particleId 特效id
  @return {boolean} 是否成功
]]
function ActorAPI.stopBodyEffect(objid, particleId)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:stopBodyEffect(objid, particleId)
  end, '停止特效', 'objid=', objid, ',particleId=', particleId)
end

--- 清除生物ID为actorid的生物
---@param actorid integer 生物类型id
---@param bkill boolean 是否显示被击败效果
---@return boolean 是否成功
function ActorAPI.clearActorWithId(actorid, bkill)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:clearActorWithId(actorid, bkill)
  end, '清除生物ID为actorid的生物', 'actorid=', actorid, ',bkill=', bkill)
end

--[[
  @param  {integer} objid 对象id
  @param  {integer} attacktype 伤害类型HURTTYPE
  @return {boolean} 是否成功
]]
function ActorAPI.setAttackType(objid, attacktype)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setAttackType(objid, attacktype)
  end, '设置伤害类型', 'objid=', objid, ',attacktype=', attacktype)
end

--[[
  @param  {integer} objid 对象id
  @param  {integer} immunetype 伤害类型HURTTYPE
  @param  {boolean} isadd 是否免疫
  @return {boolean} 是否成功
]]
function ActorAPI.setImmuneType(objid, immunetype, isadd)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setImmuneType(objid, immunetype, isadd)
  end, '设置免疫伤害类型', 'objid=', objid, ',immunetype=', immunetype, ',isadd=', isadd)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} mountobjid 被骑乘生物id
  @param  {integer} posindex 骑乘位
  @return {boolean} 是否成功
]]
function ActorAPI.mountActor(objid, mountobjid, posindex)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:mountActor(objid, mountobjid, posindex)
  end, '登上、脱离载具', 'objid=', objid, ',mountobjid=', mountobjid, ',posindex=', posindex)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} actionattr 生物行为类型，如可被杀死
  @param  {integer} switch 是否开启
  @return {boolean} 是否成功
]]
function ActorAPI.setActionAttrState(objid, actionattr, switch)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setActionAttrState(objid, actionattr, switch)
  end, '设置生物行为状态', 'objid=', objid, ',actionattr=', actionattr, ',switch=', switch)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} actionattr 生物行为类型，如可被杀死
  @return {boolean | nil} 生物行为类型是否开启，nil表示获取失败
]]
function ActorAPI.getActionAttrState(objid, actionattr)
  return YcApiHelper.callResultMethod(function()
    return Actor:getActionAttrState(objid, actionattr)
  end, '获取生物行为状态', 'objid=', objid, ',actionattr=', actionattr)
end

--[[
  @param  {integer} objid 生物id
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @param  {number} z 位置的z
  @param  {boolean} cancontrol 是否可控制移动
  @param  {boolean} bshowtip 是否显示提示
  @return {boolean} 是否成功
]]
function ActorAPI.tryNavigationToPos(objid, x, y, z, cancontrol, bshowtip)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:tryNavigationToPos(objid, x, y, z, cancontrol, bshowtip)
  end, '寻路到目标位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z, ',cancontrol=', cancontrol, ',bshowtip=',
    bshowtip)
end

--[[
  @param  {integer} objid 生物id
  @return {integer | nil} 被骑乘生物的objid，nil表示获取失败
]]
function ActorAPI.getRidingActorObjId(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getRidingActorObjId(objid)
  end, '获取骑乘生物的objid', 'objid=', objid)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} particleId 特效id
  @param  {number} scale 特效大小
  @return {boolean} 是否成功
]]
function ActorAPI.playBodyEffectById(objid, particleId, scale)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:playBodyEffectById(objid, particleId, scale)
  end, '在指定Actor身上播放特效', 'objid=', objid, ',particleId=', particleId, ',scale=', scale)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} particleId 特效id
  @return {boolean} 是否成功
]]
function ActorAPI.stopBodyEffectById(objid, particleId)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:stopBodyEffectById(objid, particleId)
  end, '停止指定Actor身上的特效', 'objid=', objid, ',particleId=', particleId)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} particleId 特效id
  @param  {number} scale 特效大小
  @return {boolean} 是否成功
]]
function ActorAPI.setBodyEffectScale(objid, particleId, scale)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setBodyEffectScale(objid, particleId, scale)
  end, '设置指定Actor身上的特效大小', 'objid=', objid, ',particleId=', particleId, ',scale=', scale)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} soundId 音效id
  @param  {number} volume 音量，声音大小
  @param  {number} pitch 音调，包括低音、中音、高音的do、rui、mi
  @param  {boolean} isLoop 是否循环播放
  @return {boolean} 是否成功
]]
function ActorAPI.playSoundEffectById(objid, soundId, volume, pitch, isLoop)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:playSoundEffectById(objid, soundId, volume, pitch, isLoop)
  end, '在指定Actor身上播放音效', 'objid=', objid, ',soundId=', soundId, ',volume=', volume, ',pitch=', pitch,
    ',isLoop=', isLoop)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} soundId 音效id
  @return {boolean} 是否成功
]]
function ActorAPI.stopSoundEffectById(objid, soundId)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:stopSoundEffectById(objid, soundId)
  end, '停止指定Actor身上的音效', 'objid=', objid, ',soundId=', soundId)
end

--[[
  @param  {integer} objid 对象id
  @param  {number} x 速度的x
  @param  {number} y 速度的y
  @param  {number} z 速度的z
  @return {boolean} 是否成功
]]
function ActorAPI.appendSpeed(objid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:appendSpeed(objid, x, y, z)
  end, '给actor附加一个速度', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  @param  {integer} objid 对象id
  @return {number | nil} 朝向的x，nil表示获取朝向失败
  @return {number | nil} 朝向的y，nil表示获取朝向失败
  @return {number | nil} 朝向的z，nil表示获取朝向失败
]]
function ActorAPI.getFaceDirection(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getFaceDirection(objid)
  end, '获取actor朝向', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @return {number | nil} 眼睛的高度，nil表示获取失败
]]
function ActorAPI.getEyeHeight(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getEyeHeight(objid)
  end, '获取眼睛高度', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @return {number | nil} 位置的x，nil表示获取失败
  @return {number | nil} 位置的y，nil表示获取失败
  @return {number | nil} 位置的z，nil表示获取失败
]]
function ActorAPI.getEyePosition(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getEyePosition(objid)
  end, '获取眼睛位置', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @return {number | nil} 身体尺寸，nil表示获取失败
]]
function ActorAPI.getBodySize(objid)
  return YcApiHelper.callResultMethod(function()
    return Actor:getBodySize(objid)
  end, '获取身体尺寸', 'objid=', objid)
end

--[[
  @param  {integer} objid 对象id
  @param  {integer} actid 动作id
  @return {boolean} 是否成功
]]
function ActorAPI.playAct(objid, actid)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:playAct(objid, actid)
  end, '播放动作', 'objid=', objid, ',actid=', actid)
end

--[[
  @param  {integer} objid 生物id
  @param  {boolean} bshow 是否显示
  @return {boolean} 是否成功
]]
function ActorAPI.shownickname(objid, bshow)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:shownickname(objid, bshow)
  end, '设置昵称显示', 'objid=', objid, ',bshow=', bshow)
end

--[[
  @param  {integer} objid 生物id
  @param  {string} nickname 昵称
  @return {boolean} 是否成功
]]
function ActorAPI.setnickname(objid, nickname)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:setnickname(objid, nickname)
  end, '设置昵称', 'objid=', objid, ',nickname=', nickname)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} toobjid 被伤害的玩家迷你号或生物id
  @param  {number} hp 生命值
  @param  {integer} attackType 伤害类型HURTTYPE
  @return {boolean} 是否成功
]]
function ActorAPI.playerHurt(objid, toobjid, hp, attackType)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:playerHurt(objid, toobjid, hp, attackType)
  end, '使玩家对（玩家或生物）造成伤害', 'objid=', objid, ',toobjid=', toobjid, ',hp=', hp,
    ',attackType=', attackType)
end

--[[
  @param  {integer} objid 生物id
  @param  {integer} toobjid 被伤害的玩家迷你号或生物id
  @param  {number} hp 生命值
  @param  {integer} attackType 伤害类型HURTTYPE
  @return {boolean} 是否成功
]]
function ActorAPI.actorHurt(objid, toobjid, hp, attackType)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:actorHurt(objid, toobjid, hp, attackType)
  end, '使生物对（玩家或生物）造成伤害', 'objid=', objid, ',toobjid=', toobjid, ',hp=', hp,
    ',attackType=', attackType)
end

--[[
  @param  {integer} objid 玩家迷你号/生物id
  @param  {integer} buffid 状态id
  @param  {integer} bufflv 状态等级
  @param  {integer} customticks 帧数，每秒20次
  @return {boolean} 是否成功
]]
function ActorAPI.addBuff(objid, buffid, bufflv, customticks)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:addBuff(objid, buffid, bufflv, customticks)
  end, '增加指定BUFF', 'objid=', objid, ',buffid=', buffid, ',bufflv=', bufflv, ',customticks=', customticks)
end

--[[
  @param  {integer} objid 玩家迷你号/生物id
  @param  {integer} buffid 状态id
  @return {boolean} 是否成功
]]
function ActorAPI.removeBuff(objid, buffid)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:removeBuff(objid, buffid)
  end, '移除指定BUFF', 'objid=', objid, ',buffid=', buffid)
end

--[[
  @param  {integer} objid 玩家迷你号/生物id
  @return {boolean} 是否成功
]]
function ActorAPI.clearAllBuff(objid)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:clearAllBuff(objid)
  end, '清除全部BUFF', 'objid=', objid)
end

--[[
  @param  {integer} objid 玩家迷你号/生物id
  @return {boolean} 是否成功
]]
function ActorAPI.clearAllBadBuff(objid)
  return YcApiHelper.callIsSuccessMethod(function()
    return Actor:clearAllBadBuff(objid)
  end, '清除全部减益BUFF', 'objid=', objid)
end

--[[
  是否已经有了指定BUFF
  @param  {integer} objid 玩家迷你号/生物id
  @param  {integer} buffid 状态id
  @return {boolean} 是否有
]]
function ActorAPI.hasBuff(objid, buffid)
  return Actor:hasBuff(objid, buffid) == ErrorCode.OK
end
