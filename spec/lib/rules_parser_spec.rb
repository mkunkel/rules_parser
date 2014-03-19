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
    describe '.parse_line' do
      it 'Should recognize a section' do
        actual = @parser.parse_line("5 PENALTIES")
        expected = "5,PENALTIES,level1"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a subsection' do
        actual = @parser.parse_line("5.1 A TYPE OF PENALTY")
        expected = "5.1,A TYPE OF PENALTY,level2"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a rule 3 levels deep' do
        actual = @parser.parse_line("5.1.1 Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.
Penalty")
        expected = "5.1.1,Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.
Penalty,level3"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a rule 7 levels deep' do
        actual = @parser.parse_line("5.1.1.4.3.8.4 Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.
Penalty")
        expected = "5.1.1.4.3.8.4,Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nam, dolorem officia nihil laboriosam! Similique, fuga.
Penalty,level7"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a paragraph' do
        paragraph = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vero, ullam, ad, ratione, non natus dignissimos unde sapiente mollitia cupiditate molestiae aspernatur voluptate quo maxime atque at sit deserunt. Recusandae, facere fugit veritatis earum molestiae laudantium excepturi rerum minus voluptatum nisi!"
        actual = @parser.parse_line(paragraph)
        expected = ",#{paragraph},paragraph"
        expect(actual).to eq(expected)
      end

      it 'Should recognize a header' do
        actual = @parser.parse_line("No Impact/No Penalty")
        expected = ",No Impact/No Penalty,header"
        expect(actual).to eq(expected)
      end
    end
  end
end
