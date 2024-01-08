SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_ASN_GINCTN_001                                */
/* Creation Date: 10-JUNE-2022                                             */
/* Copyright: LFL                                                          */
/* Written by: Harshitha                                                   */
/*                                                                         */
/* Purpose: WMS-19769                                                      */
/*                                                                         */
/* Called By: RPT_ASN_GINCTN_001                                           */
/*                                                                         */
/* GitLab Version: 1.3                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date            Author   Ver  Purposes                                  */
/* 13-Jun-2022     WLChooi  1.0  DevOps Combine Script                     */
/* 15-Jun-2023     CSCHONG  1.1  WMS-22731 add new field  (CS01)           */
/* 19-Dec-2023     CikFun   1.2  JSM-198467 Extend RHSignatory Length(CF01)*/
/* 04-Jan-2024     WLChooi  1.3  WMS-24542 - Bug Fix (WL01)                */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_ASN_GINCTN_001] @c_Receiptkey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @c_pickheaderkey      NVARCHAR(10)
         , @n_continue           INT
         , @c_errmsg             NVARCHAR(255)
         , @b_success            INT
         , @n_err                INT
         , @n_pickslips_required INT
         , @n_SortBySkuLoc       INT

   CREATE TABLE #InwardNotesCtn02
   (
      Company          NVARCHAR(45)
    , ReceiptKey       NVARCHAR(20)  NULL
    , CarrierReference NVARCHAR(18)  NULL
    , StorerKey        NVARCHAR(15)  NULL
    , CarrierName      NVARCHAR(30)  NULL
    , AddWho           NVARCHAR(128)  NULL   --WL01
    , ReceiptDate      DATETIME      NULL
    , Sku              NVARCHAR(20)  NULL
    , Lottable02       NVARCHAR(18)  NULL
    , DESCR            NVARCHAR(60)  NULL
    , Lottable04       DATETIME      NULL
    , UOM              NVARCHAR(10)  NULL
    , QtyExp           INT
    , QtyRec           INT
    , STDCUBE          FLOAT
    , RECNOTES         NVARCHAR(60)  NULL
    , CarrierAddress1  NVARCHAR(45)  NULL
    , POkey            NVARCHAR(18)  NULL
    , CaseCnt          INT
    , Lottable03       NVARCHAR(18)  NULL
    , RHSignatory      NVARCHAR(100) NULL   --(CF01) 
    , Userdefine01     NVARCHAR(30)  NULL
    , Facility         NVARCHAR(15)  NULL
    , Externreceiptkey NVARCHAR(20)  NULL
    , lottable01       NVARCHAR(18)  NULL
    , Containerkey     NVARCHAR(18)  NULL
    , conditiondesc    NVARCHAR(250) NULL
    , containertype    NVARCHAR(250) NULL
    , Signatory        NVARCHAR(30)  NULL
    , SortByLOTT02     INT           NULL
    , ShowLot15        INT           NULL
    , Lottable15       DATETIME      NULL
    , SortByLOTT01     INT           NULL
    , Showlogo         INT
    , ShowLottable06   INT
    , Lottable06       NVARCHAR(30)
    , ConditionCode    NVARCHAR(10)
    , Showgin          NVARCHAR(10)
    , ShowLottable0708 INT
    , Lottable07       NVARCHAR(30)
    , Lottable08       NVARCHAR(30)
   ) --CS01   

   SELECT Storerkey
        , SortByLOTT02 = ISNULL(MAX(CASE WHEN Code = 'SORTBYLOTT02' THEN 1
                                         ELSE 0 END)
                              , 0)
        , ShowLot15 = ISNULL(MAX(CASE WHEN Code = 'SHOWLOT15' THEN 1
                                      ELSE 0 END)
                           , 0)
        , SortByLOTT01 = ISNULL(MAX(CASE WHEN Code = 'SORTBYLOTT01' THEN 1
                                         ELSE 0 END)
                              , 0)
        , Showlogo = ISNULL(MAX(CASE WHEN Code = 'SHOWLOGO' THEN 1
                                     ELSE 0 END)
                          , 0)
        , ShowLottable06 = ISNULL(MAX(CASE WHEN Code = 'ShowLottable06' THEN 1
                                           ELSE 0 END)
                                , 0)
        , ShowLottable0708 = ISNULL(MAX(CASE WHEN Code = 'ShowLottable0708' THEN 1
                                             ELSE 0 END)
                                  , 0)
   INTO #TMP_RPTCFG
   FROM CODELKUP WITH (NOLOCK)
   WHERE LISTNAME = 'REPORTCFG' AND Long = 'RPT_ASN_GINCTN_001' AND (Short IS NULL OR Short <> 'N')
   GROUP BY Storerkey

   INSERT INTO #InwardNotesCtn02 (Company, ReceiptKey, CarrierReference, StorerKey, CarrierName, AddWho, ReceiptDate
                                , Sku, Lottable02, DESCR, Lottable04, UOM, QtyExp, QtyRec, STDCUBE, RECNOTES
                                , CarrierAddress1, POkey, CaseCnt, Lottable03, RHSignatory, Userdefine01, Facility
                                , Externreceiptkey, lottable01, Containerkey, conditiondesc, containertype, Signatory
                                , SortByLOTT02, ShowLot15, Lottable15, SortByLOTT01, Showlogo, ShowLottable06
                                , Lottable06, ConditionCode, Showgin, ShowLottable0708, Lottable07, Lottable08) --CS01  
   SELECT STORER.Company
        , RECEIPT.ReceiptKey
        , ISNULL(RECEIPT.CarrierReference, '')
        , RECEIPT.StorerKey
        , ISNULL(RECEIPT.CarrierName, '')
        , RECEIPT.AddWho
        , RECEIPT.ReceiptDate
        , RECEIPTDETAIL.Sku
        , ISNULL(RECEIPTDETAIL.Lottable02, '')
        , SKU.DESCR
        , RECEIPTDETAIL.Lottable04
        , RECEIPTDETAIL.UOM
        , SUM(RECEIPTDETAIL.QtyExpected) AS QtyExp
        , SUM(RECEIPTDETAIL.QtyReceived) AS QtyRec
        , SKU.STDCUBE
        , ISNULL(CONVERT(NVARCHAR(60), RECEIPT.Notes), '') AS RECNOTES
        , ISNULL(RECEIPT.CarrierAddress1, '')
        , ISNULL(RECEIPT.POKey, '')
        , PACK.CaseCnt
        , ISNULL(RECEIPTDETAIL.Lottable03, '')
        , ISNULL(RECEIPT.Signatory, '') AS RHSignatory
        , ISNULL(RECEIPT.UserDefine01, '')
        , RECEIPT.Facility
        , RECEIPTDETAIL.ExternReceiptKey
        , ISNULL(RECEIPTDETAIL.Lottable01, '')
        , ISNULL(RECEIPT.ContainerKey, '')
        , MAX(ISNULL(TRIM(CL2.conditiondesc), ''))   --WL01
        , MAX(ISNULL(TRIM(CL3.containertype), ''))   --WL01
        , Signatory = CASE WHEN ISNULL(RTRIM(STORER.Contact2), '') = '' THEN 'Maersk'
                           ELSE STORER.Contact2 END --WL01  
        , SortByLOTT02 = ISNULL(#TMP_RPTCFG.SortByLOTT02, 0)
        , ShowLot15 = ISNULL(#TMP_RPTCFG.ShowLot15, 0)
        , RECEIPTDETAIL.Lottable15
        , SortByLOTT01 = ISNULL(#TMP_RPTCFG.SortByLOTT01, 0)
        , showlogo = ISNULL(#TMP_RPTCFG.Showlogo, 0)
        , ShowLottable06 = ISNULL(#TMP_RPTCFG.ShowLottable06, 0)
        , RECEIPTDETAIL.Lottable06
        , CASE WHEN RECEIPTDETAIL.ConditionCode = 'D08' THEN 'QI'
               ELSE 'OK' END AS GIN
        , ISNULL(c1.Short, '') AS showgin
        , ShowLottable0708 = ISNULL(#TMP_RPTCFG.ShowLottable0708, 0) --CS01
        , ISNULL(RECEIPTDETAIL.Lottable07, '')
        , ISNULL(RECEIPTDETAIL.Lottable08, '') --CS01
   FROM RECEIPT WITH (NOLOCK)
   JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)
   JOIN STORER WITH (NOLOCK) ON (RECEIPTDETAIL.StorerKey = STORER.StorerKey)
   JOIN SKU WITH (NOLOCK) ON (RECEIPTDETAIL.StorerKey = SKU.StorerKey) AND (RECEIPTDETAIL.Sku = SKU.Sku)
   JOIN PACK WITH (NOLOCK) ON (SKU.PACKKey = PACK.PackKey)
   --LEFT JOIN STORER ST WITH (NOLOCK)  ON ( ST.Storerkey = 'IDS' )   --WL01
   LEFT JOIN #TMP_RPTCFG WITH (NOLOCK) ON #TMP_RPTCFG.Storerkey = RECEIPT.StorerKey
   LEFT JOIN CODELKUP c1 WITH (NOLOCK) ON  c1.LISTNAME = 'reportcfg'
                                       AND c1.Storerkey = RECEIPT.StorerKey
                                       AND c1.Long = 'RPT_ASN_GINCTN_001'
                                       AND c1.Code = 'showgin'
   OUTER APPLY ( SELECT TOP 1 ISNULL(CODELKUP.Description, '') AS conditiondesc
                 FROM CODELKUP (NOLOCK)
                 WHERE CODELKUP.LISTNAME = 'ASNREASON' AND CODELKUP.Code = RECEIPTDETAIL.ConditionCode
                 AND (CODELKUP.Storerkey = '' OR CODELKUP.Storerkey = RECEIPT.StorerKey)
                 ORDER BY CASE WHEN CODELKUP.Storerkey = '' THEN 2 ELSE 1 END ) AS CL2   --WL01
   OUTER APPLY ( SELECT TOP 1 ISNULL(CODELKUP.Description, '') AS containertype
                 FROM CODELKUP (NOLOCK)
                 WHERE CODELKUP.LISTNAME = 'CONTAINERT' AND CODELKUP.Code = RECEIPT.ContainerType
                 AND (CODELKUP.Storerkey = '' OR CODELKUP.Storerkey = RECEIPT.StorerKey)
                 ORDER BY CASE WHEN CODELKUP.Storerkey = '' THEN 2 ELSE 1 END ) AS CL3   --WL01
   WHERE (RECEIPT.ReceiptKey = @c_Receiptkey)
   GROUP BY STORER.Company
          , RECEIPT.ReceiptKey
          , RECEIPT.CarrierReference
          , RECEIPT.StorerKey
          , RECEIPT.CarrierName
          , RECEIPT.AddWho
          , RECEIPT.ReceiptDate
          , RECEIPTDETAIL.Sku
          , RECEIPTDETAIL.Lottable02
          , SKU.DESCR
          , RECEIPTDETAIL.Lottable04
          , RECEIPTDETAIL.UOM
          , SKU.STDCUBE
          , CONVERT(NVARCHAR(60), RECEIPT.Notes)
          , RECEIPT.CarrierAddress1
          , RECEIPT.POKey
          , PACK.CaseCnt
          , RECEIPTDETAIL.Lottable03
          , RECEIPT.Signatory
          , RECEIPT.UserDefine01
          , RECEIPT.Facility
          , RECEIPTDETAIL.ExternReceiptKey
          , RECEIPTDETAIL.Lottable01
          , RECEIPT.ContainerKey
          , RECEIPTDETAIL.ConditionCode
          , RECEIPT.ContainerType
          , CASE WHEN ISNULL(RTRIM(STORER.Contact2), '') = '' THEN 'Maersk'
                 ELSE STORER.Contact2 END --WL01  
          , #TMP_RPTCFG.SortByLOTT02
          , ISNULL(#TMP_RPTCFG.ShowLot15, 0)
          , RECEIPTDETAIL.Lottable15
          , ISNULL(#TMP_RPTCFG.SortByLOTT01, 0)
          , ISNULL(#TMP_RPTCFG.Showlogo, 0)
          , ISNULL(#TMP_RPTCFG.ShowLottable06, 0)
          , RECEIPTDETAIL.Lottable06
          , CASE WHEN RECEIPTDETAIL.ConditionCode = 'D08' THEN 'QI'
                 ELSE 'OK' END
          , ISNULL(c1.Short, '')
          , ISNULL(#TMP_RPTCFG.ShowLottable0708, 0) --CS01 
          , ISNULL(RECEIPTDETAIL.Lottable07, '')
          , ISNULL(RECEIPTDETAIL.Lottable08, '') --CS01
   GOTO SUCCESS
   FAILURE:
   DELETE FROM #InwardNotesCtn02
   SUCCESS:
   SELECT *
   FROM #InwardNotesCtn02
   ORDER BY CASE WHEN SortByLOTT02 = 1 THEN Lottable02
                 ELSE '' END
          , CASE WHEN SortByLOTT01 = 1 THEN lottable01
                 ELSE '' END
          , ReceiptKey
          , Sku
          , CASE WHEN SortByLOTT02 = 1 THEN ''
                 ELSE Lottable02 END

   IF OBJECT_ID('tempdb..#InwardNotesCtn02') IS NOT NULL
      DROP TABLE #InwardNotesCtn02
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_GINCTN_001] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_GINCTN_001] TO LogiReportRoleWM
GO