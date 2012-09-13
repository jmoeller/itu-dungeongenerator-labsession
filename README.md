# Dungeon Generator

**Phenotype**: 10x10 boolean matrix representing walls or not. Location of
three points *A*, *B*, *C*. True means floor.

**Fitness Function**: Distance between *A*, *B* and *C* (using _A\*_). The
points should be as far as possible from each other, but reachable. Formally: *(A -> B) + (B -> C) -> (C -> A)*

**Genotype**: Find something appropriate.

**Competition**: Maximise the fitness in 1000 runs.
