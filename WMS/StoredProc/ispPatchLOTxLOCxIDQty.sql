if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispPatchLOTxLOCxIDQty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispPatchLOTxLOCxIDQty]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: ispPatchLOTxLOCxIDQty                              */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   ver  Purposes                                  */
/* 14-09-2009   TLTING   1.1  ID field length	(tlting01)              */
/* 21-05-2012   KHLim01  1.3  Update EditDate                           */
/************************************************************************/

CREATE PROCEDURE ispPatchLOTxLOCxIDQty
   @c_lot NVARCHAR(10),
   @c_loc NVARCHAR(10),
   @c_id  NVARCHAR(18)		-- tlting01
AS
BEGIN		  
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @n_QtyPicked int,
   		  @n_QtyAllocated int
   
	SELECT @n_QtyPicked = SUM(Qty) 	
	FROM  PICKDETAIL (NOLOCK)
	WHERE LOT = @c_Lot
	and	LOC = @c_loc
	and   ID  = @c_id
   and   status Between '5' AND '8'   -- tlting 2009/4/8 
	--and   status in ('5','6','7','8')

	SELECT @n_QtyAllocated = SUM(Qty) 	
	FROM  PICKDETAIL (NOLOCK)
	WHERE LOT = @c_Lot
	and	LOC = @c_loc
	and   ID  = @c_id
   and   status Between '0' AND '4'     -- tlting 2009/4/8 
	-- and   status in ('0','1','2','3','4')

	IF @n_QtyPicked IS NULL 
		SELECT @n_QtyPicked = 0

	IF @n_QtyAllocated IS NULL 
		SELECT @n_QtyAllocated = 0

   IF EXISTS(SELECT 1 FROM LOTxLOCxID (NOLOCK) 
            	WHERE LOT = @c_Lot
            	and	LOC = @c_loc
            	and   ID  = @c_id
            	and   ( QtyAllocated <> @n_QtyAllocated OR QtyPicked <> @n_QtyPicked ))
   BEGIN
   	SELECT @c_LOT 'lot', @c_loc 'LOC', @c_id 'ID'

      BEGIN TRAN  

   	UPDATE LOTxLOCxID  with (ROWLOCK)    -- tlting 2009/4/8 
   		SET QtyPicked = @n_QtyPicked, QtyAllocated = @n_QtyAllocated, TrafficCop=NULL
            ,EditDate  = GETDATE()   -- KHLim01
   	WHERE LOT = @c_Lot
   	and	LOC = @c_loc
   	and   ID  = @c_id
   	and   ( QtyAllocated <> @n_QtyAllocated OR QtyPicked <> @n_QtyPicked )

   	IF @@ERROR = 0
     		COMMIT TRAN
   	ELSE
   		ROLLBACK TRAN
   END

END
GO

GRANT EXECUTE ON ispPatchLOTxLOCxIDQty TO NSQL
GO
