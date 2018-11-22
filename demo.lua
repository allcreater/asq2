asq = require("asq/asq")

local students = 
{
    {
        name = "Andrey",
        age = 17,
        department = "IT"
    },
    {
        name = "Artem",
        age = 24,
        department = "Design"
    },
    {
        name = "Olga",
        age = 20,
        department = "Applied math"
    },
    {
        name = "Shloma",
        age = 21,
        department = "Applied math"
    },
    {
        name = "Valeria",
        age = 23,
        department = "IT"
    },
    {
        name = "Boris",
        age = 25,
        department = "Design"
    },
    {
        name = "Vladlen",
        age = 23,
        department = "Engineering"
    },
    {
        name = "Artem",
        age = 25,
        department = "IT"
    }
}

local minAge = asq.values(students) : fold ( function (accum, info) return math.min(accum, info.age) end, math.huge)
print ("Min age is", minAge)



print ("Ranges:")
for v1,v2 in asq.range(1,10):zip(asq.range(2, 10), function (r1, r2) return r1[1], r2[1] end) do
    print(v1, v2)
end

-- print (" ")
-- for i in asq.range(10,1,-1) do
--     print(i)
-- end

-- print (" ")
-- for i in asq.range(1,10,2) do
--     print(i)
-- end
