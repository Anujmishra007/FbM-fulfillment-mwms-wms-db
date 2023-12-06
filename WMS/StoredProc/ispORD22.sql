SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: ispORD22                                           */
/* Creation Date: 28-NOV-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-24287 - SG Logitech auto create consignee when create   */
/*          order                                                       */
/*                                                                      */
/* Called By: isp_OrderTrigger_Wrapper from Orders Trigger              */
/*            Storerconfig: OrdersTrigger_SP                            */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 28-NOV-2023  NJOW     1.0  DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispORD22]
   @c_Action    NVARCHAR(10)
 , @c_Storerkey NVARCHAR(15)
 , @b_Success   INT           OUTPUT
 , @n_Err       INT           OUTPUT
 , @c_ErrMsg    NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT
         , @n_StartTCnt    INT
         , @c_Orderkey     NVARCHAR(10)

   SELECT @n_Continue = 1 , @n_StartTCnt = @@TRANCOUNT, @n_Err = 0, @c_ErrMsg = '', @b_Success = 1

   IF @c_Action NOT IN ( 'INSERT', 'UPDATE' )
      GOTO QUIT_SP

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END

   IF @n_continue IN (1,2) AND @c_Action = 'INSERT'
   BEGIN
      DECLARE CUR_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT I.Orderkey
      FROM #INSERTED I
      WHERE I.Storerkey = @c_Storerkey
      AND ISNULL(I.Consigneekey,'') <> ''
      AND NOT EXISTS(SELECT 1 
                     FROM STORER S (NOLOCK)
                     WHERE S.Storerkey = I.Consigneekey) 
                                                   
      OPEN CUR_ORD
      
      FETCH NEXT FROM CUR_ORD INTO @c_Orderkey
      
      WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
      BEGIN      	
      	
      	 INSERT INTO STORER (Storerkey, Type, Company, Address1, Address2, Address3, Address4,
      	                     City, Zip, Country, ConsigneeFor)
      	 SELECT O.Consigneekey, '2', O.C_Company, O.C_Address1, O.C_Address2,
                O.C_Address3, O.C_Address4, O.C_City, O.C_Zip, O.C_Country, O.Storerkey
         FROM ORDERS O (NOLOCK)
         WHERE O.Orderkey = @c_Orderkey

         SET @n_Err = @@ERROR
         
         IF @n_Err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_ErrMsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83000
            SELECT @c_ErrMsg ='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Error Insert Storer Table (ispORD22)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_ErrMsg) + ' ) '
         END      	       	 
      	 
         FETCH NEXT FROM CUR_ORD INTO @c_Orderkey
      END
      CLOSE CUR_ORD
      DEALLOCATE CUR_ORD               	
   END
   
   QUIT_SP:

   IF CURSOR_STATUS('LOCAL', 'CUR_ORD') IN ( 0, 1 )
   BEGIN
      CLOSE CUR_ORD
      DEALLOCATE CUR_ORD
   END

   IF @n_Continue = 3 -- Error Occured - Process AND Return
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
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'ispORD22'
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
GRANT EXECUTE ON [dbo].[ispORD22] TO [NSQL]
GO