### Sorbet

Mutant aims to implement full sorbet support. Full support includes:

* Being able to mutate code that has sorbet signatures, as of mutant-0.11.0.
* Being able to cover mutations via the type system. This capability is being
  developed right now.

### Setup

There is currently no special setup required on a sorbet enabled code base.
Mutant will automatically "see through" code with signatures and its type check
wrapping to act on the underlying method directly.

With adding the type system coverage feature special setup may or may not be
required.

### Sorbet version support

At this time mutant supports sorbet versions `0.5.x`, which is right now the latest
available release branch. While sorbet is being stabilized the version support
targets are fluent. Its the goal to support sorbet versions that mutants user-base needs.
This currently means: At a minimum the latest release branch, and all branches that are not
older than 6 month.

As mutants sorbet support is new, this policy may be amended based on user feedback.

### Non sorbet target projects

While mutant itself depends on `sorbet-runtime` it works with code bases that do not
use sorbet. Please reach out if the presence of `sorbet-runtime` causes issues for
your project.
