# For Veritas::Immutable. will be extracted soon
require 'veritas'

require 'securerandom'

# Library namespace
module Mutant
end

require 'mutant/support/abstract'
require 'mutant/random'
require 'mutant/mutator'
require 'mutant/mutator/literal'
require 'mutant/mutator/literal/boolean'
require 'mutant/mutator/literal/range'
require 'mutant/mutator/literal/symbol'
require 'mutant/mutator/literal/string'
require 'mutant/mutator/literal/fixnum'
require 'mutant/mutator/literal/float'
require 'mutant/mutator/literal/array'
require 'mutant/mutator/literal/empty_array'
require 'mutant/mutator/literal/hash'
require 'mutant/mutator/literal/regex'
#require 'mutant/mutator/literal/dynamic'
require 'mutant/mutator/block'
require 'mutant/loader'
require 'mutant/context'
require 'mutant/context/constant'
require 'mutant/mutatee'
require 'mutant/matcher'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
