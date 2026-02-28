SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************************/  
/* Stored Procedure: mspGetOverPickLoc01_BRA_ONBR                                                 */  
/* Creation Date: 2026-01-02                                                             */  
/* Copyright: Maersk                                                                     */  
/* Written by:                                                                           */  
/*                                                                                       */  
/* Purpose: UWP-47948-ON Running Overallocation  - Copy from mspGetOverPickLoc01         */    
/*                                                                                       */  
/* Called By: Over Allocation                                                            */  
/*                                                                                       */  
/* Version: 1.0                                                                          */  
/*                                                                                       */  
/* Data Modifications:                                                                   */  
/*                                                                                       */  
/* Updates:                                                                              */    
/* Date        Author   Ver   Purposes                                                   */ 
/* 2026-01-02  PSJ036   1.0   UWP-47948- OBR Changed Over Pick location see is empty,    */
/*                            add qty to location Overallocate when                      */
/*                            MaxCarton * PackQty = QtyLocationLimit				     */
/*                            and removed loclevel = 0 and set Maxcarton > 0	     	 */
/*							  and Changed logic Maxpallet to MaxCarton  			     */
/*							  and PutawayZone OverLoc: LOC.PutawayZone = SKU.PutawayZone */
/*****************************************************************************************/  
CREATE OR ALTER             PROC [dbo].[mspGetOverPickLoc01_BRA_ONBR]  
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
,  @c_ErrMsg                     NVARCHAR(250)     OUTPUT 
,  @c_OverPickLoc                NVARCHAR(10) = '' OUTPUT                           
,  @n_OverQtyLeftToFulfill       INT = 0           OUTPUT                           
AS     
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
       
   DECLARE @n_Continue     INT = 1 
         , @n_StartTCnt    INT = @@TRANCOUNT
         
         , @n_PalletQty    FLOAT = 0.00                                                     
         , @c_Lottable02   NVARCHAR(18) = ''  
         , @n_PickLocQty   INT          = 0      --PSJ036                                   
		 , @n_PickMaxQty   INT          = 0      --PSJ036                                   
         , @c_DPPLoc       NVARCHAR(10) = ''                                        
         , @n_RowCount     INT          = 0                                         
         , @c_PAZoneSKU       NVARCHAR(10)       --PSJ036                                   
         , @n_PackQty      FLOAT = 0.00                                             
         , @n_MaxPallet    INT          = 0                                         
         , @n_MaxCarton    INT          = 0      --PSJ036                                  
         , @n_Qty          INT          = 0                                          
         , @n_QtyAllocated INT          = 0                                       
         , @n_QtyPicked    INT          = 0                                       
         , @c_PickLoc      NVARCHAR(10) = ''                                    
         , @n_MaxPalletQty INT          = 0                                         
         , @n_MaxCartonQty INT          = 0      --PSJ036                                  
         , @n_QtyExpected  INT          = 0                                       
         , @CUR_FindLOC    CURSOR                                            

   SET @b_Success = 1    
   SET @n_Err = 0
   SET @c_ErrMsg = ''  
  
   CREATE TABLE #PICKLOCTYPE ( RowID         INT          IDENTITY(1,1) PRIMARY Key      
                             , loc           NVARCHAR(10) NOT NULL DEFAULT ('')
                             )  
  
   IF @n_continue IN (1,2)  
   BEGIN             
      SELECT @c_Lottable02 = la.Lottable02
      FROM dbo.LOTATTRIBUTE la (NOLOCK) 
      WHERE la.Lot = @c_Lot

	  SELECT @n_PackQty     = p.CaseCnt,                 --PSJ036
			 @c_PAZoneSKU   = S.PutawayZone              --PSJ036
	  FROM dbo.SKU s(NOLOCK) 							 --PSJ036 
	  JOIN dbo.PACK p (NOLOCK) ON s.Packkey = p.Packkey  --PSJ036 
	  WHERE s.Storerkey = @c_Storerkey 					 --PSJ036 
	  AND s.Sku = @c_Sku								 --PSJ036 

	  INSERT INTO #PICKLOCTYPE
      SELECT sl.LOC    
      FROM dbo.SKUxLOC sl (NOLOCK)   
      JOIN dbo.LOC l(NOLOCK) ON sl.loc = l.loc
      WHERE sl.STORERKEY = @c_StorerKey    
      AND sl.SKU = @c_Sku    
      AND sl.LocationType = @c_LocationTypeOverride      
      AND l.facility = @c_Facility  
      AND l.HostWHCode = @c_Lottable02
      AND l.[Status] = 'OK'
      AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
	  AND l.MaxCarton * @n_PackQty = sl.QtyLocationLimit  --PSJ036 
	  AND l.PutawayZone = @c_PAZoneSKU                    --PSJ036 
	  GROUP BY sl.LOC, l.LogicalLocation, l.Loc  		  --PSJ036 
	  HAVING SUM(SL.Qty-SL.QtyAllocated-SL.Qtypicked) = 0 --PSJ036 
      ORDER BY l.LogicalLocation, l.Loc                   --PSJ036 
	  
      SET @n_RowCount = @@ROWCOUNT                                            
	  
	  IF @n_RowCount = 0    --PSJ036 Start logic from Pick Face Location
	  BEGIN
	     SELECT @n_PackQty     = p.CaseCnt,    --PSJ036
		   	    @c_PAZoneSKU   = S.PutawayZone --PSJ036
	     FROM dbo.SKU s(NOLOCK) 
	     JOIN dbo.PACK p (NOLOCK) ON s.Packkey = p.Packkey
	     WHERE s.Storerkey = @c_Storerkey
	     AND s.Sku = @c_Sku

	     INSERT INTO #PICKLOCTYPE
         SELECT sl.LOC    
         FROM dbo.SKUxLOC sl (NOLOCK)   
         JOIN dbo.LOC l(NOLOCK) ON sl.loc = l.loc
         WHERE sl.STORERKEY = @c_StorerKey    
         AND sl.SKU = @c_Sku    
         AND sl.LocationType = @c_LocationTypeOverride      
         AND l.facility = @c_Facility  
         AND l.HostWHCode = @c_Lottable02
         AND l.[Status] = 'OK'
         AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
		 AND l.MaxCarton * @n_PackQty = sl.QtyLocationLimit
	     AND l.PutawayZone = @c_PAZoneSKU
	     GROUP BY sl.LOC, l.LogicalLocation, l.Loc 
	     HAVING SUM(SL.Qty-SL.QtyAllocated-SL.Qtypicked) < 0
         ORDER BY l.LogicalLocation, l.Loc 

	     SET @c_PickLoc = (SELECT TOP 1 LOC FROM #PICKLOCTYPE)

         SELECT @n_PickMaxQty    = sl.QtyLocationLimit,
		   	    @n_Qty		     = sl.Qty,
		   	    @n_QtyAllocated  = sl.QtyAllocated,
			    @n_MaxCarton     = l.MaxCarton
         FROM dbo.SKUxLOC sl (NOLOCK)   
         JOIN dbo.LOC l(NOLOCK) ON sl.loc = l.loc
         WHERE sl.STORERKEY = @c_StorerKey    
         AND sl.SKU = @c_Sku    
         AND sl.LocationType = @c_LocationTypeOverride      
         AND l.facility = @c_Facility  
         AND l.HostWHCode = @c_Lottable02
	     and l.Loc = @c_PickLoc
         AND l.[Status] = 'OK'
         AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
	     AND l.PutawayZone = @c_PAZoneSKU
         ORDER BY l.LogicalLocation, l.Loc 

	     IF @n_Qty + @n_QtyAllocated < @n_PickMaxQty
		    BEGIN
			  SET @n_RowCount = 1
			END
         ELSE IF @n_Qty + @n_QtyAllocated > @n_PickMaxQty
		    BEGIN
			  SET @n_RowCount = 0
			END
	  END --PSJ036 END logic from Pick Face Location
	  

      IF @n_RowCount = 0                                                        
      BEGIN
		 SELECT @n_PackQty     = p.CaseCnt,    --(PSJ036)
		   	    @c_PAZoneSKU   = S.PutawayZone --(PSJ036)
	     FROM dbo.SKU s(NOLOCK) 
	     JOIN dbo.PACK p (NOLOCK) ON s.Packkey = p.Packkey
	     WHERE s.Storerkey = @c_Storerkey
	     AND s.Sku = @c_Sku

         --SELECT @n_PalletQty = p.Pallet                                             
         --      ,@n_PackQty   = CASE WHEN @c_UOM = '2' THEN p.CaseCnt                
         --                           WHEN @c_UOM = '6' THEN p.Qty                    
         --                           END                                          
         --FROM dbo.SKU s(NOLOCK) 
         --JOIN dbo.PACK p (NOLOCK) ON s.Packkey = p.Packkey
         --WHERE s.Storerkey = @c_Storerkey
         --AND s.Sku = @c_Sku

         -- 1) find Loc with available inventory => SUM(lli.Qty-lli.QtyAllocated-lli.Qtypicked) > 0
         -- 2) Find same friend that which has stock and able to fit for 1 pallet 
         --    => SUM(lli.QtyAllocated) > 0

         --INSERT INTO #PICKLOCTYPE                                                
         SET @CUR_FindLOC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR                 
         SELECT l.LOC 
               --,l.MaxPallet --PSJ036
			   ,l.MaxCarton   --PSJ036
               ,QtyAvailable = SUM(lli.Qty)                                         
               ,QtyAllocated = SUM(lli.QtyAllocated)                                
               ,QtyPicked    = SUM(lli.QtyPicked)                  
         FROM dbo.LOC l (NOLOCK)   
         JOIN dbo.LOTxLOCxID lli (NOLOCK) ON  lli.Storerkey = @c_StorerKey 
                                          AND lli.SKU = @c_Sku 
                                          AND lli.loc = l.loc
                                          AND lli.Lot = @c_Lot                          
         WHERE l.LocationType = 'DYNPPICK'     
         AND l.Facility   = @c_Facility  
         AND l.HostWHCode = @c_Lottable02
         AND l.[Status] = 'OK'
         AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
		 AND l.PutawayZone = @c_PAZoneSKU --PSJ036
         GROUP BY l.loc
               ,  l.ABC        
               ,  l.LogicalLocation
               --,  l.MaxPallet
			   ,  l.MaxCarton --(PSJ036)
         --HAVING ( SUM(lli.Qty) > 0 OR SUM(lli.QtyExpected) > 0)                 
         --   AND ((SUM(lli.PendingMoveIn) = 0 AND 
         --         CEILING(SUM(lli.QtyExpected + @n_QtyLeftToFulfill)/@n_PalletQty) <= l.MaxPallet) OR   
         --         SUM(lli.QtyExpected) + @n_QtyLeftToFulfill <= SUM(lli.PendingMoveIn))
         HAVING SUM(lli.Qty-lli.QtyAllocated-lli.Qtypicked) <> 0                    
                 --((SUM(lli.Qty) = 0 AND SUM(lli.QtyAllocated) > 0) AND                      
                 -- (--(SUM(lli.PendingMoveIn) = 0 AND                                             
                 --   CEILING(SUM(lli.QtyAllocated + @n_QtyLeftToFulfill)/@n_PalletQty) <= l.MaxPallet
                 --  --) OR                                                                    
                 --  -- SUM(lli.QtyAllocated) + @n_QtyLeftToFulfill <= SUM(lli.PendingMoveIn)  
                 -- )
         ORDER BY CASE WHEN SUM(lli.Qty-lli.QtyAllocated-lli.Qtypicked-@n_QtyLeftToFulfill) > 0 
                       THEN 1 
                       WHEN SUM(lli.Qty-lli.QtyAllocated-lli.Qtypicked) > 0 
                       THEN 3
                       WHEN SUM(lli.Qty-lli.Qtypicked) = 0                        
                       THEN 5
                       WHEN SUM(lli.Qty-lli.Qtypicked) > 0 
                       THEN 6
                       ELSE 7 END                                                 
               ,  l.ABC
               ,  l.LogicalLocation                                                 
         OPEN @CUR_FindLOC
         FETCH NEXT FROM @CUR_FindLOC INTO @c_PickLoc
                                          --,@n_MaxPallet
                                          ,@n_MaxCarton  
										  ,@n_Qty
                                          ,@n_QtyAllocated
                                          ,@n_QtyPicked

         WHILE @@FETCH_STATUS = 0 AND @n_QtyLeftToFulfill > 0
         BEGIN
            IF (@n_Qty - @n_QtyPicked) - @n_QtyAllocated < 0       
            BEGIN
               IF @n_Qty - @n_QtyPicked = 0 OR @n_Qty = 0                           
               BEGIN
                  SET @n_MaxCartonQty = @n_MaxCarton * @n_PackQty  --PSJ036
				  --SET @n_MaxPalletQty = @n_MaxPallet * @n_PalletQty
               END
               ELSE
               BEGIN
                  SET @n_MaxCartonQty = ( @n_MaxCarton * (((@n_Qty)/@n_PackQty))*@n_PackQty)  --PSJ036
				  --SET @n_MaxPalletQty = (@n_MaxPallet - CEILING((@n_Qty)/@n_PalletQty))*@n_PalletQty
               END

               SET @n_QtyExpected = @n_QtyAllocated + (@n_QtyPicked - @n_Qty)

               --IF @n_MaxPalletQty < @n_QtyExpected + @n_QtyLeftToFulfill
               IF @n_MaxCartonQty < @n_QtyExpected + @n_QtyLeftToFulfill  --PSJ036
			   BEGIN
                  BREAK
               END                                                                
            END

            IF @n_Qty - @n_QtyAllocated - @n_QtyPicked > 0           --QtyAvailable inv
            BEGIN
               SET @n_QtyLeftToFulfill = @n_QtyLeftToFulfill - 
                   (((@n_Qty-@n_QtyAllocated-@n_QtyPicked)/@n_PackQty)*@n_PackQty) --PSJ036
            END
            ELSE 
            BEGIN
               SET @n_QtyLeftToFulfill = 0
            END
   
            INSERT INTO #PICKLOCTYPE
            VALUES ( @c_PickLoc )

            FETCH NEXT FROM @CUR_FindLOC INTO @c_PickLoc
                                             --,@n_MaxPallet            
                                             ,@n_MaxCarton  --PSJ036
											 ,@n_Qty 
                                             ,@n_QtyAllocated
                                             ,@n_QtyPicked
         END
         SET @n_RowCount = 1 
 
         IF @n_QtyLeftToFulfill > 0
         BEGIN
            SET @n_RowCount = 0  
         END                                                    
      END
 
      IF @n_RowCount = 0                                                            
      BEGIN  
  
         INSERT INTO #PICKLOCTYPE
         SELECT TOP 1 l.LOC     
         FROM dbo.LOC l (NOLOCK)   
         LEFT OUTER JOIN dbo.LOTxLOCxID lli (NOLOCK) ON  lli.loc = l.loc
         WHERE l.LocationType = 'DYNPPICK'     
         AND l.facility = @c_Facility  
         AND l.HostWHCode = @c_Lottable02
         AND l.[Status] = 'OK'
	     AND l.PutawayZone = @c_PAZoneSKU  --PSJ036
         AND l.LocationFlag NOT IN ('HOLD','DAMAGE')
         --AND l.MaxPallet > 0                                                     
         AND l.MaxCarton > 0   --PSJ036                                                     --(PSJ036)
		 GROUP BY l.loc
               ,  l.ABC          
               ,  l.LogicalLocation
         HAVING SUM(ISNULL(lli.PendingMoveIn,0) + ISNULL(lli.QtyAllocated,0)) = 0   
            AND SUM(ISNULL(lli.Qty,0) - ISNULL(lli.QtyPicked,0)) = 0                
         ORDER BY l.ABC
               ,  l.LogicalLocation
               ,  l.Loc

         SET @n_RowCount = @@ROWCOUNT                                              
         IF @n_RowCount = 0                                                        
         BEGIN
            SET @n_OverQtyLeftToFulfill = @n_OverQtyLeftToFulfill - @n_QtyLeftToFulfill
         END                                                                       
         
         IF @n_RowCount > 0                                                        
         BEGIN
            SELECT @c_DPPLoc = LOC
            FROM #PICKLOCTYPE pl

            IF NOT EXISTS (SELECT 1 FROM SKUxLOC sl (NOLOCK)
                           WHERE sl.Storerkey = @c_Storerkey
                           AND   sl.Sku = @c_Sku
                           AND   sl.Loc = @c_DPPLoc
                           )
            BEGIN
               INSERT INTO SKUxLOC (Storerkey, Sku, Loc, LocationType)
               VALUES (@c_Storerkey, @c_sku, @c_DPPLoc, '')
            END
         END                                                                        
      END                                                                           
  END                                                                               
	  
  SELECT TOP 1 @c_OverPickLoc= Loc                                                  
  FROM #PICKLOCTYPE                                                                 
  ORDER BY RowID DESC                                                               
 
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'mspGetOverPickLoc01_BRA_ONBR'    
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [dbo].[mspGetOverPickLoc01_BRA_ONBR] TO [NSQL]
GO    