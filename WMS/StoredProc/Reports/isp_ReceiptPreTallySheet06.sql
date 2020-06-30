IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_ReceiptPreTallySheet06]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_ReceiptPreTallySheet06]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Proc: isp_ReceiptPreTallySheet06                              */  
/* Creation Date: 17-Sep-2019                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: WMS-10604 - NIKE_PH_WMS_PreTallySheet                       */   
/*        :                                                             */  
/* Called By: r_receipt_pre_tallysheet06                                */
/*          :                                                           */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver Purposes                                  */  
/* 09-Jun-2020  WLChooi   1.1 Remove group by ExternPOKey (WL01)        */
/* 30-Jun-2020  WLChooi   1.2 LEFT JOIN UCC table and bug fix (WL02)    */
/************************************************************************/ 

CREATE PROC [dbo].[isp_ReceiptPreTallySheet06]  
            @c_ReceiptStart   NVARCHAR(10)  
         ,  @c_ReceiptEnd     NVARCHAR(10)  
         ,  @c_StorerStart    NVARCHAR(15)  
         ,  @c_StorerEnd      NVARCHAR(15) 
         ,  @c_userid         NVARCHAR(20) = ''
  
AS  
BEGIN   
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @n_continue INT = 1, @n_err INT = 0, @c_errmsg NVARCHAR(255) = '', @b_Success INT = 1
           , @n_StartTCnt INT = @@TRANCOUNT, @c_GetReceiptKey NVARCHAR(10), @c_GetUserDefine03 NVARCHAR(30)
           , @n_PalletPosCnt        INT = 0
           , @c_Receiptkey          NVARCHAR(10)
           , @c_SKU                 NVARCHAR(30)
           , @c_ItemClass           NVARCHAR(20)
           , @n_Qty                 INT = 0
           , @c_PalletPos           NVARCHAR(20)
           , @n_PrevPalletPosCnt    INT = 0
           , @c_PrevItemClass       NVARCHAR(20)
           , @n_CountUCC            INT = 0   --WL02

   CREATE TABLE #ITEMCLASS(
   RECEIPTKEY         NVARCHAR(10),
   SKU                NVARCHAR(30),
   Qty                INT,
   ItemClass          NVARCHAR(10),
   UCCNo              NVARCHAR(20),
   PalletPosition     NVARCHAR(10),
   CountPallet        INT  )

   INSERT INTO #ITEMCLASS
   SELECT RECEIPT.RECEIPTKEY,
          RECEIPTDETAIL.SKU,
          ISNULL(UCC.Qty,0) AS Qty,   --WL02   --UCC.Qty,
          SKU.ItemClass,
          ISNULL(UCC.UCCNo,'') AS UCCNo,   --WL02   --UCC.UCCNo,
          PalletPosition = CASE WHEN UCC.Userdefined06 = '1' THEN 'F'
                                WHEN UCC.Userdefined07 = '1' THEN 'M'
                                WHEN UCC.Userdefined08 = '1' THEN 'QA'
                                WHEN ISNULL(UCC.Qty,0) > 0  AND ISNULL(UCC.Qty,0) < ISNULL(SKU.SUSR1,0) THEN 'S'   --WL02
                                --ELSE 'N' + CAST(COUNT(DISTINCT SKU.ITEMCLASS) + 4 AS NVARCHAR(10)) END
                                ELSE '' END,
          CountPallet = COUNT(DISTINCT SKU.ITEMCLASS) + 4 
   FROM RECEIPT (NOLOCK)
   JOIN RECEIPTDETAIL (NOLOCK) ON RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey
   JOIN SKU (NOLOCK) ON RECEIPTDETAIL.SKU = SKU.SKU AND RECEIPT.STORERKEY = SKU.STORERKEY
   LEFT JOIN UCC (NOLOCK) ON UCC.UCCNo = RECEIPTDETAIL.Lottable10 AND UCC.Storerkey = RECEIPT.Storerkey AND UCC.SKU = RECEIPTDETAIL.SKU  --WL02
   WHERE ( RECEIPT.ReceiptKey >= @c_ReceiptStart ) AND  
         ( RECEIPT.ReceiptKey <= @c_ReceiptEnd   ) AND  
         ( RECEIPT.Storerkey  >= @c_StorerStart  ) AND 
         ( RECEIPT.Storerkey  <= @c_StorerEnd    ) 
   GROUP BY RECEIPT.RECEIPTKEY, RECEIPTDETAIL.SKU, ISNULL(UCC.Qty,0), ISNULL(UCC.UCCNo,''),   --WL02
            UCC.Userdefined06,
            UCC.Userdefined07,
            UCC.Userdefined08, SKU.ItemClass, ISNULL(SKU.SUSR1,0)

   --select * from #ITEMCLASS

   --  SELECT t.RECEIPTKEY,
   --       t.SKU,
   --       t.ITEMCLASS,
   --       SUM(t.Qty) as Qty,
   --       t.PalletPosition
   --FROM #ITEMCLASS t
   --WHERE t.PalletPosition = ''
   --GROUP BY t.Receiptkey,
   --       t.SKU,
   --       t.ITEMCLASS,
   --       t.PalletPosition

   DECLARE cur_Loop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT t.RECEIPTKEY,
          t.SKU,
          t.ITEMCLASS,
          SUM(t.Qty) as Qty,
          t.PalletPosition
   FROM #ITEMCLASS t
   WHERE t.PalletPosition = ''
   GROUP BY t.Receiptkey,
          t.SKU,
          t.ITEMCLASS,
          t.PalletPosition
   ORDER BY t.RECEIPTKEY, t.ItemClass

   OPEN cur_Loop

   FETCH NEXT FROM cur_Loop INTO   @c_Receiptkey
                                 , @c_SKU       
                                 , @c_ItemClass 
                                 , @n_Qty
                                 , @c_PalletPos       

   WHILE @@FETCH_STATUS <> - 1
   BEGIN
      IF @c_PrevItemClass <> @c_ItemClass AND @c_PrevItemClass <> ''
      BEGIN
         SET @n_PalletPosCnt = @n_PalletPosCnt + 1
      END

      --SELECT @c_Receiptkey, @c_SKU, @c_ItemClass, @n_Qty

      UPDATE #ITEMCLASS
      SET PalletPosition = 'N' + CAST(@n_PalletPosCnt AS NVARCHAR(10)) 
      WHERE RECEIPTKEY = @c_Receiptkey
      AND SKU = @c_SKU
      AND ItemClass = @c_ItemClass
      AND PalletPosition = ''

      SET @c_PrevItemClass = @c_ItemClass

   
      FETCH NEXT FROM cur_Loop INTO   @c_Receiptkey
                                    , @c_SKU       
                                    , @c_ItemClass 
                                    , @n_Qty   
                                    , @c_PalletPos 
   END

      --SELECT PalletPosition, SKU, COUNT(DISTINCT UCCNo) AS UCCNoCnt, SUM(Qty) AS QtyExpected FROM #ITEMCLASS
      --GROUP BY PalletPosition, SKU

   SELECT @n_CountUCC = COUNT(DISTINCT t.UCCNo) FROM #ITEMCLASS T WHERE t.UCCNo <> ''   --WL02
      
   SELECT RECEIPT.ReceiptKey,   
          '',--RECEIPTDETAIL.ExternPOKey,   --WL01
          t.Sku,  
          PRINCIPAL = SKU.SUSR3,
          PRINDESC = CODELKUP.DESCRIPTION, 
          SKU.DESCR,   
          RECEIPTDETAIL.UOM,
          STORER.Company,   
          RECEIPT.ReceiptDate,    
          RECEIPTDETAIL.PackKey,   
          SKU.SUSR3,   
          --RECEIPTDETAIL.QtyExpected,
          (SELECT SUM(Qty) FROM #ITEMCLASS WHERE #ITEMCLASS.RECEIPTKEY = RECEIPT.ReceiptKey 
                                             AND #ITEMCLASS.SKU = t.SKU 
                                             AND #ITEMCLASS.PalletPosition = t.Palletposition ) AS QtyExpected,
          RECEIPT.WarehouseReference,
          PACK.CaseCnt,
          PACK.Pallet,
          PACK.PackUOM3,
          SUM(RECEIPTDETAIL.FreeGoodQtyExpected) AS FreeGoodQtyExpected,
          SUSER_NAME(),
          PACK.PackUOM1,
          PACK.PackUOM2, 
          PACK.PackUOM4,
          Pack.Innerpack,
          RECEIPT.ExternReceiptkey,  
          ISNULL(CL1.Short,'') AS Lottable01,
          ISNULL(CL2.Short,'') AS Lottable02,  
          ISNULL(CL3.Short,'') AS Lottable12,  
          RECEIPTDETAIL.Lottable04,
          t.ItemClass,
          t.PalletPosition,
          @n_CountUCC AS UCCNoCnt,   --WL02   --COUNT(DISTINCT t.UCCNo) AS UCCNoCnt,
          t.CountPallet,
          (SELECT TOP 1 RD.ToLoc FROM RECEIPTDETAIL RD (NOLOCK) WHERE RD.RECEIPTKEY = RECEIPT.RECEIPTKEY) AS ToLoc
    FROM RECEIPT (NOLOCK)
    JOIN RECEIPTDETAIL (NOLOCK) ON RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey
    JOIN SKU (NOLOCK) ON SKU.StorerKey = RECEIPTDETAIL.StorerKey AND SKU.Sku = RECEIPTDETAIL.Sku
    JOIN STORER (NOLOCK) ON RECEIPT.Storerkey = STORER.Storerkey
    JOIN PACK (NOLOCK) ON PACK.PackKey = SKU.PackKey
    LEFT OUTER JOIN CODELKUP (NOLOCK) ON SKU.SUSR3 = CODELKUP.CODE AND CODELKUP.LISTNAME = 'PRINCIPAL'
    JOIN #ITEMCLASS t ON t.ReceiptKey = RECEIPT.Receiptkey AND t.SKU = RECEIPTDETAIL.SKU
    OUTER APPLY (SELECT TOP 1 ISNULL(Short,'') AS Short FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'Lottable01' AND Code = 'Lottable01' AND Storerkey = RECEIPT.StorerKey) AS CL1
    OUTER APPLY (SELECT TOP 1 ISNULL(Short,'') AS Short FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'Lottable02' AND Code = 'Lottable02' AND Storerkey = RECEIPT.StorerKey) AS CL2
    OUTER APPLY (SELECT TOP 1 ISNULL(Short,'') AS Short FROM CODELKUP (NOLOCK) WHERE LISTNAME = 'Lottable12' AND Code = 'Lottable12' AND Storerkey = RECEIPT.StorerKey) AS CL3
    GROUP BY RECEIPT.ReceiptKey,   
             --RECEIPTDETAIL.ExternPOKey,   --WL01
             t.Sku,  
             SKU.SUSR3,
             CODELKUP.DESCRIPTION, 
             SKU.DESCR,   
             RECEIPTDETAIL.UOM,
             STORER.Company,   
             RECEIPT.ReceiptDate,    
             RECEIPTDETAIL.PackKey,   
             SKU.SUSR3, 
             RECEIPT.WarehouseReference,
             PACK.CaseCnt,
             PACK.Pallet,
             PACK.PackUOM3,
             --RECEIPTDETAIL.FreeGoodQtyExpected,
             PACK.PackUOM1,
             PACK.PackUOM2, 
             PACK.PackUOM4,
             Pack.Innerpack,
             RECEIPT.ExternReceiptkey,  
             ISNULL(CL1.Short,''),
             ISNULL(CL2.Short,''), 
             ISNULL(CL3.Short,''),  
             RECEIPTDETAIL.Lottable04,
             t.ItemClass,
             t.PalletPosition,
             t.CountPallet
   ORDER BY RECEIPT.Receiptkey, t.PalletPosition
    
   IF CURSOR_STATUS('LOCAL' , 'cur_Loop') in (0 , 1)
   BEGIN
      CLOSE cur_Loop
      DEALLOCATE cur_Loop   
   END
   
   IF @n_Continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_Success = 0  
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_StartTCnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_ReceiptPreTallySheet06'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
   END  
    
   WHILE @@TRANCOUNT < @n_StartTCnt   
      BEGIN TRAN;     
  
END
GO
GRANT EXECUTE ON [dbo].[isp_ReceiptPreTallySheet06] TO nSQL 
GO
