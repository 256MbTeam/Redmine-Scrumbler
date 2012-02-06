Scrumbler.ScrumPointEditor = Class.create({
    initialize: function(element, options){
        this.options = Object.extend({
        	value: "?",
            element_classname: "scrum-points-element",
            popup_classname: "scrum-points-popup",
            popup_width: "188px",
            popup_height: "38px",
            values: ["?", "0", "0.5", "1", "2", "3", "5", "8", "13", "20", "40", "100"]
        }, options);
        var popup = this.createPopup(element, this.options);
        
        element.observe("click", function(event){
            popup.toggle();      
            return;
        });
        element.appendChild(popup);
    },
    createPopup: function(element, options){
    	var new_value = options.value;
    	var update_url = options.update_url;
    	var popup = new Element('div',{
    		'class' : options.popup_classname 
    	});
    	
    	popup.setStyle({
        	display: 'none',
            width: options["popup_width"],
            height: options["popup_height"]
        });
        
        options.values.each(function(value){
        	 var value_field = new Element('div',{
                'class' : options.element_classname
            });
            value_field.update(value);
            value_field.observe("click", function(event){
            	new_value = value;
				new Ajax.Request(update_url, {
					method : 'post',
					parameters : {
						'issue_id' : options.issue_id,
						'points' : new_value,
					},
					onSuccess : function(transport) { 
						var resp = transport.responseJSON;
						if(resp.success) {
							element.select('[class="scrumbler_points_value"]').first().update(new_value);
						}else {
							$growler.growl(resp.text, {
								header : 'Ошибка'
							});
						}
					},
					onFailure : function() {
						$growler.growl('Something went wrong...', {
							header : 'Error'
						});
					},
					onComplete: function(){
						popup.hide();
					}
					
				});
            	
            });
            popup.appendChild(value_field);
        });
        return popup;
        
    }
});

Scrumbler.IssueBacklogTemplate = Class.create(Scrumbler.IssueTemplate,{
	createPointsDiv: function(config) {
    		var points_div = new Element('div',{
    			'class' : 'scrumbler_points' 
    		});
    		
    		points_div.appendChild(new Element("span").update("Points: "));
    		
    		var points_value_span = new Element("span", {
    			'class': 'scrumbler_points_value'
    		});
    		points_value_span.update(config.issue.points);
    		
    		points_div.appendChild(points_value_span);
    		
    		this.getEl().addClassName("scrumbler_issue_backlog");

			new Scrumbler.ScrumPointEditor(points_div, {
				value : config.issue.points,
				update_url: Scrumbler.root_url+'projects/'+config.project_id+'/scrumbler_backlogs/update_scrum_points',
				issue_id: config.issue.id
			});
    		
    		return points_div;
    	}
}); 

Scrumbler.IssuesList = Class.create({

	initialize: function(config) {
		this.issues = config.issues;
		this.trackers = config.trackers;
		this.parent = $(config.parent_id);
		this.sprint_id = config.sprint_id;
		
		this.url = config.url;
		this.project_id = config.project_id;
		this.update_points_url = config.update_points_url;
		
		this.renderIssueList(this.parent, config);
		Droppables.add(this.parent, {
			accept : 'scrumbler_issue',
			onDrop : this.onDrop.bind(this)
		});
	},
	renderIssueList: function(parent_div, config) {
		var issues = config.issues;
		var trackers = config.trackers;
		var project_id = config.project_id;
		var update_points_url = config.update_points_url;
		var trackers_map = {};
		
		parent_div.update("");
	
		var trackers_div = new Element("div", {
			"class" : "scrumbler_backlog_trackers", 
			style: "padding-left: 1em;"
		});
		trackers.each(function(tracker){
			trackers_map[tracker.id] = tracker; 
			var tracker_div = new Element("span", {
				"id" : tracker.id,
				"class" : "scrumbler_backlog_tracker",
				style: "border-bottom: 5px solid #"+tracker.color+";"
				
			});
			tracker_div.update(tracker.name);
			trackers_div.appendChild(tracker_div);
		});
		
		parent_div.appendChild(trackers_div);

		var issues_div = new Element("div", {
			"class" : "scrumbler_backlog_issues"
		});
		
		if(issues.length == 0){
			issues_div.appendChild(new Element('p',{'class':'nodata'}).update(Scrumbler.Translations.nodata));
		}
		else{
			issues.each(function(issue) {
				
				var issue_div = new Scrumbler.IssueBacklogTemplate({
					'project_id': project_id,
					'tracker': trackers_map[issue.tracker_id],
					'issue': issue,
					class_name : issue.disabled ? "disabled_scrumbler_issue" : "scrumbler_issue"
				}).getEl();
	
				new Draggable(issue_div, {
					revert : true
				});
				issues_div.appendChild(issue_div);
			});
		}
		parent_div.appendChild(issues_div);
	},
	onDrop : function(issue_div, target_div, event) {
		var issue_id = getRealId(issue_div.id);
		var source_div = issue_div.parentNode.parentNode
		if(source_div == target_div) {
			return;
		}

		issue_div.hide();
		new Ajax.Request(this.url, {
			method : 'post',
			parameters : {
				'issue_id' : issue_id,
				'sprint_id' : this.sprint_id,
			},
			onSuccess : function(transport) { 
				
				var resp = transport.responseJSON;
				if(resp.success) {
					// Move issue to backlog
					if(this.sprint_id === undefined) {
						this.issues = resp.backlog.issues;
						this.selected_sprint.issues = resp.sprint.issues;
						this.renderIssueList(target_div, resp.backlog);
						this.renderIssueList(source_div, resp.sprint);
						this.sprintSelected(resp.sprint);
					}
					// Move issue to sprint
					else {
						this.issues = resp.sprint.issues;
						this.backlog.issues = resp.backlog.issues;
						this.renderIssueList(source_div, resp.backlog);
						this.renderIssueList(target_div, resp.sprint);
						this.backlog.sprintSelected(resp.sprint);
					}
				} else {
					$growler.growl(resp.text, {
						header : 'Ошибка'
					});
				}

			}.bind(this),
			onFailure : function() {
				$growler.growl('Something went wrong...', {
					header : 'Error'
				});
			},
			onComplete : function() {
				issue_div.show();
			}
		});
	}
});
	
Scrumbler.BacklogIssuesList = Class.create(Scrumbler.IssuesList, {
	sprintSelected: function(sprint){
		this.selected_sprint = sprint;
		this.issues.each(function(issue){
			issue.disabled = !containsById(sprint.trackers, issue.tracker_id);
		});
		this.renderIssueList(this.parent, {
			"issues" : this.issues,
			"trackers" : this.trackers,
			"project_id" : this.project_id,
			"update_points_url": this.update_points_url	
			}
		);
	}
});
Scrumbler.SprintIssuesList = Class.create(Scrumbler.IssuesList, {
	initialize: function($super, backlog, config){
		this.backlog = backlog;
		return $super(config);
	}
});
	
	
Scrumbler.SprintSelector = Class.create({
	initialize: function(config){
		var sprint_selector = new Element('select',{
			id: 'scrumbler_sprint_id'
		});
		sprint_selector.observe('change',function(event){
			var url = Scrumbler.root_url+'projects/'+config.project_id+'/scrumbler_backlogs/select_sprint';
			console.log(url)
			new Ajax.Request(url,{
				method: 'post',
				parameters: {
					'sprint_id':sprint_selector.value
				},
				onSuccess : function(transport) { 
				
					var resp = transport.responseJSON;
					if(resp.success) {
						backlog_list.sprintSelected(resp.sprint);
						sprint_list.sprint_id = resp.sprint.sprint_id;
						sprint_list.renderIssueList($('sprint_list'), resp.sprint);
					} else {
						$growler.growl(resp.text, {
							header : 'Ошибка'
						});
					}

				}.bind(this),
				onFailure : function() {
					$growler.growl('Something went wrong...', {
						header : 'Error'
					});
			}
			});
		});
		config.sprints.each(function(sprint){
			var option = new Element('option',{value: sprint.id}).update(sprint.name);
			sprint_selector.appendChild(option);
		});
		this.el = sprint_selector;
	}
});