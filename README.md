Scrumbler
=========
Current version: 1.4.2 ([Changelog](/256MbTeam/Redmine-Scrumbler/blob/master/CHANGELOG.md))
[Documentation](https://github.com/256MbTeam/Redmine-Scrumbler/wiki/Documentation-and-overview)

Easy to use plugin for [Redmine](http://http://www.redmine.org/). It allows users to use the Scrum/Agile process in projects.
Scrumbler have interactive dashboard with the ability to configure for each sprint. 
Plugin adds Scrum Points field in every issue in project.
Scrumbler as possible using the standard redmine structure of projects.
Plugin tested in many browsers, but it's not working in IE.

Features
--------

Scrumbler supports the following:

* Drag & Drop to change the status of an issue, following the workflow
* Change the types of statuses/trackers displayed on the dashboard
* Hide issues in one status by clicking on column header
* Choose which version to display on the dashboard
* Configurable colors for issues displayed
* Scrum Points calculation and progress displayed on the dashboard
* Automatically set the due date for each issue, when it status changed to closed
* Easy to change assignee for issue on the dashboard
* Backlog for easy sprint composing with Drag & Drop
* Burndown chart

Requirements
------------

* Redmine 1.2.x or 1.3.x

Installation
------------

To install the Scrumbler please follow the steps outlined below.

Install the plugin in your Redmine plugins directory, name of directory must be **redmine_scrumbler**:
    
    git clone git://github.com/256MbTeam/Redmine-Scrumbler.git vendor/plugins/redmine_scrumbler

Run migrations:

    rake db:migrate:plugins

Restart the Redmine:

    You should now be able to see the plugin list in Administration -> Plugins and configure the Scrumbler plugin.


Upgrading
---------

Browse to Scrumbler plugin directory.

	cd $REDMINE_HOME/vendor/plugins/redmine_scrumbler
	
Update the plugin.

	git pull
	
Execute plugin migrations.

	rake db:plugins_migrate

Restart the Redmine.

TODO
----

* Daily reporting for issue assignments
* Template customization


Authors
-------

* [Andrianov Alexandr](http://github.com/zloydadka)
* [Kotenko Ivan](http://github.com/xeta)

Sponsors
--------

* [RDTEX](http://rdtex.ru/)

Translations
------------

* [Steven.W](https://github.com/archonwang) - zh
* [Terence Miller](https://github.com/cforce) - de

License
-------

This project is licensed under GNU General Public License version 2.

