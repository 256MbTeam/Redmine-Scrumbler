Scrumbler.ScrumblerDashboard = (function() {
	// Helpers
	var BacklogHeader = function(name) {
		var el = new Element('div', {
			id: "scrumbler_sprint_header"
		});
		var h3 = new Element('h3', {
			id: "scrumbler_sprint_header_name"
		}).update(name);

		var progress_bar = new Element('table', {
			width: '100%',
			'class': 'progress'
		});
		var tr = new Element('tr');
		var td_completed = new Element('td', {
			'class': 'closed'
		});
		var td_total = new Element('td', {
			'class': 'done'
		});
		var p = new Element('p', {
			'class': 'pourcent'
		});

		el.appendChild(h3);
		el.appendChild(progress_bar);
		progress_bar.appendChild(tr);
		tr.appendChild(td_completed);
		tr.appendChild(td_total);
		el.appendChild(p);
		this.getElement = $from(el);

		this.setValues = function(total, completed) {

			function drawBar(bar, pct) {
				bar.setStyle({
					width: pct+"%",
				});
				bar.setStyle({
					display: (pct == 0) ? 'none' : 'table-cell'
				});
			}

			var pct_completed = completed/(total/100.0) || 0;
			var pct_required = 100-pct_completed;

	

			drawBar(td_completed, pct_completed)
			drawBar(td_total, pct_required);

			p.update(completed + '/' + total);
		}
	};
	var $current_user_id;
	// End helpers

	var AssignmentStatus = Class.create({
		initialize: function(issue) {
			this.issue      = issue;
			this.el         = new Element('div');
			var body        = new Element('div', {"class": "scrumbler-assignment-status"});
			this.statusLink = new Element('div', {"class": 'scrumbler-assignee-link'}).update("&nbsp;");
			this.infoEl     = new Element('span', {"class": 'scrumbler-assignment-status-info'});

			this.el.appendChild(body);

			body.appendChild(this.infoEl);
			body.appendChild(this.statusLink);

			this.generateStatus();
			this.generateInfo();

		},
		getEl: function() {
			if (!this.rendered) { this.render() };
			return this.el;

		},
		render: function() {
			this.generateInfo();
			this.generateStatus();
			this.rendered = true;
		},
		generateInfo: function() {
			var assigned_to = this.issue.getConfig().assigned_to;
			if(assigned_to) {
				this.infoEl.update(assigned_to.name)
			} else {
				this.infoEl.update(Scrumbler.Translations.issue_not_assigned)
			}
		},
		generateStatus: function() {
			var assigned_to = this.issue.getConfig().assigned_to;
			var issue_url = this.issue.getURL();
			var self = this;
			var issue = this.issue;
			// TODO
			// Rfactor please
			//
			function makeAssign(link) {
				link.stopObserving('click');
				link.removeClassName('scrumbler-not-assigned-issue')
				link.observe('click', function() {
					new Ajax.Request(issue_url + '/drop_issue_assignment', {
						onSuccess: function(response) {
							makeNOTAssign(link)
							issue.setConfig(response.responseJSON.issue);
							self.generateInfo();
						}
					})
					return false;
				});
			}

			function makeNOTAssign(link) {
				link.stopObserving('click');
				link.addClassName('scrumbler-not-assigned-issue')
				link.observe('click', function() {
					new Ajax.Request(issue_url + '/change_assignment_to_me', {
						onSuccess: function(response) {
							makeAssign(link);
							issue.setConfig(response.responseJSON.issue);
							self.generateInfo();
						}
					});

					return false;
				})
			}

			if(assigned_to && assigned_to.id == $current_user_id) {
				makeAssign(this.statusLink)
			} else {
				makeNOTAssign(this.statusLink)

			}
		}
	});

	var Issue = Class.create({
		getConfig:   function() { return this.config;},
		setConfig:   function(config) { this.config = config; return this.getConfig(); },
		getStatusId: function() { return this.config.status_id },
		setStatusId: function(status_id) { return this.config.status_id = status_id;},
		getClosed:   function() { return this.config.status_id;},
		setClosed:   function(closed) { return this.config.closed = closed;},
		initialize:  function(dashboard, sprint, issue_config, statuses, trackers, url, css_class) {
			this.setConfig(issue_config);
			// -
			// private
			var id = "scrumbler_dashboard_issue_" + issue_config.id;
			var issue_url = Scrumbler.root_url+'/issues/'+issue_config.id;
			var tracker_url = url+'/issues?tracker_id='+issue_config.tracker_id;
			var sprint_url = url+'/scrumbler_sprints/'+sprint.id+'/issue/'+issue_config.id;
			var row = new Element('tr', { 'class' : css_class });

			function makeStatusElements() {
				var statusElements = {};
				var i = 0;
				statuses.each( function(status) {
					statusElements[status.status_id] = {
						element: new Element('td', {
							"class": 'scrumbler_status_'+status.status_id
						}),
						position: i++,
						status: status
					};

					statusElements[status.status_id].element.scrumbler_status = status;
				})
				return $H(statusElements);
			};
			var tracker = trackers.get(issue_config.tracker_id);
			tracker.id = issue_config.tracker_id;
			var issueEl = new Scrumbler.IssueTemplate({
				'tracker': tracker,
				'issue': issue_config,
				'project_id': sprint.project_id,
				class_name : "scrumbler_issue"
			}).getEl();

			// +
			// public
			this.getDashboard		= $from(dashboard);
			this.getID              = $from(id);
			this.getRow             = $from(row);
			this.getURL             = $from(sprint_url);
			this.getTrackerURL      = $from(tracker_url);
			this.getTrackers        = $from(trackers);
			this.getIssueURL        = $from(issue_url);
			this.getIssueEl         = $from(issueEl);
			this.getAssn            = $from(new AssignmentStatus(this));
			this.statuses 			= makeStatusElements();

			this.render();
			this.makeInteractive();
		},
		getSortedStatuses: function() {
			function sortFn(a, b) { return a.position - b.position};
			return this.statuses.values().sort(sortFn);
		},
		render: function() {
			this.getIssueEl().appendChild(this.getAssn().getEl());

			// Draw statuses
			this.getSortedStatuses().each(function(status) {
				this.getRow().appendChild(status.element.update('&nbsp;'));
			}, this);
			
			this.statuses.get(this.getStatusId()).element.appendChild(this.getIssueEl());
		},
		makeInteractive: function() {
			// -
			// private
			var issue     = this;
			var draggable = new Draggable(this.getIssueEl(), { revert : true, constraint: 'horizontal' });

			function makeDroppableEl (status) {

				function onDrop(dragEl, dropEl, event) {
					if ((dragEl != issue.getIssueEl()) || !dropEl.scrumbler_status) {
						return;	
					}

					var status = dropEl.scrumbler_status;

					if(issue.getStatusId() != status.status_id) {
						issue.getIssueEl().hide();
						
						new Ajax.Request(issue.getURL(), {
							method:'post',
							parameters: { 'issue[status_id]': status.status_id },
							onSuccess: function(transport) {
								var resp = transport.responseJSON;
								if (!resp) { return; }

								if (resp.success) {
									issue.setStatusId(status.status_id);
									issue.setClosed(status.closed);
									dropEl.appendChild(issue.getIssueEl());
									issue.getDashboard().refreshHeader();
								} else {
									$growler.growl(resp.text, { header: 'Ошибка' });
								}

							},
							onFailure: function() {
								$growler.growl('Something went wrong...', { header: 'Error' });
							},
							onComplete: function() { issue.getIssueEl().show() }
						});

					}

				};

				Droppables.add(status.element, { accept: 'scrumbler_issue', onDrop: onDrop });

			};

			// Create droppables
			this.statuses.each(function(pair) { makeDroppableEl(pair.value); });
		}
	});

	var Dashboard = Class.create({
		sort_hash: function(hash) {
			return hash.values().sort( function(a, b) {
				return a.position - b.position;
			});
		},
		initialize: function(dashboard, config) {
			$current_user_id = config.current_user_id;

			config.statuses = $H(config.statuses);
			config.trackers = $H(config.trackers);
			var _self = this;
			var sorted_statuses = this.sort_hash(config.statuses);

			var header = new BacklogHeader(config.name);

			var table  = new Element('table', {
				'width': '100%',
				'class': 'list'
			}, {});

			var issues = [];
			var css_class = ['odd','even'];
			var css_selector = 0;
			config.issues.each( function(issue) {
				if(css_selector==0) {
					css_selector = 1
				} else {
					css_selector = 0
				}
				issues.push(new Issue(_self, config.sprint, issue, sorted_statuses, config.trackers, config.url, css_class[css_selector]));
			});
			// +
			// public
			this.getHeader    = $from(header);
			this.getDashboard = $from($(dashboard));
			this.getConfig    = $from(config);
			this.getStatuses  = $from(config.statuses);
			this.getTrackers  = $from(config.trackers);
			this.getIssues    = $from(issues);
			this.getTable     = $from(table);
			this.getSortedStatuses = $from(sorted_statuses);

			this.render();
			this.refreshHeader();
		},
		getPoints: function() {
			var total = 0;
			var completed = 0;
			this.getIssues().each( function(issue) {
				var config = issue.getConfig();
				var points = parseFloat(config.points);

				if (points == points) {
					if (config.closed) {
						completed += points;
					}
					total += points;
				}
			});
			return [total, completed];
		},
		refreshHeader: function() {
			var points = this.getPoints();
			this.getHeader().setValues(points[0], points[1]);
		},
		render: function() {
			// -
			// private
			var drawStatuses = function () {
				var tr = this.getTable().appendChild(new Element('tr'));

				var colWidth = 100/this.getStatuses().keys().length;
				this.getSortedStatuses().each( function(status) {
					var th = tr.appendChild(new Element('th', {
						width: ''+colWidth+'%',
						"class": 'scrumbler_status_'+status.status_id
					}));
					var uniq_class_name = th.className;

					th.observe('click', function(event) {
						var disabled_class = 'scrumler-dashboard-status-inactive';
						var rows_scope = $$('.'+uniq_class_name+' > div.scrumbler_issue');
						if(th.hasClassName(disabled_class)) {
							th.removeClassName(disabled_class);
							rows_scope.each( function(el) {
								el.parentNode.parentNode.show();
							});
						} else {
							th.addClassName(disabled_class);
							rows_scope.each( function(el) {
								el.parentNode.parentNode.hide();
							});
						}

					});
					th.update(status.name);
				}, this);
			}.bind(this)
			// +
			// public
			drawStatuses();
			// drawIssues
			this.getIssues().each( function(issue) {
				this.getTable().appendChild(issue.getRow())
			}, this)
			// Append table to dashboard
			this.getDashboard().appendChild(this.getHeader().getElement());
			this.getDashboard().appendChild(this.getTable());
		}
	});

	return Dashboard;
})();