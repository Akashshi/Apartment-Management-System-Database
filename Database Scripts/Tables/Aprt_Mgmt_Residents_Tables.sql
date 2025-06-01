drop table if exists TBL_DM_Residents
CREATE TABLE TBL_DIM_Residents (
    resident_id INT PRIMARY KEY IDENTITY(1,1),
    First_name VARCHAR(100) NOT NULL,
	Last_name VARCHAR(100) NOT NULL,
    flat_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    ownership_status VARCHAR(10) CHECK (ownership_status IN ('Owner', 'Tenant')),
    join_date DATE NOT NULL
);

CREATE TABLE TBL_Fact_Residents_AuditLog (
    audit_id INT PRIMARY KEY IDENTITY(1,1),
    resident_id INT,
    operation_type VARCHAR(10), -- INSERT, UPDATE, DELETE
    changed_at DATETIME DEFAULT GETDATE(),
    changed_by NVARCHAR(100), -- Optional: system user/API user ID
    old_data NVARCHAR(MAX),   -- JSON snapshot before change (for UPDATE/DELETE)
    new_data NVARCHAR(MAX)    -- JSON snapshot after change (for INSERT/UPDATE)
);