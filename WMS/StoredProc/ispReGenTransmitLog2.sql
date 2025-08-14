SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store Procedure: ispReGenTransmitLog2                                */
/* Creation Date: 14-Jul-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-5700 - Regenerate Transmitlog2                          */
/*                                                                      */
/* Input Parameters:      @c_TableName                                  */
/*                        @c_Key1                                       */
/*                        @c_Key2                                       */
/*                        @c_Key3                                       */
/*                        @c_TransmitBatch                              */
/*                        @b_Success                                    */
/*                        @n_Err                                        */
/*                        @c_Errmsg                                     */
/*                                                                      */
/* Output Parameters:  None                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:  Interfaces.                                                  */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By:  Triggers                                                 */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 14-Jul-2025  WLChooi   1.0   Initial Version                         */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[ispReGenTransmitLog2]
               @c_TableName      NVARCHAR(30)
             , @c_Key1           NVARCHAR(10)
             , @c_Key2           NVARCHAR(5)
             , @c_Key3           NVARCHAR(20)
             , @c_TransmitBatch  NVARCHAR(30)
             , @b_Success        INT        OUTPUT
             , @n_Err            INT        OUTPUT
             , @c_Errmsg         NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue INT        
         , @n_starttcnt INT        -- Holds the current transaction count

   DECLARE @c_Trmlogkey NVARCHAR(10)

   SELECT @n_starttcnt= @@TRANCOUNT , @n_continue = 1, @b_Success = 0, @n_Err = 0, @c_Errmsg = ''

   IF TRIM(@c_Key1) IS NULL OR TRIM(@c_Key1) = ''
   BEGIN
      RETURN
   END

   SELECT @c_Key2 = ISNULL(TRIM(@c_Key2), '')
   SELECT @c_Key3 = ISNULL(TRIM(@c_Key3), '')
   SELECT @c_TransmitBatch = ISNULL(TRIM(@c_TransmitBatch), '')

   IF (@n_continue = 1 OR @n_continue=2)
   BEGIN
      SELECT @b_Success = 1
      IF NOT EXISTS ( SELECT 1 FROM TransmitLog2 (NOLOCK) 
                      WHERE TableName = @c_TableName
                      AND Key1 = @c_Key1 
                      AND Key2 = @c_Key2 
                      AND Key3 = @c_Key3
                      AND (TransmitFlag = '0' OR TransmitFlag = '1'))
      BEGIN
         SELECT @b_Success = 1

         EXECUTE nspg_getkey
         'TransmitlogKey2'
         , 10
         , @c_Trmlogkey OUTPUT
         , @b_Success   OUTPUT
         , @n_Err       OUTPUT
         , @c_Errmsg    OUTPUT

         IF NOT @b_Success = 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_Errmsg = CONVERT(CHAR(250),@n_Err), @n_Err = 63810   
            SELECT @c_Errmsg ='NSQL'+CONVERT(char(5),@n_Err)+': Unable to Obtain transmitlogkey. (ispReGenTransmitLog2)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_Errmsg) + ' ) '
         END
         ELSE
         BEGIN
            INSERT INTO TransmitLog2 (transmitlogkey, tablename, key1, key2, key3, transmitflag, TransmitBatch)
            VALUES (@c_Trmlogkey, @c_TableName, @c_Key1, @c_Key2, @c_Key3, '0', @c_TransmitBatch)
         END
      END

      IF @n_continue=3  -- Error Occured - Process And Return
      BEGIN
         SELECT @b_Success = 0
         IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
         BEGIN
            ROLLBACK TRAN
         END
         ELSE
         BEGIN
            WHILE @@TRANCOUNT > @n_starttcnt
            BEGIN
               COMMIT TRAN
            END
         END
         execute nsp_logerror @n_Err, @c_Errmsg, 'ispReGenTransmitLog2'
         RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
      ELSE
      BEGIN
         SELECT @b_Success = 1
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
         RETURN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[ispReGenTransmitLog2] TO [NSQL]
GO