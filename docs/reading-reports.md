Reading Reports
===============

Mutation output is grouped by selection groups. Each group contains three sections:

1. An identifier for the current group.

   **Format**:

   ```text
   [SUBJECT EXPRESSION]:[SOURCE LOCATION]:[LINENO]
   ```

   **Example**:

   ```text
   Book#add_page:Book#add_page:/home/dev/mutant-examples/lib/book.rb:18
   ```

2. A list of specs that mutant ran to try to kill mutations for the current group.

   **Format**:

   ```text
   - [INTEGRATION]:0:[SPEC LOCATION]:[SPEC DESCRIPTION]
   - [INTEGRATION]:1:[SPEC LOCATION]:[SPEC DESCRIPTION]
   ```

   **Example**:

   ```text
   - rspec:0:./spec/unit/book_spec.rb:9/Book#add_page should return self
   - rspec:1:./spec/unit/book_spec.rb:13/Book#add_page should add page to book
   ```

3. A list of unkilled mutations diffed against the original unparsed source

   **Format**:

   ```text
   [MUTATION TYPE]:[SUBJECT EXPRESSION]:[SOURCE LOCATION]:[SOURCE LINENO]:[IDENTIFIER]
   [DIFF]
   -----------------------
   ```

   - `[MUTATION TYPE]` will be one of the following:
      - `evil` - a mutation of your source was not killed by your tests
      - `neutral` your original source was injected and one or more tests failed
   - `[IDENTIFIER]` - Unique identifier for this mutation

   **Example**:

   ```diff
   evil:Book#add_page:Book#add_page:/home/dev/mutant-examples/lib/book.rb:18:01f69
   @@ -1,6 +1,6 @@
    def add_page(page)
   -  @pages << page
   +  @pages
      @index[page.number] = page
      self
    end
   -----------------------
   evil:Book#add_page:Book#add_page:/home/dev/mutant-examples/lib/book.rb:18:b1ff2
   @@ -1,6 +1,6 @@
    def add_page(page)
   -  @pages << page
   +  self
      @index[page.number] = page
      self
    end
   -----------------------
   ```

At this time no machine readable output exists in the opensourced versions of mutant.
