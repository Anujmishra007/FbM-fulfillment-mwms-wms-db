SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Procedure: isp_RPT_IQC_IQCRPT_001                                */
/* Creation Date: 07-JAN-2022                                              */
/* Copyright: LFL                                                          */
/* Written by: Harshitha                                                   */
/*                                                                         */
/* Purpose: WMS-18711                                                      */
/*                                                                         */
/* Called By: RPT_IQC_IQCRPT_001                                           */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 07-Jan-2022  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_IQC_IQCRPT_001]
    @c_QCKey      NVARCHAR(20)


AS
BEGIN
  SET NOCOUNT ON
  SET ANSI_NULLS OFF
  SET QUOTED_IDENTIFIER OFF
  SET CONCAT_NULL_YIELDS_NULL OFF

  DECLARE @c_Storerkey   NVARCHAR(15)
       ,  @c_Type        NVARCHAR(1) = '1'
       ,  @c_DataWindow  NVARCHAR(60) = 'RPT_IQC_IQCRPT_001'
       ,  @c_RetVal      NVARCHAR(255)

  SELECT @c_StorerKey = StorerKey
  FROM InventoryQC (NOLOCK)
  WHERE QC_key = @c_QCKey

  EXEC [dbo].[isp_GetCompanyInfo]
         @c_Storerkey  = @c_Storerkey
      ,  @c_Type       = @c_Type
      ,  @c_DataWindow = @c_DataWindow
      ,  @c_RetVal     = @c_RetVal           OUTPUT

  SELECT InventoryQC.QC_Key,
         InventoryQC.StorerKey,
         InventoryQC.TradeReturnKey,
         InventoryQC.Refno,
         InventoryQC.from_facility,
         InventoryQC.to_facility,
         InventoryQCDetail.SKU,
         InventoryQCDetail.FromLoc,
         InventoryQCDetail.ToLoc,
         InventoryQCDetail.ToID,
         InventoryQCDetail.Reason,
         LOTATTRIBUTE.Lottable04,
         /*CODELKUP.Description,*/
			Description = ( SELECT TOP 1 CODELKUP.Description
                         FROM CODELKUP (NOLOCK)
  							    WHERE CODELKUP.Listname = 'ASNREASON'
							    AND CODELKUP.Code = InventoryQCDetail.Reason
                         AND (CODELKUP.StorerKey = InventoryQCDetail.StorerKey
                              OR ISNULL(CODELKUP.StorerKey,'')='')
                         ORDER BY CODELKUP.StorerKey DESC ),
         InventoryQCDetail.ToQty,
         SKU.DESCR,
         PACK.CaseCnt,
         PACK.PackDescr,
      	/*TYPE = CASE WHEN ISNULL(InventoryQC.TradeReturnKey, '') <> '' Then 'Trade Return - ' + Ltrim(Inventoryqc.Reason) + ' (' + A.Description + ')' else 'LotxlocxID - '+ Ltrim(Inventoryqc.Reason) + ' (' + A.Description + ')' end,*/
			TYPE = CASE WHEN ISNULL(InventoryQC.TradeReturnKey, '') <> ''
                	THEN 'Trade Return - ' + Ltrim(Inventoryqc.Reason) + ' (' + (SELECT TOP 1 A.Description
                                                                               FROM CODELKUP A (NOLOCK)
                                                                               WHERE A.Listname = 'IQCTYPE'
                                                                               AND A.Code = InventoryQC.Reason
                                                                               AND (A.StorerKey = InventoryQC.StorerKey
                                                                                    OR ISNULL(A.StorerKey,'')='')
                                                                               ORDER BY A.StorerKey DESC) + ')'
                	ELSE 'LotxlocxID - '+ Ltrim(Inventoryqc.Reason) + ' (' + (SELECT TOP 1 A.Description
                                                                            FROM CODELKUP A (NOLOCK)
                                                                            WHERE A.Listname = 'IQCTYPE'
                                                                            AND A.Code = InventoryQC.Reason
                                                                            AND (A.StorerKey = InventoryQC.StorerKey
                                                                                 OR ISNULL(A.StorerKey,'')='')
                                                                            ORDER BY A.StorerKey DESC) + ')'
                END,
         [user_name] = SUSER_SNAME(),
			LOTATTRIBUTE.Lottable02,
			LOTATTRIBUTE.Lottable03,
			FrHostWhs = LOC.HostWhCode,
			ToHostWhs = LOC2.HostWhCode,
			InventoryQCDetail.QCLineNo,
         STORER.Company,
         CONVERT(NVARCHAR(60), InventoryQC.Notes) as Notes,
			LOTATTRIBUTE.Lottable01, ISNULL(@c_Retval,'') AS Logo

    FROM InventoryQC WITH (NOLOCK),
         InventoryQCDetail WITH (NOLOCK),
         /*CODELKUP WITH (NOLOCK),*/
         /*CODELKUP A WITH (NOLOCK),*/
         LOTATTRIBUTE WITH (NOLOCK),
         PACK WITH (NOLOCK),
         SKU WITH (NOLOCK),
			LOC WITH (NOLOCK),
			LOC LOC2 WITH (NOLOCK),
         STORER WITH (NOLOCK)
   WHERE ( InventoryQC.QC_Key = InventoryQCDetail.QC_Key ) and
         /*( InventoryQCDetail.Reason = CODELKUP.Code ) and*/
         ( LOTATTRIBUTE.Lot = InventoryQCDetail.FromLot ) and
			( InventoryQCDetail.Storerkey = SKU.Storerkey ) and
         ( InventoryQCDetail.SKU = SKU.Sku ) and
         /*( InventoryQC.Reason = A.Code ) and*/
         /*( A.Listname = 'IQCTYPE') and*/
         /*( CODELKUP.Listname = 'ASNREASON' ) and*/
			( SKU.Packkey = PACK.Packkey ) and
			( LOC.LOC = InventoryQCDetail.FromLoc ) and
			( LOC2.LOC = InventoryQCDetail.ToLoc ) and
         ( InventoryQC.StorerKey = STORER.StorerKey ) and
         ( InventoryQC.QC_key = @c_QCKey )

END
GO
GRANT EXECUTE ON  [dbo].[isp_RPT_IQC_IQCRPT_001] TO [JReportRole]
GO
GRANT EXECUTE ON  [dbo].[isp_RPT_IQC_IQCRPT_001] TO [NSQL]
GO
