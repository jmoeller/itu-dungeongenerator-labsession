# Dungeon Generator

This is a meta-evolutionary dungeon generator. It creates 10x10 dungeons, where
each tile can be either floor or wall. Each dungeon has three points, *A*, *B*
and *C*. The optimal dungeon is the one where the combined distance from *A ->
B*, *B -> C* and *C- > A* is the highest.

## Creation of a dungeon

A single dungeon is created randomly. On each tile, if `rand()` is beneath a
threshold, the current tile will become a floor, otherwise it will become a
wall.

The three points are then positioned. *A* on the first available floor tile,
*C* on the last available floor tile, while *B* is placed on a random floor
tile inbetween. If there is no path from *A* to *B* to *C* the dungeon is
invalid and its fitness is *-1*. Otherwise the fitness is the pathlength. The
pathlength is found with A\*. Because of the dungeon layout, I decided that it
shouldn't be possible to walk diagonally when navigating through the dungeon.


## Evolution

The population of dungeons is sorted by their fitness, and the bottom *X* are
removed. The top *Y* is copied and mutated (based on a mutation factor to
determine if a tile should be mutated or not). The top *Z* is coupled to
produce 'offspring' that are (approximately) half of each parent. If the
population count is less than the desired population count, the population is
topped off with new dungeons.

### Crossover

Crossover between two dungeons is done based on *width* and *height*
parameters. The parameters determine how big a chunk should be taken from each
dungeon and put into the child before switching to the other parent.

**Example**: If a completely empty dungeon and a completely full dungeon is
crossed over with *width = 5* and *height = 5*, the result is the following
dungeon:

    +----------+
    |XXXXX     |
    |XXXXX     |
    |XXXXX     |
    |XXXXX     |
    |XXXXX     |
    |     XXXXX|
    |     XXXXX|
    |     XXXXX|
    |     XXXXX|
    |     XXXXX|
    +----------+

If *width = 2* and *height = 6* the result is:

    +----------+
    |XX  XX  XX|
    |XX  XX  XX|
    |XX  XX  XX|
    |XX  XX  XX|
    |XX  XX  XX|
    |XX  XX  XX|
    |  XX  XX  |
    |  XX  XX  |
    |  XX  XX  |
    |  XX  XX  |
    +----------+

## Metaevolution

The genome for the meta evolution is a combination of all the parameters for a single evolution run:

* Number of genomes to kill each iteration
* Number of genomes to create via mutation each iteration
* Number of genomes to create via crossover each iteration
* The probability for a tile being a floor tile during generation
* The probability for a tile being mutated during a mutation
* The width and height for the crossover chunks

The population in a meta-evolution consists of 100 runs of the regular
evolution. The fitness of an evolution is the fitness of the best dungeon.
During each of the 100 meta-iterations, the 50 worst evolutions (as well as
those with a negative fitness value) is discarded. 20 new iterations are formed
via mutation and 20 are formed via crossover. The remaining 10 are formed by
creating entirely new iterations.


## Results

So far (Sep 18th 2012), the following dungeon is the best one found. It has a
fitness value of 107.

    +----------+
    |A  XXB  X |
    |XX   XX  X|
    |   X  XX X|
    | XX   X   |
    |   XX  XX |
    |     X    |
    |XXX XXXXXX|
    |    X     |
    | XXX   X  |
    |     X  XC|
    +----------+


## Further work

If this dungeon generater were to be improved, I think its major shortcoming is
the genome for a single dungeon. The 1:1 mapping between genotype and phenotype
results in a too large search space. Another appropriate genotype, instead of
the underlying wall/floor array, should still keep a high degree of locality,
but a decrease in search space size could allow for more extensive searches and
thereby better dungeons.

(Note: I won't be improving this any furter :))
