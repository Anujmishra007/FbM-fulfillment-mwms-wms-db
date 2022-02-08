CREATE TABLE [dbo].[WAVEDETAIL]
(
[WaveDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_OrderKey] DEFAULT (' '),
[ProcessFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_ProcessFlag] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_WAVEDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_WAVEDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_WAVEDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
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

/******************************************************************************/
/* Trigger: ntrWaveDetailDelete                                               */
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
/* Called By: When records deleted                                            */
/*                                                                            */
/* PVCS Version: 1.7                                                          */
/*                                                                            */
/* Version: 5.4                                                               */
/*                                                                            */
/* Data Modifications:                                                        */
/*                                                                            */
/* Updates:                                                                   */
/* Date         Author     Ver   Purposes                                     */
/*  9-Jun-2011  KHLim01    1.1   Insert Delete log                            */
/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                      */
/* 11-Jan-2012  ChewKP     1.3   Delete ConsoOrderKey in OrderDetail when     */
/*                               Order deleted in WaveDetail (ChewKP01)       */
/* 07-May-2012  Ung        1.4   Delete ConsoOrderLineNo (ung01)              */
/* 05-Feb-2013  Shong      1.4   Do not delete Pickheader And TaskDetail with */  
/*                               Blank OrderKey                               */
/* 15-MAY-2013  YTWan     1.23  SOS#276826-VFDC SO Cancel.(Wan01)             */  
/* 06-JUN-2014  SHONG      1.5   Remove Order From Load When Delete           */  
/* 30-AUG-2018  SPChin     1.6   INC0349006 - Remove WaveKey From PickDetail  */
/*                                            When Delete                     */
/******************************************************************************/

CREATE TRIGGER [dbo].[ntrWaveDetailDelete]
ON  [dbo].[WAVEDETAIL]
FOR DELETE
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF
	
DECLARE
@b_Success            int                 -- Populated by calls to stored procedures - was the proc successful?
,         @n_err                int       -- Error number returned by stored procedure or this trigger
,         @n_err2               int       -- For Additional Error Detection
,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
,         @n_continue int                 
,         @n_starttcnt int                -- Holds the current transaction count
,         @c_preprocess NVARCHAR(250)         -- preprocess
,         @c_pstprocess NVARCHAR(250)         -- post process
,         @n_cnt int                  
,			 @c_wavekey NVARCHAR(10) 
,         @c_authority        NVARCHAR(1)  -- KHLim02
,         @c_SOStatus         NVARCHAR(10) --(Wan01)
,         @c_Status           NVARCHAR(10) --(Wan01)
SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
     /* #INCLUDE <TROHA1.SQL> */     

SET @c_SOStatus = ''  --(Wan01)
SET @c_Status   = ''  --(Wan01)

if (select count(*) from DELETED) =
   (select count(*) from DELETED where DELETED.archivecop = '9')
BEGIN
   SELECT @n_continue = 4
END

IF @n_continue = 1 OR @n_continue = 2
BEGIN
 if (select count(*) from DELETED) =
    (select count(*) from DELETED where DELETED.trafficcop = '9')
 BEGIN
    SELECT @n_continue = 4
 END
END

-- Cannot delete wavedetail records once pickslip has been printed.

IF @n_continue = 1 OR @n_continue = 2
BEGIN
	IF EXISTS (SELECT 1 FROM PICKHEADER (NOLOCK), DELETED
	WHERE DELETED.Orderkey = PICKHEADER.Orderkey 
	AND DELETED.Wavekey = PICKHEADER.Wavekey)
   --(Wan01) - START
   AND  NOT EXISTS ( SELECT 1 
                     FROM DELETED 
                     JOIN ORDERS WITH (NOLOCK) ON (DELETED.Orderkey = ORDERS.Orderkey)
                     JOIN STORERCONFIG WITH (NOLOCK) ON (STORERCONFIG.Storerkey = ORDERS.Storerkey)
                                                      AND(STORERCONFIG.Facility = ORDERS.Facility OR STORERCONFIG.facility = '')
                     WHERE STORERCONFIG.Configkey = 'DelSOCANCFromWave'
                     AND   STORERCONFIG.SValue = '1'
                     AND   ORDERS.SOStatus = 'CANC'
                     AND   ORDERS.Status = '0')
   --(Wan01) - END
	BEGIN
		SELECT @n_continue = 3  
  		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121003   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
  		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Pickslip has been printed. Cannot Delete (ntrWaveDetaildetail)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "  
	END
END  
-- Start : SOS39951
IF @n_continue = 1 OR @n_continue = 2
BEGIN
	IF EXISTS (SELECT 1 FROM WaveOrderLn (NOLOCK), DELETED
	WHERE DELETED.Wavekey  = WaveOrderLn.Wavekey
	AND   DELETED.Orderkey = WaveOrderLn.Orderkey)
	BEGIN
		DELETE WaveOrderLn
		FROM   WaveOrderLn, DELETED
		WHERE  DELETED.Wavekey  = WaveOrderLn.Wavekey
		AND    DELETED.Orderkey = WaveOrderLn.Orderkey 
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
		  SELECT @n_continue = 3
		  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63200   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On WaveDetailDelete Failed. (ntrWaveDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "
		END
	END
END  
-- End : SOS39951
/* 2001/10/12 CS IDSHK071 Prevent wavedetail from being modified if the orders have been pciked - start */   
IF @n_continue = 1 OR @n_continue = 2  
BEGIN  
 IF EXISTS (SELECT 1 FROM PICKDETAIL (NOLOCK), DELETED  
  WHERE PICKDETAIL.OrderKey = DELETED.OrderKey   
  AND  PICKDETAIL.Status >= '3')  
 BEGIN  
  SELECT @n_continue = 3  
  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121003   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Picking in progress for the orders. Cannot Delete (ntrWaveDetaildetail)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "  
 END  
END  
/* 2001/10/12 CS IDSHK071 Prevent wavedetail from being modified if the orders have been pciked - end */   

--(Wan01) - START
IF @n_continue = 1 OR @n_continue = 2  
BEGIN  
   IF EXISTS ( SELECT 1 
               FROM DELETED 
               JOIN ORDERS WITH (NOLOCK) ON (DELETED.Orderkey = ORDERS.Orderkey)
               JOIN STORERCONFIG WITH (NOLOCK) ON (STORERCONFIG.Storerkey = ORDERS.Storerkey)
                                                AND(STORERCONFIG.Facility = ORDERS.Facility OR STORERCONFIG.facility = '')
               WHERE STORERCONFIG.Configkey = 'ValidateSOStatus_SP'
               AND   STORERCONFIG.SValue = 'ispVSOST01' )
   BEGIN
      
      SELECT @c_SOStatus = ISNULL(RTRIM(SOStatus),'')
            ,@c_Status   = ISNULL(RTRIM(Status),'')
      FROM DELETED 
      JOIN ORDERS WITH (NOLOCK) ON (DELETED.Orderkey = ORDERS.Orderkey)

      IF @c_SOStatus = 'CANC'
      BEGIN
         IF @c_Status <> '0' AND @c_Status <> 'CANC'
         BEGIN
            SET @n_continue = 3
            SET @n_err      = 63201
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Order is Partial/Full allocated. Cannot Delete to auto cancel order. (ntrWaveDetaildetail)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
         END
   
         IF @n_continue = 1 OR @n_continue = 2  
         BEGIN 
            IF EXISTS ( SELECT 1 
                        FROM DELETED 
                        JOIN PREALLOCATEPICKDETAIL WITH (NOLOCK) ON (DELETED.Orderkey = PREALLOCATEPICKDETAIL.Orderkey) )
            BEGIN
               SET @n_continue = 3
               SET @n_err      = 63202
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Order Preallocated. Cannot Delete to auto cancel order. (ntrWaveDetaildetail)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
            END
         END

         IF @n_continue = 1 OR @n_continue = 2  
         BEGIN 
            UPDATE ORDERS WITH (ROWLOCK)
            SET Status     = 'CANC'
               ,Trafficcop = NULL
               ,EditDate   = GETDATE()
               ,EditWho    = SUSER_NAME()
            FROM DELETED 
            JOIN ORDERS ON (DELETED.Orderkey = ORDERS.Orderkey)

            SET @n_err = @@ERROR

            IF @n_err <> 0
            BEGIN
               SET @n_continue = 3
               SET @n_err      = 63203
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On ORDERS. (ntrWaveDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
            END
         END
      END
   END
END 
--(Wan01) - END

-- Added by Jeff - HK Customization - FBR 071 - Wave Planning
IF @n_continue = 1 OR @n_continue = 2
BEGIN
   UPDATE ORDERS
	SET 	ORDERS.USERDEFINE09 = NULL,
	      TRAFFICCOP = NULL
	FROM ORDERS, DELETED 
	WHERE ORDERS.Orderkey = DELETED.Orderkey
	AND ORDERS.USERDEFINE09 = DELETED.Wavekey

	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
	IF @n_err <> 0
	BEGIN
		SELECT @n_continue = 3
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": DELETE Failed On WaveDetail. (ntrWaveDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "
	END
END

-- (ChewKP01)
IF @n_continue = 1 OR @n_continue = 2
BEGIN
   IF EXISTS(SELECT 1 FROM DELETED   
             JOIN ORDERDETAIL WITH (NOLOCK) ON ORDERDETAIL.Orderkey = DELETED.Orderkey   
           WHERE ORDERDETAIL.ConsoOrderKey <> ''  
               AND ORDERDETAIL.ConsoOrderKey IS NOT NULL)  
   BEGIN  
      
      UPDATE ORDERDETAIL WITH (ROWLOCK)
   	SET 	ORDERDETAIL.ConsoOrderKey = '', 
   	      ORDERDETAIL.ConsoOrderLineNo = '', --(ung01)
            ORDERDETAIL.ExternConsoOrderKey = '', 
   	      ORDERDETAIL.TRAFFICCOP = NULL
   	FROM ORDERDETAIL, DELETED 
   	WHERE ORDERDETAIL.Orderkey = DELETED.Orderkey
        AND ORDERDETAIL.ConsoOrderKey <> '' -- Added by Shong on 05-Feb-2013  
        AND ORDERDETAIL.ConsoOrderKey IS NOT NULL   
   	
   	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   	IF @n_err <> 0
   	BEGIN
   		SELECT @n_continue = 3
   		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62302   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
   		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": DELETE Failed On WaveDetail. (ntrWaveDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "
   	END
   END
END


-- added by jeff -- delete the pickslip and taskdetail as well
IF @n_continue = 1 OR @n_continue = 2  
BEGIN  
	DELETE PICKHEADER  
	FROM DELETED  
	WHERE PICKHEADER.OrderKey = DELETED.OrderKey  
   AND (PICKHEADER.OrderKey <> '' AND PICKHEADER.OrderKey IS NOT NULL) -- Added by Shong on 05-Feb-2013    
   
 	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 	IF @n_err <> 0  
 	BEGIN  
  		SELECT @n_continue = 3  
  		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121004   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
  		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": DELETE Failed On PickHeader. (ntrWaveDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "  
 	END  
END  
  
IF @n_continue = 1 OR @n_continue = 2  
BEGIN  
 	DELETE TaskDetail  
 	FROM  DELETED  
 	WHERE TaskDetail.OrderKey = DELETED.OrderKey  
   AND   (TaskDetail.OrderKey IS NOT NULL AND TaskDetail.OrderKey <> '') -- Added by Shong on 05-Feb-2013  
     
 	SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
 	IF @n_err <> 0  

 	BEGIN  
  		SELECT @n_continue = 3  
  		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121005   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
  		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": DELETE Failed On TaskDetail. (ntrWaveDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " ) "  
 	END  
END  
-- end


  
-- Added by Shong on 06-Jun-2014   
-- Remove Order From Load When Delete   
IF @n_continue = 1 OR @n_continue = 2    
BEGIN  
   DECLARE @c_Facility           NVARCHAR(10),  
           @c_StorerKey          NVARCHAR(15),  
           @c_OrderKey           NVARCHAR(10),  
           @c_WaveDetDelRemvLoad CHAR(1)    
     
   DECLARE CUR_Wave_Orders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT O.Facility, O.StorerKey, O.OrderKey    
   FROM DELETED D   
   JOIN ORDERS O WITH (NOLOCK) ON D.OrderKey = O.OrderKey    
  
   OPEN CUR_Wave_Orders   
     
   FETCH NEXT FROM CUR_Wave_Orders INTO @c_Facility, @c_StorerKey, @c_OrderKey  
     
   WHILE @@FETCH_STATUS <> -1  
   BEGIN  
      SET @b_success = 0  
      SET @c_WaveDetDelRemvLoad = '0'  
              
      Execute nspGetRight   
      @c_facility,              -- Facility   
      @c_StorerKey,             -- Storer        
      '',                       -- Sku        
      'WaveDetDelRemvLoad',     -- ConfigKey        
      @b_success                output,        
      @c_WaveDetDelRemvLoad     output,        
      @n_err                    output,        
      @c_errmsg                 output        
      If @b_success <> 1        
      BEGIN        
         Select @n_continue = 3, @n_err = 62011, @c_errmsg = 'nspItrnAddMoveCheck:' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'')     
      END  
      IF ISNULL(RTRIM(@c_WaveDetDelRemvLoad), '') = '1'  
      BEGIN  
         DELETE FROM LoadPlanDetail   
         WHERE OrderKey = @c_OrderKey   
        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT    
        IF @n_err <> 0    
        BEGIN    
          SELECT @n_continue = 3    
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121006       
          SELECT @c_errmsg="NSQL"+CONVERT(varchar(6),@n_err)+": DELETE Failed On LoadPlanDetail. (ntrWaveDetailDelete)" +   
                             " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'')  + " ) "    
        END             
      END  
      
      --INC0349006 Start
      IF EXISTS (SELECT 1 FROM PickDetail WITH (NOLOCK)
                 WHERE OrderKey = @c_OrderKey)
      BEGIN
         UPDATE PICKDETAIL WITH (ROWLOCK)
         SET WAVEKEY    = ''
           , TRAFFICCOP = NULL
         WHERE Orderkey = @c_OrderKey

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63210
            SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": DELETE Failed On WaveDetail. (ntrWaveDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + " )"
         END
      END
      --INC0349006 End
      
      FETCH NEXT FROM CUR_Wave_Orders INTO @c_Facility, @c_StorerKey, @c_OrderKey  
   END               
   CLOSE CUR_Wave_Orders  
   DEALLOCATE CUR_Wave_Orders  
END          

   -- Start (KHLim01)
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrWaveDetailDelete' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'')
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.WAVEDETAIL_DELLOG ( WaveDetailKey )
         SELECT WaveDetailKey  FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ORDERS Failed. (ntrWAVEDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
         END
      END
   END
   -- End (KHLim01)

IF @n_continue=3  -- Error Occured - Process And Return
BEGIN
   IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
   execute nsp_logerror @n_err, @c_errmsg, "ntrWaveDetailDelete"
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

/************************************************************************/
/* Trigger: ntrWaveDetailUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  WAVE Update Transaction                                    */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 25 May 2012  TLTING01  DM integrity - add update editdate B4         */
/*                        TrafficCop                                    */ 
/* 28-Oct-2013  TLTING    Review Editdate column update                 */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrWaveDetailUpdate]  
 ON  [dbo].[WAVEDETAIL]  
 FOR UPDATE  
 AS  
 BEGIN 
 IF @@ROWCOUNT = 0
 BEGIN
 RETURN
 END     
 SET NOCOUNT ON
 SET ANSI_NULLS OFF
 SET QUOTED_IDENTIFIER OFF
 SET CONCAT_NULL_YIELDS_NULL OFF
 	
 DECLARE  
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger  
 ,         @n_err2 int              -- For Additional Error Detection  
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
 ,         @n_continue int                   
 ,         @n_starttcnt int                -- Holds the current transaction count  
 ,         @c_preprocess NVARCHAR(250)         -- preprocess  
 ,         @c_pstprocess NVARCHAR(250)         -- post process  
 ,         @n_cnt int                    
 ,  @c_wavekey NVARCHAR(10)   
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
      /* #INCLUDE <TROHA1.SQL> */ 
      
 IF UPDATE(ArchiveCop)
 BEGIN
 SELECT @n_continue = 4 
 END      
 --tlting01
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN 
	 UPDATE WAVEDetail
	 SET EditDate = GETDATE(),
	     EditWho  = SUSER_SNAME(),
	     TrafficCop = NULL
	 FROM WAVEDetail (NOLOCK), INSERTED (NOLOCK)
    WHERE WAVEDetail.WaveDetailKey = INSERTED.WaveDetailKey
	 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 IF @n_err <> 0
	 BEGIN
  		SELECT @n_continue = 3
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table WAVE. (ntrWaveHeaderUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	 END
 END            

 IF UPDATE(TrafficCop)
 BEGIN
 SELECT @n_continue = 4 
 END
 /* 2001/10/12 CS IDSHK071 Prevent wavedetail from being modified if the orders have been pciked - start */   
 IF @n_continue = 1 OR @n_continue = 2  
 BEGIN  
    IF EXISTS (SELECT 1 FROM PICKDETAIL, DELETED  WHERE PICKDETAIL.OrderKey = DELETED.OrderKey   
                AND  PICKDETAIL.Status >= '3')  
    BEGIN  
      SELECT @n_continue = 3  
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121003   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Picking in progress for the orders. (ntrWaveDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
    END  
 END
 -- reject manual type orders ('M'): SOS 4565
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
 	IF EXISTS (SELECT 1 FROM INSERTED, ORDERS (NOLOCK)
 	WHERE ORDERS.Orderkey = INSERTED.Orderkey
 	AND ORDERS.type = 'M' ) 
 	BEGIN
 		SELECT @n_continue = 3
 		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Manual Orders cannot be waved.(ntrWaveDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "	
 	END
 END
 IF @n_continue=3  -- Error Occured - Process And Return  
 BEGIN  
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt  
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrWaveDetailUpdate"  
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
ALTER TABLE [dbo].[WAVEDETAIL] ADD CONSTRAINT [PKWAVEDETAIL] PRIMARY KEY CLUSTERED ([WaveDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WAVEDETAIL_OrderKey] ON [dbo].[WAVEDETAIL] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WAVEDETAIL_WaveKey] ON [dbo].[WAVEDETAIL] ([WaveKey], [WaveDetailKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[WAVEDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WAVEDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave Detail.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'WaveDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'WAVEDETAIL', 'COLUMN', N'WaveKey'
GO
