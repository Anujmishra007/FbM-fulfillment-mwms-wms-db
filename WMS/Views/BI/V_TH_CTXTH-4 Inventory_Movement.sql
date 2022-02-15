SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Purpose  : Title: Create LogiReport(JReport) view in TH_DATAMART for				*/
/*					 Storerkey = 'CITYFR'											*/
/* Updates:																			*/
/* Date			Author      Ver.	Purposes										*/
/* 2021/11/24	BLLim		1.0		https://jiralfl.atlassian.net/browse/WMS-18451	*/
/************************************************************************************/

CREATE OR ALTER view [BI].[V_TH_CTXTH-4 Inventory_Movement] as
SELECT 	DISTINCT
		I.StorerKey as 'Storerkey',
		I.EditDate as 'Trandate',
		I.Sku as 'SKU',
		S.DESCR as 'Descr',
		sum(I.Qty) as 'Qty',
		Upper(P.PackUOM3) as 'UOM',
		I.FromID as 'Fromid' ,
		I.ToID as 'Toid',
		IH.LOTTABLE01 as 'Status',
		IH.LOTTABLE02 as 'CD#',
		IH.LOTTABLE03 as 'Brand',
		IH.LOTTABLE05 as 'RecDate',
		I.SourceKey as 'Sourcetypekey',
		IH.SourceTypeDesc as'Sourcetypedesc',
		I.ItrnKey as 'ITRNKey',
		S.BUSR4 as 'TESCO SKU',
		S.NOTES2 as 'TESCO Desc',
		I.AddWho as 'Addwho',
		IH.Remarks as 'Remarks',
		IH.ExternRefKey as 'CTX Doc#',
		IH.ExternRefType as 'Type',
		convert(varchar, I.EditDate, 103) as 'Editdate',
		'' as 'WOA Ref'
FROM 	ODS.ITRN I with (nolock)
JOIN 	ODS.SKU S with (nolock) ON I.StorerKey = S.StorerKey
		AND I.Sku = S.Sku
JOIN 	ODS.PACK P with (nolock) ON S.PACKKey = P.PackKey
JOIN 	ODS.ITRN_HIS IH with (nolock) ON I.ItrnKey = IH.ItrnKey
WHERE	I.StorerKey = 'CTXTH'
AND		(NOT IH.TranType = 'MV')
AND 	I.EditDate >= convert(varchar, getdate() - 1, 112)
and 	I.EditDate < convert(varchar, getdate(), 112)
AND		(NOT IH.Facility = 'UNK')
GROUP BY
		I.StorerKey,
		I.EditDate,
		I.Sku,
		S.DESCR,
		Upper(P.PackUOM3),
		I.FromID,
		I.ToID,
		IH.LOTTABLE01,
		IH.LOTTABLE02,
		IH.LOTTABLE03,
		IH.LOTTABLE05,
		I.SourceKey,
		IH.SourceTypeDesc,
		I.ItrnKey,
		S.BUSR4,
		S.NOTES2,
		I.AddWho,
		IH.Remarks,
		IH.ExternRefKey,
		IH.ExternRefType,
		convert(varchar, I.EditDate, 103)

GO
GRANT SELECT ON  [BI].[V_TH_CTXTH-4 Inventory_Movement] TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH_CTXTH-4 Inventory_Movement]

REVERT;
*/