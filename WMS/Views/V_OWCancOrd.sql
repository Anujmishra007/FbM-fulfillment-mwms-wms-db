SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_OWCancOrd]
AS
SELECT O.ExternOrderkey, O.Orderkey, O.Facility, O.OrderDate, O.DeliveryDate, O.Consigneekey, O.C_Company, O.AddDate, O.DelDate, O.DelWho
FROM  dbo.OrdersLog O (nolock)
INNER JOIN dbo.StorerConfig S (NOLOCK) ON S.Storerkey = O.Storerkey AND S.Configkey = 'OWITF' AND S.svalue = '1'

GO
GRANT DELETE ON  [dbo].[V_OWCancOrd] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_OWCancOrd] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_OWCancOrd] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_OWCancOrd] TO [NSQL]
GO
