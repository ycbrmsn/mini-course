--- 怪物管理类 v1.0.0
--- created by 莫小仙 on 2024-01-07
---@class YcMonsterManager 怪物管理类
---@field _monsterMap YcTable<actorid, YcMonster> 所有特殊怪物
YcMonsterManager = {
  _monsterMap = YcTable:new()
}

--- 添加一个怪物对象
---@param monster YcMonster 需要加入的怪物
function YcMonsterManager.addMonster(monster)
  YcMonsterManager._monsterMap[monster.actorid] = monster
end

--- 获取怪物对象
---@param objid integer 怪物id
---@return YcMonster 怪物对象
function YcMonsterManager.getMonster(actorid)
  return YcMonsterManager._monsterMap[actorid]
end
