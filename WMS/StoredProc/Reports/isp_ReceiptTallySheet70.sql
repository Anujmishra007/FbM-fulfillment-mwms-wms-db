IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_ReceiptTallySheet70]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[isp_ReceiptTallySheet70]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_ReceiptTallySheet70                                 */  
/* Creation Date: 12-Aug-2020                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-14666 - Allbirds KR Tally Sheet                         */  
/*        :                                                             */  
/* Called By: r_receipt_tallysheet70                                    */  
/*          :                                                           */  
/* GitLab Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */ 
/************************************************************************/  
  
CREATE PROC isp_ReceiptTallySheet70  
            @c_ReceiptkeyStart   NVARCHAR(15)
          , @c_ReceiptkeyEnd     NVARCHAR(15)
          , @c_StorerkeyStart    NVARCHAR(15)
          , @c_StorerkeyEnd      NVARCHAR(15)
          , @c_UserID            NVARCHAR(100) = ''
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE  
           @n_StartTCnt       INT  
         , @n_Continue        INT  
         , @b_Success         INT  
         , @n_Err             INT  
         , @c_Errmsg          NVARCHAR(255)  

   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue  = 1  
   SET @b_Success   = 1  
   SET @n_Err       = 0  
   SET @c_Errmsg    = '' 

   SELECT R.Receiptkey
        , R.ExternReceiptkey
        , R.ReceiptDate
        , RD.SKU
        , SKU.DESCR
        , CASE WHEN ISNULL(PACK.Casecnt,0) > 0 AND ISNUMERIC(PACK.CaseCnt) = 1
               THEN SUM(RD.QtyExpected) / PACK.CaseCnt ELSE 0 END AS [Box]
        , SUM(RD.QtyExpected) AS QtyExpected
        , CASE WHEN ISNULL(ST.PercentA,0) > 0 AND ISNUMERIC(ST.PercentA) = 1
               THEN SUM(RD.QtyExpected) * ST.PercentA ELSE 0 END AS InspectionQty
        , CONVERT(CHAR(16), GetDate(), 120) AS [GetDate]
   FROM RECEIPT R (NOLOCK)
   JOIN RECEIPTDETAIL RD (NOLOCK) ON RD.Receiptkey = R.Receiptkey
   JOIN SKU (NOLOCK) ON RD.SKU = SKU.SKU AND RD.Storerkey = SKU.Storerkey
   JOIN PACK (NOLOCK) ON PACK.Packkey = SKU.Packkey
   JOIN STORER ST (NOLOCK) ON ST.Storerkey = R.StorerKey
   WHERE R.Storerkey BETWEEN @c_StorerkeyStart AND @c_StorerkeyEnd
   AND R.ReceiptKey BETWEEN @c_ReceiptkeyStart AND @c_ReceiptkeyEnd
   GROUP BY R.Receiptkey
        , R.ExternReceiptkey
        , R.ReceiptDate
        , RD.SKU
        , SKU.DESCR
        , PACK.CaseCnt
        , ST.PercentA
   ORDER BY R.ReceiptKey, RD.Sku

QUIT_SP:  
END -- procedure

GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON [dbo].[isp_ReceiptTallySheet70] TO nSQL 
GO
