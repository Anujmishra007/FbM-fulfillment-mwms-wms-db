IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ALPHA\VivekDubey')
CREATE LOGIN [ALPHA\VivekDubey] FROM WINDOWS
GO
CREATE USER [ALPHA\VivekDubey] FOR LOGIN [ALPHA\VivekDubey]
GO
