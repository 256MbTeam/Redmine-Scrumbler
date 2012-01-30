var IssuesList = Class.create({

	initialize: function(config) {
		this.issues = config.issues;
		this.trackers = config.trackers;
		this.parent = $(config.parent_id);
		this.sprint_id = config.sprint_id;
		this.url = config.url;
		this.project_id = config.project_id;
		
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
			"project_id" : this.project_id			
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
	
	
	


	