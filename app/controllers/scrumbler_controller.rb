class ScrumblerController < ScrumblerAbstractController
  unloadable

#  before_filter :authorize, :only => [:settings]
  
  def index
    @versions
  end
  
end
