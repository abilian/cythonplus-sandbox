**Proposal for a persistent scheduler**



- Based on runtime/scheduler.pxd

- updated and fixed version of 15 oct 2021

- Changes:

    - `PersistScheduler.join()`

      Wait until there is no more work, then do not stop the scheduler and the
      workers. New tasks can be posted to the queue. Other join() commands can
      be made, wether new tasks have been issued or not.

    - `PersistScheduler.finish()`

      Fonctianly unchanged: Wait until there is no more work, then close
      scheduler and workers.
