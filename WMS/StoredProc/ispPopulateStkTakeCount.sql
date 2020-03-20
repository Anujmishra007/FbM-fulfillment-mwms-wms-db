IF EXISTS (SELECT name FROM   dbo.sysobjects WHERE  name = N'ispPopulateStkTakeCount' AND type = 'P')
    DROP PROCEDURE ispPopulateStkTakeCount
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/************************************************************************/  
/* Store Procedure:  ispPopulateStkTakeCount                            */  
/* Creation Date: 28-Dec-2011                                           */  
/* Copyright: IDS                                                       */  
/* Written by: Shong                                                    */  
/*                                                                      */  
/* Purpose:  Pupulate Count from 1 to another                           */  
/*                                                                      */  
/* Called By:  PowerBuilder                                             */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Purposes                                      */  
/* 01-Mar-2011  Shong     Skip Count 2 If System Qty = Counted Qty      */  
/* 27-May-2014  TKLIM     Added Lottables 06-15                         */
/************************************************************************/  
  
CREATE PROCEDURE [dbo].[ispPopulateStkTakeCount]  
      @c_StockTakeKey NVARCHAR(10),   
      @n_CountNo int  
AS  
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue  INT,   
           @c_StorerKey NVARCHAR(15),   
           @c_Facility  NVARCHAR(5),  
           @c_OnlyCountLocWithVariance NVARCHAR(1),   
           @b_Success   INT,  
           @n_ErrNo     INT,  
           @c_ErrMsg    NVARCHAR(215)  
  
   SELECT @n_Continue = 1  
  
   -- Do nothing is count no no equal 2 and 3  
   IF @n_CountNo <> 2 AND @n_CountNo <> 3   
      SELECT @n_Continue = 4  
  
   IF OBJECT_ID('tempdb..#RECNT_LOC') IS NOT NULL  
      DROP TABLE #RECNT_LOC  
   
   CREATE TABLE #RECNT_LOC (LOC NVARCHAR(10))  
  
   SELECT TOP 1     
      @c_StorerKey = CCDETAIL.StorerKey,   
      @c_Facility  = LOC.Facility     
   FROM CCDETAIL WITH (NOLOCK)      
   JOIN LOC WITH (NOLOCK) ON CCDETAIL.LOC = CCDETAIL.LOC   
   WHERE CCDETAIL.CCKEY = @c_StockTakeKey   
     AND CCDETAIL.StorerKey > ''   
     AND CCDETAIL.LOC > ''    
        
   SET @c_OnlyCountLocWithVariance = '0'  
   EXEC nspGetRight    
         @c_Facility   = @c_Facility ,     
         @c_StorerKey  = @c_StorerKey,     
         @c_sku        = '',     
         @c_ConfigKey  = 'SkipCountLocWithZeroVariance',     
         @b_Success    = @b_Success OUTPUT,     
         @c_authority  = @c_OnlyCountLocWithVariance  OUTPUT,     
         @n_err        = @n_ErrNo   OUTPUT,    
         @c_errmsg     = @c_ErrMsg  OUTPUT    
  
   IF @n_CountNo = 2  
   BEGIN  
      BEGIN TRAN  
  
      UPDATE CCDETAIL  
         SET Qty_Cnt2 = Qty, 
             Lottable01_Cnt2 = ISNULL(Lottable01, ''),  
             Lottable02_Cnt2 = ISNULL(Lottable02, ''),  
             Lottable03_Cnt2 = ISNULL(Lottable03, ''),  
             Lottable04_Cnt2 = Lottable04,  
             Lottable05_Cnt2 = Lottable05,
             Lottable06_Cnt2 = ISNULL(Lottable06, ''),
             Lottable07_Cnt2 = ISNULL(Lottable07, ''),
             Lottable08_Cnt2 = ISNULL(Lottable08, ''),
             Lottable09_Cnt2 = ISNULL(Lottable09, ''),
             Lottable10_Cnt2 = ISNULL(Lottable10, ''),
             Lottable11_Cnt2 = ISNULL(Lottable11, ''),
             Lottable12_Cnt2 = ISNULL(Lottable12, ''),
             Lottable13_Cnt2 = Lottable13,      
             Lottable14_Cnt2 = Lottable14,
             Lottable15_Cnt2 = Lottable15
      WHERE CCKEY = @c_StockTakeKey  

      IF @@ERROR <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         RAISERROR ('Error Found Populate Stock Take ispPopulateStkTakeCount.', 16, 1)  
         ROLLBACK TRAN  
         RETURN  
      END  
      ELSE  
         COMMIT TRAN  
  
      IF @c_OnlyCountLocWithVariance = '1'  
      BEGIN  
         INSERT INTO #RECNT_LOC        
         SELECT DISTINCT c.LOC   
         FROM CCDetail c WITH (NOLOCK)   
         WHERE CCKEY = @c_StockTakeKey   
         GROUP BY c.StorerKey, c.Sku, c.LOC, 
                  c.Lottable01, c.Lottable02, c.Lottable03, c.Lottable04,
                  c.Lottable06, c.Lottable07, c.Lottable08, c.Lottable09, c.Lottable10, 
                  c.Lottable11, c.Lottable12, c.Lottable13, c.Lottable14, c.Lottable15
         HAVING SUM(c.SystemQty - C.Qty) <> 0   

         BEGIN TRAN                  
         UPDATE CC   
         SET Counted_Cnt2='1', EditDate_Cnt2 = GETDATE(), EditWho_Cnt2 = 'IC_SKIP'  
         FROM CCDETAIL CC   
         WHERE CC.Counted_Cnt2 = '0'  
            AND CC.CCKEY = @c_StockTakeKey
            AND NOT EXISTS(SELECT 1 FROM #RECNT_LOC SLOC WHERE SLOC.LOC = CC.LOC)     
       
       IF @@ERROR <> 0  
       BEGIN  
          SELECT @n_continue = 3  
        RAISERROR ('Update CCDETAIL Failed - ispPopulateStkTakeCount.', 16, 1)  
          ROLLBACK TRAN  
          RETURN  
       END  
       ELSE  
         COMMIT TRAN    
      END         
        
   END  
   ELSE IF @n_CountNo = 3  
   BEGIN  
      BEGIN TRAN  
  
      UPDATE CCDETAIL  
         SET Qty_Cnt3 = Qty_Cnt2,  
             Lottable01_Cnt3 = ISNULL(Lottable01_Cnt2, ''),  
             Lottable02_Cnt3 = ISNULL(Lottable02_Cnt2, ''),  
             Lottable03_Cnt3 = ISNULL(Lottable03_Cnt2, ''),  
             Lottable04_Cnt3 = Lottable04_Cnt2,  
             Lottable05_Cnt3 = Lottable05_Cnt2,
             Lottable06_Cnt3 = ISNULL(Lottable06_Cnt2, ''),  
             Lottable07_Cnt3 = ISNULL(Lottable07_Cnt2, ''),  
             Lottable08_Cnt3 = ISNULL(Lottable08_Cnt2, ''),  
             Lottable09_Cnt3 = ISNULL(Lottable09_Cnt2, ''),  
             Lottable10_Cnt3 = ISNULL(Lottable10_Cnt2, ''),  
             Lottable11_Cnt3 = ISNULL(Lottable11_Cnt2, ''),  
             Lottable12_Cnt3 = ISNULL(Lottable12_Cnt2, ''),  
             Lottable13_Cnt3 = Lottable13_Cnt2,  
             Lottable14_Cnt3 = Lottable14_Cnt2,  
             Lottable15_Cnt3 = Lottable15_Cnt2  
      WHERE CCKEY = @c_StockTakeKey
      
      IF @@ERROR <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         RAISERROR ('Error Found Populate Stock Take ispPopulateStkTakeCount.', 16, 1)  
         ROLLBACK TRAN  
         RETURN  
      END  
      ELSE  
         COMMIT TRAN  
  
      IF @c_OnlyCountLocWithVariance = '1'  
      BEGIN  
         INSERT INTO #RECNT_LOC        
         SELECT DISTINCT c.LOC   
         FROM CCDetail c WITH (NOLOCK)   
         WHERE CCKEY = @c_StockTakeKey   
         GROUP BY c.StorerKey, c.Sku, c.LOC, 
                  c.Lottable01, c.Lottable02, c.Lottable03,  c.Lottable04,
                  c.Lottable06, c.Lottable07, c.Lottable08, c.Lottable09, c.Lottable10, 
                  c.Lottable11, c.Lottable12, c.Lottable13, c.Lottable14, c.Lottable15
         HAVING SUM(c.Qty - C.Qty_Cnt2) = 0   

         BEGIN TRAN                  
         UPDATE CC   
         SET Counted_Cnt3='1', EditDate_Cnt3 = GETDATE(), EditWho_Cnt3 = 'IC_SKIP'  
         FROM CCDETAIL CC       
         WHERE CC.Counted_Cnt3 = '0'  
         AND CC.CCKEY = @c_StockTakeKey 
         AND NOT EXISTS(SELECT 1 FROM #RECNT_LOC SLOC WHERE SLOC.LOC = CC.LOC)    
         
         IF @@ERROR <> 0  
         BEGIN  
            SELECT @n_continue = 3  
            RAISERROR ('Update CCDETAIL Failed - ispPopulateStkTakeCount.', 16, 1)  
            ROLLBACK TRAN  
            RETURN  
         END  
         ELSE  
            COMMIT TRAN  
      END   
   END   
  
   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN  
      BEGIN TRAN  
  
      UPDATE StockTakeSheetParameters  
      SET PopulateStage = @n_CountNo  
      WHERE StockTakeKey = @c_StockTakeKey  
    
      IF @@ERROR <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         RAISERROR ('Error Found when updaing StockTakeSheetParameters.', 16, 1)  
         ROLLBACK TRAN  
         RETURN  
      END  
      ELSE  
         COMMIT TRAN  
   END     

GO

GRANT EXECUTE ON ispPopulateStkTakeCount TO NSQL
GO

   
