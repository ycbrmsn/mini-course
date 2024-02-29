--- 玩家类 v1.0.0
--- created by 莫小仙 on 2023-12-13
---@class YcPlayer : YcActor 玩家
---@field id integer 玩家id/迷你号
---@field nickname string 玩家昵称
---@field moveable boolean 能否移动
YcPlayer = YcActor:new({
  yawDiff = -180, -- 朝向与镜头角度差值
})

--- 实例化一个玩家
---@param objid integer 玩家id/迷你号
---@return YcPlayer 玩家
function YcPlayer:new(objid)
  local o = {
    moveable = true -- 默认可以移动
  }
  if objid then
    o.objid = objid
    o.nickname = PlayerAPI.getNickname(objid)
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 设置昵称
---@param nickname string 昵称
---@return YcPlayer 玩家
function YcPlayer:setNickname(nickname)
  self.nickname = nickname
  ActorAPI.setnickname(self.objid, nickname)
  return self
end

--[[
	玩家获得经验
	@param  {number} exp 经验值
	@return {nil}
]]
function YcPlayer:gainExp(exp)
  self.attr:gainExp(exp)
end

--- 设置玩家是否能够移动
---@param enable boolean 是否能够移动
---@return YcPlayer 玩家
function YcPlayer:enableMove(enable)
  self:enableMoveImpl(enable) -- 具体实现
  local event = {
    eventobjid = self.id,
    moveable = enable,
    prevMoveable = self.moveable
  }
  YcEventHelper.triggerEvent(YcEventHelper.CUSTOM_EVENT.PLAYER_CHANGE_MOVEABLE, event) -- 触发玩家能否移动设置改变事件
  self.moveable = enable -- 修改玩家是否可以移动标志
  return self
end

--- 玩家是否能够移动的具体实现。可重写此方法
---@param enable boolean 是否能够移动
function YcPlayer:enableMoveImpl(enable)
  if enable then -- 能够移动
    PlayerAPI.setAttr(self.id, PLAYERATTR.WALK_SPEED, -1)
    PlayerAPI.setAttr(self.id, PLAYERATTR.RUN_SPEED, -1)
    PlayerAPI.setAttr(self.id, PLAYERATTR.SNEAK_SPEED, -1)
    PlayerAPI.setAttr(self.id, PLAYERATTR.SWIN_SPEED, -1)
    PlayerAPI.setAttr(self.id, PLAYERATTR.JUMP_POWER, -1)
  else -- 不能移动
    PlayerAPI.setAttr(self.id, PLAYERATTR.WALK_SPEED, 0)
    PlayerAPI.setAttr(self.id, PLAYERATTR.RUN_SPEED, 0)
    PlayerAPI.setAttr(self.id, PLAYERATTR.SNEAK_SPEED, 0)
    PlayerAPI.setAttr(self.id, PLAYERATTR.SWIN_SPEED, 0)
    PlayerAPI.setAttr(self.id, PLAYERATTR.JUMP_POWER, 0)
  end
end

---------事件---------

--- 再次进入游戏（YcPlayerManager.removeStrategy为AT_ONCE时不会触发）
function YcPlayer:onEnterGameAgain()
  -- 在玩家类中实现
end
