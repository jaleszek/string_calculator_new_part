require 'spec_helper'

describe StringCalculator::Performer do
	context 'numbers string length 0' do
		it { add_result_expect_to_be('', 0)}
	end

	context 'numbers string length 1' do
		it{ add_result_expect_to_be('1', 1)}
	end

	context 'numbers string length 2' do
		it{ add_result_expect_to_be('1,2', 3)}
	end

	context 'unknown number of numbers in the sequence' do
		it{ add_result_expect_to_be('1,2,3,4,5,6', 21)}
	end

	context 'new lines as additional delimiter' do
		it{ add_result_expect_to_be("1\n2\n3,4\n5,6", 21)}
	end

	context 'custom delimiters' do
		it{ add_result_expect_to_be("//[.]\n1.2.3.4,5,6", 21)}
		it{ add_result_expect_to_be("//[;]\n1;2,3;4,5;6", 21)}
	end

	context 'for negatives' do
		let(:negatives){ '-1,2,3,4,-2'}
		let(:exception_msg){ "negatives not allowed: -1, -2" }
		subject{ described_class.new(negatives)}
		it 'raises exception' do
			expect{ subject.add}.to raise_exception(Exception, exception_msg)
		end

		it 'notifies external webservice about' do
			expect(StringCalculator::Notifier).to receive(:send_message).with(exception_msg)
			expect{subject.add}.to raise_error
		end
	end

	context 'big numbers' do
		it 'skips numbers larger than 1000' do
			add_result_expect_to_be('1001, 1002, 1,2,3,4,5,6,10000000', 21)
		end
	end

	context 'any length of custom delimiters' do
		it { add_result_expect_to_be("//[***]\n1***2***3,4,5***6", 21)}
		it{ add_result_expect_to_be("//[*.]\n1*.2*.3*.4,5*.6", 21)}
	end

	context 'any number of custom delimiters' do
		it{ add_result_expect_to_be("//[.][*.][||]\n1.2,3*.4||5.6", 21)}
	end

	describe 'external interactions' do
		let(:result){ 21 }
		subject{ described_class.new('21') }

		it 'notifies logger about the result' do
			expect(StringCalculator::Log).to receive(:perform).with(result)
			subject.add
		end

		it 'prints output in the console' do
			output = capture_stdout { subject.add }
			expect(output).to eq("#{result}\n")
		end
	end
end

def add_result_expect_to_be(numbers_string, expected_result)
	expect(described_class.new(numbers_string).add).to eq(expected_result)
end

describe StringCalculator::Notifier do
	subject{described_class}

	describe '.send_message' do
		it 'sends POST message to the web service'
	end
end 

describe StringCalculator::Log do
	subject { described_class }

	describe '.perform' do
		it 'writes result to the log file' do
			expect_any_instance_of(Logger).to receive(:info).with(12)
			subject.perform(12)
		end
	end
end


def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end