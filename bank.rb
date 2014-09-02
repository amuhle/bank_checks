#require 'minitest/autorun'
require 'minitest'
#require 'debugger'


class BankChecks
  BIN_DIGITS = {
    "010101111" => 0, 
    "000001001" => 1, 
    "010011110" => 2, 
    "010011011" => 3, 
    "000111001" => 4, 
    "010110011" => 5, 
    "010110111" => 6, 
    "010001001" => 7, 
    "010111111" => 8, 
    "010111011" => 9  
  }

  def initialize
    @exacts = []
    @final_solutions = []
  end

  def read_code(line_1, line_2, line_3)
    fst_line = Array.new(27,"0")
    snd_line = Array.new(27,"0")
    thd_line = Array.new(27,"0")

    for i in 0..26 do
      fst_line[i] = "1" if value? line_1[i]
      snd_line[i] = "1" if value? line_2[i]
      thd_line[i] = "1" if value? line_3[i]
    end

    digits = []

    for i in 0..8 do
      range = (i*3)..(i*3+2)
      digits[i] = (fst_line[range] + snd_line[range] + thd_line[range]).join
    end

    @temp_solutions = []

    digits.each do |d|
      @temp_solutions << find_solutions(d)
    end

    filter_solutions
    size = @final_solutions.size 
    if size > 1
      return "ambiguous"
    elsif size < 1 
      return "failure"
    else
      return @final_solutions[0]
    end
  end

  private 
  def value? val
    val != " "
  end

  def find_solutions digit
    sols = []
    bin_dig = digit.to_i(2)
    @exacts << BIN_DIGITS[digit]
    BIN_DIGITS.keys.each do |k|
      k_bin = k.to_i(2)
      diff = (k_bin | bin_dig)
      sols << BIN_DIGITS[k] if diff == k_bin
    end
    sols
  end

  def filter_solutions 
    filtered = []
    if index = @exacts.index(nil)
      verify_solution index
    else
      @exacts.each_with_index do |val, i|
        verify_solution i
      end
    end
    filtered
  end

  def verify_checksum solution
    sol_reverse = solution.reverse
    total = sol_reverse.each_with_index.inject(0) do |sum, (digit,index)| 
      sum + ((index + 1) * digit) 
    end
    total % 11 == 0
  end

  def verify_solution index
    copy = @exacts.dup
    @temp_solutions[index].each do |s|
      copy[index] = s
      copy_str = copy.join
      if !@final_solutions.include?(copy_str) && verify_checksum(copy)
        @final_solutions << copy_str
      end
    end 
  end
end

class TestBankChecks < Minitest::Test
  def test_correct_value
    # testing with value "123456789"
    line1 = "    _  _     _  _  _  _  _ "
    line2 = "  | _| _||_||_ |_   ||_||_|"
    line3 = "  ||_  _|  | _||_|  ||_| _|"
    res = BankChecks.new.read_code(line1, line2, line3)
    assert_equal "123456789", res
  end

  def test_ambiguous_value
    # testing with value "490067715"
    line1 = "    _  _  _  _  _  _     _ "
    line2 = "|_||_|| || ||_   |  |  ||_ "
    line3 = "  | _||_||_||_|  |  |  | _|"
    res = BankChecks.new.read_code(line1, line2, line3)
    assert_equal "ambiguous", res
  end

  def test_failure_value
    # testing with value "888888888"
    line1 = " _  _  _  _  _  _  _  _  _ "
    line2 = "|_||_||_||_||_||_||_||_||_|"
    line3 = "|_||_||_||_||_||_||_||_||_|"
    res = BankChecks.new.read_code(line1, line2, line3)
    assert_equal "failure", res
  end

  def test_one_incomplete_value
    # testing with value "1nil3456789"
    line1 = "    _  _     _  _  _  _  _ "
    line2 = "  | _| _||_||_ |_   ||_||_|"
    line3 = "  | _  _|  | _||_|  ||_| _|"
    res = BankChecks.new.read_code(line1, line2, line3)
    assert_equal "123456789", res
  end
end

line1 = gets
line2 = gets
line3 = gets
puts BankChecks.new.read_code(line1, line2, line3)
