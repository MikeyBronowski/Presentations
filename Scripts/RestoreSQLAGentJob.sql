-- use restored msdb database backup
USE [msdb_backup];

-- set the bane of the job that needs to be restored
DECLARE @JobName NVARCHAR(MAX) = N'NewJobToBeRestored_001_name';

-- this will add a suffix to the name of the job
DECLARE @JobNameSuffix NVARCHAR(MAX) = N'_RESTORED';

DECLARE @Begin NVARCHAR(MAX) = CHAR(10) + 'BEGIN ' + CHAR(10);
DECLARE @End NVARCHAR(MAX) = CHAR(10) + 'END ' + CHAR(10);
DECLARE @SQLCommand NVARCHAR(MAX) = '';
DECLARE @Transaction NVARCHAR(MAX) = 'USE [msdb];' + CHAR(10) + 
'BEGIN TRANSACTION
DECLARE @ReturnCode INT = 0;
';
DECLARE @ReturnCode NVARCHAR(MAX) = '@ReturnCode = '
DECLARE @Error NVARCHAR(MAX) = CHAR(10) + 'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
DECLARE @QuitWithRollback NVARCHAR(MAX) = 'COMMIT TRANSACTION' + CHAR(10) + 'GOTO EndSave QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION' + CHAR(10) + 
'EndSave:';

SET @SQLCommand = @Transaction + @SQLCommand;

CREATE TABLE #JOBCREATION (id int identity(1,1),cmd text);

INSERT INTO #JOBCREATION
SELECT @SQLCommand;

-- 1. Category
INSERT INTO #JOBCREATION
SELECT 'IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name= '+ 'N''' 
+ sc.name + '''' + ' AND category_class=' + CAST(sc.category_class AS NVARCHAR(MAX)) +')'
	+ @Begin
	+ 'EXEC @ReturnCode = msdb.dbo.sp_add_category '
	+ '@class='+ 'N'''+ CAST(CASE sc.category_class 
WHEN 1 THEN 'JOB' 
WHEN 2 THEN 'ALERT' 
WHEN 3 THEN 'OPERATOR'
ELSE 'N/A'
END AS NVARCHAR) + ''''
	+ ', ' + '@type='+ 'N'''+ CAST(
CASE sc.category_type 
WHEN 1 THEN 'LOCAL' 
WHEN 2 THEN 'MULTISERVER' 
WHEN 3 THEN 'OPERATOR'
ELSE 'N/A'
END AS NVARCHAR(MAX)) + ''''
	+ ', ' + '@name='+ 'N''' + sc.name + ''''
	+ ';'
	+ @Error 
	+ @End
FROM dbo.sysjobs AS sj 
	JOIN dbo.syscategories AS sc ON sj.category_id = sc.category_id
WHERE sj.name = @JobName;

-- 2. Add job
INSERT INTO #JOBCREATION
SELECT 'EXEC @ReturnCode = msdb.dbo.sp_add_job '
	+ '@job_name='+ 'N''' + sj.name + @JobNameSuffix + ''''
	+ ', ' + '@enabled='+ CAST(sj.enabled AS NVARCHAR(MAX))
	+ ', ' + '@notify_email_operator_name='+ CAST(COALESCE(so.name,'''''') AS NVARCHAR(MAX))
	+ ', ' + '@notify_level_eventlog='	+ CAST(sj.notify_level_eventlog AS NVARCHAR(MAX))
	+ ', ' + '@notify_level_email='		+ CAST(sj.notify_level_email AS NVARCHAR(MAX))
	+ ', ' + '@notify_level_netsend='	+ CAST(sj.notify_level_netsend AS NVARCHAR(MAX))
	+ ', ' + '@notify_level_page='		+ CAST(sj.notify_level_page AS NVARCHAR(MAX))
	+ ', ' + '@delete_level='		+ CAST(sj.delete_level AS NVARCHAR(MAX))
	+ ', ' + '@description='		+ 'N''' + COALESCE(description, '') + ''''
	+ ', ' + '@category_name='		+ 'N''' + CAST(sc.name AS NVARCHAR(MAX)) + ''''
	+ ', ' + '@owner_login_name='		+ 'N''' + COALESCE(CAST(SUSER_SNAME(owner_sid) AS NVARCHAR(MAX)),'') + ''''
	+ ';'
	+ @Error 
FROM dbo.sysjobs AS sj 
	JOIN dbo.syscategories AS sc ON sj.category_id = sc.category_id
	LEFT JOIN dbo.sysoperators AS so ON sj.notify_email_operator_id = so.id
WHERE sj.name = @JobName;

-- 3. Add job steps
INSERT INTO #JOBCREATION
SELECT 'EXEC @ReturnCode = msdb.dbo.sp_add_jobstep '
	+ '@job_name='+ 'N''' + CAST(sj.name + @JobNameSuffix AS NVARCHAR(MAX)) + ''''
	+ ', ' + '@step_name='			+ 'N''' + step_name + ''''
	+ ', ' + '@step_id='			+ CAST(step_id AS NVARCHAR)
	+ ', ' + '@cmdexec_success_code='	+ CAST(cmdexec_success_code AS NVARCHAR(MAX))
	+ ', ' + '@on_success_action='		+ CAST(on_success_action AS NVARCHAR(MAX))
	+ ', ' + '@on_success_step_id='	+ CAST(on_success_step_id AS NVARCHAR(MAX))
	+ ', ' + '@on_fail_action='		+ CAST(on_fail_action AS NVARCHAR(MAX))
	+ ', ' + '@on_fail_step_id='		+ CAST(on_fail_step_id AS NVARCHAR(MAX))
	+ ', ' + '@retry_attempts='		+ CAST(retry_attempts AS NVARCHAR(MAX))
	+ ', ' + '@retry_interval='		+ CAST(retry_interval AS NVARCHAR(MAX))
	+ ', ' + '@os_run_priority='		+ CAST(os_run_priority AS NVARCHAR(MAX))
	+ ', ' + '@subsystem='			+ 'N''' + subsystem + ''''
	+ ', ' + '@command='			+ 'N''' + COALESCE(command,'') + ''''
	+ ', ' + '@database_name='		+ 'N''' + COALESCE(database_name,'') + ''''
	+ ', ' + '@output_file_name='		+ 'N''' + COALESCE(output_file_name,'') + ''''
	+ ', ' + '@flags='			+ CAST(flags AS NVARCHAR(MAX))
	+ ';'
	+ @Error 
FROM dbo.sysjobs AS sj 
	JOIN dbo.sysjobsteps AS sjs ON sj.job_id = sjs.job_id
WHERE sj.name = @JobName
ORDER BY sjs.step_id ASC;

-- 4. Startup step
-- it is needed in case the job starts from step_id > 1
INSERT INTO #JOBCREATION
SELECT 'EXEC @ReturnCode = msdb.dbo.sp_update_job '
	+ '@job_name='+ 'N''' + sj.name + @JobNameSuffix + ''''
	+ ', ' + '@start_step_id='+ CAST([start_step_id] AS NVARCHAR(MAX))
	+ ';'
	+ @Error 
FROM dbo.sysjobs AS sj 
WHERE sj.name = @JobName;

-- 5. Add schedule
INSERT INTO #JOBCREATION
SELECT 'EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule '
	+ '@job_name='+ 'N''' + CAST(sj.name + @JobNameSuffix AS NVARCHAR(MAX)) + ''''
	+ ', ' + '@name='+ 'N''' + CAST(ss.name AS NVARCHAR(MAX)) + ''''
	+ ', ' + '@enabled='			+ CAST(ss.enabled AS NVARCHAR(MAX))
	+ ', ' + '@freq_type='			+ CAST(ss.freq_type AS NVARCHAR(MAX))
	+ ', ' + '@freq_interval='		+ CAST(ss.freq_interval AS NVARCHAR(MAX))
	+ ', ' + '@freq_subday_type='		+ CAST(ss.freq_subday_type AS NVARCHAR(MAX))
	+ ', ' + '@freq_subday_interval='	+ CAST(ss.freq_subday_interval AS NVARCHAR(MAX))
	+ ', ' + '@freq_relative_interval='	+ CAST(ss.freq_relative_interval AS NVARCHAR(MAX))
	+ ', ' + '@freq_recurrence_factor='	+ CAST(ss.freq_recurrence_factor AS NVARCHAR(MAX))
	+ ', ' + '@active_start_date='		+ CAST(ss.active_start_date AS NVARCHAR(MAX))
	+ ', ' + '@active_end_date='		+ CAST(ss.active_end_date AS NVARCHAR(MAX))
	+ ', ' + '@active_start_time='		+ CAST(ss.active_start_time AS NVARCHAR(MAX))
	+ ', ' + '@active_end_time='		+ CAST(ss.active_end_time AS NVARCHAR(MAX))
	+ ';'
	+ @Error 
from sysjobschedules AS sjs
	join sysschedules AS ss on sjs.schedule_id = ss.schedule_id
	join sysjobs AS sj on sjs.job_id = sj.job_id
WHERE sj.name = @JobName;

-- 6. Add server
INSERT INTO #JOBCREATION
SELECT 'EXEC @ReturnCode = msdb.dbo.sp_add_jobserver '
	+ '@job_name='+ 'N''' + CAST(sj.name + @JobNameSuffix AS NVARCHAR(MAX)) + ''''
	+ ', ' + '@server_name = N''' + COALESCE(sts.server_name, '(LOCAL)') + ''''
	+ ';'
	+ @Error 
FROM sysjobservers AS sjs
JOIN sysjobs AS sj ON sjs.job_id = sj.job_id
LEFT JOIN systargetservers AS sts ON sjs.server_id = sts.server_id
WHERE sj.name = @JobName;

INSERT INTO #JOBCREATION
SELECT @QuitWithRollback;

-- see all the commands
SELECT * FROM #JOBCREATION;

-- drop the temp table
DROP TABLE #JOBCREATION;