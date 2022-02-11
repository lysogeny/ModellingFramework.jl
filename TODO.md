# TODO

## Documentation

- [ ] Documentation for defined interfaces
- [ ] Add missing docstrings

## Structural

- [ ] Move `links` to separate class, i.e. `KalamakisLink <: AbstractLink`
- [ ] New functor types for (ODE) outputs instead of closure, i.e. `ODEOutput <: AbstractModelOutput`
- [ ] Consider using composite types for dispatch of `AbstractData` methods instead of inheriting `AbstractRecursingData`
- [ ] Deal with varying norms, possibly through a new `AbstractNorm` type that can be composited with `AbstractObjective`, i.e. `Objective{ModelData,Euclidean,KalamakisFull}`

## Other

- [ ] Testing
- [ ] GitHub
