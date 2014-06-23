# encoding: utf-8
require 'fileutils'
require 'erb'

module Mutant
  class Reporter
    class HTML
      class Report

        # Class used for the HTML Report to gather information about a subject result
        class SubjectResult
          attr_reader :name, :total, :passed
          def initialize(subject)
            @name = subject.subject.identification.split(':/').first.split('#')[1]
            @total = subject.mutations.size
            failed = subject.failed_mutations.size
            @passed = total - failed
          end

          def percentage
            @passed * 100 / @total
          end
        end

        # Class used for the HTML Report to gather information about a gropu of subjects result
        class ScopeResult
          attr_reader :name, :subjects, :total, :passed
          def initialize(name)
            @name = name
            @subjects = []
            @total = 0
            @passed = 0
          end

          # Adds a subject to the group results
          #
          # @param [SubjectResult] subject
          # @return [Undefined]
          #
          # @api private
          #
          def add_subject(subject)
            subject_result = SubjectResult.new(subject)
            @subjects.push(subject_result)
            @total += subject_result.total
            @passed += subject_result.passed
          end

          def percentage
            @passed * 100 / @total
          end

        end

        # Class used for the HTML report, used to gather information about all the subjects run
        class ProjectResult
          attr_reader :scopes, :total, :passed, :project_name
          attr_accessor :runtime
          def initialize(results)
            @scopes = results
            @total = results.map(&:total).inject(:+)
            @passed = results.map(&:passed).inject(:+)
            @project_name =  File.basename(Dir.getwd.split('/').last).capitalize.gsub('_', ' ')
          end

          def percentage
            @passed * 100 / @total
          end
        end

        # Renders the ERB template.
        # It has helpers methods to avoid adding too much code to the ERB template itself.
        class TemplateHelper
          TEMPLATE_NAME = 'layout'
          TEMPLATE_DIR = 'views'

          # Renders the template in TEMPLATE_DIR/TEMPLATE_NAME
          #
          # @param [ProjectResult] result
          # @return [String]
          #
          # @api private
          #
          def render(result)
            result.project_name # This does nothing, called only to make Rubocop happy
            # the variable named result will be available in the ERB template
            template(TEMPLATE_NAME).result(binding)
          end

          private

          # Finds a template in the template directory
          #
          # @param [String] name of the template to find
          # @return [ERB]
          #
          # @api private
          #
          def template(name)
            ERB.new(File.read(File.join(File.dirname(__FILE__), TEMPLATE_DIR, "#{name}.erb")))
          end

          # used by the ERB template
          # Returns the path in the assets dir where to find a file
          #
          # @param [String] filename
          # @return [String]
          #
          # @api private
          #
          def assets_path(filename)
            File.join(Config::ASSETS_DIR, filename)
          end

          def time_in_minutes(runtime)
            if runtime > 60
              min = runtime / 60
              sec = runtime % 60
              "#{min.to_i} minutes and #{sec.to_i} seconds"
            else
              "#{runtime.to_i} seconds"
            end
          end

          # used by the ERB template
          # returns a rgb represeprensation from red (0) to green(100)
          # of the percentage of passed tests
          #
          # @param [Numeric] percentage
          # @return [String]
          #
          # @api private
          #
          def rgb_values(percentage)
            g = (255 * percentage) / 100
            r = (255 * (100 - percentage)) / 100;
            b = 0
            "rgb(#{r}, #{g}, #{b})"
          end
        end

        # Printer for configuration
        class Config < self
          MUTANT_HTML_REPORT_DIR = 'mutant'
          MUTANT_HTML_REPORT_FILE = 'mutant_report.html'
          ASSETS_DIR = 'assets'

          handle(Mutant::Runner::Config)

          delegate(:subjects, :runtime)

          # Runs the current report which will create files with its results
          #
          # @return [Self]
          #
          # @api private
          #
          def run
            scopes = subjects.group_by { |subject| subject.subject.context.scope }

            results = scopes.keys.reduce([]) do |array, scope_name|
              scope_result = ScopeResult.new(scope_name)
              scopes[scope_name].each do |subject|
                scope_result.add_subject(subject)
              end
              array.push(scope_result)
            end

            result = ProjectResult.new(results)
            result.runtime = runtime

            printout(result)
            create_html_report(result)

            self
          end

          private

          # Prints the results to the terminal
          #
          # @param [ProjectResult] result
          # @return [nil]
          #
          # @api private
          #
          def printout(result)
            puts "TOTAL  #{result.passed}/#{result.total}    #{result.percentage}%"

            result.scopes.each do |scope|
              puts "#{scope.name}  #{scope.percentage}%"
              scope.subjects.each do |subject|
                puts "   #{subject.name}  #{subject.passed}/#{subject.total}    #{subject.percentage}%"
              end
            end
          end

          # Copies and creates the files to create a html report
          #
          # @param [ProjectResult] result
          # @return [nil]
          #
          # @api private
          #
          def create_html_report(result)
            Dir[File.join(File.dirname(__FILE__), 'public/*')].each do |path|
              FileUtils.cp_r(path, assets_output_path)
            end
            File.open(output_file, 'w+') do |file|
              file.puts TemplateHelper.new.render(result)
            end
          end

          # Creates if not there already and retuns the path for the assets
          #
          # @return [String] path
          #
          # @api private
          #
          def assets_output_path
            path = File.join(MUTANT_HTML_REPORT_DIR, ASSETS_DIR)
            FileUtils.mkdir_p path
            path
          end

          # Returns the output file where the report will be created
          #
          # @return [String] output file
          #
          # @api private
          #
          def output_file
            File.join(MUTANT_HTML_REPORT_DIR, MUTANT_HTML_REPORT_FILE)
          end

        end # Config
      end # Report
    end # CLI
  end # Reporter
end # Mutant
