require 'spec_helper'
require_relative '../../lib/rules_parser'

describe RulesParser do
  before(:each) do
    @parser = RulesParser.new "spec/test_data.txt"
  end

  context 'class methods' do
    describe '.new' do
      it 'Should instantiate an RulesParser object' do
        expect(@parser.class).to be RulesParser
      end

      it 'Should raise an ArgumentError if no argument is provided' do
        lambda {RulesParser.new}.should raise_error(ArgumentError)
      end
    end
  end

  context 'instance methods' do
    describe '.write' do
      after(:each) do
        FileUtils.rm "output.csv"  if File.exists?("output.csv")
        FileUtils.rm "new.csv" if File.exists?("new.csv")
      end

      it 'Should properly write to a default file' do
        @parser.write
        expected = IO.readlines "spec/expected.csv"
        actual = IO.readlines "output.csv"
        expect(actual).to eq(expected)
      end

      it 'Should properly write to a specified file' do
        new_parser = RulesParser.new "spec/test_data.txt", "new.csv"
        new_parser.write
        expected = IO.readlines "spec/expected.csv"
        actual = IO.readlines "new.csv"
        expect(actual).to eq(expected)
      end
    end
  end

  context 'private methods' do
    describe '.line_to_csv' do
      it 'Should recognize a section' do
        actual = @parser.instance_eval{line_to_csv("5 PENALTIES")}
        expected = "5,PENALTIES,level1"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a subsection' do
        actual = @parser.instance_eval{line_to_csv("5.1 A TYPE OF PENALTY")}
        expected = "5.1,A TYPE OF PENALTY,level2"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a rule 3 levels deep' do
        actual = @parser.instance_eval{line_to_csv("5.1.1 Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.")}
        expected = "5.1.1,Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.,level3"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a rule 7 levels deep' do
        actual = @parser.instance_eval{line_to_csv("5.1.1.4.3.8.4 Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.")}
        expected = "5.1.1.4.3.8.4,Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.,level7"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a paragraph' do
        paragraph = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vero, ullam, ad, ratione, non natus dignissimos unde sapiente mollitia cupiditate molestiae aspernatur voluptate quo maxime atque at sit deserunt. Recusandae, facere fugit veritatis earum molestiae laudantium excepturi rerum minus voluptatum nisi!"
        actual = @parser.instance_eval{line_to_csv(paragraph)}
        expected = ",#{paragraph},paragraph"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a header' do
        actual = @parser.instance_eval{line_to_csv("No Impact/No Penalty")}
        expected = ",No Impact/No Penalty,header"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a placeholder' do
        actual = @parser.instance_eval{line_to_csv("--index--")}
        expected = ",index,placeholder"
        expect(actual).to eq(expected)
      end

      it 'Should not accept lines with only whitespace' do
        actual = @parser.instance_eval{line_to_csv("            \n   ")}
        expect(actual).to be_false
      end
    end

    describe '.get_type' do
      it 'Should raise an ArgumentError if no argument is provided' do
        lambda {@parser.instance_eval{get_type}}.should raise_error(ArgumentError)
      end

      it 'Should raise an ArgumentError if one argument is provided' do
        lambda {@parser.instance_eval{get_type("text")}}.should raise_error(ArgumentError)
      end

      it 'Should return header for headers' do
        actual = @parser.instance_eval{get_type("", "Expulsion (gross misconduct)")}
        expect(actual).to eq("header")
      end

      it 'Should return paragraph for paragraphs' do
        actual = @parser.instance_eval{get_type("", "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Deleniti dolore repellendus illum doloremque et aperiam ea fugiat quos alias consequatur!")}
        expect(actual).to eq("paragraph")
      end

      it 'Should return a level number for rules' do
        actual = @parser.instance_eval{get_type("6.2.5", "Lorem ipsum dolor sit amet.")}
        expect(actual).to eq("level3")
      end

      it 'Should return placeholder for placeholders' do
        actual = @parser.instance_eval{get_type("", "--index--")}
        expect(actual).to eq("placeholder")
      end
    end
  end
end
