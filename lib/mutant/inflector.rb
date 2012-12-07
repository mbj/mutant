# = English Nouns Number Inflection.
#
# This module provides english singular <-> plural noun inflections.
module Inflector

  # Take an underscored name and make it into a camelized name
  #
  # @example
  #   "egg_and_hams".classify #=> "EggAndHam"
  #   "enlarged_testes".classify #=> "EnlargedTestis"
  #   "post".classify #=> "Post"
  #
  def self.classify(name)
    words = name.to_s.sub(/.*\./, '').split('_')
    words[-1] = singularize(words[-1])
    words.collect { |word| word.capitalize }.join
  end

  # By default, camelize converts strings to UpperCamelCase.
  #
  # camelize will also convert '/' to '::' which is useful for converting paths to namespaces
  #
  # @example
  #   "active_record".camelize #=> "ActiveRecord"
  #   "active_record/errors".camelize #=> "ActiveRecord::Errors"
  #
  def self.camelize(lower_case_and_underscored_word, *args)
    lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end


  # The reverse of +camelize+. Makes an underscored form from the expression in the string.
  #
  # Changes '::' to '/' to convert namespaces to paths.
  #
  # @example
  #   "ActiveRecord".underscore #=> "active_record"
  #   "ActiveRecord::Errors".underscore #=> active_record/errors
  #
  def self.underscore(camel_cased_word)
    camel_cased_word.to_const_path
  end

  # Capitalizes the first word and turns underscores into spaces and strips _id.
  # Like titleize, this is meant for creating pretty output.
  #
  # @example
  #   "employee_salary" #=> "Employee salary"
  #   "author_id" #=> "Author"
  def self.humanize(lower_case_and_underscored_word)
    lower_case_and_underscored_word.to_s.gsub(/_id$/, '').tr('_', ' ').capitalize
  end

  # Removes the module part from the expression in the string
  #
  # @example
  #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize #=> "Inflections"
  #   "Inflections".demodulize #=> "Inflections"
  def self.demodulize(class_name_in_module)
    class_name_in_module.to_s.gsub(/^.*::/, '')
  end

  # Create the name of a table like Rails does for models to table names. This method
  # uses the pluralize method on the last word in the string.
  #
  # @example
  #   "RawScaledScorer".tableize #=> "raw_scaled_scorers"
  #   "EnlargedTestis".tableize #=> "enlarged_testes"
  #   "egg_and_ham".tableize #=> "egg_and_hams"
  #   "fancyCategory".tableize #=> "fancy_categories"
  def self.tableize(class_name)
    words = class_name.to_const_path.tr('/', '_').split('_')
    words[-1] = pluralize(words[-1])
    words.join('_')
  end

  # Creates a foreign key name from a class name.
  #
  # @example
  #   "Message".foreign_key #=> "message_id"
  #   "Admin::Post".foreign_key #=> "post_id"
  def self.foreign_key(class_name, key = "id")
    underscore(demodulize(class_name.to_s)) << "_" << key.to_s
  end

  # Constantize tries to find a declared constant with the name specified
  # in the string. It raises a NameError when the name is not in CamelCase
  # or is not initialized.
  #
  # @example
  #   "Module".constantize #=> Module
  #   "Class".constantize #=> Class
  def self.constantize(camel_cased_word)
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
      raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
    end

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end
end

@singular_of = {}
@plural_of = {}

@singular_rules = []
@plural_rules = []

class << self
  # Defines a general inflection exception case.
  #
  # ==== Parameters
  # singular<String>::
  #   singular form of the word
  # plural<String>::
  #   plural form of the word
  #
  # ==== Examples
  #
  # Here we define erratum/errata exception case:
  #
  # English::Inflect.word "erratum", "errata"
  #
  # In case singular and plural forms are the same omit
  # second argument on call:
  #
  # English::Inflect.word 'information'
  def self.word(singular, plural=nil)
    plural = singular unless plural
    singular_word(singular, plural)
    plural_word(singular, plural)
  end

  def self.clear(type = :all)
    if type == :singular || type == :all
      @singular_of = {}
      @singular_rules = []
      @singularization_rules, @singularization_regex = nil, nil
    end
    if type == :plural || type == :all
      @singular_of = {}
      @singular_rules = []
      @singularization_rules, @singularization_regex = nil, nil
    end
  end


  # Define a singularization exception.
  #
  # ==== Parameters
  # singular<String>::
  #   singular form of the word
  # plural<String>::
  #   plural form of the word
  def self.singular_word(singular, plural)
    @singular_of[plural] = singular
    @singular_of[plural.capitalize] = singular.capitalize
  end

  # Define a pluralization exception.
  #
  # ==== Parameters
  # singular<String>::
  #   singular form of the word
  # plural<String>::
  #   plural form of the word
  def self.plural_word(singular, plural)
    @plural_of[singular] = plural
    @plural_of[singular.capitalize] = plural.capitalize
  end

  # Define a general rule.
  #
  # ==== Parameters
  # singular<String>::
  #   ending of the word in singular form
  # plural<String>::
  #   ending of the word in plural form
  # whole_word<Boolean>::
  #   for capitalization, since words can be
  #   capitalized (Man => Men)      #
  # ==== Examples
  # Once the following rule is defined:
  # English::Inflect.rule 'y', 'ies'
  #
  # You can see the following results:
  # irb> "fly".plural
  # => flies
  # irb> "cry".plural
  # => cries
  # Define a general rule.

  def self.rule(singular, plural, whole_word = false)
    singular_rule(singular, plural)
    plural_rule(singular, plural)
    word(singular, plural) if whole_word
  end

  # Define a singularization rule.
  #
  # ==== Parameters
  # singular<String>::
  #   ending of the word in singular form
  # plural<String>::
  #   ending of the word in plural form
  #
  # ==== Examples
  # Once the following rule is defined:
  # English::Inflect.singular_rule 'o', 'oes'
  #
  # You can see the following results:
  # irb> "heroes".singular
  # => hero
  def self.singular_rule(singular, plural)
    @singular_rules << [singular, plural]
  end

  # Define a plurualization rule.
  #
  # ==== Parameters
  # singular<String>::
  #   ending of the word in singular form
  # plural<String>::
  #   ending of the word in plural form
  #
  # ==== Examples
  # Once the following rule is defined:
  # English::Inflect.singular_rule 'fe', 'ves'
  #
  # You can see the following results:
  # irb> "wife".plural
  # => wives
  def self.plural_rule(singular, plural)
    @plural_rules << [singular, plural]
  end

  # Read prepared singularization rules.
  def self.singularization_rules
    if defined?(@singularization_regex) && @singularization_regex
      return [@singularization_regex, @singularization_hash]
    end
    # No sorting needed: Regexen match on longest string
    @singularization_regex = Regexp.new("(" + @singular_rules.map {|s,p| p}.join("|") + ")$", "i")
    @singularization_hash  = Hash[*@singular_rules.flatten].invert
    [@singularization_regex, @singularization_hash]
  end

  # Read prepared pluralization rules.
  def self.pluralization_rules
    if defined?(@pluralization_regex) && @pluralization_regex
      return [@pluralization_regex, @pluralization_hash]
    end
    @pluralization_regex = Regexp.new("(" + @plural_rules.map {|s,p| s}.join("|") + ")$", "i")
    @pluralization_hash  = Hash[*@plural_rules.flatten]
    [@pluralization_regex, @pluralization_hash]
  end

  attr_reader :singular_of, :plural_of

  # Convert an English word from plural to singular.
  #
  #   "boys".singular      #=> boy
  #   "tomatoes".singular  #=> tomato
  #
  # ==== Parameters
  # word<String>:: word to singularize
  #
  # ==== Returns
  # <String>:: singularized form of word
  #
  # ==== Notes
  # Aliased as singularize (a Railism)
  def self.singular(word)
    if result = singular_of[word]
      return result.dup
    end
    result = word.dup
    regex, hash = singularization_rules
    result.sub!(regex) {|m| hash[m]}
    singular_of[word] = result
    return result
  end

  # Alias for #singular (a Railism).
  #
  alias_method(:singularize, :singular)

  # Convert an English word from singular to plural.
  #
  #   "boy".plural     #=> boys
  #   "tomato".plural  #=> tomatoes
  #
  # ==== Parameters
  # word<String>:: word to pluralize
  #
  # ==== Returns
  # <String>:: pluralized form of word
  #
  # ==== Notes
  # Aliased as pluralize (a Railism)
  def self.plural(word)
    # special exceptions
    return "" if word == ""
    if result = plural_of[word]
      return result.dup
    end
    result = word.dup
    regex, hash = pluralization_rules
    result.sub!(regex) {|m| hash[m]}
    plural_of[word] = result
    return result
  end

  # Alias for #plural (a Railism).
  alias_method(:pluralize, :plural)
  end

  # One argument means singular and plural are the same.

  word 'equipment'
  word 'fish'
  word 'grass'
  word 'hovercraft'
  word 'information'
  word 'milk'
  word 'money'
  word 'moose'
  word 'plurals'
  word 'postgres'
  word 'rain'
  word 'rice'
  word 'series'
  word 'sheep'
  word 'species'
  word 'status'

  # Two arguments defines a singular and plural exception.
  word 'alias'      , 'aliases'
  word 'analysis'   , 'analyses'
  word 'axis'       , 'axes'
  word 'basis'      , 'bases'
  word 'buffalo'    , 'buffaloes'
  word 'cactus'     , 'cacti'
  word 'crisis'     , 'crises'
  word 'criterion'  , 'criteria'
  word 'cross'      , 'crosses'
  word 'datum'      , 'data'
  word 'diagnosis'  , 'diagnoses'
  word 'drive'      , 'drives'
  word 'erratum'    , 'errata'
  word 'goose'      , 'geese'
  word 'index'      , 'indices'
  word 'life'       , 'lives'
  word 'louse'      , 'lice'
  word 'matrix'     , 'matrices'
  word 'medium'     , 'media'
  word 'mouse'      , 'mice'
  word 'movie'      , 'movies'
  word 'octopus'    , 'octopi'
  word 'ox'         , 'oxen'
  word 'phenomenon' , 'phenomena'
  word 'plus'       , 'plusses'
  word 'potato'     , 'potatoes'
  word 'quiz'       , 'quizzes'
  word 'status'     , 'status'
  word 'status'     , 'statuses'
  word 'Swiss'      , 'Swiss'
  word 'testis'     , 'testes'
  word 'thesaurus'  , 'thesauri'
  word 'thesis'     , 'theses'
  word 'thief'      , 'thieves'
  word 'tomato'     , 'tomatoes'
  word 'torpedo'    , 'torpedoes'
  word 'vertex'     , 'vertices'
  word 'wife'       , 'wives'

  # One-way singularization exception (convert plural to singular).

  # General rules.
  rule 'person' , 'people',   true
  rule 'shoe'   , 'shoes',    true
  rule 'hive'   , 'hives',    true
  rule 'man'    , 'men',      true
  rule 'child'  , 'children', true
  rule 'news'   , 'news',     true
  rule 'rf'     , 'rves'
  rule 'af'     , 'aves'
  rule 'ero'    , 'eroes'
  rule 'man'    , 'men'
  rule 'ch'     , 'ches'
  rule 'sh'     , 'shes'
  rule 'ss'     , 'sses'
  rule 'ta'     , 'tum'
  rule 'ia'     , 'ium'
  rule 'ra'     , 'rum'
  rule 'ay'     , 'ays'
  rule 'ey'     , 'eys'
  rule 'oy'     , 'oys'
  rule 'uy'     , 'uys'
  rule 'y'      , 'ies'
  rule 'x'      , 'xes'
  rule 'lf'     , 'lves'
  rule 'ffe'    , 'ffes'
  rule 'afe'    , 'aves'
  rule 'ouse'   , 'ouses'
  # more cases of words ending in -oses not being singularized properly
  # than cases of words ending in -osis
#    rule 'osis'   , 'oses'
  rule 'ox'     , 'oxes'
  rule 'us'     , 'uses'
  rule ''       , 's'

  # One-way singular rules.

  singular_rule 'of' , 'ofs' # proof
  singular_rule 'o'  , 'oes' # hero, heroes
  singular_rule 'f'  , 'ves'

  # One-way plural rules.

  #plural_rule 'fe' , 'ves' # safe, wife
  plural_rule 's'   , 'ses'
  plural_rule 'ive' , 'ives' # don't want to snag wife
  plural_rule 'fe'  , 'ves'  # don't want to snag perspectives

end
