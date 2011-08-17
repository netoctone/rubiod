class GappedNumHash
  def initialize
    @nums_gaps = [] # consists of: [num_or_range, val]
  end

  def last_index
    if last = @nums_gaps.last
      num_or_range = last[0]
      num_or_range.is_a?(Range) ? num_or_range.last : num_or_range
    end
  end

  # returns pair [num_or_range, val] or nil
  def at num
    found = find_pair num
    found[0] && [found[0], found[1]]
  end

  # returns pair [num_or_range, val] or nil
  def delete_at num
    found = find_pair num
    if found[0]
      @nums_gaps.delete_at found[2]
      [found[0], found[1]]
    else
      nil
    end
  end

  # TODO: num belongs to range case
  # returns pair [num, val]
  def insert_after num, val
    found = find_pair num
    ins_ind = found[2]+1
    pair = [num, val]
    @nums_gaps[ins_ind...ins_ind] = [pair]
    (ins_ind...@nums_gaps.size).each do |i|
      pair = @nums_gaps[i]
      num_or_range = pair[0]
      if num_or_range.is_a? Range
        pair[0] = num_or_range.first+1..num_or_range.last+1
      else
        pair[0] = num_or_range+1
      end
    end
    pair
  end

  # num must belong to range
  # val_hash - { :left => smth, :mid => smth, :right => smth }
  def insert_split num, val_hash
    old_range, old_val, ind = find_pair(num)
    raise ArgumentError unless old_range.is_a? Range
    new_pairs = []
    left_range_size = num - old_range.first
    if left_range_size == 1
      new_pairs << [old_range.first, val_hash[:left]]
    elsif left_range_size > 1
      new_pairs << [old_range.first..ind-1, val_hash[:left]]
    end
    new_pairs << [num, val_hash[:mid]]
    right_range_size = old_range.last - num
    if right_range_size == 1
      new_pairs << [old_range.last, val_hash[:right]]
    elsif right_range_size > 1
      new_pairs << [ind+1..old_range.last, val_hash[:right]]
    end
    @nums_gaps[ind..ind] = new_pairs
  end

  # returns pair [num_or_range, val] or nil (when range overlaps existing)
  def insert num_or_range, val
    if num_or_range.is_a? Range
      left = find_pair(num_or_range.first)
      right = find_pair(num_or_range.last)
      unless left[0] || right[0]
        if left[1] == right[1]
          pair = [num_or_range, val]
          @nums_gaps[left[1]...left[1]] = [pair]
          pair
        else
          nil
        end
      else
        nil
      end
    else
      [num_or_range, self.[]=(num_or_range, val)]
    end
  end

  # returns val or nil
  def [] num
    found = find_pair num
    found[0] && found[1]
  end

  # if num belongs to range, last one will be splitted
  # returns val
  def []= num, val
    found = find_pair num
    case found[0]
    when Numeric
      @nums_gaps[found[2]] = val
    when Range
      insert_split num, { :left => found[1], :mid => val, :right => found[1] }
      val
    when nil
      @nums_gaps[found[1]...found[1]] = [[num, val]]
      val
    end
  end

  private

  def find_pair num
    find_pair_iter num, 0, @nums_gaps.size-1
  end

  # returns [num_or_range, val, index] or [nil, l_ind]
  def find_pair_iter num, l_ind, r_ind
    return [nil, l_ind] if l_ind > r_ind

    test_ind = (l_ind + r_ind)/2
    test_pair = @nums_gaps[test_ind]
    test_key = test_pair[0]
    if test_key === num
      [test_pair, test_ind].flatten 1
    else
      compare_num = test_key.is_a?(Range) ? test_key.first : test_key
      if num < compare_num
        find_pair_iter num, l_ind, test_ind-1
      else
        find_pair_iter num, test_ind+1, r_ind
      end
    end
  end
end
