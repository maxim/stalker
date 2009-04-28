module ShouldStalkMacros
  def should_stalk(*models)
    klass = self.name.gsub(/Test$/, '').constantize
    notifier = "notify_#{klass.name.underscore}"
    
    context "#{klass}" do
      models.each do |model_klass|
        should "stalk #{model_klass}" do
          assert model_klass.instance_methods.find{|meth| meth =~ /#{notifier}/}, "Model #{model_klass} is not being stalked."
        end
      end
    end
  end
end

class ActiveSupport::TestCase
  extend ShouldStalkMacros
end