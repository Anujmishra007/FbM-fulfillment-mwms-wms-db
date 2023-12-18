SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: isp_RCM_ORD_REMY_ITF                               */
/* Creation Date: 06-Jul-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-23018 [CN] REMY Dynamic RCM to re-trigger to TS2.0      */
/*                                                                      */
/* Called By: Order Dymaic RCM configure at listname 'RCMConfig'        */
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 06-Jul-2023  WLChooi   1.0   DevOps Combine Script                   */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[isp_RCM_ORD_REMY_ITF]
   @c_Orderkey NVARCHAR(10)
 , @b_Success  INT           OUTPUT
 , @n_Err      INT           OUTPUT
 , @c_Errmsg   NVARCHAR(225) OUTPUT
 , @c_code     NVARCHAR(30) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue  INT
         , @n_cnt       INT
         , @n_Starttcnt INT

   DECLARE @c_SQL       NVARCHAR(4000)
         , @c_SQLFrom   NVARCHAR(4000)
         , @c_SQLArg    NVARCHAR(4000)
         , @c_Condition NVARCHAR(4000)
         , @c_Storerkey NVARCHAR(15)
         , @n_RecFound  INT
         , @c_Status    NVARCHAR(10)

   SELECT @n_Continue = 1
        , @b_Success = 1
        , @n_Starttcnt = @@TRANCOUNT
        , @c_Errmsg = ''
        , @n_Err = 0

   SELECT @c_Status = ORDERS.[Status]
        , @c_Storerkey = ORDERS.StorerKey
   FROM ORDERS (NOLOCK)
   WHERE ORDERS.Orderkey = @c_Orderkey

   SELECT TOP 1 @c_Condition = ISNULL(CODELKUP.Notes,'')
   FROM CODELKUP (NOLOCK)
   WHERE LISTNAME = 'REMY2TS' AND Storerkey = @c_Storerkey

   SET @c_SQL = N' SELECT @n_RecFound = COUNT(1)'
   SET @c_SQLFrom = N' FROM ORDERS (NOLOCK) '
                  + N' WHERE ORDERS.Orderkey = @c_Orderkey ' + @c_Condition
   SET @c_SQL = @c_SQL + @c_SQLFrom

   SET @c_SQLArg = N' @n_RecFound  INT OUTPUT,   '
                 + N' @c_Orderkey  NVARCHAR(50)  '

   EXEC sp_executesql @c_SQL, @c_SQLArg, @n_RecFound OUTPUT, @c_Orderkey

   IF @n_RecFound <= 0
   BEGIN
      SELECT @n_Continue = 3
      SELECT @c_Errmsg = CONVERT(NVARCHAR(250), @n_Err)
           , @n_Err = 38000 -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err)
                         + ': Order#: ' + @c_Orderkey + ' not meet condition (isp_RCM_ORD_REMY_ITF)' + ' ( '
                         + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      GOTO ENDPROC
   END
   ELSE
   BEGIN
      IF EXISTS (  SELECT 1
                   FROM TRANSMITLOG2 (NOLOCK)
                   WHERE Tablename = 'WSSOSTSLOG' AND Key1 = @c_Orderkey AND Key2 = @c_Status AND Key3 = @c_Storerkey)
      BEGIN
         UPDATE TRANSMITLOG2 WITH (ROWLOCK)
         SET transmitflag = '0'
         WHERE Tablename = 'WSSOSTSLOG' AND Key1 = @c_Orderkey AND Key2 = @c_Status AND Key3 = @c_Storerkey
      END
      ELSE
      BEGIN
         EXEC [dbo].[ispGenTransmitLog2] 'WSSOSTSLOG'
                                       , @c_Orderkey
                                       , @c_Status
                                       , @c_Storerkey
                                       , ''
                                       , @b_Success OUTPUT
                                       , @n_Err OUTPUT
                                       , @c_Errmsg OUTPUT

         IF @b_Success = 0
            SELECT @n_Continue = 3
                 , @n_Err = 38020
                 , @c_Errmsg = 'isp_RCM_ORD_REMY_ITF: ' + RTRIM(@c_Errmsg)
      END
   END

   ENDPROC:

   IF @n_Continue = 3 -- Error Occured - Process And Return  
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_Starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_Starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'isp_RCM_ORD_REMY_ITF'
      RAISERROR(@c_Errmsg, 16, 1) WITH SETERROR -- SQL2012  
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_Starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- End PROC  
GO
GRANT EXECUTE ON [dbo].[isp_RCM_ORD_REMY_ITF] TO [NSQL]
GO