module LeftoverFiles
  module_function

  def self.select(all_leftover_files, thread_count, thread_index)
    all_leftover_files = sort_by_size(all_leftover_files)

    return [] if all_leftover_files.empty?

    files = all_leftover_files
      .each_slice(thread_count)
      .reduce{ |acc, slice| acc.map{|a| a}.zip(slice.reverse) }
      .map{ |f| f.kind_of?(Array) ? f.flatten : [f] } [thread_index]

    if    files.nil?            then []
    elsif files.kind_of?(Array) then files.compact
    end
  end

  def self.sort_by_size(files) # descending
    files
      .select { |f| File.file?(f) }
      .map{ |f| [f, File.size(f)] }
      .sort_by{ |a| a[1] }
      .map{ |a| a[0] }
      .reverse
  end


end
