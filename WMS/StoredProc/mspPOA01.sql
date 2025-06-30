SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: mspPOA01                                           */
/* Creation Date: 12-Jun-2015                                           */  
/* Copyright: Maersk                                                    */
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: UWP-32704 - Auto Allocate SO                                */
/*                                                                      */  
/* Called By: StorerConfig.ConfigKey = PostAllocationSP                 */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Rev   Purposes                                  */  
/************************************************************************/  
CREATE OR ALTER PROC [dbo].[mspPOA01]
     @c_OrderKey    NVARCHAR(10)
   , @c_LoadKey    NVARCHAR(10)
   , @b_Success     INT           OUTPUT    
   , @n_Err         INT           OUTPUT    
   , @c_ErrMsg      NVARCHAR(250) OUTPUT    
   , @b_debug       INT = 0    
AS    
BEGIN    
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF     
    
   DECLARE  @n_Continue       INT
            , @n_StartTCnt    INT -- Holds the current transaction count

                          
   SELECT @n_StartTCnt=@@TRANCOUNT , @n_Continue=1, @b_Success=1, @n_Err=0  
   SELECT @c_ErrMsg=''

   IF @n_Continue=1 OR @n_Continue=2
   BEGIN
      IF ISNULL(RTRIM(@c_OrderKey),'') = ''
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 63500
         SELECT @c_ErrMsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+':  Orderkey is Blank (mspPOA01)'
         GOTO EXIT_SP
      END
   END
   /* Emergency Order Allocation */
   IF @n_Continue=1 OR @n_Continue=2
   BEGIN

      UPDATE ORDERS WITH (ROWLOCK)
      SET Ecom_Platform = 'EMG_EMER'
      ,SequenceNo = CASE WHEN ISNULL(Orders.SequenceNo,0) = 0 OR (Orders.SequenceNo = 99999999)
      THEN 1 ELSE Cast(Orders.SequenceNo as Int)+1 END
      ,TrafficCop = NULL
      WHERE Orderkey = @c_Orderkey
      AND M_Fax2 = 'AUTO ALLOCATION'

    END

    EXIT_SP:
    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SELECT @b_Success = 0    
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_StartTCnt    
         BEGIN    
            COMMIT TRAN    
         END    
      END    
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ispPOA01'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN    
   END    
   ELSE    
   BEGIN    
      SELECT @b_Success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
      RETURN    
   END    
    
END -- Procedure  
GO
GRANT EXECUTE ON [dbo].[mspPOA01] TO nSQL
GO
