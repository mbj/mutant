# frozen_string_literal: true

module Mutant
  class Matcher
    class Method
      # Matcher for metaclass methods
      # i.e. ones defined using class << self or class << CONSTANT. It might??
      # work for methods defined like class << obj, but I don't think the
      # plumbing will be in place in the subject for that to work
      class Metaclass < self

        # New singleton method matcher
        #
        # @param [Class, Module] scope
        # @param [Symbol] method_name
        #
        # @return [Matcher::Method::Singleton]
        def self.new(scope, method_name)
          super(scope, method_name, Evaluator)
        end

        # Singleton method evaluator
        class Evaluator < Evaluator
          # the "receiver" is the `self` in `class << self`
          SUBJECT_CLASS            = Subject::Method::Metaclass
          NAME_INDEX               = 0
          CONST_NAME_INDEX         = 1
          SCLASS_RECEIVER_INDEX    = 0
          SCLASS_BODY_INDEX        = 1
          RECEIVER_WARNING         = 'Can only match :def inside :sclass on ' \
                                     ':self or :const, got :sclass on %p ' \
                                     'unable to match'

        private

          # Test for node match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def match?(node)
            n_def?(node) && name?(node) && line?(node) && metaclass_receiver?(node)
          end

          def metaclass_receiver?(node)
            mc = metaclass_containing(node)
            mc && metaclass_target?(mc)
          end

          def metaclass_containing(node)
            Mutant::AST.find_last_path(ast) do |cur_node|
              next unless n_sclass?(cur_node)

              metaclass_of?(cur_node, node)
            end.last
          end

          def metaclass_of?(sclass, node)
              body = sclass.children.fetch(SCLASS_BODY_INDEX)
              body.equal?(node) ||
                (n_begin?(body) && include_exact?(body.children, node))
          end

          def include_exact?(haystack, needle)
            haystack.index { |elem| elem.equal?(needle) }
          end

          # Test for line match
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def line?(node)
            node
              .location
              .line
              .equal?(source_line)
          end

          # Test for name match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def name?(node)
            node.children.fetch(NAME_INDEX).equal?(method_name)
          end

          # Test for receiver match
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def metaclass_target?(node)
            receiver = node.children.fetch(SCLASS_RECEIVER_INDEX)
            case receiver.type
            when :self
              true
            when :const
              sclass_const_name?(receiver)
            else
              env.warn(RECEIVER_WARNING % receiver.type)
              nil
            end
          end

          # Test if sclass's const name matches context
          #
          # @param [Parser::AST::Node] node
          #
          # @return [Boolean]
          def sclass_const_name?(node)
            name = node.children.fetch(CONST_NAME_INDEX)
            name.to_s.eql?(context.unqualified_name)
          end

        end # Evaluator

        private_constant(*constants(false))
      end # Singleton
    end # Method
  end # Matcher
end # Mutant
