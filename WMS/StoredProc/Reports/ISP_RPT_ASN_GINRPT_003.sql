SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Store Procedure:  ISP_RPT_ASN_GINRPT_003                             */    
/* Creation Date:  25-MAY2023                                           */    
/* Copyright: LFL                                                       */    
/* Written by:  CSCHONG                                                 */    
/*                                                                      */    
/* Purpose: WMS-22684 -Migrate WMS Report To LogiReport                 */                                                                          
/* Called By:  RPT_ASN_GINRPT_003                                       */    
/*                                                                      */    
/* GitLab Version: 1.0                                                  */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver.  Purposes                                */  
/* 25-MAY-2023  CSCHONG   1.1   Devops Scripts Combine & WMS-21285     */    
/************************************************************************/   
CREATE OR ALTER  PROC [dbo].[ISP_RPT_ASN_GINRPT_003]  
            (@c_Receiptkey      NVARCHAR(10)   
         )  
                      
AS    
BEGIN  
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
  
  
DECLARE    @c_Type        NVARCHAR(1) = '1'                          
         , @c_DataWindow  NVARCHAR(60) = 'RPT_ASN_GINRPT_003'      
         , @c_RetVal      NVARCHAR(255)         
         , @c_storerkey   NVARCHAR(20)
  

SELECT @c_storerkey = R.Storerkey
FROM dbo.RECEIPT R WITH (NOLOCK)
WHERE R.ReceiptKey = @c_Receiptkey 
  
IF ISNULL(@c_Storerkey,'') <> ''      
BEGIN      
      
EXEC [dbo].[isp_GetCompanyInfo]      
         @c_Storerkey  = @c_Storerkey      
      ,  @c_Type       = @c_Type      
      ,  @c_DataWindow = @c_DataWindow      
      ,  @c_RetVal     = @c_RetVal           OUTPUT      
       
END   
     
SELECT STORER.Company
           , RECEIPT.ReceiptKey
           , RECEIPT.CarrierReference
           , RECEIPT.StorerKey
           , RECEIPT.CarrierName
           , PO.SellerName
           , RECEIPT.AddWho
           , RECEIPT.ReceiptDate
           , RECEIPTDETAIL.Sku
           , CASE WHEN ISNULL(CL4.Short, 'N') = 'Y' THEN RECEIPTDETAIL.Lottable07
                  ELSE RECEIPTDETAIL.Lottable02 END
           , SKU.DESCR
           , RECEIPTDETAIL.Lottable04
           , RECEIPTDETAIL.UOM
           , QtyExp = CASE WHEN CL.Short = 0 THEN SUM(RECEIPTDETAIL.QtyExpected)
                           ELSE
                              SUM(RECEIPTDETAIL.QtyExpected / NULLIF(CASE RECEIPTDETAIL.UOM
                                                                          WHEN PACK.PackUOM1 THEN PACK.CaseCnt
                                                                          WHEN PACK.PackUOM2 THEN PACK.InnerPack
                                                                          WHEN PACK.PackUOM3 THEN 1
                                                                          WHEN PACK.PackUOM4 THEN PACK.Pallet
                                                                          WHEN PACK.PackUOM5 THEN PACK.Cube
                                                                          WHEN PACK.PackUOM6 THEN PACK.GrossWgt
                                                                          WHEN PACK.PackUOM7 THEN PACK.NetWgt
                                                                          WHEN PACK.PackUOM8 THEN PACK.OtherUnit1
                                                                          WHEN PACK.PackUOM9 THEN PACK.OtherUnit2 END, 0))END
           , QtyRec = CASE WHEN CL.Short = 0 THEN SUM(RECEIPTDETAIL.QtyReceived)
                           ELSE
                              SUM(RECEIPTDETAIL.QtyReceived / NULLIF(CASE RECEIPTDETAIL.UOM
                                                                          WHEN PACK.PackUOM1 THEN PACK.CaseCnt
                                                                          WHEN PACK.PackUOM2 THEN PACK.InnerPack
                                                                          WHEN PACK.PackUOM3 THEN 1
                                                                          WHEN PACK.PackUOM4 THEN PACK.Pallet
                                                                          WHEN PACK.PackUOM5 THEN PACK.Cube
                                                                          WHEN PACK.PackUOM6 THEN PACK.GrossWgt
                                                                          WHEN PACK.PackUOM7 THEN PACK.NetWgt
                                                                          WHEN PACK.PackUOM8 THEN PACK.OtherUnit1
                                                                          WHEN PACK.PackUOM9 THEN PACK.OtherUnit2 END, 0))END
           , SKU.STDCUBE
           , CONVERT(NVARCHAR(60), RECEIPT.Notes) AS Notes
           , RECEIPT.CarrierAddress1
           , RECEIPT.POKey
           , RECEIPT.Signatory
           , RECEIPTDETAIL.ExternReceiptKey
           , RECEIPTDETAIL.Lottable03
           , CODELKUP.Description
           , CL.Short
           , SKU.SUSR3
           , SKU.SUSR4
           , CL1.Short AS ShowLot01
           , RECEIPTDETAIL.Lottable01
           , SKU.MANUFACTURERSKU
           , SKU.CLASS
           , ISNULL(f.UserDefine02, 'Maersk') AS 'FCompany'
           , ISNULL(CL2.Short, 'N') AS ShowExtraField
           , RECEIPTDETAIL.Lottable15
           , CASE WHEN ISNULL(CL3.Code, '') <> '' THEN 'Y'
                  ELSE 'N' END AS ShowLot15
           , ISNULL(CL5.Short, 'N') AS ExtendSKUDescrColumn
           , RECEIPT.ExternReceiptKey
           , RECEIPTDETAIL.Lottable12
           , RECEIPTDETAIL.Lottable10
           , RECEIPTDETAIL.Lottable11
           , RECEIPTDETAIL.Lottable08
           , RECEIPTDETAIL.Lottable09
           , RECEIPTDETAIL.ExternPoKey
           , ISNULL(RECEIPTDETAIL.Lottable06,'') AS Lottable06
           , ISNULL(CL6.Short,'N') AS ShowWHCode
      FROM RECEIPT (NOLOCK)
      INNER JOIN RECEIPTDETAIL (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)
      INNER JOIN STORER (NOLOCK) ON (RECEIPTDETAIL.StorerKey = STORER.StorerKey)
      INNER JOIN SKU (NOLOCK) ON (   SKU.StorerKey = STORER.StorerKey
                                 AND SKU.StorerKey = RECEIPTDETAIL.StorerKey
                                 AND SKU.Sku = RECEIPTDETAIL.Sku)
      --INNER JOIN CODELKUP (nolock) ON ( RECEIPTDETAIL.ConditionCode = CODELKUP.Code AND CODELKUP.Listname = 'ASNREASON' )
      INNER JOIN (  SELECT Code
                         , Description
                    FROM CODELKUP WITH (NOLOCK)
                    WHERE (LISTNAME = 'ASNREASON' AND Storerkey = Storerkey)
                    UNION
                    SELECT Code
                         , Description
                    FROM CODELKUP WITH (NOLOCK)
                    WHERE (LISTNAME = 'ASNREASON' AND Storerkey = '')
                    AND   NOT EXISTS (  SELECT 1
                                        FROM CODELKUP WITH (NOLOCK)
                                        WHERE (LISTNAME = 'ASNREASON' AND Storerkey = Storerkey))) CODELKUP ON (RECEIPTDETAIL.ConditionCode = CODELKUP.Code)
      LEFT JOIN CODELKUP CL WITH (NOLOCK) ON (   CL.LISTNAME = 'REPORTCFG'
                                             AND CL.Code = 'SHOWSIGNATURE'
                                             AND CL.Long = 'RPT_ASN_GINRPT_003'
                                             AND CL.Storerkey = RECEIPT.StorerKey)
      LEFT JOIN CODELKUP CL1 WITH (NOLOCK) ON (   CL1.LISTNAME = 'REPORTCFG'
                                              AND CL1.Code = 'SHOWLOT01'
                                              AND CL1.Long = 'RPT_ASN_GINRPT_003'
                                              AND CL1.Storerkey = RECEIPT.StorerKey)
      LEFT JOIN CODELKUP CL2 WITH (NOLOCK) ON (   CL2.LISTNAME = 'REPORTCFG'
                                              AND CL2.Code = 'ShowExtraField'
                                              AND CL2.Long = 'RPT_ASN_GINRPT_003'
                                              AND CL2.Storerkey = RECEIPT.StorerKey)
      LEFT JOIN PO (NOLOCK) ON (PO.POKey = RECEIPTDETAIL.POKey)
      INNER JOIN PACK (NOLOCK) ON (PACK.PackKey = RECEIPTDETAIL.PackKey)
      LEFT JOIN FACILITY AS f WITH (NOLOCK) ON f.Facility = RECEIPT.Facility
      LEFT OUTER JOIN CODELKUP CL3 (NOLOCK) ON (   RECEIPT.StorerKey = CL3.Storerkey
                                               AND CL3.Code = 'showlot15'
                                               AND CL3.LISTNAME = 'REPORTCFG'
                                               AND CL3.Long = 'RPT_ASN_GINRPT_003'
                                               AND ISNULL(CL3.Short, '') <> 'N')
      LEFT JOIN CODELKUP CL4 WITH (NOLOCK) ON (   CL4.LISTNAME = 'REPORTCFG'
                                              AND CL4.Code = 'ShowLot07'
                                              AND CL4.Long = 'RPT_ASN_GINRPT_003'
                                              AND CL4.Storerkey = RECEIPT.StorerKey)
      LEFT JOIN CODELKUP CL5 WITH (NOLOCK) ON (   CL5.LISTNAME = 'REPORTCFG'
                                              AND CL5.Code = 'ExtendSKUDescrColumn'
                                              AND CL5.Long = 'RPT_ASN_GINRPT_003'
                                              AND CL5.Storerkey = RECEIPT.StorerKey)
      LEFT JOIN CODELKUP CL6 WITH (NOLOCK) ON (   CL6.LISTNAME = 'REPORTCFG'
                                              AND CL6.Code = 'ShowWHCode'
                                              AND CL6.Long = 'RPT_ASN_GINRPT_003'
                                              AND CL6.Storerkey = RECEIPT.StorerKey)
      WHERE (RECEIPT.ReceiptKey = @c_Receiptkey)
      AND   ((RECEIPT.RECType = 'NORMAL') OR (RECEIPT.DOCTYPE = 'A'))
      AND RECEIPT.storerkey = @c_storerkey
      GROUP BY STORER.Company
             , RECEIPT.ReceiptKey
             , RECEIPT.CarrierReference
             , RECEIPT.StorerKey
             , RECEIPT.CarrierName
             , PO.SellerName
             , RECEIPT.AddWho
             , RECEIPT.ReceiptDate
             , RECEIPTDETAIL.Sku
             , CASE WHEN ISNULL(CL4.Short, 'N') = 'Y' THEN RECEIPTDETAIL.Lottable07
                    ELSE RECEIPTDETAIL.Lottable02 END
             , SKU.DESCR
             , RECEIPTDETAIL.Lottable04
             , RECEIPTDETAIL.UOM
             , SKU.STDCUBE
             , CONVERT(NVARCHAR(60), RECEIPT.Notes)
             , RECEIPT.CarrierAddress1
             , RECEIPT.POKey
             , RECEIPT.Signatory
             , RECEIPTDETAIL.ExternReceiptKey
             , RECEIPTDETAIL.Lottable03
             , CODELKUP.Description
             , CL.Short
             , SKU.SUSR3
             , SKU.SUSR4
             , CL1.Short
             , RECEIPTDETAIL.Lottable01
             , SKU.MANUFACTURERSKU
             , SKU.CLASS
             , ISNULL(f.UserDefine02, 'Maersk')
             , ISNULL(CL2.Short, 'N')
             , RECEIPTDETAIL.Lottable15
             , ISNULL(CL3.Code, '')
             , ISNULL(CL5.Short, 'N')
             , RECEIPT.ExternReceiptKey
             , RECEIPTDETAIL.Lottable12
             , RECEIPTDETAIL.Lottable10
             , RECEIPTDETAIL.Lottable11
             , RECEIPTDETAIL.Lottable08
             , RECEIPTDETAIL.Lottable09
             , RECEIPTDETAIL.ExternPoKey
             , ISNULL(RECEIPTDETAIL.Lottable06,'')
             , ISNULL(CL6.Short,'N')
       HAVING SUM(RECEIPTDETAIL.QtyExpected) > 0 OR SUM(RECEIPTDETAIL.QtyReceived) > 0
  
  
END    


SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [ISP_RPT_ASN_GINRPT_003]  TO NSQL
GO  
GRANT EXECUTE ON [ISP_RPT_ASN_GINRPT_003] TO LogiReportRoleWM
GO 
GO