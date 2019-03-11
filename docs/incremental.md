# Incremental mutation testing

Incremental mutation testing allows you to significantly speed up mutation
analysis, via skipping over subjects that are not changed.

This is an explicit trade off, often worth the downsides.

## Motivation

Despite all efforts in setting up a project for maximum mutation testing
efficiency, running a full pass over all available subjects is not always
desired. On building your branches on CI, and during local commit stage, its
instead more efficient to scope the Mutant run to everything that was
touched in the current branch / commit. The working set of subjects.

For not having to manually keep track of the working set, the `--since` option
allows you to specify a git reference point. Mutant will automatically subset all
available subjects to the ones that where touched since the reference point.

## Usage

Use the `--since git-reference` flag to enable automatic filtering of the
matched subjects to the ones that have a line changed since the reference
point.

Internally mutant will use the semantics of `git diff git-reference` to
determine which subjects have changes. A subject is selected by this mechanism
when `git diff` reports a hunk that overlaps with the current subjects line
range.

## Example

On a branch, executing:

```
mutant --since master 'ProjectNamespace*'
```

Will run mutation testing against all subjects that have a direct source code
since the `master` branch. Assuming your project has 100 subjects, and you
touched 2 of them in your branch: Mutant will only select these 2 subjects for
mutation testing.

## Recommended use

Use incremental for any project where a full pass does not fit within acceptable
round trip times for the human mind.

A small 200 loc gem, should probably never use it. Typically its the local per
developer environment that should use incremental first. On CI its recommended
to stay with the full pass as long as possible and switch to incremental mode
when the CI cycle time gets too annoying.

In addition, once using incremental its recommended to run a full pass as a
nightly job.

Incremental is also a good mode to retrofit mutation testing into a legacy
project.

Good selectors for reference points are `HEAD~1` (the previous commit) or
`master` (the integration branch).

## Limitations

Mutant only triggers incremental subject selection for *direct* code changes.
It'll currently not select subjects that where indirectly changed.

Counter examples:

* A change to a constant that results in a behavior change of a subject will
  not trigger that subject to be selected.
* A change to a subject A that causes another subject B to change in behavior,
  will not select subject B.

These limitations may be removed in future versions of mutant, work on more
fine grained tracing is underway.
