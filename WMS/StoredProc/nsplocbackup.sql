if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsplocbackup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsplocbackup]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Stored Procedure: nsplocbackup                                       */
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
/* Date         Author        Purposes                                  */
/************************************************************************/

CREATE PROCEDURE nsplocbackup  AS
 BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
 	/* Just in case this sp have been run twice, so have to delete first before insert */
  	DELETE FROM locbak WHERE datediff (day, getdate() - 1, inventorydate) = 0
 	INSERT INTO locbak (Loc, Locationtype, Putawayzone, InventoryDate)
 	SELECT loc, Locationtype, Putawayzone, GETDATE() - 1  FROM loc 
 END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON nsplocbackup to nSQL
GO
