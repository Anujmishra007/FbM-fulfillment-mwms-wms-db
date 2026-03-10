USE [GBRWMS]
GO


SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/***************************************************************************/
/* Stored Procedure: isp_RPT_EMG03_JCB_QC_sheet_001					       */
/* Creation Date: 10-09-2025										       */
/* Copyright: Maersk CE EUR                                                */
/* Written by: VMA237                                                      */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Called By: QC sheet									                   */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 10-09-2025   VMA237  1.0   Initial Version  WCEET-3459                  */
/* 02-18-2026   AGM046  1.1   Order Changed, added picker				   */
/*                                                                         */
/***************************************************************************/

CREATE OR ALTER PROC [BI].[isp_RPT_EMG03_JCB_QC_sheet_001]
    @Facility            NVARCHAR(30),
	@StorerKey           NVARCHAR(30),
	@Bay                 NVARCHAR(30),
	@Trailer_Number      NVARCHAR(30),
	@Transfer_Reference  NVARCHAR(30),
	@Deliver_To          NVARCHAR(MAX),
	@Despatch_Date       DATE, 
	@Location            NVARCHAR(MAX)


AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @Location = REPLACE(REPLACE(REPLACE(@Location, '[', ''), ']', ''), ' ', '');

SELECT  'Unit 5, SEGRO Logistics Park, East Midlands Gateway, Kegworth, Leicestershine, DE74, 2DL' AS [Despatcher],
		pcd.Storerkey,
		@Bay                  AS [Bay],
		@Trailer_Number       AS [Trailer_Number],
		@Transfer_Reference   AS [Transfer_Reference],
		@Deliver_To           AS [Deliver_To],
		@Despatch_Date        AS [Despatch_Date],
		pcd.Loc               AS [Location],
		CASE 
			WHEN ISNULL(pcd.DropID, '') != '' THEN pcd.DropID 
			ELSE pcd.ID 
		END                   AS [LPN-100],
		pcd.Sku               AS [SKU],
		pcd.Qty               AS [Qty],
		sku.Descr             AS [SKU Description],
		orm.ExternOrderKey    AS [Order],
		orm.UserDefine09      AS [Wave],
		orm.DeliveryDate      AS [Delivery D&T],
		--itrn.AddWho           AS [Picker]
		COALESCE(NULLIF(tdp.UserKey, ''), NULLIF(itrn.AddWho, '')) AS [Picker]
FROM DBO.V_ORDERS orm WITH (NOLOCK)
INNER JOIN DBO.V_PICKDETAIL pcd WITH (NOLOCK)
    ON pcd.StorerKey = orm.StorerKey
   AND pcd.OrderKey  = orm.OrderKey
LEFT JOIN DBO.V_SKU sku WITH (NOLOCK)
    ON sku.Facility  = orm.Facility
   AND sku.StorerKey = pcd.StorerKey
   AND sku.Sku       = pcd.Sku
LEFT JOIN DBO.V_ITRN itrn WITH (NOLOCK)
    ON itrn.StorerKey  = pcd.StorerKey
   AND itrn.FromID     = pcd.ID
   AND itrn.Lot        = pcd.Lot
   AND itrn.Sku        = pcd.Sku
   AND itrn.SourceType = 'rdt_PickPallet_Confirm'
OUTER APPLY (
    SELECT TOP (1) td.UserKey
    FROM DBO.V_TaskDetail td WITH (NOLOCK)
    WHERE td.Storerkey = pcd.Storerkey
      AND td.OrderKey  = pcd.OrderKey
      AND td.Sku       = pcd.Sku
      AND td.TaskType  = 'FCP'
    ORDER BY td.EditDate DESC
) tdp
LEFT JOIN RDT.RDTSCANTOTRUCK rst WITH (NOLOCK)
    ON rst.OrderKey = pcd.OrderKey
   AND rst.URNNo    = CASE WHEN ISNULL(pcd.DropID, '') <> '' THEN pcd.DropID ELSE pcd.ID END
WHERE orm.Facility  = 'EMG03'
  AND orm.StorerKey = 'JCB'
  AND ISNULL(rst.Door, '') = ''
  AND ISNULL(pcd.Loc, '') IN (
      SELECT TRIM(ColValue)
      FROM fnc_DelimSplit(',', @Location)
  )
ORDER BY
  CASE WHEN ISNULL(pcd.DropID, '') <> '' THEN pcd.DropID ELSE pcd.ID END,
  pcd.Sku;

	
END
GO



