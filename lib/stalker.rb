module Stalker
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def instance; end
    
    def stalk(*models)
      options = models.extract_options!
      models.flatten!
      
      models.map do |m|
        m.add_stalker!(self, options)
      end
    end
    
    def add_stalker!(klass, options = {})
      stalkee = options[:group] || self.name.underscore
      establish_channels = ""
      
      for callback in ActiveRecord::Callbacks::CALLBACKS
        mole = :"notify_#{klass.to_s.underscore}_#{callback}"
        notify_stalker = :"#{callback.split('_', 2).join("_#{stalkee.downcase}_")}"
        self.send(callback, mole)
        establish_channels += <<-end_code 
          def #{mole}
            #{klass}.#{notify_stalker}(self) if #{klass}.respond_to?(:#{notify_stalker})
          end
        end_code
      end
      
      self.class_eval(establish_channels)
    end
  end
end

ActiveRecord::Base.send(:include, Stalker)