
/**
 * Send AJAX request and update HTML Element - observer
 * 
 * Usage:       	
 *	new UpdateIssuePointsRequest({
 *       		'issue_id' : issue.id, 
 *       		'points' : points,
 *       		'observer' : observer,
 *       		'popup' : popup
 *       	});
**/
Scrumbler.Backlog = (function() {
	
var UpdateIssuePointsRequest = Class.create(Ajax.Request, {
	initialize: function($super, config){
		var url = Scrumbler.root_url+'projects/'+config.project_id+'/scrumbler_backlogs/update_scrum_points';
		$super(url, {
			method : 'post', 
			parameters : {
				'issue_id' : config.issue_id,
				'points' : config.points
			},
			onSuccess : function(transport) {
				var response = transport.responseJSON;
				if(response.success) {
					config.observer.update(config.points);
				}else{
					// TODO create localizations for header
					$growler.growl(resp.text, { header : 'Ошибка' });
				}
			},
			onFailure : function() {
				// TODO display more details about error 
				$growler.growl('Something went wrong...', { header : 'Error' });
			},
			onComplete: function(){ config.popup.hide(); }
		});
	}
});

/**
 * Create popup element for scrum points selection.
 * 
 * Usage:
 * 	var editor = new ScrumPointEditor({
 *		update_url: Scrumbler.root_url+'projects/'+config.project_id+'/scrumbler_backlogs/update_scrum_points'
 *	});
 * 
 *  editor.enableForElement($('some_div_id'), {"id" : some_issue_id});
**/
var ScrumPointEditor = Class.create({
    initialize: function(config){
        this.config = Object.extend({
            element_classname: "scrum-points-element",
            popup_classname: "scrum-points-popup",
            popup_width: "188px",
            popup_height: "38px",
            values: ["?", "0", "0.5", "1", "2", "3", "5", "8", "13", "20", "40", "100"]
        }, config);
        
        this.el = this.createPopup(config);
    },
	createPopup: function(){
		var popup = new Element('div',{ 'class' : this.config.popup_classname });
		popup.setStyle({
        	display: 'none',
            width: this.config.popup_width,
            height: this.config.popup_height
        });
        this.config.values.each(function(value){
        	var value_field = this.createPopupOptionEl(value);
            popup.appendChild(value_field);
        }, this);
        return popup;
    },
    createPopupOptionEl: function(value){
    	var value_div = new Element('div', { 'class' : this.config.element_classname }).update(value);
    	
	  	value_div.observe("click", function(event) {
        	new UpdateIssuePointsRequest({
        		project_id: this.config.project_id,
        		issue_id: this.current_issue.id, 
        		points: value,
        		observer: this.observer,
        		popup: this.el
        	});
        }.bind(this));
    	return value_div;
    },
    // enable point editor for element     
    enableForElement: function(element, issue){
    	var parentNode = this.el.parentNode;
    	element.observe("click", function(event){
    		if(parentNode == element.parentNode){
    			this.el.toggle();
    			return;
    		}
			// change current issue, that will be edited
    		this.current_issue = issue;
    		this.observer = element;
    		
    		this.el.hide();
    		// remove from previews edited element
    		if(parentNode){ parentNode.removeChild(this.el); }
    		element.parentNode.appendChild(this.el);
            this.el.show();
        }.bind(this));
	}
});

/**
 * Generate HTML Element for single Issue
 */
var IssueBacklogTemplate = Class.create(Scrumbler.IssueTemplate,{
	// create HTML element for point rendering and editing
	createPointsDiv: function() {
		var points_div = new Element('div',{'class' : 'scrumbler_points'});
		points_div.appendChild(new Element("span").update("Points: "));
		var points_value_span = new Element("span", {'class': 'scrumbler_points_value'}).update(this.config.issue.points);
		points_div.appendChild(points_value_span);

		// make point element editable for ScrumPointEditor
		var points_editor = this.config.points_editor;
		points_editor.enableForElement(points_value_span, {"id" : this.config.issue.id});		
				
		this.getEl().addClassName("scrumbler_issue_backlog");
		return points_div;
	}
}); 

/**
 * Create ui element for tracker displaying
 */
var TrackersListUI = Class.create({
	// Create trackers ui element 	
	initialize: function(trackers, config){
		this.config = Object.extend({
			collection_class_name : "scrumbler_backlog_trackers",
			element_class_name : "scrumbler_backlog_tracker",
		}, config);
		
		this.trackers = trackers;
		this.el = this.createUI();
		this.drawTrackers();
	},
	// create DOM Element
	createUI: function(){
		var collection_class_name = this.config.collection_class_name;
		return new Element("div", {"class" : collection_class_name });
	},
	// update trackers list and repaint	
	update: function(trackers){
		this.trackers = trackers;
		this.drawTrackers();
	},
	// repaint tracker list from this.trackers data
	drawTrackers: function(){
		var trackers_div = this.el.update("");
		this.trackers.each(function(tracker){
			var tracker_el = this.createTrackerEl(tracker);
			trackers_div.appendChild(tracker_el);
		},this);
	},
	// create tracker ui element
	createTrackerEl: function(tracker){
		var element_class_name = this.config.element_class_name;
		var tracker_el = new Element("span", {"id" : tracker.id, "class" : element_class_name, style: "border-bottom: 5px solid #"+tracker.color+";"}).update(tracker.name);
		return tracker_el;
	}
});


/** 
 *Create HTML Element for displaying issues list. User to display sprint and backlog issues.
 **/
var IssuesListUI = Class.create({
	// Create issue ui element
	initialize: function(issues, config) {
		this.config = Object.extend({
			list_class_name : "scrumbler_backlog_issues",
			issue_class_name : "scrumbler_issue",
			disabled_issue_class_name : "disabled_scrumbler_issue"
		}, config);
		
		this.issues = issues;
		this.el = this.createUI();
		this.editor = new ScrumPointEditor({
 			project_id: this.config.project_id
 		});
 		
 		Droppables.add(this.el, {
			accept : this.config.issue_class_name,
			onDrop : this.onDrop.bind(this)
		});
		
		this.drawIssues();
	},
	// create DOM Element
	createUI: function(){
		var list_class_name = this.config.list_class_name;
		var issues_div = new Element("div", { "class" : list_class_name });
		return issues_div;
	},
	// update issues list and repaint 	
	update: function(issues){
		this.issues = issues;
		this.drawIssues();
	},
	// repaint issues list from this.issue data
	drawIssues: function(){
		var issues_div = this.el.update("");
		if(this.issues.length == 0){
			// TODO Extract transaction strings to this.config 			
			issues_div.appendChild(new Element('p',{'class':'nodata'}).update(t('nodata')));
		}else{
			this.issues.each(function(issue) {
				var issue_div = this.createIssueEl(issue);
				issues_div.appendChild(issue_div);
			}, this);
		}
	},
	// create issue ui element
	createIssueEl: function(issue){
		var issue_div = new IssueBacklogTemplate({
					'project_id': this.config.project_id,
					'tracker': issue.tracker,
					'issue': issue,
					'class_name' : issue.disabled ? this.config.disabled_issue_class_name : this.config.issue_class_name,
					'points_editor' : this.editor
				}).getEl();
		
		new Draggable(issue_div, { revert : true });
		
		return issue_div;
	},
	onDrop: function(issue_div, target_div, event){
		var issue_id = getRealId(issue_div.id);

		var source_div = issue_div.parentNode;
		if(source_div == target_div) {
			return;
		}
		issue_div.hide();
		this.el.fire('issue:drop', { id: issue_id, source: issue_div });
	}
});

var SelectSprintRequest = Class.create(Ajax.Request,{
	initialize: function($super, config){
		this.config = Object.extend({}, config);
		var selector = this.config.selector;
		var url = Scrumbler.root_url+'projects/'+this.config.project_id+'/scrumbler_backlogs/select_sprint';
		$super(url,{ method: 'post',
				parameters: { 'sprint_id': selector.value },
				onSuccess : function(transport) { 
					var resp = transport.responseJSON;
					if(resp.success) {
						selector.fire('sprint:selected', resp.sprint);
					} else {
						$growler.growl(resp.text, { header : 'Ошибка' });
					}
				}.bind(this),
				onFailure : function() {
					// TODO More details
					$growler.growl('Something went wrong...', { header : 'Error' });
				}
			});
	}
});

/**
 * Create HTML Select element for sprints. Observe change actionm and send request on it. 
 * After success sprint selected fire "sprint:selected" event.
 * 
 * Usage:
 * 	new SprintSelector({
 * 									project_id: project_id,
 * 								 	sprints: [
 * 												{ id:1, name:"name1" },
 * 												{ id:2, name:"name2" }
 * 											]
 * 								});
 */
var SprintSelector = Class.create({
	initialize: function(config){
		this.config = Object.extend({
			selector_id: 'scrumbler_sprint_id'
		}, config);
		var sprint_selector = new Element('select', { id: this.config.selector_id });
		
		if(this.config.sprints.length == 0){
			// TODO Extract transaction strings to this.config 			
			this.el = new Element('p',{'class':'nodata'}).update(t('nodata'));
			return;
		}
		
		// Populate selector with avaliable options
		config.sprints.each(function(sprint){
			var option = new Element('option',{value: sprint.id}).update(sprint.name);
			sprint_selector.appendChild(option);
		});
		
		// Send request on sprint selected
		sprint_selector.observe('change', function(event){
			new SelectSprintRequest({
				project_id: this.config.project_id,
				selector: sprint_selector
			});
		}.bind(this));
		
		this.el = sprint_selector;
	}
});

var MoveIssue = Class.create(Ajax.Request, {
	initialize: function($super, config){
		var url = "projects/"+config.project_id+"/scrumbler_backlogs/change_issue_version";
		$super(url, {
				method : 'post',
				parameters : {
					issue_id : config.issue_id,
					sprint_id : config.sprint_id,
				},
				onSuccess : function(transport) { 
					var resp = transport.responseJSON;
					if(resp.success) {
						$(document).fire('issue:moved',{
							backlog: resp.backlog,
							sprint: resp.sprint
						});
					} else {
						$growler.growl(resp.text, { header : 'Ошибка' });
					}
				},
				onFailure : function() {
					$growler.growl('Something went wrong...', { header : 'Error' });
				},
				onComplete: function(){
					config.source.show();
				}
		});
	}
});


return Class.create({
	initialize: function(config){
		this.config = Object.extend({
			parent_id : "content"
		}, config);
		
		this.backlog = this.createBacklog();
		this.sprint = this.createSprint();
		
		this.el = this.createUI();
		
		// Update backlog on sprint selection
		this.sprint.selector.el.observe('sprint:selected', function(event){
			var sprint = event.memo;
			this.updateSprint(sprint);
		}.bind(this));

		// Update backlog on issue movement
		$(document).observe('issue:moved', function(event){
			var config = event.memo;
			this.update(config);
		}.bind(this));
		
		this.sprint.list.el.observe('issue:drop', function(event){
			var issue = event.memo;
			new MoveIssue({
				project_id: this.config.project_id,
				sprint_id: this.config.sprint.id,
				issue_id: issue.id,
				source: issue.source
			});
		}.bind(this));
		
		this.backlog.list.el.observe('issue:drop', function(event){
			var issue = event.memo;
			new MoveIssue({
				project_id: this.config.project_id,
				issue_id: issue.id,
				source: issue.source
			});
		}.bind(this));
	},
	createBacklog: function(){
		this.disableIssuesInUnsupportedTrackers(this.config.backlog.issues, this.config.sprint.trackers);
		var backlog = {};
		backlog.list = new IssuesListUI(this.config.backlog.issues, {
			project_id: this.config.project_id
		});
		backlog.trackers = new TrackersListUI(this.config.backlog.trackers);
		return backlog;			
	},
	createSprint: function(){
		var sprint = {};
		sprint.list = new IssuesListUI(this.config.sprint.issues,{
			project_id: this.config.project_id
		});
		sprint.trackers = new TrackersListUI(this.config.sprint.trackers);
		sprint.selector = new SprintSelector({sprints: this.config.sprints, project_id: this.config.project_id});
		return sprint;
	},
	// Create Backlog HTML Element 
	createUI: function(){
		var el = new Element('div');
		var div;
		div = new Element('div',{id:'splitcontentleft', style: "float:left;width:48%;"});
		div.appendChild(new Element('h2').update(t('label_backlog')));
		div.appendChild(this.backlog.trackers.el);
		div.appendChild(this.backlog.list.el);
		el.appendChild(div);

		div = new Element('div',{id:'splitcontentright', style: "float:right; width:50%;"})
		var contextual_div = new Element('div', {'class': 'contextual'});
		var h2 = new Element('h2').update(t('scrumbler_sprint'));
		contextual_div.appendChild(this.sprint.selector.el);
		div.appendChild(contextual_div);
		div.appendChild(h2);
		div.appendChild(this.sprint.trackers.el);
		div.appendChild(this.sprint.list.el);
		el.appendChild(div);
		return el;
	},
	update: function(config){
		this.updateBacklog(config.backlog);
		this.updateSprint(config.sprint);
	},
	updateBacklog: function(backlog){
		this.config.backlog = Object.extend(this.config.backlog, backlog);
		this.backlog.list.update(this.config.backlog.issues);
		this.backlog.trackers.update(this.config.backlog.trackers);
	},
	updateSprint: function(sprint){
		this.config.sprint = Object.extend(this.config.sprint, sprint);
		this.sprint.list.update(sprint.issues);
		this.sprint.trackers.update(sprint.trackers);
		this.disableIssuesInUnsupportedTrackers(this.backlog.list.issues, sprint.trackers);
		this.backlog.list.update(this.backlog.list.issues);
	},
	disableIssuesInUnsupportedTrackers: function(issues, trackers){
		issues.each(function(issue){ issue.disabled = !containsById(trackers, issue.tracker.id) });
	}
});
})();
