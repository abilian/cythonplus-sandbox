# distutils: language = c++
# from libcythonplus.list cimport cyplist
from runtime.runtime cimport SequentialMailBox, BatchMailBox, NullResult, Scheduler


cdef cypclass Greeter activable:
    int identifier

    __init__(self, lock Scheduler scheduler, int identifier):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.identifier = identifier

    void hello(self):
        with gil:
            print("Hello from greeter %d" % self.identifier)

def main():
    cdef lock Scheduler scheduler
    with nogil:
        scheduler = Scheduler()

        # Create 3 Greeters
        g0 = Greeter(scheduler, 0)
        g1 = Greeter(scheduler, 1)
        g2 = Greeter(scheduler, 2)

        # Consume two of them into active Greeters
        # g1 and g2 will now be NULL
        # a1 and a2 are actors that can only be accessed asynchronously
        a1 = <active Greeter> consume g1
        a2 = <active Greeter> consume g2

        # Call a1 and a2 asynchronously: the calls will be executed later
        # Call g0 synchronously: the call will be executed immediately
        # Asynchronous calls can take an additional predicate argument, NULL here.
        a1.hello(NULL)
        a2.hello(NULL)
        g0.hello()

        # Wait until all the actors have no more tasks
        scheduler.finish()
