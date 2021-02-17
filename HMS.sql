
-------------------------------------------------------------------------------------------------------
--Delete NULLS
Delete from dbo.UnderGoes
Where OperationID is Null


ALTER DATABASE HospitalManagementSystem MODIFY NAME = HOSPITALMANAGEMENTSYSTEM
-------------------------------------------------------------------------------------------------------
--Create INDEXES
--Index1
CREATE INDEX empolyee_salary_desc 
ON Employee(Salary ASC);

--Index2
CREATE INDEX Employee_Addresses  
On Addresses(AddressID ASC)

SELECT *
FROM Employee WITH(INDEX(empolyee_salary_desc))


SELECT *
FROM Employee WITH(INDEX(empolyee_salary_desc))

DROP INDEX Employee_Addresses ON Addresses;
-------------------------------------------------------------------------------------------------------
--Create UNIQUES
Alter Table dbo.Prescription ADD CONSTRAINT UQ_MEDICATION UNIQUE NONCLUSTERED (Medication)
Alter Table Employee ADD CONSTRAINT UQ_PNUMBER UNIQUE NONCLUSTERED (PNumber)

Alter Table Employee
Drop Constraint UQ_PNUMBER
-------------------------------------------------------------------------------------------------------
--Create DEFAULTS

ALTER TABLE dbo.UnderGoes ADD CONSTRAINT DF_Date DEFAULT getdate() for [Date]
ALTER TABLE dbo.Appointment ADD CONSTRAINT DF_Date DEFAULT getdate() for [Date]
ALTER TABLE dbo.Stay ADD CONSTRAINT DF_Start_Date DEFAULT getdate() for [Start]
ALTER TABLE dbo.Stay ADD CONSTRAINT DF_End_Date DEFAULT getdate() for [End]

ALTER TABLE dbo.Addresses ADD CONSTRAINT DF_Address_State DEFAULT 'Turkey' for [State]
ALTER TABLE dbo.Addresses ADD CONSTRAINT DF_Address_City DEFAULT 'Istanbul' for [City]
ALTER TABLE dbo.Addresses ADD CONSTRAINT DF_Address_ZipCode DEFAULT 34720  for [ZipCode]

ALTER TABLE Addresses
Drop Constraint DF_Address_ZipCode
-------------------------------------------------------------------------------------------------------
--Create Identities
-------------------------------------------------------------------------------------------------------
--Create CHECK CONSTRAINTS
--Check1
ALTER TABLE Employee
ADD CHECK (Age>=18);
--Check2
Alter Table Employee
Add Check (Salary >= 1000)
--Çalýþanlarýn adresi istanbul check constraint
--Check3
Alter Table Addresses
ADD CHECK (AddresID not in (Select e.AddressID
							From Employee e inner join Addresses a on e.AddressID = a.AddressID
							Where e.AddressID >= 10000 and e.AddressID < 20000 and a.City like 'Istanbul'))


ALTER TABLE Addresses
ADD CHECK (AddressID>10000 and AddressID<20000 and City like 'Istanbul');
-------------------------------------------------------------------------------------------------------
--Computed columns
-------------------------------------------------------------------------------------------------------
Update Employee
Set age = DATEDIFF(year, DateOfBirth, GETDATE())

-------------------------------------------------------------------------------------------------------
--Views
--View1
create view Avg_Salary
as
Select avg(e1.Salary) "Doctor Average Salary" , avg(e2.Salary) "Nurse Average Salary" , avg(e3.Salary) "Trainee Average Salary"
from Employee e1, Employee e2, Employee e3, Doctor d, Nurse n, Trainee t
where e1.EmployeeID = d.DoctorID AND n.NurseID = e2.EmployeeID AND t.TraineeID = e3.EmployeeID

Select * From Avg_Salary
-------------------------------------------------------------------------------------------------------
--View2
create view Nurse_count_surgery
as
select u.NurseID,Count(*) Count_join_surgery , s.Name from dbo.UnderGoes u join dbo.Surgery s on u.ProcedureID=s.ProcedureID where u.NurseID IS NOT NULL
group by u.NurseID,s.Name 

select *  from Nurse_count_surgery

Drop view Nurse_count_surgery
-------------------------------------------------------------------------------------------------------
--View3
create view  Patient_Surgeries
as
SELECT distinct p.PatientID,p.FirstName,p.LastName,p.Age,p.AddressID, s.Name,Count(*) NumberOfSurgeries,s.Cost
FROM Patient p
inner join UnderGoes u on p.PatientID=u.PatientID
inner join Surgery s on s.ProcedureID =u.ProcedureID
group by p.PatientID,p.FirstName,p.LastName,p.Age,p.AddressID,s.Name,s.Cost
having count(*) >= 1

select *  from Patient_Surgeries

Drop view Patient_Surgeries
-------------------------------------------------------------------------------------------------------
--View4
alter view Attending_Nurses
as
Select   e.EmployeeID,e.FirstName +' '+ e.LastName "Employee Name", s.Room, p.FirstName +' '+ p.LastName "Patient Name", p.PatientID
FROM Employee e
inner join Nurse n on e.EmployeeID=n.NurseID
inner join Undergoes u on u.NurseID=n.NurseID
inner join Stay s on s.StayID=u.StayID
inner join Patient p on p.PatientID=s.Patient

select *  from Attending_Nurses
-------------------------------------------------------------------------------------------------------
--View5

create view  Appointment_Info
as
Select e.FirstName + ' ' + e.LastName as DoctorFullName, ap.Date, pr.Medication,p.FirstName + ' ' + p.LastName as PatientFullName
From Employee e, Doctor d, Appointment ap, Prescription pr, Patient p
Where e.EmployeeID = d.DoctorID and d.DoctorID = ap.DoctorID and ap.PatientID = p.PatientID and ap.AppointmentID = pr.AppointmentID
and pr.Medication like 'Granidryl Aflucane'

select *  from Appointment_Info
-------------------------------------------------------------------------------------------------------
--View6
--Find doctors with multiple appointments and more than one operations
Alter view Find_Doctors
as
Select Distinct e.EmployeeID, e.FirstName + ' ' + e.LastName as DoctorFullName, Count(e.EmployeeID) noOfUnderGoes, u.NurseID
From Employee e left outer join UnderGoes u on u.DoctorID=e.EmployeeID 
where e.EmployeeID in (Select a.DoctorID
                    from Appointment a
                    group by a.DoctorID
                    having count(*)>=2)
group by e.EmployeeID, e.FirstName + ' ' + e.LastName , u.DoctorID, u.NurseID
having count(*)>=1

Select * From Find_Doctors
-------------------------------------------------------------------------------------------------------
--Stored Procedures
--Procedure1
--Information of all the female over 40 patients that had cataract surgery and the doctor that performed it
CREATE PROCEDURE GetCataractPatients
AS
BEGIN
SET NOCOUNT ON
Select pa.PatientID, pa.FirstName, pa.LastName, pa.Age, pa.Gender, e.FirstName + ' '  + E.LastName as Doctor_Full_Name, do.DoctorID
From Employee e inner join Doctor do on e.EmployeeID = do.DoctorID inner join UnderGoes u on do.DoctorID = u.DoctorID inner join Patient pa on pa.PatientID = u.PatientID
Where pa.PatientID in (SELECT p.PatientID
						FROM Patient p
						WHERE p.PatientID IN
						( SELECT u.PatientID
						FROM UnderGoes u
						LEFT JOIN Surgery s ON u.ProcedureID=s.ProcedureID
						WHERE s.Name like 'Cataract surgery' and p.Age>=40 and p.Gender like 'F'));
END

exec GetCataractPatients

Drop procedure GetCataractPatients
-------------------------------------------------------------------------------------------------------
--Insert Patient
--Procedure2
CREATE PROCEDURE insertPatient
       @PatientID                   int  = NULL   , 
       @FirstName					NVARCHAR(50)      = NULL   , 
       @LastName                    NVARCHAR(50)  = NULL   ,
	   @AddressID					int = NULL,
       @Age							int = NULL,
	   @Gender                      VARCHAR(1)  = NULL  
AS 
BEGIN 
     SET NOCOUNT ON 

     INSERT INTO dbo.Patient
          (                    
            PatientID                   ,
            FirstName                   , 
            LastName                    ,
			AddressID					,
            Age							,
			Gender
          ) 
     VALUES 
          ( 
            @PatientID,
            @FirstName,
            @LastName,
			@AddressID,
            @Age,
			@Gender
          ) 

END 

GO
SET IDENTITY_INSERT Patient OFF

exec insertPatient
    @PatientID  = 300   , 
    @FirstName = 'Ali',
	@LastName = 'Çelik',
	@AddressID = 20030,
	@Gender = 'M'

--------------------------------------------------------------------------------------------------------------------

--Procedure3
--Create Employee
CREATE PROCEDURE insertEmployee
       @EmployeeID                   int  = NULL   , 
       @FirstName					NVARCHAR(50)      = NULL   , 
       @LastName                    NVARCHAR(50)  = NULL   ,
	   @Salary						int = NULL,
       @DateOfBirth					date = NULL,
	   @Age							int = NULL,
	   @Gender						VARCHAR(1) = NULL,
	   @AddressID					int = NULL,
	   @PNumber						VARCHAR(50) = NULL
AS 
BEGIN 
     SET NOCOUNT ON 

     INSERT INTO dbo.Employee
          (                    
            EmployeeID      ,              
			FirstName	,				
			LastName    ,                
			Salary	,					
			DateOfBirth,					
			Age	,						
			Gender	,					
			AddressID,					
			PNumber
          ) 
     VALUES 
          ( 
            @EmployeeID      ,              
			@FirstName	,				
			@LastName    ,                
			@Salary	,					
			@DateOfBirth,					
			@Age	,						
			@Gender	,					
			@AddressID,					
			@PNumber
          ) 
END 
GO
SET IDENTITY_INSERT Employee OFF
exec insertEmployee
    @EmployeeID  = 150  , 
    @FirstName = 'Ayþe',
	@LastName = 'Burçak',
	@Salary = '4200',
	@DateOfBirth = '1990-12-03',
	@Age = NULL,
	@Gender = 'M',
	@AddressID = 20030,
	@PNumber = '(152) 398-8269'

--------------------------------------------------------------------------------------------------------------------
--Create Address
--Procedure 4
CREATE PROCEDURE insertAddress
       @AddressID                   int  = NULL   , 
       @State						NVARCHAR(50)      = NULL   , 
       @City						NVARCHAR(50)  = NULL   ,
	   @ZipCode						NVARCHAR(50)  = NULL

AS 
BEGIN 
     SET NOCOUNT ON 

     INSERT INTO dbo.Addresses
          (                    
            AddressID,                 
			State,						 
			City,						
			ZipCode		
          ) 
     VALUES 
          ( 
            @AddressID,                   
			@State,						
			@City,						
			@ZipCode		
          ) 

END 

GO
SET IDENTITY_INSERT Addresses ON

exec insertAddress
    @AddressID  = 20050  , 
    @State = 'Türkiye',
	@City = 'Ankara',
	@ZipCode = '3100'

--------------------------------------------------------------------------------------------------------------------
--Create Appointment 
--Procedure 5
alter PROCEDURE insertAppointment
       @AppointmentID               int  = NULL   , 
       @DoctorID                    int  = NULL   ,
       @PatientID                    int  = NULL


AS 
BEGIN 
     SET NOCOUNT ON 
DECLARE @cu date = getdate()+6;
     INSERT INTO dbo.Appointment
          (
            AppointmentID ,
            DoctorID    ,
            PatientID,
            Date
          ) 
     VALUES 
          ( 
            @AppointmentID  ,
            @DoctorID    ,
            @PatientID,
            @cu
          ) 

END

GO
SET IDENTITY_INSERT Appointment ON
SET IDENTITY_INSERT Employee ON

exec insertAppointment 998,22,202,'2018-12-01'

--------------------------------------------------------------------------------------------------------------------
--Procedure 6
CREATE PROCEDURE emp_for_raise_proc
(@p_empid int)
AS
DECLARE
        @v_empsalary int,
        @v_empname nvarchar(50)
BEGIN
        SELECT @v_empsalary = Salary , @v_empname = LastName
        FROM Employee e, Doctor do
        WHERE e.EmployeeID = @p_empid
 
        IF (@v_empsalary < 5000)
        PRINT 'This employee is up for a raise --&amp;gt; ' + @v_empname
        ELSE
        PRINT 'This employees is not up for a raise -- &amp;gt; ' + @v_empname
END

EXEC emp_for_raise_proc 36

DROP PROCEDURE emp_for_raise_proc
--------------------------------------------------------------------------------------------------------------------

--Procedure 7
CREATE PROCEDURE check_salary_raise
(@p_employeeID  int)
AS
DECLARE
    @v_empSalary int  ,
    @v_empName nvarchar(25)
BEGIN
    SELECT @v_empSalary = Salary , @v_empName = FirstName + LastName
    FROM Employee
    WHERE EmployeeID = @p_employeeID
 
    PRINT 'Current Salary for employee is : ' +  CAST(@v_empSalary AS VARCHAR) + ' (' + @v_empName + ')'
 
    IF @v_empSalary > 5000
    PRINT 'Greater than 5000'
    ELSE IF @v_empSalary= 5000
    PRINT 'Equal to 5000'
    ELSE
    BEGIN
        PRINT 'Less than 5000'
        UPDATE Employee SET Salary = Salary * 1.1 WHERE EmployeeID = @p_employeeID
        -- Print new price
        SELECT @v_empSalary = Salary , @v_empName = FirstName + LastName
        FROM Employee
        WHERE EmployeeID = @p_employeeID
        PRINT 'Current Salary is : ' +  CAST(@v_empSalary AS VARCHAR) + ' (' + @v_empName + ')'
    END
END
 
EXEC check_salary_raise 11

DROP PROCEDURE check_salary_raise

----------------------------------------------------------------------------------------------------------------------
--Procedure 8
CREATE PROCEDURE change_address
(@p_addID int, @p_empID int)
AS
DECLARE
        @v_empID int,
        @v_empCurrentAdd int
BEGIN
        SELECT @v_empID = EmployeeID , @v_empCurrentAdd = e.AddressID
        FROM Employee e, Addresses a
        WHERE e.EmployeeID = @p_empID and e.AddressID = @v_empCurrentAdd
 
        UPDATE Employee SET AddressID = @p_addID WHERE EmployeeID = @p_empID 
END

EXEC change_address 10010,1
--
--------------------------------------------------------------------------------------------------------------------
--Procedure 9
CREATE PROCEDURE createUnderGoes
       @PatientID                   int, 
       @ProcedureID                 int, 
       @StayID						int  = NULL   ,
	   @Date						date = NULL,
       @DoctorID					int, 
	   @NurseID						int 
AS 
BEGIN 
     SET NOCOUNT ON 

     INSERT INTO dbo.UnderGoes
          (                    
            PatientID                   , 
			ProcedureID                 , 
			StayID						   ,
			Date						,
			DoctorID					, 
			NurseID						 
          ) 
     VALUES 
          ( 
            @PatientID                   , 
			@ProcedureID                 , 
			@StayID						   ,
			@Date						,
			@DoctorID					, 
			@NurseID					
          ) 

END 

exec createUnderGoes
    @PatientID  = 204   , 
    @ProcedureID	 = 703   ,
	@StayID = NULL,
	@Date = '2018-02-12',
	@DoctorID = 27,
	@NurseID = 5
--------------------------------------------------------------------------------------------------------------------
--Procedudre 10
-- Find Empty Room After Operation
CREATE PROCEDURE check_empty_room
(@p_operationID  int,@p_stayID int)
AS
DECLARE
    @v_stayID int  ,
    @v_roomID int,
	@v_isAvailable smallint
BEGIN
    SELECT @v_stayID = s.StayID, @v_roomID = r.RoomNumber, @v_isAvailable = r.isAvailable
    FROM Stay s, Room r, UnderGoes u
    WHERE s.StayID = @p_stayID and u.OperationID = @p_operationID and s.Room = r.RoomNumber
 

    IF @v_isAvailable = 1
	BEGIN
    PRINT 'Room is Empty! '
	UPDATE UnderGoes SET StayID = @v_stayID WHERE OperationID = @p_operationID
	Update Room Set isAvailable = 0 Where roomNumber = @v_roomID
	PRINT 'Your room is : ' +  CAST(@v_roomID AS VARCHAR)
	END
    ELSE
	BEGIN
    PRINT 'Room is being used by another patient. Please try another stayID. '
	END
END

EXEC check_empty_room 38,10

Drop procedure check_empty_room

--------------------------------------------------------------------------------------------------------------------

--Trigger1
--Calculate Age After each insertion of Employee?
Create Trigger tr_UpdateAge
	On Employee
	After Insert
As
Begin
	Update e
	Set e.Age = DATEDIFF(year, e.DateOfBirth, GETDATE())
	From Employee e inner join inserted i on e.EmployeeID = i.EmployeeID

End
Go

ALTER TABLE [dbo].Employee ENABLE TRIGGER tr_UpdateAge
--------------------------------------------------------------------------------------------------------------------
--Trigger 2
Create Trigger update_Employee
	On Employee
	After insert,delete,update
As
Begin
	Update e
	Set e.Age = DATEDIFF(year, e.DateOfBirth, GETDATE())
	From Employee e inner join inserted as i on e.EmployeeID = i.EmployeeID

	Delete From Doctor Where DoctorID in (Select EmployeeID from deleted)
	DELETE FROM Appointment WHERE Appointment.DoctorID IN (SELECT EmployeeID FROM deleted)

End
Go

Delete From Employee Where EmployeeID = 1000
Drop trigger update_Employee

--------------------------------------------------------------------------------------------------------------------
