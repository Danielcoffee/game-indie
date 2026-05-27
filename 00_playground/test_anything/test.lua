function fact(n)
	if n < 0 then
		print("need a positive number")
		return
	end
	if n == 0 then
		return 1
	else
		return n * fact(n-1)
	end
end



--[[
function add(a, b)
end

print(...)
]]
--[[
function devide (a, b)
	if b == 0 then return nil
	else
		return a / b
	end
end

function showcase(a, b)
	f = devide(a,b)
	if f then 
		print(f)
	else
		print("khong chia cho 0")
	end
end
]]

--[[M = {}
x = 124
table.insert(M, x)
]]


-- define factorial function
--[[
function fact(n)
	if n == 0 then
		return 1
	else
		return n * fact(n-1)
	end

end
print("enter a number: ") -- comment out
a = io.read("*n")
print(fact(a))
]]
--[[
x = 10
y = 5
function twice(x, y)
	return x ^ 2

end
]]


