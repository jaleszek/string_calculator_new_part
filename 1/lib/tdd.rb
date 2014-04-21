class StringCalculator
	DEFAULT_RESULT = 0
	DEFAULT_DELIMITER = ','
	SUPPORTED_DELIMITERS = [",", "\n"]

	attr_reader :input

	def initialize(numbers_string)
		@input = numbers_string
	end

	def add
		return DEFAULT_RESULT if not_processable_input?
		validate_negatives
		numbers.inject(:+)
	end

	private

	def validate_negatives
		invalid_numbers = numbers.select{|number| number < 0 }
		raise Exception.new("negatives not allowed: #{invalid_numbers.join(', ')}") unless invalid_numbers.empty?
	end

	def not_processable_input?
		input == ''
	end

	# takes into consideration only numbers able to processing (eg. smaller than 1000)
	def numbers
		output = normalized_input.split(DEFAULT_DELIMITER).map(&:to_i)
		output.select{ |number| number <= 1000 }
	end

	# def custom_delimiter
	# 	input[3] if input.start_with?('//')
	# end

	def custom_delimiters
		output = []
		output << input.split("]\n").first[3..-1].split("][") if input.start_with?('//')
		output.flatten
	end

	def cut_off_delimiters_definition
		output = input.split("]\n")[1..-1].join unless custom_delimiters.empty?
		output || input
	end

	def normalized_input
		t_input = cut_off_delimiters_definition

	  (custom_delimiters + SUPPORTED_DELIMITERS).each do |delimiter|
	  	t_input.gsub!(delimiter, DEFAULT_DELIMITER)
	  end
	  t_input
	end
end