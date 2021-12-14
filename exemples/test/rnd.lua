math.randomseed(1415)

request = function()
  wrk.headers["Connection"] = "Keep-Alive"
  rnd = math.random(1, 750)
  path = "/static/many/" .. rnd .. ".jpg"
  -- print(path)
  return wrk.format("GET", path)
end
