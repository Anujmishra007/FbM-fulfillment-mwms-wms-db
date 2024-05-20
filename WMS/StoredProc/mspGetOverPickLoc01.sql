SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Procedure: mspGetOverPickLoc01                                */  
/* Creation Date: 2024-05-09                                            */  
/* Copyright: Maersk                                                    */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: Mattel                                                      */    
/*                                                                      */  
/* Called By: Over Allocation                                           */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */    
/* Date         Author   Ver  Purposes                                  */ 
/* 2024-05-20  Wan      1.0   Created.                                  */
/************************************************************************/  
CREATE OR ALTER PROC mspGetOverPickLoc01     
   @c_Storerkey                  NVARCHAR(15)   
,  @c_Sku                        NVARCHAR(20)   
,  @c_AllocateStrategykey        NVARCHAR(10)  
,  @c_AllocateStrategyLineNumber NVARCHAR(5)  
,  @c_LocationTypeOverride       NVARCHAR(10)   
,  @c_LocationTypeOverridestripe NVARCHAR(10)  
,  @c_Facility                   NVARCHAR(5)   
,  @c_HostWHCode                 NVARCHAR(10)   
,  @c_Orderkey                   NVARCHAR(10)   
,  @c_Loadkey                    NVARCHAR(10)   
,  @c_Wavekey                    NVARCHAR(10)   
,  @c_Lot                        NVARCHAR(10)   
,  @c_Loc                        NVARCHAR(10)   
,  @c_ID                         NVARCHAR(18)   
,  @c_UOM                        NVARCHAR(10) --allocation strategy UOM  
,  @n_QtyToTake                  INT   
,  @n_QtyLeftToFulfill           INT   
,  @c_CallSource                 NVARCHAR(20) ----ORDER LOADORDER LOADCONSO WAVEORDER WAVECONSO  
,  @b_success                    INT OUTPUT   
,  @n_err                        INT OUTPUT   
,  @c_ErrMsg                     NVARCHAR(250) OUTPUT  
AS     
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
       
   DECLARE @n_Continue     INT = 1 
         , @n_StartTCnt    INT = @@TRANCOUNT
         
         , @n_PackQty      FLOAT = 0.00
         , @c_Lottable02   NVARCHAR(18) = ''  
    
   SET @b_Success = 1    
   SET @n_Err = 0
   SET @c_ErrMsg = ''  
  
   CREATE TABLE #PICKLOCTYPE (loc  NVARCHAR(10) NOT NULL DEFAULT (''))  
  
   IF @n_continue IN (1,2)  
   BEGIN             
      SELECT @c_Lottable02 = la.Lottable02
      FROM LOTATTRIBUTE la (NOLOCK) 
      WHERE la.Lot = @c_Lot
   
      INSERT INTO #PICKLOCTYPE
      SELECT sl.LOC    
      FROM SKUxLOC sl (NOLOCK)   
      JOIN LOC l(NOLOCK) ON sl.loc = l.loc
      WHERE sl.STORERKEY = @c_StorerKey    
      AND sl.SKU = @c_Sku    
      AND sl.LocationType = @c_LocationTypeOverride      
      AND l.facility = @c_Facility  
      AND l.HostWHCode = @c_Lottable02
      AND l.[Status] = 'OK'
      AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
      ORDER BY l.LogicalLocation, l.Loc  
      
      IF @@ROWCOUNT = 0
      BEGIN
         SELECT @n_PackQty = p.Pallet
         FROM dbo.SKU s(NOLOCK) 
         JOIN dbo.PACK p (NOLOCK) ON s.Packkey = p.Packkey
         WHERE s.Storerkey = @c_Storerkey
         AND s.Sku = @c_Sku

         -- Find same friend 1) which has stock and able to fit for 1 pallet                             
         INSERT INTO #PICKLOCTYPE
         SELECT TOP 1 l.LOC     
         FROM LOC l (NOLOCK)   
         JOIN LOTxLOCxID lli (NOLOCK) ON  lli.Storerkey = @c_StorerKey 
                                      AND lli.SKU = @c_Sku 
                                      AND lli.loc = l.loc
         WHERE l.LocationType = 'DYNPPICK'     
         AND l.Facility   = @c_Facility  
         AND l.HostWHCode = @c_Lottable02
         AND l.LocLevel = 0
         AND l.[Status] = 'OK'
         AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
         GROUP BY l.loc
               ,  l.ABC        
               ,  l.LogicalLocation
               ,  l.MaxPallet
         HAVING   SUM(lli.Qty) > 0
            AND ((SUM(lli.PendingMoveIn) = 0 AND 
                  CEILING(SUM(lli.QtyExpected + @n_QtyLeftToFulfill)/@n_PackQty) <= l.MaxPallet) OR
                  SUM(lli.QtyExpected) + @n_QtyLeftToFulfill <= SUM(lli.PendingMoveIn))
         ORDER BY SUM(lli.Qty)
               ,  l.ABC
               ,  l.LogicalLocation
      END

      IF @@ROWCOUNT = 0
      BEGIN
         INSERT INTO #PICKLOCTYPE
         SELECT TOP 1 l.LOC     
         FROM LOC l (NOLOCK)   
         LEFT OUTER JOIN LOTxLOCxID lli (NOLOCK) ON  lli.loc = l.loc
         WHERE l.LocationType = 'DYNPPICK'     
         AND l.facility = @c_Facility  
         AND l.HostWHCode = @c_Lottable02
         AND l.LocLevel = 0
         AND l.[Status] = 'OK'
         AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
         GROUP BY l.loc
               ,  l.ABC          
               ,  l.LogicalLocation
         HAVING SUM(ISNULL(lli.PendingMoveIn,0) + ISNULL(lli.Qty,0)) = 0
         ORDER BY l.ABC
               ,  l.LogicalLocation
               ,  l.Loc
      END
  END  
  
  SELECT Loc FROM #PICKLOCTYPE
     
QUIT_SP:  
    
   IF @n_Continue=3  -- Error Occured - Process AND Return  
   BEGIN  
      SET @b_Success = 0  
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt  
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspGetOverPickLoc01'    
      --RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012  
      RETURN  
   END  
   ELSE  
   BEGIN  
      SET @b_Success = 1  
      WHILE @@TRANCOUNT > @n_StartTCnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END    
END    
GO
GRANT EXECUTE ON mspGetOverPickLoc01 TO NSQL
GO
