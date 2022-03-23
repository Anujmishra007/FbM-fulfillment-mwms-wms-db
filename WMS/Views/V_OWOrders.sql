SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_OWOrders]
AS
SELECT ExternOrderKey, Orders.AddDate FROM ORDERS (NOLOCK), STORERCONFIG (NOLOCK)
WHERE  Orders.StorerKey = StorerConfig.StorerKey
AND    ConfigKey = 'OWITF'
AND    sValue = '1'
AND    Orders.AddDate > '01 May 2002'
AND    ExternOrderKey <> ''
UNION
SELECT ExternreceiptKey, Receipt.AddDate FROM RECEIPT (NOLOCK), STORERCONFIG (NOLOCK)
WHERE  RECEIPT.StorerKey = StorerConfig.StorerKey
AND    ConfigKey = 'OWITF'
AND    sValue = '1'
AND    RECEIPT.AddDate > '01 May 2002'
AND    ExternReceiptKey <> ''










GO
GRANT DELETE ON  [dbo].[V_OWOrders] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_OWOrders] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_OWOrders] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_OWOrders] TO [NSQL]
GO
