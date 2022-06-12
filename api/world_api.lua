--[[ 封装世界API v1.0.0
  create by 莫小仙 on 2022-06-12
]]
WorldAPI = {}

--[[
  @return {boolean} 是否是白天
]]
function WorldAPI.isDaytime ()
  return World:isDaytime() == ErrorCode.OK
end

--[[
  @return {integer | nil} 游戏中当前几点，nil表示获取时间失败
]]
function WorldAPI.getHours ()
  return YcApiHelper.callResultMethod(function ()
    return World:getHours()
  end, '获取游戏中当前几点')
end

--[[
  @param  {integer} hour 小时数
  @return {boolean} 是否成功
]]
function WorldAPI.setHours (hour)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:setHours(hour)
  end, '设置游戏中当前几点', 'hour=', hour)
end

--[[
  @param  {integer} objtype 对象类型：
    0全部
    1玩家OBJ_TYPE.OBJTYPE_PLAYER
    2生物OBJ_TYPE.OBJTYPE_CREATURE
    3掉落物OBJ_TYPE.OBJTYPE_DROPITEM
    4投掷物OBJ_TYPE.OBJTYPE_MISSILE
  @param  {number} x1 区域起点x
  @param  {number} y1 区域起点y
  @param  {number} z1 区域起点z
  @param  {number} x2 区域终点x
  @param  {number} y2 区域终点y
  @param  {number} z2 区域终点z
  @return {integer | nil} 区域内该种对象数量，nil表示获取信息失败
  @return {table | nil} 区域内该种对象的对象id数组，nil表示获取信息失败
]]
function WorldAPI.getActorsByBox (objtype, x1, y1, z1, x2, y2, z2)
  return YcApiHelper.callResultMethod(function ()
    return World:getActorsByBox(objtype, x1, y1, z1, x2, y2, z2)
  end, '获取范围内对象', 'objtype=', objtype, ',x1=', x1, ',y1=', y1, ',z1=',
    z1, ',x2=', x2, ',y2=', y2, ',z2=', z2)
end

--[[
  @param  {integer} objid 对象id
  @return {boolean} 是否成功
]]
function WorldAPI.despawnActor (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:despawnActor(objid)
  end, '移除对象', 'objid=', objid)
end

--[[
  @param  {number} x 生成生物的位置x
  @param  {number} y 生成生物的位置y
  @param  {number} z 生成生物的位置z
  @param  {integer} actorid 生物类型id
  @param  {integer} actorCnt 生物数量
  @return {table | nil} 被创建生物的对象id数组，nil表示生成失败
]]
function WorldAPI.spawnCreature (x, y, z, actorid, actorCnt)
  return YcApiHelper.callResultMethod(function ()
    return World:spawnCreature(x, y, z, actorid, actorCnt)
  end, '生成生物', 'x=', x, ',y=', y, ',z=', z, ',actorid=', actorid,
    ',actorCnt=', actorCnt)
end

--[[
  @param  {integer} objid 对象id
  @return {boolean} 是否成功
]]
function WorldAPI.despawnCreature (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:despawnCreature(objid)
  end, '移除生物', 'objid=', objid)
end

--[[
  @param  {number} x 生成掉落物的位置x
  @param  {number} y 生成掉落物的位置y
  @param  {number} z 生成掉落物的位置z
  @param  {integer} itemId 道具id
  @param  {integer} itemCnt 道具数量
  @return {integer | nil} 掉落物id，nil表示生成失败
]]
function WorldAPI.spawnItem (x, y, z, itemId, itemCnt)
  return YcApiHelper.callResultMethod(function ()
    return World:spawnItem(x, y, z, itemId, itemCnt)
  end, '在指定位置生成掉落物', 'x=', x, ',y=', y, ',z=', z, ',itemId=', itemId,
    ',itemCnt=', itemCnt)
end

--[[
  @param  {number} x1 区域起点x
  @param  {number} y1 区域起点y
  @param  {number} z1 区域起点z
  @param  {number} x2 区域终点x
  @param  {number} y2 区域终点y
  @param  {number} z2 区域终点z
  @return {boolean} 是否成功
]]
function WorldAPI.despawnItemByBox (x1, y1, z1, x2, y2, z2)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:despawnItemByBox(x1, y1, z1, x2, y2, z2)
  end, '通过区域移除掉落物', 'x1=', x1, ',y1=', y1, ',z1=', z1, ',x2=', x2, ',y2=', y2, ',z2=', z2)
end

--[[
  @param  {number} objid 掉落物id
  @return {boolean} 是否成功
]]
function WorldAPI.despawnItemByObjid (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:despawnItemByObjid(objid)
  end, '通过id移除掉落物', 'objid=', objid)
end

--[[
  @param  {integer} shooter 投掷物的主人
  @param  {integer} itemid 投掷物(道具)id
  @param  {number} x 生成投掷物的位置x
  @param  {number} y 生成投掷物的位置y
  @param  {number} z 生成投掷物的位置z
  @param  {number} dstx 投掷物的目标位置x
  @param  {number} dsty 投掷物的目标位置y
  @param  {number} dstz 投掷物的目标位置z
  @param  {number} speed 投掷物的速度
  @return {integer | nil} 投掷物的对象id，nil表示生成失败
]]
function WorldAPI.spawnProjectile (shooter, itemid, x, y, z, dstx, dsty, dstz, speed)
  return YcApiHelper.callResultMethod(function ()
    return World:spawnProjectile(shooter, itemid, x, y, z, dstx, dsty, dstz, speed)
  end, '生成投掷物', 'shooter=', shooter, ',itemid=', itemid, ',x=', x, ',y=',
    y, ',z=', z, ',dstx=', dstx, ',dsty=', dsty, ',dstz=', dstz, ',speed=', speed)
end

--[[
  @param  {integer} shooter 投掷物的主人
  @param  {integer} itemid 投掷物(道具)id
  @param  {number} x 生成投掷物的位置x
  @param  {number} y 生成投掷物的位置y
  @param  {number} z 生成投掷物的位置z
  @param  {number} dirx 投掷物的运动方向x，如投掷物朝正东方向水平运动，则dirx大于0，diry、dirz等于0
  @param  {number} diry 投掷物的运动方向y
  @param  {number} dirz 投掷物的运动方向z
  @param  {number} speed 投掷物的速度
  @return {integer | nil} 投掷物的对象id，nil表示生成失败
]]
function WorldAPI.spawnProjectileByDir (shooter, itemid, x, y, z, dirx, diry, dirz, speed)
  return YcApiHelper.callResultMethod(function ()
    return World:spawnProjectileByDir(shooter, itemid, x, y, z, dirx, diry, dirz, speed)
  end, '生成投掷物', 'shooter=', shooter, ',itemid=', itemid, ',x=', x, ',y=',
    y, ',z=', z, ',dirx=', dirx, ',diry=', diry, ',dirz=', dirz, ',speed=', speed)
end

--[[
  @param  {table} pos1 位置1，{ x, y, z }
  @param  {table} pos2 位置2，{ x, y, z }
  @return {number} 位置之间的距离
]]
function WorldAPI.calcDistance (pos1, pos2)
  return World:calcDistance(pos1, pos2)
end

--[[
  @param  {number} x 特效的位置x
  @param  {number} y 特效的位置y
  @param  {number} z 特效的位置z
  @param  {integer} particleId 特效id
  @param  {number} scale 特效大小
  @return {boolean} 是否成功
]]
function WorldAPI.playParticalEffect (x, y, z, particleId, scale)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:playParticalEffect(x, y, z, particleId, scale)
  end, '在指定位置播放特效', 'x=', x, ',y=', y, ',z=', z, ',particleId=',
    particleId, ',scale=', scale)
end

--[[
  @param  {number} x 特效的位置x
  @param  {number} y 特效的位置y
  @param  {number} z 特效的位置z
  @param  {integer} particleId 特效id
  @return {boolean} 是否成功
]]
function WorldAPI.stopEffectOnPosition (x, y, z, particleId)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:stopEffectOnPosition(x, y, z, particleId)
  end, '停止指定位置的特效', 'x=', x, ',y=', y, ',z=', z, ',particleId=', particleId)
end

--[[
  @param  {number} x 特效的位置x
  @param  {number} y 特效的位置y
  @param  {number} z 特效的位置z
  @param  {integer} particleId 特效id
  @param  {number} scale 特效大小
  @return {boolean} 是否成功
]]
function WorldAPI.setEffectScaleOnPosition (x, y, z, particleId, scale)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:setEffectScaleOnPosition(x, y, z, particleId, scale)
  end, '设置指定位置的特效大小', 'x=', x, ',y=', y, ',z=', z, ',particleId=',
    particleId, ',scale=', scale)
end

--[[
  @param  {table} pos 播放位置，{ x, y, z }
  @param  {integer} soundId 音效id
  @param  {number} volume 音量，声音大小
  @param  {number} pitch 音调，包括低音、中音、高音的do、rui、mi
  @param  {boolean} isLoop 是否循环播放
  @return {boolean} 是否成功
]]
function WorldAPI.playSoundEffectOnPos (pos, soundId, volume, pitch, isLoop)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:playSoundEffectOnPos(pos, soundId, volume, pitch, isLoop)
  end, '在指定位置上播放音效', 'pos=', pos, ',soundId=', soundId, ',volume=',
    volume, ',pitch=', pitch, ',isLoop=', isLoop)
end

--[[
  @param  {table} pos 播放位置，{ x, y, z }
  @param  {integer} soundId 音效id
  @return {boolean} 是否成功
]]
function WorldAPI.stopSoundEffectOnPos (pos, soundId)
  return YcApiHelper.callIsSuccessMethod(function ()
    return World:stopSoundEffectOnPos(pos, soundId)
  end, '停止指定位置上播放的音效', 'pos=', pos, ', soundId=', soundId)
end