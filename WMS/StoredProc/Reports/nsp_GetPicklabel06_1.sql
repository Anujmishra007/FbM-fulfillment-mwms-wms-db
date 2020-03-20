IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[nsp_GetPicklabel06_1]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[nsp_GetPicklabel06_1]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Proc : nsp_GetPicklabel06_1                                      */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-1066-UNITY - To migrate Picklabel from Hyperion to EXCEED  */
/*                                                                         */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Local Variables:                                                        */
/*                                                                         */
/* Called By: r_dw_picklabel_06_1                                          */
/*                                                                         */
/* PVCS Version: 1.1                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author      Ver   Purposes                                  */
/***************************************************************************/

CREATE PROC dbo.nsp_GetPicklabel06_1 (@c_wavekey NVARCHAR(10))
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   -- Added by YokeBeen on 30-Jul-2004 (SOS#25474) - (YokeBeen01)
   -- Added SKU.SUSR3 (Agency) & ORDERS.InvoiceNo.
   
   DECLARE @n_starttcnt INT

   ;With C as (SELECT row_number() OVER (ORDER BY ORD.ConsigneeKey + PDET.Sku) rownum,
	   PDET.DropID, 
	   L.PutawayZone, 
	   PDET.Sku, 
	   S.DESCR, 
	   SUM (PDET.Qty) Qty, 
	   P.CaseCnt, 
	   P.InnerPack, 
	   P.Qty PQty, 
	   WVDET.WaveKey, 
	   WVDET.EditWho, 
	   PDET.CaseID, 
	   Store = ORD.ConsigneeKey, 
	   STRSODef.Route, 
	   LEFT( S.BUSR7, 1) BUSR7, 
	   L1.LocationCategory, 
	   L1.LocLevel, 
	   L1.LocAisle, 
	   STLD.LOC STLD_Loc, 
	   PDET.Loc,
	   
	   CS =  (CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END),
	   Q1 =  SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt),

	   IN_Computed = ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ),

	   Q2 =   SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt) -  
			  ( ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ) * P.InnerPack ),
		
		PC = (CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt) -  
			  ( ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ) * P.InnerPack )) > 0 
					THEN SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt) -  
							( ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ) * P.InnerPack ) 
			  ELSE 0 END),
		PTL_Zone = Right(L.PutawayZone, Len(L.PutawayZone) - 3),
		TotalQty = CONVERT(VARCHAR, (CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END))
		           + '/' + CONVERT(VARCHAR, ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ))
					+ '/' + CONVERT(VARCHAR, (CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt) -  
			  ( ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ) * P.InnerPack )) > 0 
					THEN SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt) -  
							( ( CASE WHEN (SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) > 0 
							THEN (CASE WHEN P.InnerPack > 0 THEN FLOOR ((SUM(PDET.Qty) - ((CASE WHEN P.CaseCnt > 0 THEN FLOOR(SUM(PDET.Qty) / P.CaseCnt) ELSE 0 END) * P.CaseCnt)) / P.InnerPack) ELSE 0 END) 
					   ELSE 0 END ) * P.InnerPack ) 
			  ELSE 0 END)),
		 PackSize = CONVERT(VARCHAR, P.CaseCnt) + '/' + CONVERT(VARCHAR, P.InnerPack),
		  CASE WHEN UPPER(L1.LocationCategory) = 'RACK' AND L1.LocLevel = '1' THEN 'LOW' 
	           WHEN (UPPER(L1.Locationcategory) = UPPER('Shelving' ) AND Substring(PDET.Loc,1,2) = 'B7' AND L1.LocLevel < 4) THEN 'LOW'
               WHEN (UPPER(L1.LocationCategory) = UPPER('Shelving') AND (Substring(PDET.Loc,1,2) = 'B8' ) AND (L1.LocLevel <  3 ) ) THEN 'LOW' 
		  ELSE 'HIGH'  
	      END AS BayLevel,
		  
		  Srt = L1.LocAisle + '-' + (CASE WHEN UPPER(L1.LocationCategory) = 'RACK' AND L1.LocLevel = '1' THEN 'LOW' 
	           WHEN (UPPER(L1.Locationcategory) = UPPER('Shelving' ) AND Substring(PDET.Loc,1,2) = 'B7' AND L1.LocLevel < 4) THEN 'LOW'
               WHEN (UPPER(L1.LocationCategory) = UPPER('Shelving') AND (Substring(PDET.Loc,1,2) = 'B8' ) AND (L1.LocLevel <  3 ) ) THEN 'LOW' 
		  ELSE 'HIGH'  
	      END),
		  Serial_No_C = 1,
		  StoreSKU = ORD.ConsigneeKey + PDET.Sku
		  
FROM dbo.V_WAVEDETAIL WVDET, dbo.V_PICKDETAIL PDET, dbo.V_StoreToLocDetail STLD, dbo.V_LOC L, dbo.V_SKU S, dbo.V_PACK P, dbo.V_LOC L1, 
	 dbo.V_ORDERS ORD LEFT OUTER JOIN dbo.V_StorerSODefault STRSODef ON (STRSODef.StorerKey = ORD.ConsigneeKey) 
WHERE (WVDET.OrderKey = ORD.OrderKey AND ORD.ConsigneeKey = STLD.ConsigneeKey AND STLD.LOC = L.Loc AND ORD.OrderKey = PDET.OrderKey 
AND PDET.Storerkey = S.StorerKey AND S.Sku = PDET.Sku AND S.PACKKey = P.PackKey AND PDET.Loc = L1.Loc)  
AND ((WVDET.WaveKey = '0000005983' AND PDET.CaseID > '0')) 
GROUP BY PDET.DropID, L.PutawayZone, PDET.Sku, S.DESCR, P.CaseCnt, P.InnerPack, 
		 P.Qty, WVDET.WaveKey, WVDET.EditWho, PDET.CaseID, 
		 ORD.ConsigneeKey, STRSODef.Route, LEFT( S.BUSR7, 1), 
		 L1.LocationCategory, L1.LocLevel, L1.LocAisle, STLD.LOC, PDET.Loc)

Select A.DropID, A.PutAwayZone, A.SKU, A.Descr, A.Qty, A.CaseCnt, A.InnerPack, A.PQty, A.WaveKey,
	   A.EditWho, A.Store, A.CaseID, A.Route, A.BUSR7, A.LocationCategory, A.LocLevel, A.LocAisle, 
	   A.STLD_Loc, A.Loc, A.CS, A.Q1, A.In_Computed, A.Q2, A.PC, A.PTL_Zone, A.TotalQty, A.PackSize, A.BayLevel,
	   A.Srt, A.StoreSKU, A.Serial_No_C, SUM(B.Serial_No_C) AS [Cumulative_Sum],
	   Total_Cases = SUM(A.Serial_No_C) OVER (PARTITION BY A.StoreSKU ORDER BY A.StoreSKU),
	   n_of_n_Cases =  convert(varchar, SUM(B.Serial_No_C)) + ' of ' + convert(varchar, SUM(A.Serial_No_C) OVER (PARTITION BY A.StoreSKU ORDER BY A.StoreSKU))
From C A
Inner Join C B ON B.StoreSKU = A.StoreSKU AND B.rownum <= A.rownum
GROUP BY A.DropID, A.PutAwayZone, A.SKU, A.Descr, A.Qty, A.CaseCnt, A.InnerPack, A.PQty, A.WaveKey,
	   A.EditWho, A.Store, A.CaseID, A.Route, A.BUSR7, A.LocationCategory, A.LocLevel, A.LocAisle, 
	   A.STLD_Loc, A.Loc, A.CS, A.Q1, A.In_Computed, A.Q2, A.PC, A.PTL_Zone, A.TotalQty, A.PackSize, A.BayLevel,
	   A.Srt, A.StoreSKU, A.Serial_No_C

   WHILE @@TRANCOUNT < @n_starttcnt
   BEGIN
      BEGIN TRAN
   END
END
GO
GRANT EXECUTE ON [dbo].[nsp_GetPicklabel06_1] TO nSQL 
GO
