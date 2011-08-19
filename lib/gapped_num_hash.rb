class GappedNumHash
  def initialize
    @nums_gaps = [] # consists of: [key, val]
  end

  def each &block
    block ? @nums_gaps.each(&block) : @nums_gaps.each
  end

  def last_index
    last = @nums_gaps.last
    last[0].last if last
  end

  # returns pair [key, val] or nil
  def at num
    found = find_pair num
    found[0] && [found[0], found[1]]
  end

  # returns pair [key, val] or nil
  def delete_at num
    found = find_pair num
    if found[0]
      @nums_gaps.delete_at found[2]
      [found[0], found[1]]
    else
      nil
    end
  end

  # num must belong to atom key
  # returns pair [key, val]
  def insert_after num, val
    f = find_pair num
    raise ArgumentError unless f[0].atom?

    ins_ind = f[2] + 1
    pair = [num..num, val]
    @nums_gaps[ins_ind...ins_ind] = [pair]
    (ins_ind...@nums_gaps.size).each do |i|
      cur_pair = @nums_gaps[i]
      cur_pair[0] = cur_pair[0].move 1
    end
    pair
  end

  # num must belong non-atom key
  # val_hash - { :left => smth, :mid => smth, :right => smth }
  def insert_split num, val_hash
    key, old_val, ind = find_pair(num)
    raise ArgumentError if key.atom?

    new_pairs = []
    new_pairs << [key.first..num-1, val_hash[:left]] if num > key.first
    new_pairs << [num..num, val_hash[:mid]]
    new_pairs << [num+1..key.last, val_hash[:right]] if num < key.last

    @nums_gaps[ind..ind] = new_pairs
  end

  # returns pair [key, val] or nil (when new key overlaps existing ones)
  def insert num_or_range, val
    key = Range(num_or_range)
    unless key.atom?
      left, right = find_pair(key.first), find_pair(key.last)
      unless left[0] || right[0]
        if left[1] == right[1]
          pair = [key, val]
          @nums_gaps[left[1]...left[1]] = [pair]
          pair
        else
          nil
        end
      else
        nil
      end
    else
      [key, self.[]=(key.first, val)]
    end
  end

  # returns val or nil
  def [] num
    found = find_pair num
    found[0] && found[1]
  end

  # may cause splitting
  # returns val
  def []= num, val
    f = find_pair num
    key = f[0]
    if key
      if key.atom?
        @nums_gaps[f[2]] = val
      else
        insert_split num, { :left => f[1], :mid => val, :right => f[1] }
        val
      end
    else
      @nums_gaps[f[1]...f[1]] = [[num..num, val]]
      val
    end
  end

  private

  def find_pair num
    find_pair_iter num, 0, @nums_gaps.size-1
  end

  # returns [key, val, index] or [nil, l_ind]
  def find_pair_iter num, l_ind, r_ind
    return [nil, l_ind] if l_ind > r_ind

    test_ind = (l_ind + r_ind)/2
    test_pair = @nums_gaps[test_ind]
    test_key = test_pair[0]
    if test_key.include? num
      [test_pair, test_ind].flatten 1
    else
      if num < test_key.first
        find_pair_iter num, l_ind, test_ind-1
      else
        find_pair_iter num, test_ind+1, r_ind
      end
    end
  end
end
