local sessions = require("persistence").list()
for i, s in ipairs(sessions) do
  print(s)
end
