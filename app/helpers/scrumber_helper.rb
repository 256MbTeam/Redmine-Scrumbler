module ScrumberHelper
 
  def draw_statuses_on_dashboard(statuses)
    statuses.map {|status| 
      "<th class='issue_status_#{status.id} #{cycle 'odd', 'even'}'>#{status.name}</th>" 
    }.join
  end
  
  def draw_issue_on_dashboard(issue, statuses)
    statuses.map {|status| 
      draw_issue_status_on_dashboard(issue, status) 
    }.join
  end
  
  def select_color_tag(params)
    out = "<input type='text' id='#{params[:id]}' name='#{params[:name]}' class='color_input' value='#{params[:value]}' size='6'> <div id='#{params[:id]}_preview' class='color_preview' style='background-color: #{params[:value]};'></div>"
    out << javascript_tag("new colorPicker('#{params[:id]}',{color:'#{params[:value]}', previewElement:'#{params[:id]}_preview'})")
  end
  
  private
  def draw_issue_status_on_dashboard(issue, status)
    fill = if issue.status_id == status.id 
      render :partial => 'issue', :object => issue
    else
      '&nbsp;'
    end
    "<td class='issue_status_#{status.id}' id='issue_status_#{status.id}_for_#{issue.id}'>#{fill}</td>"
  end
  
end
