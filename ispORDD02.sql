/************************************************************************/
/* Stored Procedure: ispORDD02                                          */
/* Creation Date: 03-Jan-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/*                                                                      */
/* Called By: isp_OrderdetailTrigger_Wrapper from Orderdetail Trigger   */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 2                                                           */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/************************************************************************/
CREATE OR ALTER PROC [dbo].[ispORDD02]     
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
     
   DECLARE @n_Continue        INT,
           @n_StartTCnt       INT,
           @c_OrderKey        NVARCHAR(10), 
           @c_OrderLineNumber NVARCHAR(5), 
           @n_OpenQty         INT
         , @n_QtyAlloc        INT = 0                                               --(Wan02)
         , @c_OrdLineNo_Orig  NVARCHAR(5) = ''                                      --(Wan01)
                                                       
   SELECT @n_Continue = 1, @n_StartTCnt = @@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_Success = 1

   IF @c_Action NOT IN('INSERT','UPDATE','DELETE')
      GOTO QUIT_SP      

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END     

   IF @c_Action IN('INSERT') 
   BEGIN
		UPDATE OD 
		SET OD.OriginalQty = (OD.OpenQty - OD.OpenQty%convert(INT, P.CaseCnt))
		  , OD.OpenQty = (OD.OpenQty - OD.OpenQty%convert(INT, P.CaseCnt))
		FROM dbo.ORDERDETAIL AS OD (NOLOCK) INNER JOIN SKU ON OD.Sku = SKU.SKU AND OD.StorerKey = SKU.StorerKey
		INNER JOIN PACK AS P (NOLOCK) ON SKU.PACKKey = P.PackKey  
		WHERE EXISTS(SELECT 1 FROM #INSERTED WHERE OD.OrderKey = #INSERTED.OrderKey) 
		AND OD.StorerKey = @c_Storerkey
		AND OD.Status < 9
		AND OD.OpenQty%convert(INT, P.CaseCnt) > 0

		SET @n_err = @@ERROR

        IF @n_err <> 0
        BEGIN
           SET @n_continue = 3
           SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
           SET @n_err = 81030  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Orderdetail.Qty Failed. (ispORDD02)'
                       + '( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                                                            
        END 
   END
   
   IF @c_Action IN('UPDATE') 
   BEGIN
	   UPDATE OD 
	   SET OD.OriginalQty = (OD.OpenQty - OD.OpenQty % convert(INT, P.CaseCnt))
		  ,OD.OpenQty = (OD.OpenQty - OD.OpenQty % convert(INT, P.CaseCnt))
	   FROM dbo.ORDERDETAIL AS OD (NOLOCK) INNER JOIN SKU ON OD.Sku = SKU.SKU AND OD.StorerKey = SKU.StorerKey
	   INNER JOIN PACK AS P (NOLOCK) ON SKU.PACKKey = P.PackKey
	   INNER JOIN #INSERTED AS I ON I.Orderkey = OD.Orderkey AND I.OrderLineNumber = OD.OrderLineNumber
       INNER JOIN #DELETED D ON I.Orderkey = D.Orderkey AND I.OrderLineNumber = D.OrderLineNumber
	   WHERE OD.StorerKey = @c_Storerkey
		AND OD.Status < 9
		AND OD.OpenQty%convert(INT, P.CaseCnt) > 0
	   
		SET @n_err = @@ERROR

        IF @n_err <> 0
        BEGIN
           SET @n_continue = 3
           SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
           SET @n_err = 81030  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Orderdetail.Qty Failed. (ispORDD02)'
                       + '( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                                                             
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispORDD02'
      IF @c_Action IN('DELETE')       
         RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
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

