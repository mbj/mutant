# frozen_string_literal: true

module Mutant
  class Mutator
    # SQL mutation backed by a real parser
    #
    # The SQL heredoc body is parsed with +pg_query+ into a PostgreSQL parse
    # tree, mutated one typed node at a time, and deparsed back to SQL text.
    #
    # Using the AST — instead of flipping keywords with a regex — avoids the
    # edge cases a regex cannot handle: the literal string "OR" inside a
    # query, "AND" inside a comment, "IN" as a substring of an identifier.
    # The parser distinguishes string literals and comments from operators,
    # so only real operators are ever mutated.
    #
    # A heredoc body that is not valid PostgreSQL yields no SQL mutations
    # rather than raising, so a non-PostgreSQL dialect is simply left alone.
    module Sql
      # Maps an +IN+ operator name to its negation and back.
      #
      # +x IN (..)+ parses to +name = ["="]+ and +x NOT IN (..)+ to
      # +name = ["<>"]+; flipping it is a circular orthogonal mutation
      # (see CONTRIBUTING.md §"Mutation Direction Rules").
      IN_OPERATORS = {
        '='  => '<>',
        '<>' => '='
      }.freeze

      # Single-field orthogonal flips, keyed by parse-tree node class.
      # Each entry names the enum field to flip and the +from => to+ values.
      FIELD_FLIPS = {
        PgQuery::BoolExpr => { field: :boolop, map: { AND_EXPR: :OR_EXPR, OR_EXPR: :AND_EXPR } },
        PgQuery::NullTest => { field: :nulltesttype, map: { IS_NULL: :IS_NOT_NULL, IS_NOT_NULL: :IS_NULL } },
        PgQuery::SortBy   => { field: :sortby_dir, map: { SORTBY_ASC: :SORTBY_DESC, SORTBY_DESC: :SORTBY_ASC } }
      }.transform_values(&:freeze).freeze

      # Generate SQL mutations for +sql+
      #
      # Each mutation flips exactly one typed node in the parse tree; the
      # mutated tree is deparsed back to SQL text. Parse failures return an
      # empty set.
      #
      # @param [String] sql
      #
      # @return [Set<String>]
      def self.mutate(sql)
        Either
          .wrap_error(PgQuery::ParseError) { PgQuery.parse(sql) }
          .fmap { |parsed| Set.new(targets(parsed).map { |target| apply(sql, target) }) }
          .from_right { Set.new }
      end

      class << self
        private

        # Collect one target per flippable node, in walk order
        #
        # A target is the node's stable tree location plus its mutator.
        # Locations are stable across re-parses, so each target can be
        # replayed against a fresh parse in {apply}.
        #
        # @param [PgQuery::ParserResult] parsed
        #
        # @return [Array<Hash{Symbol=>Object}>]
        def targets(parsed)
          list      = []
          forbidden = Set.new # inner EXISTS sublinks already handled by a NOT EXISTS unwrap

          each_target(parsed) do |node, location|
            mutator = mutator_for(node, location, forbidden)
            list << { location:, mutator: } if mutator
          end
          list
        end

        # Yield each node in +parsed+ with its stable tree location.
        # pg_query's +walk!+ yields four values; only the node and location
        # are needed.
        def each_target(parsed)
          # rubocop:disable Metrics/ParameterLists
          parsed.walk! do |_parent_node, _parent_field, node, location|
            yield node, location
          end
          # rubocop:enable Metrics/ParameterLists
        end

        # The mutator for +node+, if +node+ is flippable
        def mutator_for(node, location, forbidden)
          case node
          when PgQuery::A_Expr then in_expr_mutator(node)
          # PgQuery::Node is the protobuf oneof wrapper (holds sub_link/
          # bool_expr), NOT the base class; concrete leaf types (BoolExpr,
          # NullTest, SortBy) fall through to field_flip below.
          when PgQuery::Node then exists_mutator(node, location, forbidden)
          else field_flip(node)
          end
        end

        # A single-field orthogonal flip (AND/OR, IS NULL/IS NOT NULL,
        # ASC/DESC), looked up by node class in {FIELD_FLIPS}
        def field_flip(node)
          spec = FIELD_FLIPS[node.class] or return nil

          replacement = spec.fetch(:map)[node.public_send(spec.fetch(:field))]
          flip(spec.fetch(:field), replacement) if replacement
        end

        def in_expr_mutator(node)
          return unless node.kind.equal?(:AEXPR_IN)

          # +name+ holds the single IN operator; iterate once and flip it in
          # place on the re-parsed target (indexing would give +0+ == +-1+).
          lambda do |_parent_node, _parent_field, target|
            target.name.each { |name| name.string.sval = IN_OPERATORS.fetch(name.string.sval) }
          end
        end

        def exists_mutator(node, location, forbidden)
          if not_exists?(node)
            forbidden << inner_exists_location(location)
            unwrap_exists
          elsif sublink_exists?(node) && !forbidden.include?(location)
            wrap_exists
          end
        end

        # Whether +node+ is a bare +EXISTS (..)+ sublink
        def sublink_exists?(node)
          node.sub_link&.sub_link_type.equal?(:EXISTS_SUBLINK)
        end

        # Whether +node+ is a +NOT EXISTS (..)+ (a NOT bool-expr over an
        # EXISTS sublink)
        def not_exists?(node)
          bool_expr = node.bool_expr
          return false unless bool_expr&.boolop.equal?(:NOT_EXPR)

          # +args+ holds one operand, so +one?+ is true iff it is an EXISTS sublink.
          bool_expr.args.one? { |arg| arg.sub_link&.sub_link_type.equal?(:EXISTS_SUBLINK) }
        end

        # Location of the inner sublink of a +NOT EXISTS+ at +location+
        #
        # Recording it lets the later visit of the sublink skip wrapping,
        # which would only produce a redundant +NOT NOT EXISTS+.
        def inner_exists_location(location)
          location + %i[bool_expr args] + [0]
        end

        # Replay +target+ against a fresh parse and deparse to SQL text
        def apply(sql, target)
          parsed = PgQuery.parse(sql)
          parsed.find_tree_location(parsed.tree, target.fetch(:location)) do |parent_node, parent_field, node|
            target.fetch(:mutator).call(parent_node, parent_field, node)
          end
          parsed.deparse
        end

        # A mutator that sets a single field on the yielded node in place
        def flip(field, value)
          ->(_parent_node, _parent_field, target) { target[field.to_s] = value }
        end

        # A mutator that wraps a bare +EXISTS+ sublink in a NOT bool-expr
        def wrap_exists
          lambda do |parent_node, parent_field, node|
            replace(
              parent_node,
              parent_field,
              PgQuery::Node.new(
                bool_expr: PgQuery::BoolExpr.new(boolop: :NOT_EXPR, args: [node])
              )
            )
          end
        end

        # A mutator that unwraps a +NOT EXISTS+ back to a bare +EXISTS+
        def unwrap_exists
          lambda do |parent_node, parent_field, node|
            # A +NOT+ bool-expr holds one operand; iterate rather than index.
            node.bool_expr.args.each { |arg| replace(parent_node, parent_field, arg) }
          end
        end

        # Replace +node+ in its parent, accounting for the two field kinds
        # the treewalker yields: a Symbol name (message field) or an Integer
        # index (repeated field). The protobuf +[]+ setter needs a String.
        def replace(parent, field, value)
          field.instance_of?(Integer) ? parent[field] = value : parent[field.to_s] = value
        end
      end
    end # Sql
  end # Mutator
end # Mutant
