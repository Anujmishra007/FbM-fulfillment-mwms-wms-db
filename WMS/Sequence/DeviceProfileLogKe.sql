/****** Object:  Sequence [dbo].[DeviceProfileLogKe]    Script Date: 8/17/2022 4:39:54 PM ******/
CREATE SEQUENCE [dbo].[DeviceProfileLogKe] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 999999989999
 CYCLE 
 CACHE  50 
GO

grant Update on dbo.[DeviceProfileLogKe]  to NSQL
GO

