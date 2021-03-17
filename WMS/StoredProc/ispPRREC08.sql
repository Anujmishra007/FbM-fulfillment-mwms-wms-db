IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPRREC08]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPRREC08]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPRREC08                                            */
/* Creation Date: 14-Aug-2018                                              */
/* Copyright: LFL                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-5981 CN PVH Pre-finalize update userdefine 1 & 2           */                               
/*        : Before finalize ASN                                            */
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.1                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 2021-03-16   WLChooi 1.1   WMS-16573 - Avoid updating Receiptdetail     */
/*                                        table multiple times (WL01)      */
/***************************************************************************/  
CREATE PROC [dbo].[ispPRREC08]  
(     @c_Receiptkey  NVARCHAR(10)  
  ,   @c_ReceiptLineNumber  NVARCHAR(5) = ''      
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_Debug              INT
         , @n_Cnt                INT
         , @n_Continue           INT 
         , @n_StartTranCount     INT 
   
   SET @b_Success= 1 
   SET @n_Err    = 0  
   SET @c_ErrMsg = ''
   SET @b_Debug = '0' 
   SET @n_Continue = 1  
   SET @n_StartTranCount = @@TRANCOUNT  
   
   IF NOT EXISTS( SELECT 1
                  FROM RECEIPT WITH (NOLOCK)
                  WHERE ReceiptKey = @c_Receiptkey
                  AND DocType = 'A'
                )
   BEGIN
      GOTO QUIT_SP        
   END
   
   IF EXISTS(SELECT 1 
             FROM RECEIPT R (NOLOCK)
             JOIN CODELKUP CL (NOLOCK) ON R.Storerkey = CL.Storerkey AND R.Userdefine10 = CL.Short AND CL.Listname = 'ID2UDF01'
             WHERE R.Receiptkey = @c_Receiptkey)
   BEGIN
   	  UPDATE RECEIPTDETAIL WITH (ROWLOCK)
   	  SET Userdefine02 = Userdefine01,
   	      Userdefine01 = ToId
   	  WHERE Receiptkey = @c_Receiptkey
   	  AND LEFT(ToID, 2) = 'PS'
   	  AND ISNULL(Userdefine02, '') = ''   --WL01                    
   END          
      
   SET @n_err = @@ERROR  
   
   IF @n_err <> 0   
   BEGIN  
      SET @n_continue = 3  
      SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)  
      SET @n_err = 82000    
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update RECEIPTDETAIL Table Failed. (ispPRREC08)' 
                   + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '  
      GOTO QUIT_SP
   END  

   QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTranCount
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispPRREC08'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount
      BEGIN
         COMMIT TRAN
      END
   END
END
GO

GRANT EXECUTE ON [dbo].[ispPRREC08] TO nSQL 
GO
