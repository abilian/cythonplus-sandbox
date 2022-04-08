#!/usr/bin/env  python
import matplotlib.pyplot as plt

gx = [1, 2, 4, 8, 10, 12, 16, 20, 24]
gy = [3477, 6770, 10549, 10590, 10586, 10178, 10027, 10578, 11063]

hx = [1, 2, 4, 8, 10, 12, 16, 20, 24]
hy = [1871, 4076, 9964, 22396, 25946, 30440, 38368, 44098, 47563]

plt.plot(gx, gy, linestyle="-", marker="o", label="Gunicorn req/s")
plt.plot(hx, hy, linestyle="-", marker="o", label="Httpd-Plus req/s")
plt.xticks(gx, gx)
plt.legend()

plt.title("Nombre de requêtes par sec. / nombre de workers\n(serveur quadri-coeur)")
plt.grid(True)
plt.show()
