IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ALPHA\YingShanWong')
CREATE LOGIN [ALPHA\YingShanWong] FROM WINDOWS
GO
CREATE USER [ALPHA\YingShanWong] FOR LOGIN [ALPHA\YingShanWong]
GO
