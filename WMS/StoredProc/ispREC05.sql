SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: ispREC05                                           */
/* Creation Date: 05-FEB-2021                                           */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-16172-RG NIKE Receipt Header Trigger update ASNStatus   */   
/*                                                                      */
/* Called By: isp_ReceiptTrigger_Wrapper from Receipt Trigger           */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/

CREATE OR ALTER PROC ispREC05   
   @c_Action        NVARCHAR(10),
   @c_Storerkey     NVARCHAR(15),  
   @b_Success       INT      OUTPUT,
   @n_Err           INT      OUTPUT, 
   @c_ErrMsg        NVARCHAR(250) OUTPUT
AS   
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @n_Continue     INT,
           @n_StartTCnt    INT,
           @c_Receiptkey   NVARCHAR(10),
           @c_doctype NCHAR(1)           
                                             
    SELECT @n_Continue = 1, @n_StartTCnt = @@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_Success = 1

   IF @c_Action NOT IN('INSERT','UPDATE','DELETE')
      GOTO QUIT_SP      

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END   
         
    IF @c_Action IN('UPDATE') 
    BEGIN
      
      SET @c_Receiptkey = ''

      SELECT TOP 1 @c_Receiptkey = I.Receiptkey
      FROM #INSERTED I 

      IF EXISTS (SELECT 1 FROM #INSERTED I 
                 JOIN #DELETED D ON I.Receiptkey = D.Receiptkey 
                 WHERE I.Userdefine06 <> ISNULL(D.Userdefine06,'1900-01-01 00:00:00.000') AND I.Storerkey = @c_Storerkey)
       BEGIN   

          UPDATE RECEIPT WITH (ROWLOCK)
             SET ASNStatus = 'RCVD',
                 Trafficcop = NULL,
                 EditWho = SUSER_SNAME(),
                 EditDate = GETDATE()
             WHERE Receiptkey = @c_Receiptkey

        END
   END
      
   QUIT_SP:
   
    IF @n_Continue=3  -- Error Occured - Process AND Return
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
       EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispREC05'     
       --RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
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
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [ispREC05] TO NSQL
GO
