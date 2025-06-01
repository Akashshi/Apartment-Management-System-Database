CREATE TABLE TBL_DIM_VisitorLogs (
    visitor_id INT PRIMARY KEY IDENTITY(1,1),
    resident_id INT NOT NULL,
    visitor_name VARCHAR(100) NOT NULL,
    purpose VARCHAR(50),
    in_time DATETIME NOT NULL DEFAULT GETDATE(),
    out_time DATETIME NULL,
    FOREIGN KEY (resident_id) REFERENCES TBL_DIM_Residents(resident_id)
);

CREATE TABLE TBL_Fact_VisitorLogs_AuditLog (
    audit_id INT PRIMARY KEY IDENTITY(1,1),
    visitor_id INT,
    operation_type VARCHAR(10), -- INSERT, UPDATE, DELETE
    changed_at DATETIME DEFAULT GETDATE(),
    changed_by NVARCHAR(100), -- Optional system/API user info
    old_data NVARCHAR(MAX),   -- JSON snapshot before change
    new_data NVARCHAR(MAX)    -- JSON snapshot after change
);
