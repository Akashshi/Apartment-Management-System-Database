CREATE TABLE TBL_Fact_WorkAssignments (
    assignment_id INT PRIMARY KEY IDENTITY(1,1),
    request_id INT NOT NULL,
    staff_id INT NOT NULL,
    assigned_on DATETIME DEFAULT GETDATE(),
	request_status VARCHAR(20),
	completed_on DATETIME NULL,
    FOREIGN KEY (completed_on) REFERENCES TBL_DIM_MaintenanceRequests(resolved_On),
	FOREIGN KEY (request_status) REFERENCES TBL_DIM_MaintenanceRequests(status),
    FOREIGN KEY (request_id) REFERENCES TBL_DIM_MaintenanceRequests(request_id),
    FOREIGN KEY (staff_id) REFERENCES TBL_DIM_MaintenanceStaff(staff_id)
);

