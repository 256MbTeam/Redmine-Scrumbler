module ScrumberHelper


  def select_color_tag(params)
    out = "<input type='text' id='#{params[:id]}' name='#{params[:name]}' class='color_input' value='#{params[:value]}' size='6'> <div id='#{params[:id]}_preview' class='color_preview' style='background-color: #{params[:value]};'></div>"
    out << javascript_tag("new colorPicker('#{params[:id]}',{color:'#{params[:value]}', previewElement:'#{params[:id]}_preview'})")
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
