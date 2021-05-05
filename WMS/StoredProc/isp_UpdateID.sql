IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_UpdateID]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_UpdateID]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store Procedure: isp_UpdateID                                        */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: - Due to DEADLOCK situation for accessing this script       */
/*            of - "nspItrnAddMoveCheck" by IDSHK, the script is        */
/*            to be reversed back to the previous one.                  */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author    Ver.  Purposes                                */
/************************************************************************/

CREATE PROC [dbo].[isp_UpdateID]
AS
BEGIN
   SET NOCOUNT ON
   SET XACT_ABORT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   UPDATE ID WITH (ROWLOCK)
      SET Qty =
         ( SELECT SUM(LOTXLOCXID.QTY)
           FROM LOTXLOCXID WITH (NOLOCK)
           WHERE ID = '' ),
          TrafficCop = NULL , EditDate = getdate()
    WHERE ID = ''
END -- Procedure
GO
GRANT EXECUTE ON [dbo].[isp_UpdateID] TO NSQL
GO