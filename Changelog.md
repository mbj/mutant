# v0.9.0

* New license.
* Fix mutations to void value expressions to not be reported as integration error.
* Remove regexp body mutations
* Remove restarg mutations
* Remove support for rspec-3.{4,5,6}

# v0.8.25 2018-12-31

* Change to {I,M}Var based concurrency
* Remove actors

# v0.8.24 2018-12-29

* Change to always insert mutations with frozen string literals
* Fix various invalid AST or source mutations
* Handle regexp `regexp_parser` cannot parse but MRI accepts gracefully

# v0.8.23 2018-12-23

* Improved isolation error reporting
* Errors between isolation and tests do not kill mutations anymore.

# v0.8.22 2018-12-04

* Remove hard ruby version requirement. 2.5 is still the only officially supported version.

# v0.8.21 2018-12-03

* Change to modern ast format via unparser-0.4.1.

# v0.8.20 2018-11-27

* Replace internal timers with monotonic ones.

Find older changelogs in the project [history](https://github.com/mbj/mutant/blob/84d119fe49ebad51b213cb08285b95e6e7c4fab6/Changelog.md#v0821-2018-12-03)
