    var ISSUE_TEMPLATE = new Template(
    "<div class='scrumbler_issue_heading' >\n\
            <div class='scrumbler_issue_color' style='background: ##{color};'>&nbsp;\n\
                <a href='#{tracker_url}'>#{tracker_name}</a>\n\
                <div class='scrumbler_issue_id'>\n\
                    <a href='#{issue_url}'>##{issue_id}</a>\n\
                </div>\n\
            </div>\n\
        </div>\n\
        <div class='scrumbler_issue_body'>\n\
            <div class='scrumbler_points'>Points: <span class='scrumbler_points_value'>#{points}</span></div>\n\
            #{issue_subject}\n\
        </div>");
    $from = function(v) {
      return function() {
        return v
      }
    };
        
	function getRealId(id) {
		var splitted = id.split("_");
		return splitted.last();
	};
	
	function containsById(collection, id){
		var return_value = false;
		collection.each(function(element){
				if(element.id == id){
					return_value = true;
				}
		});
		return return_value;
	};