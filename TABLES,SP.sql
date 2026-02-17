--Tables--

CREATE TABLE MOM_MeetingType(
    MeetingTypeID INT IDENTITY(1,1) PRIMARY KEY,
    MeetingTypeName NVARCHAR(100) NOT NULL UNIQUE,
    Remarks NVARCHAR(100) NOT NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Modified DATETIME NOT NULL
);
TRUNCATE TABLE MOM_MeetingType;

CREATE TABLE MOM_Department(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Modified DATETIME NOT NULL
);
TRUNCATE TABLE MOM_Department;

CREATE TABLE MOM_MeetingVenue(
    MeetingVenueID INT IDENTITY(1,1) PRIMARY KEY,
    MeetingVenueName NVARCHAR(100) NOT NULL UNIQUE,
    Created DATETIME NOT NULL DEFAULT GETDATE(),    Modified DATETIME NOT NULL
);
TRUNCATE TABLE MOM_MeetingVenue;

CREATE TABLE MOM_Staff(
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentID INT NOT NULL,
    StaffName NVARCHAR(50) NOT NULL,
    MobileNo NVARCHAR(20) NOT NULL,
    EmailAddress NVARCHAR(50) NOT NULL UNIQUE,
    Remarks NVARCHAR(250) NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Modified DATETIME NOT NULL,
    CONSTRAINT FK_Staff_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES MOM_Department(DepartmentID)
);
TRUNCATE TABLE MOM_Staff;

CREATE TABLE MOM_Meetings
(
    MeetingID INT IDENTITY(1,1) PRIMARY KEY,
    MeetingDate DATETIME NOT NULL,
    MeetingVenueID INT NOT NULL,
    MeetingTypeID INT NOT NULL,
    DepartmentID INT NOT NULL,
    MeetingDescription NVARCHAR(250) NULL,
    DocumentPath NVARCHAR(250) NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Modified DATETIME NOT NULL,
    IsCancelled BIT NULL,
    CancellationDateTime DATETIME NULL,
    CancellationReason NVARCHAR(250) NULL,
    CONSTRAINT FK_Meeting_Venue
        FOREIGN KEY (MeetingVenueID)
        REFERENCES MOM_MeetingVenue(MeetingVenueID),
    CONSTRAINT FK_Meeting_Type
        FOREIGN KEY (MeetingTypeID)
        REFERENCES MOM_MeetingType(MeetingTypeID),
    CONSTRAINT FK_Meeting_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES MOM_Department(DepartmentID)
);
TRUNCATE TABLE MOM_Meetings;

CREATE TABLE MOM_MeetingMember
(
    MeetingMemberID INT IDENTITY(1,1) PRIMARY KEY,
    MeetingID INT NOT NULL,
    StaffID INT NOT NULL,
    IsPresent BIT NOT NULL,
    Remarks NVARCHAR(250) NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Modified DATETIME NOT NULL,
    CONSTRAINT FK_MeetingMember_Meeting
        FOREIGN KEY (MeetingID)
        REFERENCES MOM_Meetings(MeetingID),
    CONSTRAINT FK_MeetingMember_Staff
        FOREIGN KEY (StaffID)
        REFERENCES MOM_Staff(StaffID),
    CONSTRAINT UQ_Meeting_Staff
        UNIQUE (MeetingID, StaffID)
);
TRUNCATE TABLE MOM_MeetingMember;

DELETE FROM MOM_MeetingMember;
DELETE FROM MOM_Meetings;
DELETE FROM MOM_Staff;
DELETE FROM MOM_MeetingVenue;
DELETE FROM MOM_MeetingType;
DELETE FROM MOM_Department;

-- Identity Reset
DBCC CHECKIDENT ('MOM_MeetingMember', RESEED, 0);
DBCC CHECKIDENT ('MOM_Meetings', RESEED, 0);
DBCC CHECKIDENT ('MOM_Staff', RESEED, 0);
DBCC CHECKIDENT ('MOM_MeetingVenue', RESEED, 0);
DBCC CHECKIDENT ('MOM_MeetingType', RESEED, 0);
DBCC CHECKIDENT ('MOM_Department', RESEED, 0);

--Stored Procedures--

--1.MOM_MeetingType--
--Insert
CREATE PROCEDURE PR_MOM_MeetingType_Insert
    @MeetingTypeName NVARCHAR(100),
    @Remarks NVARCHAR(100)
AS
BEGIN
INSERT INTO MOM_MeetingType(
    MeetingTypeName,Remarks,Created,Modified)
VALUES(
    @MeetingTypeName,@Remarks,GETDATE(),GETDATE())
END

--Update
CREATE PROCEDURE PR_MOM_MeetingType_Update
    @MeetingTypeID INT,
    @MeetingTypeName NVARCHAR(100),
    @Remarks NVARCHAR(100)
AS
BEGIN
UPDATE MOM_MeetingType
SET
    MeetingTypeName = @MeetingTypeName,
    Remarks = @Remarks,
    Modified = GETDATE()
WHERE MeetingTypeID = @MeetingTypeID
END

--Delete
CREATE PROCEDURE PR_MOM_MeetingType_Delete
    @MeetingTypeID INT
AS
BEGIN
DELETE FROM MOM_MeetingType 
WHERE MeetingTypeID = @MeetingTypeID
END

--SelectAll
CREATE PROCEDURE PR_MOM_MeetingType_SelectAll
AS
BEGIN
SELECT
    MeetingTypeID,
    MeetingTypeName,
    Remarks,
    Created,
    Modified
FROM MOM_MeetingType
ORDER BY MeetingTypeName
END

--Select by Primary key
CREATE PROCEDURE PR_MOM_MeetingType_SelectByPK
    @MeetingTypeID INT
AS
BEGIN
SELECT
    MeetingTypeID,
    MeetingTypeName,
    Remarks
FROM MOM_MeetingType
WHERE MeetingTypeID = @MeetingTypeID
END


--2.MOM_Department--
--Insert
CREATE PROCEDURE PR_MOM_Department_Insert
    @DepartmentName NVARCHAR(100)
AS
BEGIN
INSERT INTO MOM_Department(
    DepartmentName,Created,Modified)
VALUES(
    @DepartmentName,GETDATE(),GETDATE())
END

--Update
CREATE PROCEDURE PR_MOM_Department_Update
    @DepartmentID INT,
    @DepartmentName NVARCHAR(100)
AS
BEGIN
UPDATE MOM_Department
SET
    DepartmentName = @DepartmentName,
    Modified = GETDATE()
WHERE DepartmentID = @DepartmentID
END

--Delete
ALTER PROCEDURE PR_MOM_Department_Delete
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete meetings first
    DELETE FROM MOM_Meetings
    WHERE DepartmentID = @DepartmentID;

    -- Delete staff
    DELETE FROM MOM_Staff
    WHERE DepartmentID = @DepartmentID;

    -- Delete department
    DELETE FROM MOM_Department
    WHERE DepartmentID = @DepartmentID;
END


--Select All
CREATE PROCEDURE PR_MOM_Department_SelectAll
AS
BEGIN
SELECT
    DepartmentID,
    DepartmentName,
    Created,
    Modified
FROM MOM_Department
ORDER BY DepartmentName
END

--Select By Primary Key
CREATE PROCEDURE PR_MOM_Department_SelectByPK
    @DepartmentID INT
AS
BEGIN
SELECT
    DepartmentID,
    DepartmentName
FROM MOM_Department
WHERE DepartmentID = @DepartmentID
END


--3.MOM_MeetingVenue--
--Insert
CREATE PROCEDURE PR_MOM_MeetingVenue_Insert
    @MeetingVenueName NVARCHAR(100)
AS
BEGIN
    INSERT INTO MOM_MeetingVenue(
        MeetingVenueName,Created,Modified)
    VALUES(
    @MeetingVenueName,GETDATE(),GETDATE())
END

--Update
CREATE PROCEDURE PR_MOM_MeetingVenue_Update
    @MeetingVenueID INT,
    @MeetingVenueName NVARCHAR(100)
AS
BEGIN
UPDATE MOM_MeetingVenue
SET
    MeetingVenueName = @MeetingVenueName,
    Modified = GETDATE()
WHERE MeetingVenueID = @MeetingVenueID
END

--Delete
CREATE PROCEDURE PR_MOM_MeetingVenue_Delete
    @MeetingVenueID INT
AS
BEGIN
DELETE
FROM MOM_MeetingVenue
WHERE MeetingVenueID = @MeetingVenueID
END

--Select All
CREATE PROCEDURE PR_MOM_MeetingVenue_SelectAll
AS
BEGIN
SELECT
    MeetingVenueID,
    MeetingVenueName,
    Created,
    Modified
FROM MOM_MeetingVenue
ORDER BY MeetingVenueName
END

--Select By Primary Key
CREATE PROCEDURE PR_MOM_MeetingVenue_SelectByPK
    @MeetingVenueID INT
AS
BEGIN
SELECT
    MeetingVenueID,
    MeetingVenueName
FROM MOM_MeetingVenue
WHERE MeetingVenueID = @MeetingVenueID
END


--4.MOM_Meetings --
--Insert
CREATE PROCEDURE PR_MOM_Meetings_Insert
    @MeetingDate DATETIME,
    @MeetingVenueID INT,
    @MeetingTypeID INT,
    @DepartmentID INT,
    @MeetingDescription NVARCHAR(250),
    @DocumentPath NVARCHAR(250)
AS
BEGIN
INSERT INTO MOM_Meetings(
    MeetingDate,MeetingVenueID,MeetingTypeID,DepartmentID,MeetingDescription,DocumentPath,Created,Modified)
VALUES(
    @MeetingDate,@MeetingVenueID,@MeetingTypeID,@DepartmentID,@MeetingDescription,@DocumentPath,GETDATE(),GETDATE())
END

--Update
CREATE PROCEDURE PR_MOM_Meetings_Update
    @MeetingID INT,
    @MeetingDate DATETIME,
    @MeetingVenueID INT,
    @MeetingTypeID INT,
    @DepartmentID INT,
    @MeetingDescription NVARCHAR(250),
    @DocumentPath NVARCHAR(250)
AS
BEGIN
UPDATE MOM_Meetings
SET
    MeetingDate = @MeetingDate,
    MeetingVenueID = @MeetingVenueID,
    MeetingTypeID = @MeetingTypeID,
    DepartmentID = @DepartmentID,
    MeetingDescription = @MeetingDescription,
    DocumentPath = @DocumentPath,
    Modified = GETDATE()
WHERE MeetingID = @MeetingID
END

--Delete
CREATE PROCEDURE PR_MOM_Meetings_Delete
    @MeetingID INT
AS
BEGIN
DELETE
FROM MOM_Meetings
WHERE MeetingID = @MeetingID
END

--Select All
ALTER PROCEDURE PR_MOM_Meetings_SelectAll
AS
BEGIN
    SELECT
        M.MeetingID,
        M.MeetingDate,
        MT.MeetingTypeName,
        MV.MeetingVenueName,
        D.DepartmentName,
        M.Created
    FROM MOM_Meetings M
    INNER JOIN MOM_MeetingType MT
        ON M.MeetingTypeID = MT.MeetingTypeID
    INNER JOIN MOM_MeetingVenue MV
        ON M.MeetingVenueID = MV.MeetingVenueID
    INNER JOIN MOM_Department D
        ON M.DepartmentID = D.DepartmentID
    ORDER BY M.MeetingDate DESC
END


--Selecr By Primary Key
CREATE PROCEDURE PR_MOM_Meetings_SelectByPK
    @MeetingID INT
AS
BEGIN
SELECT
    MeetingID,
    MeetingDate,
    MeetingVenueID,
    MeetingTypeID,
    DepartmentID,
    MeetingDescription,
    DocumentPath
FROM MOM_Meetings
WHERE MeetingID = @MeetingID
END


--5.MOM_Staff--
--Insert
CREATE PROCEDURE PR_MOM_Staff_Insert
    @DepartmentID INT,
    @StaffName NVARCHAR(50),
    @MobileNo NVARCHAR(20),
    @EmailAddress NVARCHAR(50),
    @Remarks NVARCHAR(250)
AS
BEGIN
INSERT INTO MOM_Staff(
    DepartmentID,StaffName,MobileNo,EmailAddress,Remarks,Created,Modified)
VALUES(
    @DepartmentID,@StaffName,@MobileNo,@EmailAddress,@Remarks,GETDATE(),GETDATE())
END

--Update
CREATE PROCEDURE PR_MOM_Staff_Update
    @StaffID INT,
    @DepartmentID INT,
    @StaffName NVARCHAR(50),
    @MobileNo NVARCHAR(20),
    @EmailAddress NVARCHAR(50),
    @Remarks NVARCHAR(250)
AS
BEGIN
UPDATE MOM_Staff
SET
    DepartmentID = @DepartmentID,
    StaffName = @StaffName,
    MobileNo = @MobileNo,
    EmailAddress = @EmailAddress,
    Remarks = @Remarks,
    Modified = GETDATE()
WHERE StaffID = @StaffID
END

--Delete
CREATE PROCEDURE PR_MOM_Staff_Delete
    @StaffID INT
AS
BEGIN
DELETE
FROM MOM_Staff
WHERE StaffID = @StaffID
END

--SelectAll
Alter PROCEDURE PR_MOM_Staff_SelectAll
AS
BEGIN
SET NOCOUNT ON;
SELECT 
    S.StaffID,
    S.DepartmentID,
    D.DepartmentName,
    S.StaffName,
    S.MobileNo,
    S.EmailAddress,
    S.Remarks,
    S.Created,
    S.Modified
FROM MOM_Staff S
INNER JOIN MOM_Department D
    ON S.DepartmentID = D.DepartmentID
END

--Select by Primary Key
CREATE PROCEDURE PR_MOM_Staff_SelectByPK
    @StaffID INT
AS
BEGIN
SELECT
    StaffID,
    DepartmentID,
    StaffName,
    MobileNo,
    EmailAddress,
    Remarks
FROM MOM_Staff
WHERE StaffID = @StaffID
END


--6.MOM_MeetingMember--
--Insert
CREATE PROCEDURE PR_MOM_MeetingMember_Insert
    @MeetingID INT,
    @StaffID INT,
    @IsPresent BIT,
    @Remarks NVARCHAR(250)
AS
BEGIN
INSERT INTO MOM_MeetingMember(
    MeetingID,StaffID,IsPresent,Remarks,Created,Modified)
VALUES(
    @MeetingID,@StaffID,@IsPresent,@Remarks,GETDATE(),GETDATE())
END

--Update
CREATE PROCEDURE PR_MOM_MeetingMember_Update
    @MeetingMemberID INT,
    @MeetingID INT,
    @StaffID INT,
    @IsPresent BIT,
    @Remarks NVARCHAR(250)
AS
BEGIN
UPDATE MOM_MeetingMember
SET
    MeetingID = @MeetingID,
    StaffID = @StaffID,
    IsPresent = @IsPresent,
    Remarks = @Remarks,
    Modified = GETDATE()
WHERE MeetingMemberID = @MeetingMemberID
END

--Delete
CREATE PROCEDURE PR_MOM_MeetingMember_Delete
    @MeetingMemberID INT
AS
BEGIN
DELETE
FROM MOM_MeetingMember
WHERE MeetingMemberID = @MeetingMemberID
END

--SelectAll
ALTER PROCEDURE PR_MOM_MeetingMember_SelectAll
AS
BEGIN
SET NOCOUNT ON;

SELECT
    MM.MeetingMemberID,
    MM.MeetingID,
    MM.StaffID,
    M.MeetingDate,
    S.StaffName,
    MM.IsPresent,
    MM.Remarks,
    MM.Created,
    MM.Modified
FROM MOM_MeetingMember MM
INNER JOIN MOM_Meetings M
    ON MM.MeetingID = M.MeetingID
INNER JOIN MOM_Staff S
    ON MM.StaffID = S.StaffID
ORDER BY M.MeetingDate DESC, S.StaffName
END


--Select By Primary Key
CREATE PROCEDURE PR_MOM_MeetingMember_SelectByPK
    @MeetingMemberID INT
AS
BEGIN
SELECT
    MeetingMemberID,
    MeetingID,
    StaffID,
    IsPresent,
    Remarks
FROM MOM_MeetingMember
WHERE MeetingMemberID = @MeetingMemberID
END