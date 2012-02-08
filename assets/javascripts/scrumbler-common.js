$from = function(v) {

	return function() {
		return v
	}
};

t = function(msg){
	return Scrumbler.Translations[msg];
}

Scrumbler.IssueTemplate = Class.create({
	initialize: function(config){
		this.config = Object.extend({
			class_name : 'scrumbler_issue'
		}, config);
		var el = new Element('div',{
			id : 'issue_'+this.config.issue.id,
			'class': this.config.class_name
		});
	
		this.getEl = $from(el);
		el.appendChild(this.createHeader());
		el.appendChild(this.createBody());
	},
	createHeader: function(){
		var header_div = new Element('div',{
			'class' : 'scrumbler_issue_heading'
		});

		var color_div = new Element('div',{
			'class' : 'scrumbler_issue_color',
			style: 'background: #'+this.config.tracker.color+';'
		});
		color_div.update("&nbsp;");
		var tracker_link = new Element('a',{
			href: Scrumbler.root_url+'projects/'+this.config.project_id+'/issues?tracker_id='+this.config.tracker.id
		});
		tracker_link.update(this.config.tracker.name);
		var issue_id_div = new Element('div',{
			'class' : 'scrumbler_issue_id'
		});

		var issue_link = new Element('a',{
			href: Scrumbler.root_url+'issues/'+this.config.issue.id
		});
		issue_link.update("#"+this.config.issue.id);
		issue_id_div.appendChild(issue_link);
		
		color_div.appendChild(tracker_link);
		color_div.appendChild(issue_id_div);
		 
		header_div.appendChild(color_div);
		return header_div;
	},
	createBody:function(){
		var body_div = new Element('div', {
			'class': 'scrumbler_issue_body'
		});
		
		var points_div = this.createPointsDiv(this.config);
		
		body_div.appendChild(points_div);
		
		var subject = new Element('p').update(this.config.issue.subject);
		
		body_div.appendChild(subject);
		
		return body_div;
	},
	createPointsDiv: function() {
		var points_div = new Element('div',{
			'class' : 'scrumbler_points' 
		});
		var points_value_span = new Element("span", {
			'class': 'scrumbler_points_value'
		});
		points_value_span.update("Points: "+this.config.issue.points);
		
		
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