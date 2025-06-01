CREATE TABLE TBL_DIM_MaintenanceRequests (  
    request_id INT PRIMARY KEY IDENTITY(1,1),  
    resident_id INT NOT NULL,  
    category VARCHAR(50) NOT NULL,  
    description TEXT,  
    status VARCHAR(20) DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved')),  
    created_On DATETIME DEFAULT GETDATE(),  
    resolved_On DATETIME NULL, 
	maintenance_comments TEXT NULL,
    FOREIGN KEY (resident_id) REFERENCES TBL_DIM_Residents(resident_id)  
);


CREATE TABLE TBL_DIM_ResidentNotifications (
    notification_id INT PRIMARY KEY IDENTITY(1,1),
    resident_id INT,
    message NVARCHAR(500),
    sent_On DATETIME DEFAULT GETDATE(),
	is_read BIT DEFAULT 0
    FOREIGN KEY (resident_id) REFERENCES TBL_DIM_Residents(resident_id)
);



