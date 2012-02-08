
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