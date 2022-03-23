SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_WMS_Users]
AS
SELECT
   DATEPART(year,  login_date) As [Year],
   DATEPART(month, login_date) As [Month],
   Application,
   COUNT(Distinct login_name) As NoOfUsers
FROM USER_CONNECTIONS WITH (NOLOCK)
where  NOT ( Application = 'RDT' and login_name = 'RESET' )
GROUP BY
   DATEPART(month, login_date),
   DATEPART(year,  login_date),
   Application

GO
GRANT DELETE ON  [dbo].[V_WMS_Users] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WMS_Users] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WMS_Users] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WMS_Users] TO [NSQL]
GO
