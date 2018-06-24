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

local test = {
    vasya = 125,
    petya = 10,
    vika = 83,
    oleg = 113,
    katya = 3
}

--local a = asq.map(test, function (k,v) return k .. k, v, v * v end)

print("test...")
for k,v,vv in asq.pairs(test)
                    :map (function (k,v) return k .. k, v, v*v end) 
                    :map (function (k,v,vv) return k, vv, v end)
                    :sort (function (k,v,vv) return vv end)
                    do
    print(k,v,vv)
end