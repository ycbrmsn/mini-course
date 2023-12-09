--- 玩家工具类 v1.0.0
--- created by 莫小仙 on 2023-11-26
YcPlayerHelper = {}

--- 设置玩家指定道具是否可丢弃
---@param playerid integer 玩家id/迷你号
---@param itemid integer 道具类型id
---@param enable boolean | nil 是否可丢弃。nil表示不可丢弃
---@return boolean 是否设置成功
function YcPlayerHelper.setItemEnableThrow(playerid, itemid, enable)
  return PlayerAPI.setItemAttAction(playerid, itemid, PLAYERATTR.ITEM_DISABLE_THROW, not enable)
end

--- 设置玩家是否可以移动
---@param playerid integer 玩家id/迷你号
---@param enable boolean | nil 是否可移动。nil表示不可移动
---@return boolean 是否设置成功
function YcPlayerHelper.setPlayerEnableMove(playerid, enable)
  return PlayerAPI.setActionAttrState(playerid, PLAYERATTR.ENABLE_MOVE, enable)
end

--- 查询玩家是否可被杀死
---@param playerid integer 玩家id/迷你号
---@return boolean 是否可被杀死
function YcPlayerHelper.getPlayerEnableBeKilled(playerid)
  return PlayerAPI.checkActionAttrState(playerid, PLAYERATTR.ENABLE_BEKILLED)
end

--- 设置玩家是否可被杀死
---@param playerid integer 玩家id/迷你号
---@param enable boolean | nil 是否可被杀死。nil表示不可以
---@return boolean 是否设置成功
function YcPlayerHelper.setPlayerEnableBeKilled(playerid, enable)
  return PlayerAPI.setActionAttrState(playerid, PLAYERATTR.ENABLE_BEKILLED, enable)
end

--- 设置玩家是否可被攻击
---@param playerid integer 玩家id/迷你号
---@param enable boolean | nil 是否可被攻击。nil表示不可以
---@return boolean 是否设置成功
function YcPlayerHelper.setPlayerEnableBeAttacked(playerid, enable)
  return PlayerAPI.setActionAttrState(playerid, PLAYERATTR.ENABLE_BEATTACKED, enable)
end

--- 设置玩家是否可破坏方块
---@param playerid integer 玩家id/迷你号
---@param enable boolean | nil 是否可破坏方块。nil表示不可以
---@return boolean 是否设置成功
function YcPlayerHelper.setPlayerEnableDestroyBlock(playerid, enable)
  return PlayerAPI.setActionAttrState(playerid, PLAYERATTR.ENABLE_DESTROYBLOCK, enable)
end

--- 获取玩家生命值
---@param playerid integer 玩家id/迷你号
---@return number | nil 生命值。nil表示玩家不存在
function YcPlayerHelper.getHp(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.CUR_HP)
end

--- 设置玩家生命值
---@param playerid integer 玩家id/迷你号
---@param hp number 生命值
---@return boolean 是否设置成功
function YcPlayerHelper.setHp(playerid, hp)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.CUR_HP, hp)
end

--- 获取玩家最大生命值
---@param playerid integer 玩家id/迷你号
---@return number | nil 最大生命值。nil表示玩家不存在
function YcPlayerHelper.getMaxHp(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.MAX_HP)
end

--- 设置玩家最大生命值
---@param playerid integer 玩家id/迷你号
---@param maxHp number 最大生命值
---@return boolean 是否设置成功
function YcPlayerHelper.setMaxHp(playerid, maxHp)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.MAX_HP, maxHp)
end

--- 获取玩家等级
---@param playerid integer 玩家id/迷你号
---@return integer | nil 等级。nil表示玩家不存在
function YcPlayerHelper.getLevel(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.LEVEL)
end

--- 获取玩家经验值
---@param playerid integer 玩家id/迷你号
---@return number | nil 经验值。nil表示玩家不存在
function YcPlayerHelper.getExp(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.CUR_LEVELEXP)
end

--- 设置玩家经验值
---@param playerid integer 玩家id/迷你号
---@param exp number 经验值
---@return boolean 是否设置成功
function YcPlayerHelper.setExp(playerid, exp)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.CUR_LEVELEXP, exp)
end

--- 获取玩家等级
---@param playerid integer 玩家id/迷你号
---@return number | nil 玩家等级。nil表示玩家不存在
function YcPlayerHelper.getLevel(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.CUR_LEVEL)
end

--- 设置玩家等级
---@param playerid integer 玩家id/迷你号
---@param level integer 等级
---@return boolean 是否设置成功
function YcPlayerHelper.setLevel(playerid, level)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.CUR_LEVEL, level)
end

--- 获取玩家氧气
---@param playerid integer 玩家id/迷你号
---@return number | nil 氧气。nil表示玩家不存在
function YcPlayerHelper.getOxygen(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.CUR_OXYGEN)
end

--- 设置玩家移动速度
---@param playerid integer 玩家id/迷你号
---@param speed number 移动速度
---@return boolean 是否设置成功
function YcPlayerHelper.setWalkSpeed(playerid, speed)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.WALK_SPEED, speed)
end

--- 设置玩家奔跑速度
---@param playerid integer 玩家id/迷你号
---@param speed number 奔跑速度
---@return boolean 是否设置成功
function YcPlayerHelper.setRunSpeed(playerid, speed)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.RUN_SPEED, speed)
end

--- 设置玩家游泳速度
---@param playerid integer 玩家id/迷你号
---@param speed number 游泳速度
---@return boolean 是否设置成功
function YcPlayerHelper.setSwimSpeed(playerid, speed)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.SWIN_SPEED, speed)
end

--- 设置玩家跳跃力
---@param playerid integer 玩家id/迷你号
---@param jumpPower number 跳跃力
---@return boolean 是否设置成功
function YcPlayerHelper.setJumpPower(playerid, jumpPower)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.JUMP_POWER, jumpPower)
end

--- 获取玩家模型大小
---@param playerid integer 玩家id/迷你号
---@return number | nil 模型大小。nil表示玩家不存在
function YcPlayerHelper.getDimension(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.DIMENSION)
end

--- 设置玩家模型大小
---@param playerid integer 玩家id/迷你号
---@param dimension number 模型大小
---@return boolean 是否设置成功
function YcPlayerHelper.setDimension(playerid, dimension)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.DIMENSION, dimension)
end

--- 设置玩家饥饿度
---@param playerid integer 玩家id/迷你号
---@param hunger number 饥饿度
---@return boolean 是否设置成功
function YcPlayerHelper.setHunger(playerid, hunger)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.CUR_HUNGER, hunger)
end

--- 获取玩家最大饥饿度
--- 2020-11-24 测试无效
---@param playerid integer 玩家id/迷你号
---@return number | nil 最大饥饿度。nil表示玩家不存在
function YcPlayerHelper.getMaxHunger(playerid)
  return PlayerAPI.getAttr(playerid, PLAYERATTR.MAX_HUNGER)
end

--- 设置最大饥饿度
--- 2020-11-18 测试依然无效
---@param playerid integer 玩家id/迷你号
---@param maxHunger number 最大饥饿度
---@return boolean 是否设置成功
function YcPlayerHelper.setMaxHunger(playerid, maxHunger)
  return PlayerAPI.setAttr(playerid, PLAYERATTR.MAX_HUNGER, maxHunger)
end

--- 玩家是否满血
---@param playerid integer 玩家id/迷你号
---@return boolean | nil 是否满血。nil表示玩家不存在
function YcPlayerHelper.isHpFull(playerid)
  local hp = YcPlayerHelper.getHp(playerid)
  local maxHp = YcPlayerHelper.getMaxHp(playerid)
  return hp and maxHp and hp == maxHp
end

--- 增加玩家某属性值
---@param playerid integer 玩家id/迷你号
---@param attrtype integer 属性
---@param val number 属性值变化大小
---@return boolean 是否设置成功
function YcPlayerHelper.addAttr(playerid, attrtype, val)
  local curVal = YcPlayerHelper.getAttr(playerid, attrtype) -- 当前属性值
  return PlayerAPI.setAttr(playerid, attrtype, curVal + val)
end

--- 增加玩家经验值
---@param playerid integer 玩家id/迷你号
---@param exp number 经验值
---@return boolean 是否设置成功
function YcPlayerHelper.addExp(playerid, exp)
  return PlayerAPI.addAttr(playerid, PLAYERATTR.CUR_LEVELEXP, exp)
end

--- 恢复玩家某属性值
---@param playerid integer 玩家id/迷你号
---@param attrtype integer 属性。包括：
--- 生命值(CREATUREATTR.MAX_HP)
--- 饥饿值(CREATUREATTR.MAX_HUNGER)
--- 氧气值(CREATUREATTR.MAX_OXYGEN)
---@return boolean 是否设置成功
function YcPlayerHelper.recoverAttr(playerid, attrtype)
  return PlayerAPI.setAttr(playerid, attrtype + 1, YcPlayerHelper.getAttr(playerid, attrtype))
end
