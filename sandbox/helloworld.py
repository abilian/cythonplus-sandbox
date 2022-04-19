from fake import cypclass


@cypclass
class HelloWorld:
    message: str

    def __init__(self):
        self.message = "Hello World!"

    def print_message(self) -> None:
        print(self.message)


def main():
    hello: HelloWorld

    hello = HelloWorld()
    hello.print_message()
