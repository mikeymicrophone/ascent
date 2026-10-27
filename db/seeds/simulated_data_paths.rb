module SimulatedSeedDataPaths
  module_function

  def root
    Rails.root.join("db", "seeds", "simulated", "data")
  end

  def file(*parts)
    root.join(*parts)
  end
end
