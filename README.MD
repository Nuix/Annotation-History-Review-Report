Annotation History Review Report
================================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) ![This script was last tested in Nuix 8.0](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-8.0-green.svg)

View the GitHub project [here](https://github.com/Nuix/Annotation-History-Review-Report) or download the latest release [here](https://github.com/Nuix/Annotation-History-Review-Report/releases).

# Overview

This script generates a report of case history events of types "annotation" and "export". For each of these events, details regarding the items involved in those events are also reported.  The report is generated in three levels:

## Event Summary
This part of the report lists all the "annotation" and "export" type events found in the case.  Each event listed has a hyper link to an Event Details report.

![image](https://user-images.githubusercontent.com/11775738/62799165-f7649100-ba94-11e9-829a-bfcbd771d13b.png)

## Event Details

This part of the report is generated for each event reported on the event summary page.  Lists the items affected by the given event.  Each listed item has a hyper link to an Item Details report.

![image](https://user-images.githubusercontent.com/11775738/62798981-7efdd000-ba94-11e9-9d54-259163e7cc8f.png)

## Item Details

This part of the report is generated for each item involved in an event.  Each per item page lists some high level details about that item and the history events that the given item was involved in.

![image](https://user-images.githubusercontent.com/11775738/62799199-0c412480-ba95-11e9-8bf9-ce71aa95711d.png)

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

# Usage

Run the script, provide the directory the report should be saved to and click "Ok".  Script will display a progress dialog as it generates the report.  Note that due to the way the history API works, the script cannot know how many total history events need to be reported without incurring extra resources and time.  Therefore the progress dialog shows how many events have been processed thus far at any given point, but does not know how many are left to process.

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2019 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
