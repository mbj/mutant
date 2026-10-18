# frozen_string_literal: true

if RUBY_VERSION > '3.4.0'
  Mutant::Meta::Example.add :itblock do
    source 'foo(false) { it.to_s }'

    singleton_mutations
    mutation 'foo(true) { it.to_s }'
    mutation 'foo { it.to_s }'
    mutation 'foo(false) { it }'
    mutation 'foo(false) { it.to_str }'
  end

  Mutant::Meta::Example.add :itblock do
    source 'foo { it.bar(1) { it } }'

    singleton_mutations
    mutation 'foo { it.bar { it } }'
    mutation 'foo { it.bar(nil) { it } }'
    mutation 'foo { it.bar(0) { it } }'
    mutation 'foo { it.bar(2) { it } }'
    mutation 'foo { it.bar(167) { it } }'
  end

  Mutant::Meta::Example.add :itblock do
    source 'foo { it.bar { |it| it } }'

    singleton_mutations
    mutation 'foo { it.bar }'
    mutation 'foo { it }'
    mutation 'foo { it.bar { |it| } }'
    mutation 'foo { it.bar { |it| raise } }'
    mutation 'foo { it.bar { |it| nil } }'
  end

  Mutant::Meta::Example.add :itblock do
    source 'foo { it; def bar(it) = it }'

    singleton_mutations
    mutation 'foo { it }'
    mutation 'foo { it; def bar(it); end }'
    mutation 'foo { it; def bar(it); raise; end }'
    mutation 'foo { it; def bar(it); super; end }'
    mutation 'foo { it; def bar(it); nil; end }'
  end

  Mutant::Meta::Example.add :itblock do
    source 'foo { it; def self.bar(it) = it }'

    singleton_mutations
    mutation 'foo { it }'
    mutation 'foo { it; def self.bar(it); end }'
    mutation 'foo { it; def self.bar(it); raise; end }'
    mutation 'foo { it; def self.bar(it); super; end }'
    mutation 'foo { it; def self.bar(it); nil; end }'
  end

  Mutant::Meta::Example.add :itblock do
    source 'foo { def it.bar = 1 }'

    singleton_mutations
    mutation 'foo { def it.bar; end }'
    mutation 'foo { def it.bar; raise; end }'
    mutation 'foo { def it.bar; super; end }'
    mutation 'foo { def it.bar; nil; end }'
    mutation 'foo { def it.bar; 0; end }'
    mutation 'foo { def it.bar; 2; end }'
    mutation 'foo { def it.bar; 167; end }'
  end

  Mutant::Meta::Example.add :itblock do
    source 'foo { bar(it, 1) }'

    singleton_mutations
    mutation 'foo { bar(it) }'
    mutation 'foo { bar(it, nil) }'
    mutation 'foo { bar(it, 0) }'
    mutation 'foo { bar(it, 2) }'
    mutation 'foo { bar(it, 167) }'
  end
end
