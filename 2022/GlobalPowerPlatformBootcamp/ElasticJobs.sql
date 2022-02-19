-- job server | job database
-- create a database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD='<EnterStrongPasswordHere>';  

-- job server | job database
-- The credential to connect to the Azure SQL logical server, to execute jobs
CREATE DATABASE SCOPED CREDENTIAL job_credential WITH IDENTITY = 'job_credential',
    SECRET = '<EnterStrongPasswordHere>';
GO
-- The credential to connect to the Azure SQL logical server, to refresh the database metadata in server
CREATE DATABASE SCOPED CREDENTIAL refresh_credential WITH IDENTITY = 'refresh_credential',
    SECRET = '<EnterStrongPasswordHere>';
GO




-- target server | master database
CREATE LOGIN [refresh_credential] WITH PASSWORD = N'<EnterStrongPasswordHere>';
CREATE USER [refresh_credential] FOR LOGIN [refresh_credential];
CREATE LOGIN [job_credential] WITH PASSWORD = N'<EnterStrongPasswordHere>';

 
 -- target server | target database
CREATE USER [job_credential] FOR LOGIN [job_credential];
ALTER ROLE db_ddladmin ADD MEMBER [job_credential];




-- job server | job database
-- create Target group
EXEC jobs.sp_add_target_group @target_group_name = 'TargetGroupForDemo';

-- add members
EXEC jobs.sp_add_target_group_member @target_group_name ='TargetGroupForDemo',
                                     @membership_type = 'Include',
                                     @target_type = 'SqlServer',
                                     @refresh_credential_name = 'refresh_credential',
                                     @server_name = 'portaltargetserver.database.windows.net'

-- confirm it has been added
SELECT * FROM jobs.target_groups 
SELECT * FROM jobs.target_group_members


-- job server | job database
-- create job
EXEC jobs.sp_add_job @job_name = 'JobToCreateTable',
                     @description = 'JobToCreateTable',
                     @enabled = 0,
                     @schedule_interval_type = 'Once';

-- add job steps
EXEC jobs.sp_add_jobstep @job_name = 'JobToCreateTable',
                         @step_name = 'StepToCreateTable',
                         @command = 'IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id(''Table'')) CREATE TABLE [dbo].[Table]([TestId] [int] NOT NULL);',
                         @credential_name = 'job_credential',
                         @target_group_name = 'TargetGroupForDemo',
                         @max_parallelism = 3;
/*


	select * from jobs.jobs
	select * from jobs.jobsteps;


*/
-- start the job
EXEC jobs.sp_start_job @job_name = N'JobToCreateTable';


/*


	select * from jobs.job_executions
	select @@servername, db_name()

*/