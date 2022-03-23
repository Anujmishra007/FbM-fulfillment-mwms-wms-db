SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_ids_ec_scgdsrn]
AS
SELECT [externreceiptkey]
, [pokey]
, [sku]
, [goodqty]
, [badqty]
FROM [ids_ec_scgdsrn] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_ids_ec_scgdsrn] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_ids_ec_scgdsrn] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_ids_ec_scgdsrn] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_ids_ec_scgdsrn] TO [NSQL]
GO
