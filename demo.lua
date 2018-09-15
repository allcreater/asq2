asq = require("asq/asq")

local test = {
    vasya = 125,
    petya = 10,
    vika = 83,
    oleg = 113,
    katya = 3
}

local a = asq.pairs(test) : map(function (k,v) return k .. k, v, v * v end)

print("test...")
for k,v,vv in a :where (function (k,v,vv) return v > 10 end)
                :sort (function (k,v,vv) return vv end)
                do
    print(k,v,vv)
end

print("folding... ", asq.fold(a : map(function (k,v,vv) return v end ), function (acc, v) return math.max(acc, v) end, 0))
print("first value > 100 is", a : first(function (k,v, vv) return v > 100 end)) --TODO: somehow reset sequence to start?
print("second value > 100 is", a : first(function (k,v, vv) return v > 100 end)) --TODO: somehow reset sequence to start?
--  print("third value > 100 is", a : first(function (k,v, vv) return v > 100 end)) --TODO: somehow reset sequence to start?

print("list:")
for i,v in ipairs(a : toList()) do
    print(i, ":", v[1], v[2], v[3])
end

print("table:")
for k,v in pairs(a : toTable()) do
    print(k, v)
end