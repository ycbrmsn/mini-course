--- 跟随行为类 v1.0.0
---created by 莫小仙 on 2024-03-11
---@class YcFollowAction 跟随行为
---@field _actor YcActor 行为者
---@field _toobjid integer 目标玩家id/生物id
---@field _maxDistance number 最大活动范围。超过该范围将进入跟随状态。默认为6米
---@field _minDistance number 最小停止跟随范围。进入该范围后，停止跟随。默认为4米
---@field _noFollowAction YcAction | nil 非跟随状态下的行为。默认什么都不做
---@field _noTargetAction YcAction | nil 没有发现跟随目标时的行为。默认什么都不做
---@field _isFollowing boolean 是否正在跟随
---@field _isFoundTarget boolean 是否找到目标
---@field _isFoundSelf boolean 是否找到了自己
---@field _t string | number 类型
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
YcFollowAction = YcAction:new({
  NAME = 'follow'
})

---@class YcFollowActionOption 跟随行为的其他配置信息
---@field maxDistance number | nil 最大活动范围。超过该范围将进入跟随状态。默认为6米
---@field minDistance number | nil 最小停止跟随范围。进入该范围后，停止跟随。默认为4米
---@field noFollowAction YcAction | nil 非跟随状态下的行为。默认什么都不做
---@field noTargetAction YcAction | nil 没有发现跟随目标时的行为。默认什么都不做
YcFollowActionOption = {}

--- 实例化一个跟随行为
---@param actor YcActor 行为者
---@param toobjid integer 目标玩家id/生物id
---@param option YcFollowActionOption 跟随行为的其他配置信息
---@return YcLookAction 持续看行为
function YcFollowAction:new(actor, toobjid, option)
  option = option or {}
  local maxDistance = option.maxDistance or 6
  local minDistance = option.minDistance or 4
  local noFollowAction = option.noFollowAction
  local noTargetAction = option.noTargetAction
  local o = {
    _actor = actor,
    _toobjid = toobjid,
    _maxDistance = maxDistance,
    _minDistance = minDistance,
    _noFollowAction = noFollowAction,
    _noTargetAction = noTargetAction,
    _isPaused = false
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcFollowAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  self._isPaused = false
  self._isFollowing = true
  self._isFoundTarget = true
  self._isFoundSelf = false
  self:_run()
end

function YcFollowAction:_run()
  local tx, ty, tz = YcCacheHelper.getPosition(self._toobjid) -- 目标的位置
  if tx then -- 找到目标
    self._isFoundTarget = true -- 标记找到目标
    self:_tryPauseNoTargetAction()
    local x, y, z = YcCacheHelper.getPosition(self._actor.objid) -- 自己的位置
    local distance = YcPositionHelper.getDistance(x, y, z, tx, ty, tz) -- 距离
    if distance then -- 如果成功计算出距离
      self._isFoundSelf = true -- 标记找到了自己
      if self._isFollowing then -- 如果正在跟随
        if distance > self._minDistance then -- 如果超过最小距离
          ActorAPI.tryMoveToPos(self._actor.objid, tx, ty, tz, self._actor.defaultSpeed)
        else -- 如果进入合适距离
          self._isFollowing = false -- 标记没有跟随
          if self._noFollowAction then
            self._noFollowAction:resume() -- 做自己的事
          end
        end
      else -- 如果没有在跟随
        if distance > self._maxDistance then -- 如果超过最大距离
          self:_tryPauseNoFollowAction()
          self._isFollowing = true -- 标记在跟随
          ActorAPI.tryMoveToPos(self._actor.objid, tx, ty, tz, self._actor.defaultSpeed)
        else -- 如果没有超过最大距离
          -- 继续做自己的事。这里不处理
        end
      end
    else -- 计算距离失败，有参数不合法。这里表示没有找到自己的位置。
      if self._isFoundSelf then -- 之前是找到了自己
        self:_tryPauseNoFollowAction()
      else -- 之前就没找到自己
        -- 那么这里不做什么
      end
      self._isFoundSelf = false
    end
  else -- 如果没找到目标
    if self._isFoundTarget then -- 如果之前找到了目标
      self:_tryPauseNoFollowAction()
      self._noTargetAction:resume() -- 做没找到目标时该做的事
    else -- 如果之前没找到目标
      -- 继续做之前的事。这里不处理
    end
    self._isFoundTarget = false -- 标记没找到目标
  end
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:_run()
  end)
end

--- 暂停行动
function YcFollowAction:pause()
  self._isPaused = true -- 标记是暂停
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t)
    self._t = nil
    self:_tryPauseNoFollowAction()
    self:_tryPauseNoTargetAction()
  end
end

--- 恢复行动
function YcFollowAction:resume()
  self:start()
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcFollowAction:stop(isTurnNext)
  self:pause()
  if isTurnNext then
    self:_turnNext()
  end
end

function YcFollowAction:_tryPauseNoFollowAction()
  if self._noFollowAction then
    self._noFollowAction:pause() -- 暂停自己的事
  end
end

function YcFollowAction:_tryPauseNoTargetAction()
  if self._noTargetAction then
    self._noTargetAction:pause() -- 暂停没找到目标时该做的事
  end
end
