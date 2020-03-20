IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dbo.ispMVCHK01') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE dbo.ispMVCHK01
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: ispMVCHK01                                         */
/* Creation Date: 16-OCT-2019                                           */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-10923 Not allow WMS move if the pallet have pending     */
/*          putaway task for RDT.                                       */
/*                                                                      */
/* Called By: Inventory Move                                            */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/************************************************************************/

CREATE PROCEDURE dbo.ispMVCHK01
   @c_Lot       NVARCHAR(10),
   @c_FromLoc   NVARCHAR(10), 
   @c_FromID    NVARCHAR(18), 
   @b_Success   INT = 1  OUTPUT,
   @n_Err       INT = 0  OUTPUT,
   @c_Errmsg    NVARCHAR(250) = '' OUTPUT   
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @c_Storerkey NVARCHAR(15),
           @c_Taskdetailkey NVARCHAR(10),
           @n_Continue INT,
           @n_IsRDT INT 
   
   SELECT @b_Success = 1, @n_Err = 0, @c_Errmsg = '', @n_Continue = 1, @c_Storerkey = '', @c_Taskdetailkey = ''
   
   IF ISNULL(@c_Lot,'') <> ''
   BEGIN
   	  SELECT @c_Storerkey = Storerkey
   	  FROM LOT (NOLOCK)
   	  WHERE Lot = @c_Lot   	        	  
   END
   ELSE
      SET @c_Storerkey = ''
   
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT 
 
   IF @n_IsRDT <> 1 
   BEGIN   	   	
   	  SELECT TOP 1 @c_Taskdetailkey = Taskdetailkey 
   	  FROM TASKDETAIL (NOLOCK)
   	  WHERE TaskType = 'PA1'
   	  AND FromLoc = @c_FromLoc
   	  AND FromID = @c_FromID
   	  AND Status =  '0'
   	  AND LEFT(SourceType,4) = 'rdt_' 
   	  AND (Storerkey = @c_Storerkey OR @c_Storerkey = '')

      IF ISNULL(@c_Taskdetailkey,'') <> ''   
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_Err = 7590
         SELECT @c_errmsg = 'Not allow to move pallet with pending putaway task. From Loc: ' + RTRIM(@c_FromLoc) + ' From ID: ' + RTRIM(@c_FromID) + ' Task#: ' + RTRIM(@c_Taskdetailkey) + ' (ispMVCHK01)' 
         SELECT @b_Success = 0
         GOTO EXIT_SP   	
      END
   END   
        
   EXIT_SP:  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.ispMVCHK01 TO NSQL
GO
