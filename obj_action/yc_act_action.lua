--- 动作行为类 v1.0.0
---created by 莫小仙 on 2024-03-07
---@class YcActAction : YcAction 动作行为
---@field _actor YcActor 行为者
---@field _actid integer 动作id
---@field _seconds number 做几秒会结束
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
---@field ACT table<string, integer> 动作字典
YcActAction = YcAction:new({
  NAME = 'act',
  ACT = {
    GREET = 1, -- 打招呼
    THINK = 2, -- 低头思考
    CRY = 3, -- 哭泣
    ANGRY = 4, -- 生气
    STRETCH = 5, -- 伸懒腰
    HAPPY = 6, -- 高兴
    THANK = 7, -- 感谢
    FREE = 8, -- 休闲动作
    FALL = 9, -- 倒地
    POSS = 10, -- 摆姿势
    STAND = 11, -- 站立
    RUN = 12, -- 跑
    SLEEP = 13, -- 躺下睡觉
    SIT = 14, -- 坐下
    SWIM = 15, -- 游泳
    ATTACK = 16, -- 攻击
    DIE = 17, -- 死亡
    FRIGHTEN = 18, -- 受惊
    FREE2 = 19, -- 休闲
    JUMP = 20 -- 跳
  }
})

--- 实例化一个动作行为
---@param actor YcActor 行为者
---@param actid integer 动作id
---@param seconds number 做几秒会结束。默认2秒
---@return YcActAction 动作行为
function YcActAction:new(actor, actid, seconds)
  seconds = seconds or 2
  local o = {
    _actor = actor,
    _actid = actid,
    _seconds = seconds,
    _isPaused = false
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcActAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  self._isPaused = false
  ActorAPI.playAct(self._actor.objid, self._actid)
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:_turnNext() -- 轮到下一个行动
  end, self._seconds)
end

--- 暂停行动
function YcActAction:pause()
  self._isPaused = true -- 标记是暂停
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t)
    self._t = nil
  end
end

--- 恢复行动
function YcActAction:resume()
  self:start()
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcActAction:stop(isTurnNext)
  self:pause()
  if isTurnNext then
    self:_turnNext()
  end
end
