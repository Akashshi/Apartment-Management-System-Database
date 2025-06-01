CREATE TABLE TBL_DIM_Notices (
    notice_id INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    posted_on DATE DEFAULT GETDATE(),
    posted_by VARCHAR(100),
	Validity DATE NOT NULL
);


CREATE TABLE TBL_DIM_ResidentNotifications (
    notification_id INT PRIMARY KEY IDENTITY(1,1),
    resident_id INT,
    message NVARCHAR(500),
    sent_at DATETIME DEFAULT GETDATE(),
    is_read BIT DEFAULT 0,
    FOREIGN KEY (resident_id) REFERENCES TBL_DIM_Residents(resident_id)
);
