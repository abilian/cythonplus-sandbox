from fake import cypclass, consume, activate, SequentialMailBox, wlocked, Lock, double

IntDoubleDict = dict[int, double]


@cypclass  # activable
class Fibo:
    level: int
    results: Annotated(IntDoubleDict, Lock)

    def __init__(
        self,
        scheduler: Annotated(Scheduler, Lock),
        results: Annotated(IntDoubleDict, Lock),
        level: int,
    ):
        # self._active_result_class = NullResult
        self._active_queue_class = consume(SequentialMailBox(scheduler))
        self.level = level
        self.results = results

    def run(self) -> None:
        a: double
        b: double
        i: int

        a = 0.0
        b = 1.0
        for i in range(self.level):
            a, b = b, a + b
        with wlocked(self.results):
            self.results[self.level] = a


def fibo_list_cyp(
    scheduler: Annotated(Scheduler, Lock), level: int
) -> Annotated(IntDoubleDict, Lock):
    # nogil function (by default)
    results: Annotated(IntDoubleDict, Lock)
    n: int

    results = consume(IntDoubleDict())

    for n in range(level, -1, -1):  # reverse order to compute first the big numbers
        fibo = activate(consume(Fibo(scheduler, results, n)))
        fibo.run()  # remove the NULL argument

    scheduler.finish()
    return results


def fibo_list(level: int) -> list[int]:
    # nogil function (by default)

    results_cyp: IntDoubleDict
    result_py: list[int]
    scheduler: Annotated(Scheduler, Lock)
    i: int

    scheduler = Scheduler()
    results_cyp = consume(fibo_list_cyp(scheduler, level))
    del scheduler

    result_py = [
        item[1] for item in sorted((i, results_cyp[i]) for i in range(level + 1))
    ]
    return result_py


def main(level_arg: int = 0) -> None:
    # nogil function (by default)
    result: list[int]
    level: int

    if level_arg > 0:
        level = level_arg
    else:
        level = 1476
    result = fibo_list(level)
    print(f"Computed values: {len(result)=}, Fibonacci({level}) is: {result[-1]=}")
