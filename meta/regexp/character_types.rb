mutations = {
  [:regexp_digit_type,           '/\d/'] => [:regexp_nondigit_type,           '/\D/'],
  [:regexp_hex_type,             '/\h/'] => [:regexp_nonhex_type,             '/\H/'],
  [:regexp_space_type,           '/\s/'] => [:regexp_nonspace_type,           '/\S/'],
  [:regexp_word_boundary_anchor, '/\b/'] => [:regexp_nonword_boundary_anchor, '/\B/'],
  [:regexp_word_type,            '/\w/'] => [:regexp_nonword_type,            '/\W/']
}

mutations = mutations.merge(mutations.invert)

mutations.each do |(source_type, source_mutation), (_, regexp_mutation)|
  Mutant::Meta::Example.add source_type do
    source(source_mutation)

    singleton_mutations
    regexp_mutations

    mutation(regexp_mutation)
  end
end
