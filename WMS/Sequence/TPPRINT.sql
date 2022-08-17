 

/****** Object:  Sequence [dbo].[TPPRINT]    Script Date: 8/17/2022 4:35:03 PM ******/
CREATE SEQUENCE [dbo].[TPPRINT] 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 999999989999
 CYCLE 
 CACHE  50 
GO
grant Update on dbo.[TPPRINT]  to NSQL
GO

