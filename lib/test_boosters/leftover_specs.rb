module LeftoverSpecs
  module_function

  def select(all_leftover_specs, thread_count, thread_index)
    all_leftover_specs = sort_by_size(all_leftover_specs)

    return [] if all_leftover_specs.empty?

    specs = all_leftover_specs
      .each_slice(thread_count)
      .reduce{ |acc, slice| acc.map{|a| a}.zip(slice.reverse) }
      .map{ |f| f.kind_of?(Array) ? f.flatten : [f] } [thread_index]

    if    specs.nil?            then []
    elsif specs.kind_of?(Array) then specs.compact
    end
  end

  def sort_by_size(specs) # descending
    specs
      .select { |f| File.file?(f) }
      .map{ |f| [f, File.size(f)] }
      .sort_by{ |a| a[1] }
      .map{ |a| a[0] }
      .reverse
  end


end
