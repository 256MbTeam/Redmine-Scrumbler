module Infector
 
end

Dir[File.join(File.dirname(__FILE__), "infector", "*.rb")].each{|file| 
  require_dependency file;
  infected_name = File.basename(file, ".rb").classify
  puts "#{file} #{infected_name}\n"*7
  _module = Infector.const_get(infected_name)
  _class = Kernel.const_get(infected_name)
  _class.send(:include, _module) unless _class.included_modules.include? _module
}