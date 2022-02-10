IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ALPHA\ChuanJingOoi')
CREATE LOGIN [ALPHA\ChuanJingOoi] FROM WINDOWS
GO
CREATE USER [ALPHA\ChuanJingOoi] FOR LOGIN [ALPHA\ChuanJingOoi]
GO
