IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[ispITrnSerialNoAdjustment]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[ispITrnSerialNoAdjustment]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Stored Procedure: ispITrnSerialNoAdjustment                          */  
/* Creation Date: 23-May-2017                                           */  
/* Copyright: LFL                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: WMS-1884 Serial Number adjustment transaction               */ 
/*                                                                      */  
/* Called By: isp_FinalizeADJ                                           */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Rev   Purposes                                  */ 
/************************************************************************/  

CREATE PROCEDURE dbo.ispITrnSerialNoAdjustment (
     @c_TranType     NVARCHAR(10) = 'AJ'
   , @c_StorerKey    NVARCHAR(15)
   , @c_SKU          NVARCHAR(20)
   , @c_SerialNo     NVARCHAR(30)
   , @n_QTY          INT = 1
   , @c_SourceKey    NVARCHAR(20)
   , @c_SourceType   NVARCHAR(30)
   , @b_Success      INT            OUTPUT  
   , @n_Err          INT            OUTPUT  
   , @c_ErrMsg       NVARCHAR(250)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue       INT,
           @c_ITrnKey        NVARCHAR(10),
           @n_StartTranCount INT           
   
   SELECT  @n_Err = 0, @c_ErrMsg = '', @b_Success = 1, @n_continue = 1, @n_StartTranCount = @@TRANCOUNT 

   SELECT @c_ITrnKey = ITrnKey
   FROM ITrn WITH (NOLOCK)
   WHERE TranType = @c_TranType
   AND StorerKey = @c_StorerKey
   AND SKU = @c_SKU
   AND SourceKey = @c_SourceKey
      
   IF @@ROWCOUNT <> 1
   BEGIN
   	  SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 109351
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': ITrn adjustment record not found (ispITrnSerialNoAdjustment)' 
      GOTO QUIT_SP
   END
   
   INSERT INTO ITrnSerialNo (ITrnKey, TranType, StorerKey, SKU, SerialNo, QTY, SourceKey, SourceType)
   VALUES (@c_ITrnKey, @c_TranType, @c_StorerKey, @c_SKU, @c_SerialNo, @n_QTY, @c_SourceKey, @c_SourceType)
   
   SET @n_err = @@ERROR 
   
   IF @n_err  <> 0
   BEGIN
   	  SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 109352
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert ITrnSerialNo failed (ispITrnSerialNoAdjustment)' + ' ( '
                             + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
      GOTO QUIT_SP
   END
      
QUIT_SP:

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispITrnSerialNoAdjustment'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      
      WHILE @@TRANCOUNT > @n_StartTranCount  
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
GRANT EXECUTE ON [dbo].[ispITrnSerialNoAdjustment] TO nSQL 
GO
