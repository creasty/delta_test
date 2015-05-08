require_relative "gamma"

module Sample
  class Beta

    def beta
      self
    end

    def gamma
      Gamma.new.gamma
    end

  end
end
