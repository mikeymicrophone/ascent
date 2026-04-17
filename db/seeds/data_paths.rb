module SeedDataPaths
  module_function

  def primary_root
    Rails.root.join("db", "seeds", "ascent_seed_data")
  end

  def legacy_root
    Rails.root.join("db", "seeds", "data")
  end

  def roots
    [primary_root, legacy_root]
  end

  def file(*parts)
    roots.each do |root|
      candidate = root.join(*parts)
      return candidate if candidate.exist?
    end

    primary_root.join(*parts)
  end

  def glob(*parts)
    pattern = File.join(*parts)

    roots.flat_map do |root|
      Dir.glob(root.join(pattern))
    end.uniq
  end
end
