#!/usr/bin/env  python
import matplotlib.pyplot as plt
import json

RESULT_FILE = "result.json"
RESULT_PNG = "result.png"

with open(RESULT_FILE, encoding="utf8") as f:
    result = json.load(f)

data = []
for r in result:
    data.append((r["args"][0], r["duration"]))

data.sort()
x = [item[0] for item in data]
y = [item[1] for item in data]

plt.plot(x, y, linestyle="-", marker="o", label="durée (s)")
# plt.xticks(x)
# plt.yticks(y)
plt.legend()

plt.title("N-reines - heuristique, single-core\nDurée du calcul / dimension")
plt.grid(True)
plt.savefig(RESULT_PNG, bbox_inches="tight")
plt.close()
