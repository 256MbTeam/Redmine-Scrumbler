$from = function(v) {

	return function() {
		return v
	}
};
    
Scrumbler.IssueTemplate = Class.create({
	initialize: function(config){
		
		var config = Object.extend({
			class_name : 'scrumbler_issue'
		}, config);
		var el = new Element('div',{
			id : 'issue_'+config.issue.id,
			'class': config.class_name
		});
	
		this.getEl = $from(el);
		el.appendChild(this.createHeader(config));

		el.appendChild(this.createBody(config));
		
	},
	createHeader: function(config){
		var header_div = new Element('div',{
			'class' : 'scrumbler_issue_heading'
		});

		var color_div = new Element('div',{
			'class' : 'scrumbler_issue_color',
			style: 'background: #'+config.tracker.color+';'
		});
		color_div.update("&nbsp;");
		var tracker_link = new Element('a',{
			href: Scrumbler.root_url+'projects/'+config.project_id+'/issues?tracker_id='+config.tracker.id
		});
		tracker_link.update(config.tracker.name);
		var issue_id_div = new Element('div',{
			'class' : 'scrumbler_issue_id'
		});

		var issue_link = new Element('a',{
			href: Scrumbler.root_url+'issues/'+config.issue.id
		});
		issue_link.update("#"+config.issue.id);
		issue_id_div.appendChild(issue_link);
		
		color_div.appendChild(tracker_link);
		color_div.appendChild(issue_id_div);
		 
		header_div.appendChild(color_div);
		return header_div;
	},
	createBody:function(config){
		var body_div = new Element('div', {
			'class': 'scrumbler_issue_body'
		});
		
		var points_div = this.createPointsDiv(config);
		
		body_div.appendChild(points_div);
		
		var subject = new Element('p').update(config.issue.subject);
		
		body_div.appendChild(subject);
		
		return body_div;
	},
	createPointsDiv: function(config) {
		var points_div = new Element('div',{
			'class' : 'scrumbler_points' 
		});
		var points_value_span = new Element("span", {
			'class': 'scrumbler_points_value'
		});
		points_value_span.update("Points: "+config.issue.points);
		
		
		points_div.appendChild(points_value_span);
		return points_div;
	}
});
    

        
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