IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPatchSKUxLOCQty]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPatchSKUxLOCQty]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* 21-May-2012 KHLim01     1.2   Update EditDate                        */
/* 13-Jul-2017 TLTING      1.3   Commit tran fix                        */

CREATE PROCEDURE ispPatchSKUxLOCQty
   @c_storerkey NVARCHAR(15),
   @c_SKU  NVARCHAR(20),   
   @c_loc  NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_QtyAllocated  int,
		     @n_QtyPicked     int

	SELECT @n_QtyAllocated = SUM(Qty) 	
	FROM  PICKDETAIL (NOLOCK)
	WHERE StorerKey = @c_StorerKey
	and   SKU = @c_SKU
	and   LOC = @c_LOC
	and   status in ('0','1','2','3','4')

	SELECT @n_QtyPicked = SUM(Qty) 	
	FROM  PICKDETAIL (NOLOCK)
	WHERE StorerKey = @c_StorerKey
	and   SKU = @c_SKU
	and   LOC = @c_LOC
	and   status in ('5','6','7','8')

	IF @n_QtyAllocated IS NULL 
		SELECT @n_QtyAllocated = 0

	IF @n_QtyPicked IS NULL 
		SELECT @n_QtyPicked = 0

	BEGIN TRAN
   
   IF EXISTS(SELECT 1 FROM SKUxLOC (NOLOCK) WHERE StorerKey = @c_StorerKey
            	and   SKU = @c_SKU
            	and   LOC = @c_LOC
            	and   ( QtyAllocated <> @n_QtyAllocated OR QtyPicked <> @n_QtyPicked ))
   BEGIN
      BEGIN TRAN 

   	UPDATE SKUxLOC  WITH (RowLOCK) -- TLTING 2009/4/8  rowlock
   		SET QtyAllocated = @n_QtyAllocated, QtyPicked = @n_QtyPicked, TrafficCop=NULL
            ,EditDate  = GETDATE()   -- KHLim01
   	WHERE StorerKey = @c_StorerKey
   	and   SKU = @c_SKU
   	and   LOC = @c_LOC
   	and   ( QtyAllocated <> @n_QtyAllocated OR QtyPicked <> @n_QtyPicked )
   	IF @@ERROR = 0
      BEGIN
     		   COMMIT TRAN
      END 
   	ELSE
   		ROLLBACK TRAN
   END

   COMMIT TRAN

END
GO
GRANT EXECUTE ON [dbo].[ispPatchSKUxLOCQty] TO nSQL 
GO
