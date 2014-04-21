require 'spec_helper'


describe StringCalculator do

	# The method can take 0, 1 or 2 numbers, and will return 
	# their sum (for an empty string it will return 0) for example “” 
	# or “1” or “1,2”
	subject{ described_class}

	describe '.add' do
		context 'numbers string size 0' do
			it{assert_add_result('', 0)}
		end

		context 'numbers string size 1' do
			it{ assert_add_result('0', 0)}
			it{ assert_add_result('1', 1)}
		end

		context 'numbers string size 2' do
			it{ assert_add_result('0,1', 1) }
		end

		# Allow the Add method to handle an unknown amount of numbers
		context 'number string size unknown' do
			it{ assert_add_result('0,1,2,3,4', 10)}
			it{ assert_add_result('1,10,100,200', 311)}
		end
		# Allow the Add method to handle new lines between numbers (instead of commas).
		# the following input is ok:  “1\n2,3”  (will equal 6)
		# the following input is NOT ok:  “1,\n” (not need to prove it - just clarifying)

		context 'with new line delimiter' do
			it{ assert_add_result("1\n2,3\n4", 10)}
		end

		# to change a delimiter, the beginning of the string will contain a 
		# separate line that looks like this:   “//[delimiter]\n[numbers…]” 
		# for example “//;\n1;2” should return three where the default delimiter 
		# is ‘;’ .
		# the first line is optional. all existing scenarios should still be 
		# supported

		context 'custom delimiter' do
			context 'length 1' do
				it{ assert_add_result("//[.]\n1.2.3.4,6\n7", 23)}
				it{ assert_add_result("//[|]\n1|2,3|4|5\n6|7", 28)}
			end
			# Delimiters can be of any length with the following format:  “//[delimiter]\n” for example: “//[***]\n1***2***3” should return 6

			context 'any length' do
				it{ assert_add_result("//[..]\n1..2..3..4", 10)}
				it{ assert_add_result("//[,,]\n1,,2,,3,4", 10)}
			end

			context 'any number' do
				it{ assert_add_result("//[.][@]\n1.2.3@4.5@6,7\n8", 36)}
			end

			context 'any length any number' do
				it{ assert_add_result("//[..][,,][|]\n1..2,,3,4|5,,6", 21)}
				it{ assert_add_result("//[|][.][,][,,]\n1,2,,3,4,,5,6", 21)}
			end
		end

		# Calling Add with a negative number will throw an exception 
		# “negatives not allowed” - and the negative that was passed.
		# if there are multiple negatives, show all of them in the exception message

		context 'negative numbers' do
			it 'throws exception' do
				expect{ subject.new('-1,2,-2,4').add}.to raise_exception(Exception, "negatives not allowed: -1, -2")
			end
		end

		context 'big numbers' do
			it 'ignores numbers larger than 1000' do
				assert_add_result('1001,1000001,1000000,100000,66', 66)
			end
		end

	end
end

def assert_add_result(numbers_string, expected_sum)
	expect(subject.new(numbers_string).add).to eq(expected_sum)
end