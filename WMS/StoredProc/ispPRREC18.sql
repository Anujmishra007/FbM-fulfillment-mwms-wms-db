IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPRREC18]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPRREC18]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPRREC18                                            */
/* Creation Date: 17-MAY-2021                                              */
/* Copyright: LFL                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-17011- [CN] LACOSTE_PreFinalizeReceiptSP                    */                               
/*        : Before finalize ASN                                            */
/*                                                                         */
/* Called By:                                                              */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/  
CREATE PROC [dbo].[ispPRREC18]  
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
         , @n_Continue           INT 
         , @n_StartTranCount     INT         
         , @c_ToID               NVARCHAR(18)
         , @c_Storerkey          NVARCHAR(15)
         , @c_ReceiptGroup       NVARCHAR(20)
         , @c_RecType            NVARCHAR(10) = N''
         , @c_UserDefine03       NVARCHAR(30) = N''
         , @c_Style              NVARCHAR(20) = N''
         , @c_Color              NVARCHAR(10) = N''
   
   SET @b_Success= 1 
   SET @n_Err    = 0  
   SET @c_ErrMsg = ''
   SET @b_Debug = '0' 
   SET @n_Continue = 1  
   SET @n_StartTranCount = @@TRANCOUNT  
   
   IF @n_Continue IN(1,2)
   BEGIN        

      SELECT @c_ReceiptGroup = ReceiptGroup,
             @c_UserDefine03 = UserDefine03,
             @c_RecType = RECType,
             @c_Storerkey = StorerKey  
      FROM  RECEIPT (NOLOCK) WHERE ReceiptKey = @c_ReceiptKey;
      
   IF @c_ReceiptGroup = ''
   BEGIN
      DECLARE CUR_RECDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT  rd.ReceiptLineNumber,
                  s.Style,
                  s.Color
         FROM   RECEIPTDETAIL rd (NOLOCK)
         JOIN   SKU s (NOLOCK) ON s.StorerKey = rd.StorerKey
                               AND s.Sku      = rd.Sku
   WHERE ReceiptKey = @c_ReceiptKey
   ORDER BY  rd.ReceiptLineNumber
      
      OPEN CUR_RECDET  
      
      FETCH NEXT FROM CUR_RECDET INTO @c_ReceiptLineNumber, @c_Style, @c_Color
      
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)          
      BEGIN
          IF @c_RecType = 'ASN'
           AND NOT EXISTS (    SELECT      1
                               FROM  RECEIPT r (NOLOCK)
                               JOIN  RECEIPTDETAIL rd (NOLOCK) ON rd.ReceiptKey = r.ReceiptKey
                               JOIN SKU s (NOLOCK) ON s.StorerKey = rd.StorerKey AND s.Sku = rd.Sku
                               WHERE r.StorerKey = @c_Storerkey
                               AND r.UserDefine03   = @c_UserDefine03
                               AND rd.QtyExpected   > 0
                               AND s.Style          = @c_Style
                               AND s.Color          = @c_Color)
      BEGIN
          UPDATE RECEIPTDETAIL WITH (ROWLOCK)
          SET UserDefine03 = 'NONASN', TrafficCop = NULL 
          WHERE ReceiptKey = @c_ReceiptKey AND ReceiptLineNumber = @c_ReceiptLineNumber
      END;
      ELSE
      BEGIN
       UPDATE RECEIPTDETAIL WITH (ROWLOCK)
       SET UserDefine03 = @c_RecType, TrafficCop = NULL 
       WHERE ReceiptKey = @c_ReceiptKey AND ReceiptLineNumber = @c_ReceiptLineNumber
      END
            
         SET @n_err = @@ERROR  
         
         IF @n_err <> 0   
         BEGIN  
            SET @n_continue = 3  
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)  
            SET @n_err = 82020    
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update RECEIPTDETAIL Table Failed. (ispPRREC18)' 
                         + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '  
         END  
         
      FETCH NEXT FROM CUR_RECDET INTO @c_ReceiptLineNumber, @c_Style, @c_Color
      END            
      CLOSE CUR_RECDET
      DEALLOCATE CUR_RECDET 

   END                                   
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispPRREC18'
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

GRANT EXECUTE ON [dbo].[ispPRREC18] TO nSQL 
GO
