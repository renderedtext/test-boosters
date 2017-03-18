module TestBoosters
  module LeftoverFiles
    module_function

    def select(all_leftover_files, thread_count, thread_index)
      all_leftover_files = sort_descending_by_size(all_leftover_files)

      return [] if all_leftover_files.empty?

      files = all_leftover_files
        .each_slice(thread_count)
        .reduce { |acc, slice| acc.map { |a| a }.zip(slice.reverse) }
        .map { |f| f.is_a?(Array) ? f.flatten : [f] } [thread_index]

      if    files.nil?            then []
      elsif files.is_a?(Array) then files.compact
      end
    end

    def sort_descending_by_size(files)
      files
        .select { |f| File.file?(f) }
        .map { |f| [f, File.size(f)] }
        .sort_by { |a| a[1] }
        .map { |a| a[0] }
        .reverse
    end

  end
end
