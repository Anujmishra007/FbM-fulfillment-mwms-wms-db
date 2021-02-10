if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsp_updateconsignee]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nsp_updateconsignee]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: nsp_updateconsignee                                */
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

CREATE PROCEDURE nsp_updateconsignee AS
begin
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   update orders
   set consigneekey=substring(consigneekey,1,11)+substring(stop,1,3)
   where storerkey="fuji"
   and len(consigneekey)<14
end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nsp_updateconsignee to nSQL
GO
