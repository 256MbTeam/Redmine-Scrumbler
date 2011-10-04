module ScrumberHelper


  def select_color_tag(params)
    x_id = "color_#{params[:id]}"
    previev_element_id = "#{params[:id]}_preview"
    out = text_field_tag params[:name], params[:value], {
      :class => 'color_input',
      :x_id => x_id,
      :size => 6
    }
    out << "<div id='#{previev_element_id}' class='color_preview' style='background-color: #{params[:value]};'></div>"
    picker_config = {
      :color => params[:value],
      :previewElement => previev_element_id
    }.to_json
    
    out << javascript_tag("new colorPicker($$('input[x_id=#{x_id}]')[0], #{picker_config})")
  end
  
  def draw_scrumbler_dashboard(sprint)
    div_id = "dashboard_for_sprint_#{sprint.id}"
    config = {
      :sprint => sprint,
      :project => sprint.project,
      :statuses => sprint.scrumbler_sprint_statuses,
      :issues => sprint.issues,
      :url => project_scrumbler_sprint_url(sprint.project, sprint)
    }.to_json
    out = "<div id='#{div_id}'></div>"
    out << javascript_tag("new ScrumblerDashboard(#{div_id}, #{config})")
  end
  
  
  
end
