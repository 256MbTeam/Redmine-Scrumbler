Scrumbler
=========

Easy to use plugin for (Redmine)[http://http://www.redmine.org/]. It allows users to use the Scrum process in projects.
Scrumbler have interactive dashboard with the ability to configure for each sprint. 
Plugin adds Scrum Points field in every issue in project.
Scrambler as possible using the standard redmine structure of projects.
Plugin tested in many browsers, it's not working only in IE.

Features
--------

Scrumbler supports the following:
- Drag & Drop to change the status of an issue, following the workflow
- Change the types of statuses/trackers displayed on the dashboard
- Hide issues in one status by clicking on column header
- Choose which version to display on the dashboard
- Configurable colors for issues displayed
- Scrum Points calculation and progress displayed on the dashboard
- Automatically set the due date for each issue, when it status changed to closed
- Easy to change assignee for issue on the dashboard

Installation
------------

To install the Scrumbler please follow the steps outlined below.

1. Install the plugin in your Redmine plugins directory:

    git clone git://github.com/256MbTeam/Redmine-Scrumbler.git vendor/plugins/redmine_scrumbler

1. Run migrations:

    rake db:migrate:plugins

1. Restart the Redmine:

    You should now be able to see the plugin list in Administration -> Plugins and configure the Scrumbler plugin.

TODO
----

* Burndown chart
* Sprint states 
* IE support
* Daily reporting for issue assignments
* Template customization


Authors
-------

* [Andrianov Alexandr](http://github.com/zloydadka)
* [Kotenko Ivan](http://github.com/xeta)

Sponsors
--------

* [RDTEX](http://rdtex.ru/)

License
-------

This project is licensed under GNU General Public License version 2.

