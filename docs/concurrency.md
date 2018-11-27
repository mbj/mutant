Concurrency
===========

By default, mutant will test mutations in parallel by running up
to one process for each core on your system. You can control the
number of processes created using the `-j/--jobs` argument.

Mutant forks a new process for each mutation to be tested to prevent side
affects in your specs and the lack of thread safety in integrations from
impacting the results.

Database
--------

If the code under test relies on a database, you may experience problems
when running mutant because of conflicting data in the database. For
example, if you have a test like this:

```ruby
resource = MyModel.create!(...)
expect(MyModel.first.name).to eql(resource.name)
```

It might fail if some other test wrote a record to the `MyModel` table
at the same time as this test was executed. (It would find the MyModel
record created by the other test.) Most of these issues can be fixed
by writing more specific tests. Here is a concurrent safe version of
the same test:

```
resource = MyModel.create!(...)
expect(MyModel.find_by_id(m.id).name).to eql(resource.name)
```

An alternative is to try wrapping each test into an enclosing transaction.

Note that some databases, SQLite in particular, are not designed for
concurrent access and will fail if used in this manner. If you are
using SQLite, you should set the `--jobs` to 1.
