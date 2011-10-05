var ScrumblerDashboard = (function() {
    $from = function(v) {
        return function() {
            return v
            }
        };

var ISSUE_TEMPLATE = new Template(
    "<div class='scrumbler_dashboard_issue_color' style='background: ##{color};'>\n\
        <a href='#{tracker_url}'>#{tracker_name}</a>\n\
        </div>\n\
        <a href='#{issue_url}'>#{subject}</a>");

var Issue = Class.create({
    initialize: function(sprint, config, statuses, trackers, url) {
        // -
        // private
        var id = "scrumbler_dashboard_issue_" + config.id;
        var issue_url = '/issues/'+config.id;
        var tracker_url = url+'/issues?tracker_id='+config.tracker_id;
        var sprint_url = url+'/scrumbler_sprints/'+sprint.id+'/issue/'+config.id;
        var row = new Element('tr');
        var issueEl = new Element('div', {
            'class': 'scrumbler_dashboard_issue',
            id: id
        });
                
        function makeStatusElements() {
            var statusElements = {};
            var i = 0;
            statuses.each(function(status){
                statusElements[status.issue_status_id] = {
                    element: new Element('td'),
                    position: i++,
                    status: status
                };
                statusElements[status.issue_status_id].element.scrumbler_status = status;
            })
            return $H(statusElements); 
        };
                
                
        // +
        // public
        this.getID          = $from(id);
        this.getRow         = $from(row);
        this.getIssueEl     = $from(issueEl);
        this.getConfig      = $from(config);
        this.getURL         = $from(sprint_url);
        this.getIssueURL    = $from(issue_url);
        this.getTrackerURL  = $from(tracker_url);
        this.getTrackers    = $from(trackers);
          
        this.statuses = makeStatusElements(statuses);
          
        this.render();

        this.makeInteractive();


    },
    getSortedStatuses: function() {
        return this.statuses.values().sort(function(a, b) {
            return a.position - b.position
        });
    },
    render: function() {
        this.getIssueEl().update(ISSUE_TEMPLATE.evaluate({
            issue_url: this.getIssueURL(),
            tracker_url: this.getTrackerURL(),
            tracker_name: this.getTrackers()[this.getConfig().tracker_id].name,
            subject: this.getConfig().subject,
            //description: this.getConfig().description, 
            color: this.getTrackers()[this.getConfig().tracker_id].settings.color
        }));

        // Draw statuses
        this.getSortedStatuses().each(function(status) {
            this.getRow().appendChild(status.element);
            status.element.update('&nbsp;')
        }, this);
        this.statuses.get(this.getConfig().status_id).element.appendChild(this.getIssueEl());
    },
    makeInteractive: function() {
        // -
        // private
        var issue = this;
        var draggable = new Draggable(this.getIssueEl(), {
            revert : true,
            constraint: 'horizontal'
        });
                
        function makeDroppableEl (status) {
            function onDrop(dragEl, dropEl, event) {
                if((dragEl != issue.getIssueEl()) || 
                    !dropEl.scrumbler_status) return;
                        
                issue.getIssueEl().hide();
                var status = dropEl.scrumbler_status;
                new Ajax.Request(issue.getURL(),
                {
                    method:'post',
                    parameters: {
                        'issue[status_id]': status.issue_status_id
                    },
                    onSuccess: function(transport){
                        var resp = transport.responseJSON;
                        if(!resp) return;

                        if(resp.success) {
                            dropEl.appendChild(issue.getIssueEl());
                        } else {
                            alert(resp.text);
                        }
                                
                    },
                    onFailure: function(){ 
                        alert('Something went wrong...') 
                    },
                    onComplete: function() {
                        issue.getIssueEl().show()
                    }
                });
                        
                        
            }
                    
            Droppables.add(status, {
                accept: 'scrumbler_dashboard_issue',
                onDrop: onDrop
            });
        };
                
        // Create droppables
        this.statuses.each(function(pair) {
            makeDroppableEl(pair.value.element);
        });
    }
});


    
var Dashboard = Class.create({
    initialize: function(dashboard, config) {
        // -
        // private
        function makeIssues(config) {
            var issues = [];
            config.issues.each(function(issue) {
                issues.push(new Issue(config.sprint , issue, config.statuses, config.trackers, config.url));
            });
            return issues;
        }
        var table  = new Element('table', {
            'width': '100%'
        }, {})
        var issues = makeIssues(config);
            
        
        // +
        // public
        this.getDashboard = $from($(dashboard));
        this.getConfig    = $from(config);
        this.getStatuses  = $from(config.statuses);
        this.getTrackers  = $from(config.trackers);
        this.getIssues    = $from(issues);
        this.getTable     = $from(table);
                
        this.render();
    },
    render: function() {
        // -
        // private
        var drawStatuses = function () {
            var tr = this.getTable().appendChild(new Element('tr'));
            var colWidth = 100/this.getStatuses().length;
            this.getStatuses().each(function(status){
                var th = tr.appendChild(new Element('th', {
                    width: ''+colWidth+'%'
                }));
                th.update(status.name);
            }, this);
        }.bind(this)
            
        // +
        // public
        drawStatuses();
                
        // drawIssues
        this.getIssues().each(function(issue) {
            this.getTable().appendChild(issue.getRow())
        }, this)
                
        // Append table to dashboard
        this.getDashboard().appendChild(this.getTable());
    }
});
    
return Dashboard;
})();
