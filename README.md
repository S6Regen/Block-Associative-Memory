# Block-Associative-Memory
Associative memory using (locality sensitive) hashing to dynamically select out specific weight vectors to use for a given input.

This allows large and fast associative memory. The issue is being revisited because there are fast neural networks that you may wish to add an external memory bank to. It would be better if there was not too much of a speed mismatch between the 2 systems.

I allowed the hash based indexing procedure to act as a nonlinearity for the associative memory algorithm. For better numerical surety you may wish to directly include a nonlinearity such as f(x)=1 x>=0, f(x)=-1 x<0.

Code is FreeBasic 1.07.1 (Linux AMD64), cos' that's how it is.

Added JavaScript version in the docs folder:

https://s6regen.github.io/Block-Associative-Memory/

The JavaScript version of the associative memory algorithm requires a more specific input vector to get the wanted output vector.
There are lots of different selectivity tradeoffs you can choose, depending on which non-linear function you use and which specific way you use locality sensitive hashing to select between different weight vectors or individual weights.

