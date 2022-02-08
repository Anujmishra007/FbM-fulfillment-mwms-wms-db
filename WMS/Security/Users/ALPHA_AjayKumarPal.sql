IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ALPHA\AjayKumarPal')
CREATE LOGIN [ALPHA\AjayKumarPal] FROM WINDOWS
GO
CREATE USER [ALPHA\AjayKumarPal] FOR LOGIN [ALPHA\AjayKumarPal]
GO
