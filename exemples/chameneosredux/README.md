# Chameneosredux

A benchmark very agressive on threading performances and balance, with a not so simple
algorithm.

See .pdf paper.

The cython+ implementation in cyp_actor_mem_bug is kep as is until some understanding
of the problem.
The cyp_actor_v2 is a cython+ implementation that duplicate objects. The active
creature instance is not reintroduced in the arena, but a object.clone(), so it may
be quite slow implementation.

Hoever, the cython+ balancing seems very good, all creatures have equal chance to be
activated.


## To launch everything

    ./make_all.sh
    ./launch_all.sh


# Expected results

    $ ./launch_all.sh
    ============================================================================
    Chameneos, cpython using threads
    params: [100000]
    zoo: blue red yellow
     0: met = 59836  self_met = 0
     1: met = 57750  self_met = 0
     2: met = 82414  self_met = 0
    total met: 200000

    zoo: blue red yellow red yellow blue red yellow red blue
     0: met = 17696  self_met = 0
     1: met = 21181  self_met = 0
     2: met = 20600  self_met = 0
     3: met = 14534  self_met = 0
     4: met = 19504  self_met = 0
     5: met = 26261  self_met = 0
     6: met = 24738  self_met = 0
     7: met = 23686  self_met = 0
     8: met = 16208  self_met = 0
     9: met = 15592  self_met = 0
    total met: 200000

    duration: 4.178s

    ============================================================================
    Chameneos, cython+ actor v2, using clone() of objects
    params: [100000]
    zoo: blue red yellow
     0: met = 66985  self_met = 0
     1: met = 66693  self_met = 0
     2: met = 66322  self_met = 0
    total met: 200000

    zoo: blue red yellow red yellow blue red yellow red blue
     0: met = 20145  self_met = 0
     1: met = 19955  self_met = 0
     2: met = 20020  self_met = 0
     3: met = 19983  self_met = 0
     4: met = 19958  self_met = 0
     5: met = 20040  self_met = 0
     6: met = 19920  self_met = 0
     7: met = 20044  self_met = 0
     8: met = 19972  self_met = 0
     9: met = 19963  self_met = 0
    total met: 200000

    duration: 6.604s
