local asq = {
}

asq.metatable = {
    __index = asq,
    __call = function(self, ...)
        return self:next(...)
    end
}

function asq.pairs(sourceTable)
    assert(type(sourceTable) == "table")
    local k,v

    local iterator = {
        table = sourceTable,
        next = function()
            k,v = next(sourceTable, k)
            return k,v
        end
    }

    return setmetatable(iterator, asq.metatable)
end

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

-- even if iterator returns tuples only first argument will be folded.
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

return asq