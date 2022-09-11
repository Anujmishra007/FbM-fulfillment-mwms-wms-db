IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[dbo].[ntrWaveDetailAdd]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[ntrWaveDetailAdd]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Trigger: ntrWaveDetailAdd                                                  */
/* Creation Date:                                                             */
/* Copyright: IDS                                                             */
/* Written by:                                                                */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Input Parameters: NONE                                                     */
/*                                                                            */
/* OUTPUT Parameters: NONE                                                    */
/*                                                                            */
/* Return Status: NONE                                                        */
/*                                                                            */
/* Usage:                                                                     */
/*                                                                            */
/* Local Variables:                                                           */
/*                                                                            */
/* Called By: When records Insert                                             */
/*                                                                            */
/* PVCS Version: 1.0                                                          */
/*                                                                            */
/* Version: 5.4                                                               */
/*                                                                            */
/* Data Modifications:                                                        */
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author     Ver   Purposes                                     */
/* 05-Feb-2013  Shong      1.1   Do not Allow Blank OrderKey                  */
/* 30-AUG-2018  SPChin     1.2   INC0349006 - Remove WaveKey From PickDetail  */
/*                                            When Delete                     */
/* 24-MAY-2022  LZG        1.3   JSM-69426 - Calculate Wave status when       */
/*                               adding order into WaveDetail (ZG01)          */
/******************************************************************************/
CREATE TRIGGER [dbo].[ntrWaveDetailAdd]
ON [dbo].[WAVEDETAIL]
FOR  INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success     INT -- Populated by calls to stored procedures - was the proc successful?
          ,@n_err         INT -- Error number returned by stored procedure or this trigger
          ,@n_err2        INT -- For Additional Error Detection
          ,@c_errmsg      NVARCHAR(250) -- Error message returned by stored procedure or this trigger
          ,@n_continue    INT
          ,@n_starttcnt   INT -- Holds the current transaction count
          ,@c_preprocess  NVARCHAR(250) -- preprocess
          ,@c_pstprocess  NVARCHAR(250) -- post process
          ,@n_cnt         INT
          ,@c_wavekey     NVARCHAR(10)
          ,@c_OrderKey    NVARCHAR(10) --INC0349006

   SET @c_wavekey  = '' --INC0349006
   SET @c_OrderKey = '' --INC0349006

   SELECT @n_continue = 1
         ,@n_starttcnt = @@TRANCOUNT
   /* #INCLUDE <TROHA1.SQL> */
   -- Added by Jeff - HK Customization - FBR 071 - Wave Planning
   -- reject any population of orders with status = 'shipped'
   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
       IF EXISTS (
              SELECT 1
              FROM   INSERTED
                    ,ORDERS(NOLOCK)
              WHERE  ORDERS.Orderkey = INSERTED.Orderkey
              AND    ORDERS.Status IN ('8' ,'9')
          )
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                 ,@n_err = 62301 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5) ,@n_err) +
                  ': Shipped Orders cannot be populated into WaveDetail. (ntrWaveDetailAdd)'
                  + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') +
                  ' ) '
       END
   END
   -- Added by SHONG - Do not allow Blank OrderKey
   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
      IF EXISTS (
             SELECT 1
             FROM   INSERTED
             WHERE  OrderKey = ''
             OR     OrderKey IS NULL
         )
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
               ,@n_err = 62301 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5) ,@n_err) +
                 ': Insert Failed, OrderKey BLANK. (ntrWaveDetailAdd)' + ' ( '
                 + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
      END
   END
   -- reject if user manually inserts orders that has already been waved
   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
       IF EXISTS (
              SELECT 1
              FROM   INSERTED
                    ,ORDERS(NOLOCK)
              WHERE  ORDERS.Orderkey = INSERTED.Orderkey
              AND    (ORDERS.Userdefine09 IS NOT NULL)
              AND    (ORDERS.Userdefine09 <> '')
          )
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                 ,@n_err = 62301 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5) ,@n_err) +
                  ': Orders have been waved.(ntrWaveDetailAdd)' + ' ( ' +
                  ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
       END
   END
   -- reject manual type orders ('M'): SOS 4565
   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
       IF EXISTS (
              SELECT 1
              FROM   INSERTED
                    ,ORDERS(NOLOCK)
              WHERE  ORDERS.Orderkey = INSERTED.Orderkey
              AND    ORDERS.type = 'M'
          )
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                 ,@n_err = 62301 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5) ,@n_err) +
                  ': Manual Orders cannot be waved.(ntrWaveDetailAdd)' + ' ( ' +
                  ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
       END
   END

   IF @n_continue = 1
   OR @n_continue = 2
   BEGIN
       UPDATE ORDERS
       SET    ORDERS.USERDEFINE09 = INSERTED.WaveKey
             ,TRAFFICCOP = NULL
       FROM   ORDERS
             ,INSERTED
       WHERE  ORDERS.Orderkey = INSERTED.Orderkey
       AND    (ORDERS.Status <> '8' OR ORDERS.Status <> '9')

       SELECT @n_err = @@ERROR
             ,@n_cnt = @@ROWCOUNT

       IF @n_err <> 0
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                 ,@n_err = 62301 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5) ,@n_err) +
                  ': Insert Failed On WaveDetail. (ntrWaveDetailAdd)' + ' ( ' +
                  ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
       END
   END

   --INC0349006 Start
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE @c_Wv_Cur_Status NVARCHAR(10) = ''
      DECLARE CUR_Wave_Orders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT I.WaveKey, I.OrderKey
      FROM INSERTED I
      JOIN ORDERS O WITH (NOLOCK) ON I.OrderKey = O.OrderKey

      OPEN CUR_Wave_Orders
      FETCH NEXT FROM CUR_Wave_Orders INTO @c_wavekey, @c_OrderKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF EXISTS (SELECT 1 FROM PickDetail WITH (NOLOCK)
                    WHERE OrderKey = @c_OrderKey)
         BEGIN
            UPDATE PICKDETAIL WITH (ROWLOCK)
            SET WAVEKEY    = @c_wavekey
              , TRAFFICCOP = NULL
            WHERE Orderkey = @c_OrderKey

            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                                 , @n_err = 62309 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5) ,@n_err) +
                                  ': Insert Failed On WaveDetail. (ntrWaveDetailAdd)' + ' ( ' +
                                  ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
            END
         END
         
         -- ZG01 (Start)
         EXEC [dbo].[isp_GetWaveStatus]
             @c_WaveKey    = @c_WaveKey
          ,  @b_UpdateWave = 1                         --1 => yes, 0 => No
          ,  @c_Status     = @c_Wv_Cur_Status OUTPUT
          ,  @b_Success    = @b_Success       OUTPUT
          ,  @n_Err        = @n_Err           OUTPUT
          ,  @c_ErrMsg     = @c_ErrMsg        OUTPUT
         
         IF @b_Success = 0
         BEGIN
            SET @n_continue = 3
         END
         -- ZG01 (End)
         
         FETCH NEXT FROM CUR_Wave_Orders INTO @c_wavekey, @c_OrderKey
      END
      CLOSE CUR_Wave_Orders
      DEALLOCATE CUR_Wave_Orders
   END
   --INC0349006 End

   IF @n_continue = 3 -- Error Occured - Process And Return
   BEGIN
       IF @@TRANCOUNT = 1
       AND @@TRANCOUNT >= @n_starttcnt
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
       EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrWaveDetailAdd'
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
       RETURN
   END
   ELSE
   BEGIN
       WHILE @@TRANCOUNT > @n_starttcnt
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