module SoftDestroyable
  extend ActiveSupport::Concern

  included do 
    scope :active, -> { where(deleted_at: nil) }
    scope :destroyed, -> { where.not(deleted_at: nil) }
  end

  def soft_destroy(time = nil)
    return self if !time.nil? && time.eql?(deleted_at)
    raise_error_not_destroyed("Record already destroyed") unless deleted_at.nil?
    
    associations = self.class.reflect_on_all_associations.select do |a|
      a.options[:dependent] == :destroy && a.klass.include?(SoftDestroyable)
    end

    result = transaction do
      time = time.nil? ? Time.zone.now.round(6) : time
      update_column(:deleted_at, time)

      associations.each do |a|
        public_send(a.name).unscope(where: :deleted_at).each do |m|
          m.soft_destroy(time)
        end
      end  
    end
    result ? self : false
  end

  def restore(time = nil)
    return if deleted_at.nil?
    
    
    if time.nil? || time.eql?(deleted_at)
      time = time.nil? ? deleted_at : time
      update_column(:deleted_at, nil)
      
      associations = self.class.reflect_on_all_associations.select do |a|
        a.options[:dependent] == :destroy && a.klass.include?(SoftDestroyable)
      end

      result = transaction do
        associations.each do |a|
          public_send(a.name).unscope(where: :deleted_at).each do |m|
            m.restore(time)
          end
        end
      end
      result ? self : false
    end
  end

  def raise_error_not_destroyed(message)
    raise ActiveRecord::RecordNotDestroyed.new("Failed to destroy the record: #{message}", self)
  end
end