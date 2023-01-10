SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Procedure: isp_RPT_KIT_POPUPKITRP_001_2                          */
/* Creation Date: 21-JAN-2022                                              */
/* Copyright: LFL                                                          */
/* Written by: Harshitha                                                   */
/*                                                                         */
/* Purpose: WMS-18809                                                      */
/*                                                                         */
/* Called By: RPT_KIT_POPUPKITRP_001_2                                     */
/*                                                                         */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 21-Jan-2022  WLChooi 1.0   DevOps Combine Script                        */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_KIT_POPUPKITRP_001_2]
      @c_KITKey        NVARCHAR(20)
    , @n_ExpectedQty   INT

AS
BEGIN

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SELECT KITDETAIL.Sku,
          KITDETAIL.ExpectedQty / @n_ExpectedQty AS ComponentQty
   FROM KITDETAIL (NOLOCK), KIT (NOLOCK)
   WHERE ( KITDETAIL.KitKey = KIT.kitKey )
	AND	( KITDETAIL.[Type] = 'F' )
	AND   ( KIT.[Status]     < '9' )
	AND   ( KIT.Kitkey       = @c_KITKey )

END
GO
GRANT EXECUTE ON  [dbo].[isp_RPT_KIT_POPUPKITRP_001_2] TO [JReportRole]
GO
GRANT EXECUTE ON  [dbo].[isp_RPT_KIT_POPUPKITRP_001_2] TO [NSQL]
GO
