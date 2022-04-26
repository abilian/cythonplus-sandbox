#!/usr/bin/env  python
import matplotlib.pyplot as plt
import json

RESULT_A_FILE = "result.json"
RESULT_M_FILE = "../cyp_heuristic_mono/result.json"
RESULT_PNG = "result_comparison.png"

with open(RESULT_A_FILE, encoding="utf8") as f:
    result = json.load(f)

data = []
for r in result:
    data.append((r["args"][0], r["duration"]))

data.sort()
ax = [item[0] for item in data]
ay = [item[1] for item in data]

with open(RESULT_M_FILE, encoding="utf8") as f:
    result = json.load(f)
data = []
for r in result:
    data.append((r["args"][0], r["duration"]))

data.sort()
mx = [item[0] for item in data]
my = [item[1] for item in data]

plt.plot(mx, my, linestyle="-", marker="o", label="single-core, duration (s)")
plt.plot(ax, ay, linestyle="-", marker="o", label="actors, duration (s)")
# plt.xticks(x)
# plt.yticks(y)
plt.legend()

plt.title("N-queens - actors versus single-core \nDuration / board size")
plt.grid(True)
plt.savefig(RESULT_PNG, bbox_inches="tight")
plt.close()
