DebugHelper = {}

function DebugHelper.PrintDump(o) 
	print(DebugHelper.Dump(o))
end

function DebugHelper.Dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. DebugHelper.Dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

return DebugHelper