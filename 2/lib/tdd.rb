module StringCalculator

	class Notifier
		def self.send_message(msg)
			# NOT IMPLEMENTED YET
		end
	end

	class Performer
		attr_reader :numbers_string

		DEFAULT_RESULT = 0
		DEFAULT_DELIMITER = ','

		def initialize(numbers_string)
			@numbers_string = numbers_string
		end

		def add
			if not_processable?
				result = DEFAULT_RESULT
			else
				handle_invalid_input
				result = without_big_numbers.inject(:+)
				StringCalculator::Log.perform(result)
			end
			puts result
			result
		end

		private

		def without_big_numbers
			numbers.select{|number| number <= 1000}
		end

		def handle_invalid_input
			negatives = numbers.select{|num| num < 0}
			unless negatives.empty?
				msg = "negatives not allowed: #{negatives.join(', ')}"
				StringCalculator::Notifier.send_message(msg)
				raise Exception.new(msg)
			end
		end

		def custom_delimiters
			output = []
			output << numbers_string.split("]\n").first[3..-1].split("][") if numbers_string.start_with?('//')
			output.flatten
		end

		def body
			output = numbers_string.split("]\n")[1..-1].join unless custom_delimiters.empty?
			output || numbers_string
		end

		def numbers
			normalized_input.split(DEFAULT_DELIMITER).map(&:to_i)
		end

		def normalized_input
			output = body
			delimiters = ["\n"]
			delimiters += custom_delimiters unless custom_delimiters.empty?
			delimiters.each do |delimiter|
				output.gsub!(delimiter, DEFAULT_DELIMITER)
			end
			output
		end

		def not_processable?
			numbers_string == ''
		end
	end
end

module StringCalculator
	require 'logger'

	class Log
		DEFAULT_FILE_NAME = 'string_calculator.log'

		def self.perform(result)
			logger = Logger.new(File.new DEFAULT_FILE_NAME, 'w+')
			logger.info result
		end
	end
end