math.randomseed(1415)

request = function()
  wrk.headers["Connection"] = "Keep-Alive"
  rnd = math.random(1, 50000)
  path = "/static/small/" .. rnd .. ".txt"
  -- print(path)
  return wrk.format("GET", path)
end
