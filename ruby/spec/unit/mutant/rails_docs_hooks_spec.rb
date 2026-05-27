# frozen_string_literal: true

# Guards against docs/rails.md drifting from the hook recipes that are actually
# verified against real Rails by the manager's `rails-verify` command. Each
# marked ```ruby block in the docs must be byte-identical to its source file.
RSpec.describe 'docs/rails.md hook recipes', mutant: false do
  root = File.expand_path('../../../..', __dir__)

  recipes = {
    'config/mutant/hooks_postgresql.rb' => 'rails_example/config/mutant/hooks_postgresql.rb',
    'config/mutant/hooks_sqlite.rb'     => 'rails_example/config/mutant/hooks_sqlite.rb'
  }

  recipes.each do |label, relative_path|
    it "keeps the #{label} snippet identical to #{relative_path}" do
      doc = File.read(File.join(root, 'docs/rails.md'))

      pattern = /
        ^<!--\ BEGIN\ #{Regexp.escape(label)}\ -->\n
        ```ruby\n
        (.*?)\n
        ```\n
        <!--\ END\ #{Regexp.escape(label)}\ -->$
      /mx

      match = doc.match(pattern)

      expect(match).not_to(
        be_nil,
        "docs/rails.md is missing the marked code block for #{label}"
      )

      documented = "#{match[1]}\n"
      source     = File.read(File.join(root, relative_path))

      expect(documented).to eq(source)
    end
  end
end
