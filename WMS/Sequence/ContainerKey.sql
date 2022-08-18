/****** Object:  Sequence [dbo].[ContainerKey]    Script Date: 8/17/2022 4:40:16 PM ******/
CREATE SEQUENCE [dbo].[ContainerKey] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 999999989999
 CYCLE 
 CACHE  50 
GO

grant Update on dbo.[ContainerKey]  to NSQL
GO
