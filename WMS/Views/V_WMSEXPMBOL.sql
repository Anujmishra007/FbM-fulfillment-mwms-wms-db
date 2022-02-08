SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_WMSEXPMBOL]   
AS   
SELECT [ExternOrderkey]  
, [Consigneekey]  
, [ExternLineNo]  
, [SKU]  
, [OriginalQty]  
, [ShippedQty]  
, [Shortqty]  
, [TRANSFLAG]  
, [MBOLKey]  
, [AddDate]  
, [EditDate]  
, [TotalCarton]  
, [StorerKey]  
FROM [WMSEXPMBOL] (NOLOCK)   
GO
GRANT DELETE ON  [dbo].[V_WMSEXPMBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_WMSEXPMBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_WMSEXPMBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_WMSEXPMBOL] TO [NSQL]
GO
