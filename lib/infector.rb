Dir[File.join(File.dirname(__FILE__), "infectors", "*.rb")].each{|file| 
  require_dependency file;
  infected_name = File.basename(file, ".rb").classify
  puts "Infected #{infected_name} with #{file} "
  _module = Scrumbler::Infectors.const_get(infected_name)
  _class = Kernel.const_get(infected_name)
  _class.send(:include, _module) unless _class.included_modules.include? _module
}