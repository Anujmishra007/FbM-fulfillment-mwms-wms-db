SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE VIEW [dbo].[v_rdtSTDEventLog]   
  
 AS SELECT *   
 FROM [rdt].[rdtSTDEventLog] WITH (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[v_rdtSTDEventLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[v_rdtSTDEventLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[v_rdtSTDEventLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[v_rdtSTDEventLog] TO [NSQL]
GO
