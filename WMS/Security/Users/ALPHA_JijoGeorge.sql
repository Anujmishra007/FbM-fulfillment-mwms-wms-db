IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ALPHA\JijoGeorge')
CREATE LOGIN [ALPHA\JijoGeorge] FROM WINDOWS
GO
CREATE USER [ALPHA\JijoGeorge] FOR LOGIN [ALPHA\JijoGeorge]
GO
