SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [BI].[V_TH_4CARE_Outbound] AS
SELECT
   O.StorerKey,
   O.ExternOrderKey,
   O.ConsigneeKey,
   O.C_Company,
   OD.Sku,
   S.DESCR,
   PD.Qty,
   PD.ID,
   case
      when
         A.Lottable01 = 'UR' 
      then
         'Saleable' 
      else
         A.Lottable01 
   end AS 'Status'
, A.Lottable02, A.Lottable03, A.Lottable04, 
   case
      when
         len(A.Lottable06) = '0' 
      then
         '' 
      else
         SUBSTRING(A.Lottable06, CHARINDEX('-', A.Lottable06) + 1, Len(A.Lottable06)) 
   end AS 'Container No.'
, 
   case
      when
         len(A.Lottable06) = '0' 
      then
         '' 
      else
         SUBSTRING(A.Lottable06, 1, CHARINDEX('-', A.Lottable06)) 
   end 'Invoice No.'
FROM
   dbo.ORDERS O
join dbo.ORDERDETAIL OD with (nolock) on O.OrderKey = OD.OrderKey 
      AND O.StorerKey = OD.StorerKey 
join dbo.SKU S with (nolock) on OD.StorerKey = S.StorerKey 
      AND OD.Sku = S.Sku 
join dbo.PICKDETAIL PD with (nolock) on OD.OrderKey = PD.OrderKey 
      AND OD.StorerKey = PD.Storerkey 
      AND OD.Sku = PD.Sku 
      AND OD.OrderLineNumber = PD.OrderLineNumber 
join dbo.LOTATTRIBUTE A with (nolock) on PD.Storerkey = A.StorerKey 
      AND PD.Sku = A.Sku 
      AND PD.Lot = A.Lot
WHERE O.StorerKey = '4CARE' 
      AND O.Status = '9' 
      AND convert(varchar, OD.EditDate, 112) >= convert(varchar, getdate() - 1, 112)
GO
GRANT SELECT ON  [BI].V_TH_4CARE_Outbound TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH_4CARE_Outbound]

REVERT;
*/