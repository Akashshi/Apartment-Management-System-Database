# Apartment Database Management System 

## Overview

This SQL database is designed to manage core operations of an apartment complex or residential community. It provides a structured system for managing resident information, maintenance requests, staff assignments, notifications, notices, and visitor logs. The database also includes audit logging for critical tables to track data changes.

## Features

* **Resident Management:**
    * Stores resident details (name, flat number, contact info, ownership).
    * Manages resident information (insert, update, delete) with audit trails.
    * Retrieves resident information based on various criteria.
    * Provides functionality to get available residents.
    * Manages resident notifications and retrieves unread notifications.
* **Maintenance Management:**
    * Logs maintenance requests with categories and descriptions.
    * Tracks maintenance request status (Open, In Progress, Resolved).
    * Assigns maintenance requests to staff members.
    * Manages maintenance staff information (insert, update, delete) with audit trails.
    * Retrieves available maintenance staff based on roles.
    * Provides a comprehensive view of work assignments.
    * Updates maintenance request status and adds comments.
* **Notice Board:**
    * Manages and displays notices to residents.
    * Allows posting of new notices with validity dates.
    * Retrieves notices based on various filters (date, keywords).
* **Visitor Management:**
    * Logs visitor information (name, purpose, in/out times).
    * Provides visitor logs with associated resident information.
    * Manages visitor logs (insert, update, delete) with audit trails.
* **Auditing:**
    * Maintains audit logs for resident, maintenance staff, and visitor log data to track changes.

## Database Schema

The database schema consists of the following tables:

* `TBL_DIM_Residents`: Stores resident information.
* `TBL_Fact_Residents_AuditLog`: Tracks changes to resident data.
* `TBL_Dim_MaintenanceStaff`: Stores maintenance staff information.
* `TBL_Fact_MaintenanceStaff_AuditLog`: Tracks changes to maintenance staff data.
* `TBL_DIM_MaintenanceRequests`: Stores maintenance requests.
* `TBL_DIM_ResidentNotifications`: Stores notifications sent to residents.
* `TBL_Fact_WorkAssignments`: Tracks assignments of maintenance requests to staff.
* `TBL_DIM_Notices`: Stores notices for residents.
* `TBL_DIM_VisitorLogs`: Stores visitor logs.
* `TBL_Fact_VisitorLogs_AuditLog`: Tracks changes to visitor log data.

## Stored Procedures

The database includes various stored procedures to perform specific actions:

* **Residents:**
    * `usp_Get_AvailableResidents`: Retrieves residents based on criteria.
    * `usp_Get_UnreadResidentNotifications`: Retrieves unread notifications for a resident.
    * `usp_POST_ResidentInformation`: Manages resident information (insert, update, delete).
* **Maintenance Staff:**
    * `usp_Get_AvailableMaintenanceStaff`: Retrieves available maintenance staff.
    * `usp_POST_MaintenanceStaffInformation`: Manages maintenance staff information.
* **Maintenance Requests:**
    * `usp_Get_MaintenanceRequests`: Retrieves maintenance requests for a flat.
    * `usp_Get_WorkAssignments`: Retrieves work assignments.
    * `usp_POST_AssignMaintenanceRequestToStaff`: Assigns a request to a staff member.
    * `usp_POST_LogMaintenanceRequest`: Logs a new maintenance request.
    * `usp_POST_UpdateMaintenanceRequestStatus`: Updates the status of a request.
* **Notices:**
    * `usp_Get_Notices`: Retrieves notices. 
    * `usp_POST_Notice`: Posts a new notice. 
* **Visitors:**
    * `usp_Get_VisitorLogsWithResidentInfo`: Retrieves visitor logs with resident details.
    * `usp_POST_ManageVisitorLog`: Manages visitor logs (insert, update, delete).


