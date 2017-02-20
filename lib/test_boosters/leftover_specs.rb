module LeftoverSpecs
  def self.select(all_leftover_specs, thread_count, thread_index)
    all_leftover_specs = sort_by_size(all_leftover_specs)

    return [] if all_leftover_specs.empty?

    specs = all_leftover_specs
      .each_slice(thread_count)
      .reduce{|acc, slice| acc.map{|a| a}.zip(slice.reverse)}
      .map{|f| if f.kind_of?(Array) then f.flatten else [f] end} [thread_index]

    if    specs.nil?            then []
    elsif specs.kind_of?(Array) then specs.compact
    end
  end

  def self.sort_by_size(specs) # descending
    specs
      .map{|f| if File.file?(f) then f else nil end}
      .compact
      .map{|f| [f, File.size(f)]}
      .sort_by{|a| a[1]}.map{|a| a[0]}.reverse
  end


end
