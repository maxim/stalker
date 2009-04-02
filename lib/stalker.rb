module Stalker
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def instance; end
    
    def stalk(*models)
      models.flatten!
      
      models.map do |m|
        m.add_stalker!(self)
      end
    end
    
    def add_stalker!(klass)
      establish_channels = ""
      for callback in ActiveRecord::Callbacks::CALLBACKS
        mole = :"notify_#{klass.to_s.underscore}_#{callback}"
        notify_stalker = :"#{callback.split('_', 2).join("_#{self.name.underscore}_")}"
        self.send(callback, mole)
        establish_channels += <<-end_code 
          def #{mole}
            #{klass}.send(:#{notify_stalker}, self) if #{klass}.respond_to?(:#{notify_stalker})
          end
        end_code
      end
      
      self.class_eval(establish_channels)
    end
  end
end

ActiveRecord::Base.send(:include, Stalker)