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

Mutant depends on:
* `sorbet-runtime` `~> 0.5.0` - Runtime type checking support
* `sorbet-static` `~> 0.6.0` - Static type checker binary (LSP server)

While Sorbet is being stabilized, version support targets are fluid. The goal is to
support sorbet versions that mutant's user-base needs. This currently means: At a
minimum the latest release branch, and all branches that are not older than 6 months.

As mutant's Sorbet integration is new, this policy may be amended based on user feedback.

### Non sorbet target projects

Mutant depends on both `sorbet-runtime` and `sorbet-static` as core dependencies.
These are required for mutant's Sorbet integration features. If you don't use Sorbet
in your project, the integration remains disabled by default and has minimal overhead.

### Type-checking architecture

When Sorbet type checking is enabled (`--use-sorbet`), mutant uses a **per-mutation
copy-on-write cache architecture** that handles the double-fork execution model:

#### Three-level isolation hierarchy

1. **Parent process (main)**: Pre-warms a Sorbet LSP cache by indexing the entire
   project once. This cache is stored in `tmp/sorbet-cache` (configurable via
   `--sorbet-cache-dir`). This happens BEFORE forking worker processes.

2. **Worker processes**: Each parallel worker forks from the main process but does
   NOT create its own cache at this level. Workers run sequentially through their
   assigned mutations.

3. **Per-mutation isolation**: For EACH mutation tested, a fresh cache copy is created
   at `tmp/sorbet-cache-worker-<pid>-mutation-<index>`. Each mutation gets:
   - A fresh LSP server instance
   - An isolated cache copy inheriting parent state
   - Complete isolation from previous/concurrent mutations
   - Automatic cleanup after type checking

#### Why per-mutation isolation?

Mutant uses **double fork**: Workers fork from main, then workers execute mutations
sequentially. Without per-mutation isolation, mutation N would see the polluted cache
state from mutation N-1, causing false positives/negatives in type checking.

#### Performance characteristics

- **Parent cache warmup**: O(project size) - paid once before forking
- **Per-mutation overhead**: O(cache copy) - typically fast with copy-on-write filesystems
- **Type checking**: O(changed files) - LSP uses incremental checking with cache
- **Cleanup**: Automatic removal of mutation caches after checking

This architecture ensures:
- ✅ Workers start fast (inherit pre-indexed cache)
- ✅ Mutations don't pollute each other
- ✅ Parent cache stays pristine for subsequent runs
- ✅ Correct type-checking results for every mutation
