SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [BI].[V_TH_JNJTRKIT_TotalShipped] AS 
SELECT
   O.StorerKey,
   M.DepartureDate,
   convert(varchar, O.DeliveryDate, 105) AS 'Delivery date',
   O.ConsigneeKey,
   OD.OriginalQty,
   OD.ShippedQty,
   convert(varchar, OD.EffectiveDate, 105) AS 'Efeective date',
   O.OrderKey,
   OD.MBOLKey,
   OD.Sku,
   O.ExternOrderKey,
   M.ArrivalDate,
   M.ArrivalDateFinalDestination,
   M.Remarks,
   OD.Lottable02 
FROM
   dbo.ORDERS O with (nolock)
JOIN dbo.ORDERDETAIL OD with (nolock) ON O.OrderKey = OD.OrderKey 
      AND O.StorerKey = OD.StorerKey 
JOIN dbo.MBOL M with (nolock) ON O.MBOLKey = M.MbolKey 
      AND O.Facility = M.Facility
WHERE
   (
(O.StorerKey = 'JNJTRKIT' 
      AND convert(varchar, O.DeliveryDate, 112) > convert(varchar, getdate() - 31, 112) 
      and convert(varchar, O.DeliveryDate, 112) <= convert(varchar, getdate(), 112) 
      AND OD.Status = '9' 
      AND O.Status = '9')
   )
--ORDER BY
--   3,
--   8
--   Deliverydate and  OrderKey
GO
GRANT SELECT ON  [BI].V_TH_JNJTRKIT_TotalShipped TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH_JNJTRKIT_TotalShipped]

REVERT;
*/