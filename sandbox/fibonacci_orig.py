# Fibonacci, python implementation
# for "int" on 64bits fibonacci max is n: 92 fibo: 7540113804746346429
# (for fib(n) <= 2**63)
# So for testing purpose, use "float" (aka double) fibonacci max is about 1476


def fibo(n):
    a = 0.0
    b = 1.0
    for i in range(n):
        a, b = b, a + b
    return a


def fibo_list(level):
    return [fibo(n) for n in range(level + 1)]


def main(level=None):
    if not level:
        level = 1476
    result = fibo_list(int(level))
    print(f"Computed values: {len(result)=}, Fibonacci({level}) is: {result[-1]=}")


if __name__ == "__main__":
    main()
