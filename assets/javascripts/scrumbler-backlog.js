var ScrumPointEditor = Class.create({
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
							element.firstChild.update(new_value);
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

var IssuesList = Class.create({

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
			"class" : "scrumbler_backlog_trackers"
		});
		trackers.each(function(tracker){
			trackers_map[tracker.id] = tracker; 
			var tracker_div = new Element("div", {
				"id" : tracker.id,
				"class" : "scrumbler_backlog_tracker",
				"style" : "background:#"+tracker.color+";"
			});
			tracker_div.update(tracker.name);
			trackers_div.appendChild(tracker_div);
		});
		
		parent_div.appendChild(trackers_div);

		var issues_div = new Element("div", {
			"class" : "scrumbler_backlog_issues"
		});

		issues.each(function(issue) {
			
			var tracker = trackers_map[issue.tracker_id];
			var issue_url = '/issues/'+issue.id;
			var tracker_url = '/projects/'+project_id+'/issues?tracker_id='+issue.tracker_id;
			  
			var issue_div = new Element("div", {
				"id" : "issue_" + issue.id,
				"class" : issue.disabled ? "disabled_scrumbler_issue" : "scrumbler_issue"
			});
			
			var issue_content = ISSUE_TEMPLATE.evaluate({
									issue_url: issue_url,
									tracker_url: tracker_url,
									tracker_name: tracker.name,
									issue_subject: issue.subject,
									issue_id: issue.id,
									color: tracker.color || '507AAA',
									points: issue.points
								});
			issue_div.update(issue_content);
			var points_div = issue_div.select('[class="scrumbler_points"]').first(); 
			new ScrumPointEditor(points_div, {
				value : issue.points,
				update_url: update_points_url,
				issue_id: issue.id
			});
			
			new Draggable(issue_div, {
				revert : true
			});
			issues_div.appendChild(issue_div);
		});
		
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
					}
					// Move issue to sprint
					else {
						this.issues = resp.sprint.issues;
						this.backlog.issues = resp.backlog.issues;
						this.renderIssueList(source_div, resp.backlog);
						this.renderIssueList(target_div, resp.sprint);
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
	
	

	
var BacklogIssuesList = Class.create(IssuesList, {
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
var SprintIssuesList = Class.create(IssuesList, {
	initialize: function($super, backlog, config){
		this.backlog = backlog;
		return $super(config);
	}
});
	
	
	


	