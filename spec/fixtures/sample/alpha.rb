require_relative "beta"

module Sample
  class Alpha

    def alpha
      self
    end

    def beta
      Beta.new.beta
    end

    def beta_gamma
      beta.gamma
    end

  end
end
