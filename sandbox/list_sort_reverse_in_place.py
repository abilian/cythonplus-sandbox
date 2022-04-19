IntList = list[int]


def print_list(lst: IntList) -> None:
    i: int

    for i in lst:
        print(f"{i} ", end="")
    print()


def demo_sort() -> None:
    lst: IntList

    lst = IntList()
    lst = IntList([20, 300, 10, 2, 1000, 1])

    print("-------- containers demo list sort / reverse --------")

    # lst = [20, 300, 10, 2, 1000, 1]

    print("original list:")
    print_list(lst)

    print("reverse list in-place:")
    lst.reverse()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)

    print("reverse list in-place:")
    lst.reverse()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)

    print("sort list in-place:")
    lst.sort()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)

    print("reverse list in-place:")
    lst.reverse()  # raise some ActiveIteratorError if another iterator running
    print_list(lst)


def main() -> None:
    demo_sort()
