require './lib/clause'
require './lib/declaration'

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation

  # https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-context#background
  #config.shared_context_metadata_behavior = :apply_to_host_groups
end


RSpec.describe 'Clause' do

  describe 'tokenizing' do 
    it "can tokenize a simple string" do 
      expr = "foo bar baz"
      tokens = %w{foo bar baz}
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end

     it "can tokenize a non-trimmed string" do 
      expr = " foo bar  baz  "
      tokens = %w{foo bar baz}
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end


    it "can respect apostrophes when tokenizing" do
      expr = "It's not like that at all"
      tokens = %w{It's not like that at all}
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end

    it "can respect single quotes when tokenizing" do
      expr = "foo = 'bar  baz'"
      tokens = ["foo", "=", "'bar  baz'"]
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end

    it "can respect double quotes when tokenizing" do
      expr = 'foo = "bar  baz"'
      tokens = ["foo", "=", '"bar  baz"']
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end

    it "can respect mixed single & double quotes when tokenizing" do
      expr = %q{ "Listen, Harry," she said, "I don't know about this little 'scam' of yours." }
      tokens = ['"Listen, Harry,"', 'she', 'said,', '"I don\'t know about this little \'scam\' of yours."']
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end

    it "can tokenize a logical expression" do
      expr = "pc.eye_color == 'blue' && (pc.hair_color == \"blue\" )"
      tokens = [
        'pc.eye_color', 
        '==', 
        "'blue'", 
        "&&", 
        '(pc.hair_color', 
        '==', 
        '"blue"', 
        ')'
      ]
      expect(Clause.new(expr).tokenized).to eq(tokens)
    end
  end

  describe 'clauses' do
    #let(:a) { File.read('spec/data/footnote-before.xml' )}
    #let(:b) { File.read('spec/data/footnote-after.xml' )}

    it "can convert a simple Chapbook math expression to the ChoiceScript equivalent" do
      chpbk = "times.hit == 5"
      chsrpt = 'times_hit = 5' 
      clause = Clause.new(chpbk)
      expect(clause.to_choicescript).to eq(chsrpt)
    end

    it "can convert a Chapbook logical expression to the ChoiceScript equivalent" do
      chpbk = "pc.eye_color == 'blue' && (pc.hair_color == \"blue\" || pc.hair_color == 'green')"
      chsrpt = 'pc_eye_color = "blue" and (pc_hair_color = "blue" or pc_hair_color = "green")' 
      clause = Clause.new(chpbk)
      expect(clause.to_choicescript).to eq(chsrpt)
    end

    it "successfully handles quoted special characters" do
      chpbk =  %q{delimiter == '.' || greeting = '"Hello there, Timmy."' || foo = 'a && b'}
      chsrpt = %q{delimiter = "." or greeting = ""Hello there, Timmy."" or foo = "a && b"} 
      clause = Clause.new(chpbk)
      expect(clause.to_choicescript).to eq(chsrpt)
    end

  end
end

RSpec.describe 'Declaration' do
  describe 'setting variables' do
    it 'can set a simple numeric variable' do
      chpbk =  %q{strength: 18}
      chsrpt = %q{*set strength 18}
      expect(Declaration.new(chpbk).to_choicescript).to eq(chsrpt)
    end

    it 'can set a simple string variable' do
      chpbk =  %q{name: 'foo'}
      chsrpt = %q{*set name "foo"}
      expect(Declaration.new(chpbk).to_choicescript).to eq(chsrpt)
    end

    it 'can set a simple boolean variable' do
      chpbk =  %q{is_wizard: true}
      chsrpt = %q{*set is_wizard true}
      expect(Declaration.new(chpbk).to_choicescript).to eq(chsrpt)
    end

    it 'can set a variable to a formula' do
      chpbk =  %q{is_wizard: has_pointy_hat && spells_known > 0}
      chsrpt = %q{*set is_wizard has_pointy_hat and spells_known > 0}
      expect(Declaration.new(chpbk).to_choicescript).to eq(chsrpt)
    end

    it 'can conditionally set a variable to a formula' do
      chpbk =  %q{is_wizard  (has_pointy_hat && spells_known > 0 ): true}
      chsrpt = "*if (has_pointy_hat and spells_known > 0)\n" +
               "  *set is_wizard true"
      expect(Declaration.new(chpbk).to_choicescript).to eq(chsrpt)
    end
  end
end