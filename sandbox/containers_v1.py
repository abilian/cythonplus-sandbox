class Containers:
    some_list: list[int]
    some_dict: dict[int, float]
    another_dict: dict[str, int]

    def __init__(self):
        # self.some_list = []
        # self.some_dict = {}
        # self.another_dict = {}
        self.some_list = list[int]()
        self.some_dict = dict[int, float]()
        self.another_dict = dict[str, int]()

    def load_values(self) -> None:
        # self.some_list.append(1)
        # self.some_list.append(20)
        # self.some_list.append(30)
        self.some_list = [1, 20, 30]
        self.some_dict = {1: 0.1234, 20: 3.14}
        self.another_dict["a"] = 1
        self.another_dict["foo"] = self.some_list[1]

    def show_content(self) -> None:
        print("-------- containers quick example, version 1 --------")
        print("some_list:")
        for i in self.some_list:
            print(f"  {i} ", end="")
        print()

        print("some_dict:")
        for k, v in self.some_dict.items():
            print(f"  {k}: {v}")

        print("another_dict:")
        for item2 in self.another_dict.items():
            print(f"  {item2[0]}: {item2[1]}")


def main():
    c: Containers

    c = Containers()
    c.load_values()
    c.show_content()
