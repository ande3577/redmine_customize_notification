# Redmine Customize Notification

## Overview

This plugin a allows a user to customize the fields on which to receive an issue
email notification.  It is intended to allow a user to reduce the number of
notifications they receive.

It is compatible with versions 2.4.x and 2.5.x.  Other versions may or may not work.

Please report issues to: 
  https://github.com/ande3577/redmine_project_alias/issues

## Installation

1.  Clone to the plugins/redmine_customize_notification directory
1.  Migrate the database
1.  Restart server

## Usage

A user can filter notifications by selecting which field changes for which to 
receive notifications.  The filter will be applied after filtering according to 
the users normal mail settings (e.g. all events, only assigned to me, etc.) and 
will only be applied when issues are modified 

![account notification settings](assets/images/mail_settings.png "Notification settings in My Account")

The plugin settings contains a list of default fields.  If a user selects "Restore 
default fields" these settings will be loaded.

Currently only issue fields are available for customization other notification
types are not supported.

## License

This program is free software: you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
