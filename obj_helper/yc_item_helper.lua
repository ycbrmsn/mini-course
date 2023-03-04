--[[ 道具工具类 v1.0.1
  create by 莫小仙 on 2022-07-17
  last modified on 2022-07-18
]]
YcItemHelper = {
  MISSILE_STAY_SECONDS = 30, -- 投掷物信息保存时长（秒）
  item = {}, -- 特殊自定义道具 { [itemid] = item }
  itemcd = {}, -- 道具cd { [objid] = { [itemid] = time } }
  --[[
    自定义道具投掷物信息 { [projectileid] = { projectileid = projectileid, objid = objid, item = item, ... } }
  ]]
  projectile = {},
  --[[
    一般投掷物信息 { [missileid] = { teamid = teamid, speedVector3 = speedVector3, itemid = itemid, ... } }
  ]]
  missile = {},
  --[[
    持续技能信息
    { [objid] = { [skillname] = { frame = frame, ... } }
  ]]
  continueSkill = {}
}

--[[
  可能会用到的函数：
    YcItemHelper.getItem (itemid)
    YcItemHelper.useSkill (objid, itemid, index)
    YcItemHelper.getProjectile (projectileid)
    YcItemHelper.recordProjectile (projectileid, objid, item, o)
    YcItemHelper.keepProjectile (projectileid)
    YcItemHelper.getMissile (projectileid)
    YcItemHelper.getMissileObjid (projectileid)
    YcItemHelper.getMissileItemid (projectileid)
    YcItemHelper.getMissileTeamid (projectileid)
    YcItemHelper.getMissileSpeed (projectileid)
    YcItemHelper.recordMissile (projectileid, attr, val)
    YcItemHelper.recordMissileObjid (projectileid, objid)
    YcItemHelper.recordMissileItemid (projectileid, itemid)
    YcItemHelper.recordMissileTeamid (projectileid, teamid)
    YcItemHelper.recordMissileSpeed (projectileid, speed)
    YcItemHelper.recordUseSkill (objid, itemid, cd, dontSetCD)
    YcItemHelper.ableUseSkill (objid, itemid, cd)
    YcItemHelper.recordContinueSkill (objid, skillname, info)
    YcItemHelper.getContinueSkill (objid, skillname)
    YcItemHelper.delContinueSkillRecord (objid, skillname)
    YcItemHelper.cancelContinueSkill (objid, skillname, callback)
    YcItemHelper.removeCurTool (objid)
]]

--[[
  注册道具
  @param  {YcItem} item 道具对象
  @return {nil}
]]
function YcItemHelper.register (item)
  YcItemHelper.item[item.itemid] = item
end

--[[
  获取注册道具
  @param  {integer} itemid 道具id
  @return {YcItem} 道具对象
]]
function YcItemHelper.getItem (itemid)
  return YcItemHelper.item[itemid]
end

--[[
  切换手持物。当然手持物也可能没有变化，即切换为相同道具
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid1 切换前道具id
  @param  {integer} itemid2 切换后道具id
  @return {boolean} 切换前后是否有自定义道具
  @return {YcItem | nil} 切换前自定义道具，nil表示切换前不是自定义道具
  @return {YcItem | nil} 切换后自定义道具，nil表示切换后不是自定义道具
]]
function YcItemHelper.changeHold (objid, itemid1, itemid2)
  local item1 = YcItemHelper.getItem(itemid1)
  local item2 = YcItemHelper.getItem(itemid2)
  local foundItem = false -- 是否有自定义道具
  if item1 then -- 之前手持物是自定义特殊道具
    item1:putDown(objid)
    foundItem = true
  end
  if item2 then -- 当前手持物是自定义特殊道具
    item2:pickUp(objid)
    foundItem = true
  end
  return foundItem, item1, item2
end

--[[
  新增道具
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {integer} itemnum 道具数量
  @return {nil}
]]
function YcItemHelper.addItem (objid, itemid, itemnum)
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:addItem(objid, itemnum)
  end
end

--[[
  使用道具
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {integer} itemnum 道具数量
  @return {nil}
]]
function YcItemHelper.useItem (objid, itemid, itemnum)
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:useItem(objid, itemnum)
  end
end

--[[
  消耗道具
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {integer} itemnum 道具数量
  @return {nil}
]]
function YcItemHelper.consumeItem (objid, itemid, itemnum)
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:consumeItem(objid, itemnum)
  end
end

--[[
  丢弃道具
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {integer} itemnum 道具数量
  @return {nil}
]]
function YcItemHelper.discardItem (objid, itemid, itemnum)
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:discardItem(objid, itemnum)
  end
end

--[[
  选择道具
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {integer} itemnum 道具数量
  @return {nil}
]]
function YcItemHelper.selectItem (objid, itemid, itemnum)
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:selectItem(objid)
  end
end

--[[
  使用道具技能
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id。不传则获取玩家手持道具id
  @param  {integer} index 技能序号，从1开始
  @return {nil}
]]
function YcItemHelper.useSkill (objid, itemid, index)
  itemid = itemid or PlayerAPI.getCurToolID(objid) -- 默认为手持道具类型id
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:useSkill(objid, index)
  end
end

--[[
  手持道具点击方块
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具类型id。不传则获取玩家手持道具id
  @param  {integer} blockid 方块id
  @param  {number} x 方块位置x
  @param  {number} y 方块位置y
  @param  {number} z 方块位置z
  @return {nil}
]]
function YcItemHelper.clickBlock (objid, itemid, blockid, x, y, z)
  itemid = itemid or PlayerAPI.getCurToolID(objid) -- 默认为手持道具类型id
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:clickBlock(objid, blockid, x, y, z)
  end
end

--[[
  手持道具攻击命中
  @param  {integer} objid 迷你号/生物id
  @param  {integer} toobjid 命中玩家迷你号/生物id
  @param  {integer} itemid 道具类型id。不传则获取玩家手持道具id
  @return {nil}
]]
function YcItemHelper.attackHit (objid, toobjid, itemid)
  itemid = itemid or PlayerAPI.getCurToolID(objid) -- 默认为手持道具类型id
  local item = YcItemHelper.getItem(itemid)
  if item then -- 表示是自定义特殊道具
    item:attackHit(objid, toobjid)
  end
end

--[[
  投掷物击中
  @param  {integer} projectileid 投掷物id
  @param  {integer} toobjid 被击中的玩家的迷你号/生物id
  @param  {integer} blockid 被击中的方块类型id
  @param  {number} x 事件发生的位置x
  @param  {number} y 事件发生的位置y
  @param  {number} z 事件发生的位置z
  @return {nil}
]]
function YcItemHelper.projectileHit (projectileid, toobjid, blockid, x, y, z)
  local projectileInfo = YcItemHelper.getProjectile(projectileid)
  if projectileInfo then -- 找到投掷物信息
    local objid = projectileInfo.objid
    local item = projectileInfo.item
    item:projectileHit(projectileid, objid, toobjid, blockid, x, y, z)
  end
end

--[[
  投掷物被创建
  @param  {integer} objid 投掷物所属者的迷你号/生物id
  @param  {integer} projectileid 投掷物id
  @param  {integer} itemid 投掷物的道具类型id
  @param  {number} x 事件发生的位置x
  @param  {number} y 事件发生的位置y
  @param  {number} z 事件发生的位置z
  @return {nil}
]]
function YcItemHelper.missileCreate (objid, projectileid, itemid, x, y, z)
  YcItemHelper.recordMissileObjid(projectileid, objid) -- 记录归属者id
  YcItemHelper.recordMissileItemid(projectileid, itemid) -- 记录道具类型id
end

--[[
  获取自定义道具投掷物信息
  @param  {integer} projectileid 投掷物id
  @return {table} 道具投掷物信息，nil表示道具投掷物信息不存在
]]
function YcItemHelper.getProjectile (projectileid)
  return YcItemHelper.projectile[projectileid]
end

--[[
  记录自定义道具投掷物信息，包括投掷物id、人物id、道具（、伤害）等
  @param  {integer} projectileid 投掷物id
  @param  {integer} objid 归属者id。表示是谁的投掷物
  @param  {YcItem} item 道具对象
  @param  {table} o 其他需要记录的信息
  @return {nil}
]]
function YcItemHelper.recordProjectile (projectileid, objid, item, o)
  o = o or {}
  o.projectileid = projectileid
  o.objid = objid
  o.item = item
  YcItemHelper.projectile[projectileid] = o
  YcItemHelper.keepProjectile(projectileid) -- 用于保存投掷物信息一段时间
end

--[[
  延长自定义道具投掷物信息保存时间
  @param  {integer} projectileid 投掷物id
  @return {nil}
]]
function YcItemHelper.keepProjectile (projectileid)
  if YcItemHelper.getProjectile(projectileid) then -- 该投掷物信息存在
    local t = projectileid .. 'recordProjectile'
    YcTimeHelper.delAfterTimeTask(t) -- 删除 删除倒计时
    -- 新建删除倒计时，用于一定时间后清除数据
    YcTimeHelper.newAfterTimeTask(function ()
      YcItemHelper.projectile[projectileid] = nil
    end, YcItemHelper.MISSILE_STAY_SECONDS, t)
  end
end

--[[
  获取投掷物信息
  @param  {integer} projectileid 投掷物id
  @return {table | nil} 投掷物信息，nil表示没找到投掷物信息
]]
function YcItemHelper.getMissile (projectileid)
  return YcItemHelper.missile[projectileid]
end

--[[
  获取投掷物所属者id
  @param  {integer} projectileid 投掷物id
  @return {integer | nil} 所属者id，-1表示没有所属者，nil表示没有所属者信息
]]
function YcItemHelper.getMissileObjid (projectileid)
  return (YcItemHelper.getMissile(projectileid) or {}).objid
end

--[[
  获取投掷物道具类型
  @param  {integer} projectileid 投掷物id
  @return {integer | nil} 道具id，nil表示没有道具信息
]]
function YcItemHelper.getMissileItemid (projectileid)
  return (YcItemHelper.getMissile(projectileid) or {}).itemid
end

--[[
  获取投掷物队伍id
  @param  {integer} projectileid 投掷物id
  @return {integer | nil} 队伍id，nil表示没有队伍信息
]]
function YcItemHelper.getMissileTeamid (projectileid)
  return (YcItemHelper.getMissile(projectileid) or {}).teamid
end

--[[
  获取投掷物速度
  @param  {integer} projectileid 投掷物id
  @return {YcVector3 | nil} 速度向量，nil表示没有速度信息
]]
function YcItemHelper.getMissileSpeed (projectileid)
  return (YcItemHelper.getMissile(projectileid) or {}).speed
end

--[[
  记录投掷物属性
  @param  {integer} projectileid 投掷物id
  @param  {string} attr 属性名
  @param  {number} val 属性值
  @return {nil}
]]
function YcItemHelper.recordMissile (projectileid, attr, val)
  local t = projectileid .. 'recordMissile'
  if YcItemHelper.missile[projectileid] then -- 已存在
    YcItemHelper.missile[projectileid][attr] = val
    YcTimeHelper.delAfterTimeTask(t) -- 清除删除投掷物信息的任务
  else -- 不存在
    YcItemHelper.missile[projectileid] = { [attr] = val }
  end
  -- 保留的记录30秒后删除
  YcTimeHelper.newAfterTimeTask(function ()
    YcItemHelper.missile[projectileid] = nil
  end, YcItemHelper.MISSILE_STAY_SECONDS, t)
end

--[[
  记录投掷物归属者id
  @param  {integer} projectileid 投掷物id
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItemHelper.recordMissileObjid (projectileid, objid)
  YcItemHelper.recordMissile(projectileid, 'objid', objid)
end

--[[
  记录投掷物道具类型
  @param  {integer} projectileid 投掷物id
  @param  {integer} itemid 道具类型id
  @return {nil}
]]
function YcItemHelper.recordMissileItemid (projectileid, itemid)
  YcItemHelper.recordMissile(projectileid, 'itemid', itemid)
end

--[[
  记录投掷物队伍id
  @param  {integer} projectileid 投掷物id
  @param  {integer} teamid 队伍id
  @return {nil}
]]
function YcItemHelper.recordMissileTeamid (projectileid, teamid)
  YcItemHelper.recordMissile(projectileid, 'teamid', teamid)
end

--[[
  记录投掷物速度
  @param  {integer} projectileid 投掷物id
  @param  {YcVector3} speed 速度向量
  @return {nil}
]]
function YcItemHelper.recordMissileSpeed (projectileid, speed)
  YcItemHelper.recordMissile(projectileid, 'speed', speed)
end

--[[
  记录使用技能
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {number} cd 冷却时长（秒）
  @param  {boolean} dontSetCD 不设置CD
  @return {nil}
]]
function YcItemHelper.recordUseSkill (objid, itemid, cd, dontSetCD)
  if objid and itemid and cd then -- 确保玩家/生物、道具类型、冷却时间必须存在
    if not YcItemHelper.itemcd[objid] then -- 如果玩家对应的道具冷却信息不存在，则创建一个
      YcItemHelper.itemcd[objid] = {}
    end
    YcItemHelper.itemcd[objid][itemid] = YcTimeHelper.getFrame() -- 将道具技能使用时间记录下来，记录为当前帧数
    if not dontSetCD then -- 表示需要进入冷却
      PlayerAPI.setSkillCD(objid, itemid, cd) -- 使道具开始冷却
    end
  else -- 参数不足
    if not objid then
      YcLogHelper.debug('objid不存在')
    elseif not itemid then
      YcLogHelper.debug('itemid不存在')
    else
      YcLogHelper.debug('cd不存在')
    end
  end
end

--[[
  判断是否能够使用技能
  @param  {integer} objid 迷你号/生物id
  @param  {integer} itemid 道具id
  @param  {number} cd 冷却时长（秒）
  @return {boolean} 是否能够
  @return {number} 剩余时间（秒）
]]
function YcItemHelper.ableUseSkill (objid, itemid, cd)
  if not cd or cd <= 0 then -- cd值有误
    return true, 0
  end
  if objid and itemid then -- 参数齐全
    local info = YcItemHelper.itemcd[objid]
    if not info then -- 玩家未使用过技能
      return true, 0
    else -- 有使用技能cd信息
      local frame = info[itemid] -- 使用时间
      if not frame then -- 该技能未使用过
        return true, 0
      else -- 技能使用过
        local cdFrames = math.ceil(cd * 20) -- 冷却时间换算为帧数
        local remainingTime = frame + cdFrames - YcTimeHelper.getFrame()
        if remainingTime <= 0 then -- 表示没有剩余时间
          return true, 0
        else -- 还有剩余时间
          return false, remainingTime
        end
      end
    end
  else -- 参数不足
    if objid then
      YcLogHelper.debug('itemid不存在')
    else
      YcLogHelper.debug('objid不存在')
    end
    return true, 0
  end
end

--[[
  记录持续技能
  @param  {integer} objid 迷你号/生物id
  @param  {string} skillname 技能名称
  @param  {table | nil} info 其他信息
  @return {nil}
]]
function YcItemHelper.recordContinueSkill (objid, skillname, info)
  if objid and skillname then -- 玩家迷你号/生物id、技能名称必须同时存在
    if not YcItemHelper.continueSkill[objid] then -- 表示玩家/生物未使用过任意技能
      YcItemHelper.continueSkill[objid] = {}
    end
    info = info or {} -- info默认为空信息
    info.frame = YcTimeHelper.getFrame()
    YcItemHelper.continueSkill[objid][skillname] = info
  else
    YcLogHelper.debug('记录持续技能失败：', objid, ',', skillname)
  end
end

--[[
  获取持续技能
  @param  {integer} objid 迷你号/生物id
  @param  {string} skillname 技能名称
  @return {table | nil} 技能发动时间，nil表示没有找到
]]
function YcItemHelper.getContinueSkill (objid, skillname)
  if YcItemHelper.continueSkill[objid] then -- 表示玩家使用过某持续技能
    return YcItemHelper.continueSkill[objid][skillname] -- 返回该技能的信息
  else -- 表示未使用过任意持续技能
    return nil
  end
end

--[[
  删除持续技能记录
  @param  {integer} objid 迷你号/生物id
  @param  {string} skillname 技能名称
  @return {table | nil} table为删除的持续技能信息，nil表示该技能不存在
]]
function YcItemHelper.delContinueSkillRecord (objid, skillname)
  local info = YcItemHelper.getContinueSkill(objid, skillname)
  if info then -- 找到持续技能信息
    YcItemHelper.continueSkill[objid][skillname] = nil
    return info
  end
  return nil
end

--[[
  取消持续技能
  @param  {integer} objid 迷你号/生物id
  @param  {string} skillname 技能名称
  @param  {function} callback 取消成功后的回调
  @return {nil}
]]
function YcItemHelper.cancelContinueSkill (objid, skillname, callback)
  local info = YcItemHelper.delContinueSkillRecord(objid, skillname)
  if info then -- 删除成功
    if type(callback) == 'function' then -- 有成功回调函数
      callback(info)
    end
  end
end

--[[
  移除玩家当前手持物
  @param  {integer} objid 迷你号
  @return {nil}
]]
function YcItemHelper.removeCurTool (objid)
  local gridid = YcBackpackHelper.getCurShotcutGrid(objid) -- 获取玩家当前手持道具的道具格id
  BackpackAPI.removeGridItem(objid, gridid) -- 通过道具格移除道具
end

-- 事件相关

-- 新增道具事件
YcEventHelper.registerEvent('Player.AddItem', function (event)
  local objid = event.eventobjid
  local itemid = event.itemid
  local itemnum = event.itemnum
  YcItemHelper.addItem(objid, itemid, itemnum)
end)

-- 使用道具事件
YcEventHelper.registerEvent('Player.UseItem', function (event)
  local objid = event.eventobjid
  local itemid = event.itemid
  local itemnum = event.itemnum
  YcItemHelper.useItem(objid, itemid, itemnum)
end)

-- 消耗道具事件
YcEventHelper.registerEvent('Player.ConsumeItem', function (event)
  local objid = event.eventobjid
  local itemid = event.itemid
  local itemnum = event.itemnum
  YcItemHelper.consumeItem(objid, itemid, itemnum)
end)

-- 丢弃道具事件
YcEventHelper.registerEvent('Player.DiscardItem', function (event)
  local objid = event.eventobjid
  local itemid = event.itemid
  local itemnum = event.itemnum
  YcItemHelper.discardItem(objid, itemid, itemnum)
end)

-- 玩家选择快捷键事件
YcEventHelper.registerEvent('Player.SelectShortcut', function (event)
  local objid = event.eventobjid
  local itemid = event.itemid
  local itemnum = event.itemnum
  YcItemHelper.selectItem(objid, itemid, itemnum)
end)

-- 玩家点击方块事件
YcEventHelper.registerEvent('Player.ClickBlock', function (event)
  local objid = event.eventobjid
  local blockid = event.blockid
  local x, y, z = event.x, event.y, event.z
  YcItemHelper.clickBlock(objid, nil, blockid, x, y, z)
end)

-- 玩家攻击命中事件
YcEventHelper.registerEvent('Player.AttackHit', function (event)
  local objid = event.eventobjid
  local toobjid = event.toobjid
  YcItemHelper.attackHit(objid, toobjid)
end)

-- 投掷物击中事件
YcEventHelper.registerEvent('Actor.Projectile.Hit', function (event)
  local objid = event.eventobjid
  local toobjid = event.toobjid
  local blockid = event.blockid
  local x, y, z = event.x, event.y, event.z
  YcItemHelper.projectileHit(objid, toobjid, blockid, x, y, z)
end)

-- 投掷物被创建事件
YcEventHelper.registerEvent('Missile.Create', function (event)
  local objid = event.eventobjid
  local toobjid = event.toobjid
  local itemid = event.itemid
  local x, y, z = event.x, event.y, event.z
  YcItemHelper.missileCreate(objid, toobjid, itemid, x, y, z)
end)
