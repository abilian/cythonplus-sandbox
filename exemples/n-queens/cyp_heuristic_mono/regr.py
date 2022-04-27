#!/usr/bin/env  python
import json
import sys
from math import exp, log
from statistics import linear_regression  # python 3.10

import matplotlib.pyplot as plt


def graph_estim(data, label):
    points = []
    for r in data:
        points.append((r["args"][0], r["duration"], r["estim"]))

    points.sort()
    x = [item[0] for item in points]
    y = [item[1] for item in points]
    e = [item[2] for item in points]

    plt.plot(x, y, linestyle="-", marker="o", label="duration (s)")
    plt.plot(x, e, linestyle="-", marker="+", label=label)
    # plt.xticks(x)
    # plt.yticks(y)
    plt.legend()

    plt.title("N-queens - heuristic, single-core time complexity")
    plt.grid(True)
    plt.savefig("reg.png", bbox_inches="tight")
    plt.close()


def main(data_file):
    with open(data_file, encoding="utf8") as f:
        data = json.load(f)
    xx = []
    yy = []
    for d in data[4:]:
        xx.append(d["args"][0])
        yy.append(d["duration"])
    lxx = []
    lyy = []
    for x, y in zip(xx, yy):
        lxx.append(log(x))
        lyy.append(log(y))
    print(list(zip(lxx, lyy)))
    slope, intercept = linear_regression(lxx, lyy)
    a = exp(intercept)
    b = slope
    label = f"a.x^b : {a=:.2e} {b=:.2e}"

    for d in data:
        x = d["args"][0]
        estim = a * x**b
        d["estim"] = estim

    # with open(data_file, "w", encoding="utf8") as f:
    #     json.dump(f, data)
    graph_estim(data, label)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        data_file = sys.argv[1]
    else:
        data_file = "result.json"
    main(data_file)
