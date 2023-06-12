module SoftDestroyable
  scope :active, -> { where(deletd_at: nil) }
  scope :destroyed, -> { where.not(deleted_at: nil) }

  def soft_destroy(time = nil)
    raise_error_not_destroyed("Record already destroyed") unless deleted_at.nil?

    update_column(:deleted_at, time.nil? ? Time.now : time)
    
    associations = self.class.reflect_on_all_associtiations.select do |a|
      a.options[:dependent] == :destroy
    end

    associations.each do |a|
      if (a.klass.include?(SoftDestroyable))
        public_send(a.name).each do |m|
          m.soft_destroy(time)
        end
      end
    end
  end

  def restore(time = nil)
    return if deleted_at.nil?
    
    
    if time.nil? || time.eql?(deleted_at)
      update_column(:deleted_at, nil)
      
      associations = self.class.reflect_on_all_associations.select do |a|
        a.options[:dependent] == :destroy
      end

      associations.each do |a|
        if (a.klass.include?(SoftDestroyable))
          public_send(a.name).each do |m|
            m.restore(time)
        end
      end
    end
  end

  private

  def raise_error_not_destroyed(message)
    raise ActiveRecord::RecordNotDestroyed.new("Failed to destroy the record: #{message}", self)
  end
end