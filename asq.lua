local asq = {
}

asq.metatable = {
    __index = asq,
    __call = function(self, ...)
        return self:next(...)
    end
}

-- @brief transforms source table into sequence (iterator)
-- @return sequence of key/value pairs. Iterator is compatible with range-based for loop
function asq.pairs(sourceTable)
    assert(type(sourceTable) == "table")
    local k,v

    local iterator = {
        table = sourceTable,
        reset = function()
            k,v = nil, nil
        end,
        next = function()
            k,v = next(sourceTable, k)
            return k,v
        end
    }

    return setmetatable(iterator, asq.metatable)
end

-- @brief transforms source table into sequence (iterator)
-- @return sequence of keys. Iterator is compatible with range-based for loop
function asq.keys(sourceTable)
    assert(type(sourceTable) == "table")
    local k,v

    local iterator = {
        table = sourceTable,
        next = function()
            k,v = next(sourceTable, k)
            return k
        end
    }

    return setmetatable(iterator, asq.metatable)
end

-- @brief transforms source table into sequence (iterator)
-- @return sequence of table values. Iterator is compatible with range-based for loop
function asq.values(sourceTable)
    assert(type(sourceTable) == "table")
    local k,v

    local iterator = {
        table = sourceTable,
        next = function()
            k,v = next(sourceTable, k)
            return v
        end
    }

    return setmetatable(iterator, asq.metatable)
end

-- @brief transforms initial sequence into another. 
-- @param mapping - function (v1, v2, ..., vn) -> v1`, v2`, ..., vm` 
-- @return sequence

function asq.map(iterator, mapping)
    assert(getmetatable(iterator) == asq.metatable)

    local safeMapping = function (k, ...)
        if k then
            return mapping(k, ...)
        else
            return
        end
    end

    local resIterator = {
        next = function()
            return safeMapping(iterator())
        end
    }

    return setmetatable(resIterator, asq.metatable)
end

-- @brief sorts entire sequence by user criteria (lesser to bigger)
-- @param sortCriteria - function (...) -> number . Result number is a priority in result table
-- @return sorted sequence
function asq.sort(iterator, sortCriteria)
    assert(getmetatable(iterator) == asq.metatable)

    local resIterator = {
        next = function(self)
            print("sorting...")

            self.sortedList = {}
            while true do
                local results = {iterator()}

                if results[1] then
                    results.criteria = (sortCriteria(table.unpack(results)))
                    table.insert(self.sortedList, results)
                else
                    break
                end
            end

            local sortfunction = function(a, b)
                return a.criteria < b.criteria
            end

            table.sort( self.sortedList, sortfunction )
            
            local index = 1
            self.next = function()
                local v = self.sortedList[index]
                if v then
                    index = index + 1
                    return table.unpack(v)
                else
                    return
                end
            end

            return self.next()
        end
    }

    return setmetatable(resIterator, asq.metatable)
end

-- @brief folds whole sequence into a single value
-- @param iterator - input sequence. Even if returns more than one value only first will be folded
-- @param func - function op(accumulator, newValue) must return new accumulator value
-- @param accum - initial accumulator value 
-- @return final accumulator value
function asq.fold (iterator, func, accum)
    assert(getmetatable(iterator) == asq.metatable)
    assert(func and type(func) == "function")
    
    local value
    while true do
        value = iterator()

        if value then
            accum = func(accum, value)
        else
            break
        end
    end

    return accum
end

-- @brief filters the sequence leaving only values satisfying the predicate
-- @param predicate - function (...) -> bool
-- @return filtered sequence (all elements where predicate was true)
function asq.where (iterator, predicate)
    assert(getmetatable(iterator) == asq.metatable)
    assert(predicate and type(predicate) == "function")

    local resIterator = {
        next = function(self)

            local results
            repeat
                results = {iterator()}

                if not results[1] then
                    break
                end
            until predicate(table.unpack(results))
            
            return table.unpack(results)
        end
    }

    return setmetatable(resIterator, asq.metatable)
end

-- @brief finds first element satisfying the condition
-- @return v1,v2,...,vn
function asq.first (iterator, predicate)
    local results
    repeat
        results = {iterator()}

        if not results[1] then
            return
        end
    until predicate(table.unpack(results))

    return table.unpack(results)
end

-- @brief gathers all sequence values into list table
-- @param iterator
-- @return {1 = {...}, 2 = {...}, ..., n = {...}}
function asq.toList(iterator)
    local list = {}
    while true do
        local result = {iterator()}
        if result[1] then
            table.insert( list, result)
        else
            break
        end
    end

    return list
end

-- @brief gathers all sequence values into table
-- @param iterator - should returns key/values pairs to map on generic Lua table 
-- @return {k1 = v1, k2 = v2, ..., kn = vn}
function asq.toTable(iterator)
    local resTable = {}

    while true do
        local key, value = iterator()

        if key then
            resTable[key] = value
        else
            break
        end
    end

    return resTable
end

return asq