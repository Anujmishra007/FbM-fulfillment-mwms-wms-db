IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_EOrderReplenConfirm]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_EOrderReplenConfirm]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* SP: isp_EOrderReplenConfirm                                          */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Update Pickdetail UOM from 7 to 6                           */
/*          7: Required Replenishment 6=No replenishment needed         */
/* Usage:                                                               */
/*                                                                      */
/* Called By: nsp_ConfirmReplenishment                                  */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/************************************************************************/
CREATE PROC [dbo].[isp_EOrderReplenConfirm] ( 
   @c_ReplenishmentGroup   NVARCHAR(10)
  ,@c_ReplenishmentKey     NVARCHAR(10)
  ,@b_Success              INT = 1 OUTPUT 
  ,@n_Err                  INT = 0 OUTPUT 
  ,@c_Errmsg               NVARCHAR(255) = '' OUTPUT
  ,@b_Debug                INT = 0 
)
AS 
BEGIN
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
   	
   DECLARE @c_SKU                NVARCHAR(20),
           @n_QtyOrdered         INT,
           @c_Facility           NVARCHAR(5),
           @c_LOC                NVARCHAR(10),
           @c_ToLOC              NVARCHAR(10),   
           @c_LOT                NVARCHAR(10),
           @c_ID                 NVARCHAR(20),  
           @n_CaseCnt            INT, 
           @n_ReplenQty          INT, 
           @c_StorerKey          NVARCHAR(15), 
           @n_StartTCnt          INT, 
           @n_Continue           INT,            
           @c_SQL                NVARCHAR(2000),  
           @c_LoadKey            NVARCHAR(10), 
           @c_PickDetailKey      NVARCHAR(18) ='', 
           @c_NewPickDetailKey   NVARCHAR(18) = '',
           @n_QtyAvaliable       INT = 0 , 
           @b_ExistsFlag         BIT, 
           @n_QtyAlloc       INT, 
           @n_QtyTakeFromPickLoc INT, 
           @n_LooseQtyFromBulk   INT, 
           @n_FullCasePickQty    INT, 
           @c_MoveRefKey         NVARCHAR(10),
           @c_ToID               NVARCHAR(20),  
           @n_QtyToTake          INT,
           @n_QtyReplan          INT = 0, 
           @n_PT_RowRef          BIGINT = 0,
           @cFastPickLoc         CHAR(1) = 'N' 	
	
	SET @n_ReplenQty = 0 
	SELECT @c_LOT = r.LOT,
	       @c_LOC = r.ToLoc, 
	       @c_ID  = r.ToID,
	       @c_Facility = L.Facility, 
	       @c_StorerKey = r.Storerkey, 
	       @c_SKU = r.Sku, 
	       @n_ReplenQty = r.Qty -  r.QtyInPickLoc  
	FROM REPLENISHMENT AS r WITH(NOLOCK) 
	JOIN LOC AS l WITH(NOLOCK) ON r.ToLoc = L.Loc
	WHERE r.ReplenishmentKey = @c_ReplenishmentKey
	AND   r.Qty > r.QtyInPickLoc 
       
   IF @n_ReplenQty > 0  
   BEGIN
      IF @b_Debug = 1
      BEGIN
      	PRINT '>>>   ReplenishmentKey:' + @c_ReplenishmentKey + 
      	      ', Replen Qty:' + CAST(@n_ReplenQty AS VARCHAR(10))
      	PRINT '      SKU: ' + @c_SKU   
      	PRINT '      LOT: ' + @c_LOT + ', LOC: ' + @c_LOC
      END 
            	
   	SET @n_QtyAvaliable = 0 
   	SET @c_ToID = ''
  	
   	SELECT TOP 1 
   		@n_QtyAvaliable = SL.Qty - SL.QtyAllocated - SL.QtyPicked 
   	FROM SKUxLOC AS SL WITH(NOLOCK) 
   	WHERE SL.StorerKey = @c_StorerKey 
   	AND SL.Sku = @c_SKU 
   	AND SL.Loc = @c_LOC

      IF @b_Debug = 1
      BEGIN
      	PRINT '      Available Qty:' + CAST(@n_QtyAvaliable AS VARCHAR(10)) + 
      	      ', To ID:' + @c_ToID
      END     
            	
   	IF @n_QtyAvaliable >= @n_ReplenQty 
   	   GOTO EXIT_SP
   	
   	IF @n_QtyAvaliable > 0 
   	   SET @n_ReplenQty = @n_ReplenQty - @n_QtyAvaliable
   	
   	WHILE @n_ReplenQty > 0 
   	BEGIN         			
   		SET @c_PickDetailKey = ''
   			
   		-- swap with other batch
   		SELECT TOP 1 
   			@c_PickDetailKey = P.PickDetailKey,
   			@n_QtyAlloc  = P.Qty  
   		FROM  PICKDETAIL P WITH (NOLOCK) 
   		JOIN ORDERS AS o WITH(NOLOCK) ON o.OrderKey = P.OrderKey AND o.DocType='E'  
   		WHERE NOT EXISTS(SELECT 1 FROM PackTask AS PT WITH (NOLOCK)  
   			               WHERE PT.ReplenishmentGroup = @c_ReplenishmentGroup
   			               AND   PT.OrderKey = P.OrderKey)   	
   		AND   P.DoReplenish = 'N' 
         AND   P.StorerKey = @c_StorerKey   
   	   AND   P.Sku = @c_SKU    		
   		AND   P.LOC = @c_LOC
   		AND   P.UOM = '7'
   		AND   P.Qty > 0 
         AND   P.STATUS < '4'
         AND   P.ShipFlag NOT IN ('P','Y')  
   		ORDER BY CASE WHEN P.LOT = @c_LOT AND P.ID = @c_ToID THEN 1 
   		              WHEN P.LOT = @c_LOT AND P.ID <> @c_ToID THEN 2
   		              ELSE 2 
   		         END 
                    
         IF @c_PickDetailKey <> ''
         BEGIN
            IF @b_Debug = 1
            BEGIN
               PRINT '  *** Exchange UOM ***'
      	      PRINT '      With PickDetailKey: ' + @c_PickDetailKey + ', To ID: ' + @c_ToID 
      	      PRINT '      Qty: ' + CAST(@n_QtyAlloc AS VARCHAR(10))  
            END
            
            IF @n_QtyAlloc > @n_ReplenQty
            BEGIN
                 SET @c_NewPickDetailKey = ''
                              		
                  EXECUTE dbo.nspg_GetKey  
                     'PICKDETAILKEY',   
                     10 ,  
                     @c_NewPickDetailKey  OUTPUT,  
                     @b_success        OUTPUT,  
                     @n_err            OUTPUT,  
                     @c_errmsg         OUTPUT  
     
                  IF @b_success <> 1  
                  BEGIN  
                     SET @n_Err = 63885  
                     SET @c_ErrMsg = 'Get Pickdetail Key'
                     SEt @n_Continue = 3
                     GOTO EXIT_SP
                  END 

                  IF @b_Debug = 1
                  BEGIN
                  	PRINT '  *** Split PickDetail ***'
      	            PRINT '      New PickDetailKey: ' + @c_NewPickDetailKey + ', Qty: ' 
      	                  + CAST((@n_QtyAlloc -  @n_ReplenQty) AS VARCHAR(10))  
                  END
                  
                  INSERT INTO dbo.PICKDETAIL
                    (
                      PickDetailKey    ,CaseID           ,PickHeaderKey
                     ,OrderKey         ,OrderLineNumber  ,Lot
                     ,Storerkey        ,Sku              ,AltSku
                     ,UOM              ,UOMQty           ,Qty
                     ,QtyMoved         ,STATUS           ,DropID
                     ,Loc              ,ID               ,PackKey
                     ,UpdateSource     ,CartonGroup      ,CartonType
                     ,ToLoc            ,DoReplenish      ,ReplenishZone
                     ,DoCartonize      ,PickMethod       ,WaveKey
                     ,EffectiveDate    ,TrafficCop       ,ArchiveCop
                     ,OptimizeCop      ,ShipFlag         ,PickSlipNo
                    )
                  SELECT @c_NewPickDetailKey  AS PickDetailKey
                        ,CaseID           ,PickHeaderKey    ,OrderKey
                        ,OrderLineNumber  ,Lot              ,Storerkey
                        ,Sku              ,AltSku           ,UOM
                        ,UOMQty           ,@n_QtyAlloc -  @n_ReplenQty
                        ,QtyMoved         ,[STATUS]         ,DropID       
                        ,Loc              ,ID               ,PackKey      
                        ,UpdateSource     ,CartonGroup      ,CartonType      
                        ,ToLoc            ,DoReplenish      ,ReplenishZone      
                        ,DoCartonize      ,PickMethod       ,WaveKey      
                        ,EffectiveDate    ,TrafficCop       ,ArchiveCop      
                        ,'1'              ,ShipFlag         ,PickSlipNo
                  FROM   dbo.PickDetail WITH (NOLOCK)
                  WHERE  PickDetailKey = @c_PickDetailKey 
                  
                  UPDATE PickDetail WITH (ROWLOCK)
                     SET Qty = @n_ReplenQty, TrafficCop = NULL, EditDate = GETDATE(), EditWho = SUSER_SNAME()
                  WHERE PickDetailKey = @c_PickDetailKey
                  
                  SET @n_QtyAlloc =  @n_ReplenQty                  	
            END -- IF @n_QtyAlloc > @n_ReplenQty
                       
            IF @c_ToID <> @c_ID 
            BEGIN
               UPDATE PICKDETAIL WITH (ROWLOCK) 
            	   SET UOM = '6', ID = @c_ToID, EditDate = GETDATE(), EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @c_PickDetailKey            	
            END
            ELSE 
            BEGIN
               UPDATE PICKDETAIL WITH (ROWLOCK) 
            	   SET UOM = '6', TrafficCop = NULL, EditDate = GETDATE(), EditWho = SUSER_SNAME()
               WHERE PickDetailKey = @c_PickDetailKey            	
            END
                                  	            	            
            SET @n_ReplenQty = @n_ReplenQty - @n_QtyAlloc            	

   		   IF @n_ReplenQty = 0 
   		      BREAK            	
         END -- IF @c_PickDetailKey <> ''
         ELSE 
         	BREAK          	
   	END -- WHILE @@n_ReplenQty > 0 
   END -- IF @n_ReplenQty > 0 
   
   EXIT_SP:	
END
GO
GRANT EXECUTE ON [dbo].[isp_EOrderReplenConfirm] TO nSQL 
GO
