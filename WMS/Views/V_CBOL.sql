SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/* MY have exist CBOL physical table and view table early */
/* 2020-12-16 kocy  WMS-15883  create for CN Sephora      */

CREATE   VIEW [dbo].[V_CBOL]  AS
SELECT * 
FROM [dbo].[CBOL] WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_CBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_CBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_CBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_CBOL] TO [NSQL]
GO
