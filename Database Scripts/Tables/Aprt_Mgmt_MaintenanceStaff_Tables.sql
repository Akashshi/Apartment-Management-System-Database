CREATE TABLE TBL_Dim_MaintenanceStaff (
    staff_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
	availability_status BIT DEFAULT 0
);

CREATE TABLE TBL_Fact_MaintenanceStaff_AuditLog (
    audit_id INT PRIMARY KEY IDENTITY(1,1),
    staff_id INT,
    operation_type VARCHAR(10), -- INSERT, UPDATE, DELETE
    changed_at DATETIME DEFAULT GETDATE(),
    changed_by NVARCHAR(100), -- Optional: system user/API user ID
    old_data NVARCHAR(MAX),   -- JSON snapshot before change
    new_data NVARCHAR(MAX)    -- JSON snapshot after change
);

