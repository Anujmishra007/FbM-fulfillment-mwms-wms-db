if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ids_sp_extract_inventory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ids_sp_extract_inventory]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/***************************************************************************/ 
/* Object Name: ids_SP_Extract_Inventory                                   */
/* Modification History:                                                   */  
/*                                                                         */  
/* Called By:  Exceed                                                      */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Date         Author    Ver.  Purposes                                   */
/* 05-Aug-2002            1.0   Initial revision                           */
/***************************************************************************/ 
CREATE PROC ids_SP_Extract_Inventory
 AS
 BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
 	
 	-- remove records which are more than 30 days old
 	DELETE ids_inventory_balance
 	WHERE DATEDIFF(DAY, exportdate, GETDATE()) > 60
 	INSERT ids_inventory_balance (storerkey, sku, lot, id, loc, putawayzone, qty, qtyallocated, qtypicked)
 	SELECT storerkey, sku, lot, id, a.loc, putawayzone, qty, qtyallocated, qtypicked
 	FROM lotxlocxid a (NOLOCK) INNER JOIN loc b
 	ON a.loc = b.loc
 	WHERE qty > 0
 END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


GRANT EXECUTE ON ids_sp_extract_inventory to nSQL
GO
