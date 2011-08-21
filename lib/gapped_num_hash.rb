class GappedNumHash
  def initialize
    @pairs = [] # consists of [key, val]; key - [Range] x..y
  end

  def each &block
    block ? @pairs.each(&block) : @pairs.each
  end

  def last_index
    last = @pairs.last
    last[0].last if last
  end

  # returns pair [key, val] or nil
  def at num
    key, val = find_pair num
    key && [key, val]
  end

  # num must belong to non-atom key, and it's 'width' must be > +by+
  # returns pair [key, val]
  def taper num, by=1
    key, some_val, ind = find_pair num
    raise ArgumentError if key.nil? || key.count <= by

    @pairs[ind][0] = key.first+by..key.last
    move_keys -by, ind
    @pairs[ind]
  end

  # returns pair [key, val] or nil
  def delete num
    key, val, ind = find_pair num
    if key
      move_keys -1, ind
      @pairs.delete_at ind
      [key, val]
    end
  end

  # num must belong to atom key
  # returns pair [key, val]
  def insert_after num, val
    key, some_val, ind = find_pair num
    raise ArgumentError unless key && key.atom?

    ins_ind = ind + 1
    pair = [num..num, val]
    @pairs[ins_ind...ins_ind] = [pair]
    move_keys 1, ins_ind
    pair
  end

  # num must belong to non-atom key
  # val_hash - { :left => smth, :mid => smth, :right => smth }
  def insert_split num, val_hash
    key, some_val, ind = find_pair(num)
    raise ArgumentError if key.nil? || key.atom?

    new_pairs = []
    new_pairs << [key.first..num-1, val_hash[:left]] if num > key.first
    new_pairs << [num..num, val_hash[:mid]]
    new_pairs << [num+1..key.last, val_hash[:right]] if num < key.last

    @pairs[ind..ind] = new_pairs
  end

  # returns pair [key, val] or nil (when new key overlaps existing ones)
  def insert num_or_range, val
    key = Range(num_or_range)
    unless key.atom?
      left, right = find_pair(key.first), find_pair(key.last)
      unless left[0] || right[0]
        if left[1] == right[1]
          pair = [key, val]
          @pairs[left[1]...left[1]] = [pair]
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
    key, val = find_pair num
    key && val
  end

  # may cause splitting
  # returns val
  def []= num, val
    f = find_pair num
    key = f[0]
    if key
      if key.atom?
        @pairs[f[2]] = val
      else
        insert_split num, { :left => f[1], :mid => val, :right => f[1] }
        val
      end
    else # can make gaps between keys - quite unsafe
      @pairs[f[1]...f[1]] = [[num..num, val]]
      val
    end
  end

  private

  def move_keys direction, start_index=0
    (start_index...@pairs.size).each do |i|
      pair = @pairs[i]
      pair[0] = pair[0].move direction
    end
  end

  def find_pair num
    find_pair_iter num, 0, @pairs.size-1
  end

  # returns [key, val, index] or [nil, l_ind]
  def find_pair_iter num, l_ind, r_ind
    return [nil, l_ind] if l_ind > r_ind

    test_ind = (l_ind + r_ind)/2
    test_pair = @pairs[test_ind]
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
