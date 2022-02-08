CREATE TABLE [dbo].[PreAllocatePickDetail]
(
[PreAllocatePickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PreAllocatePickDetailKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_OrderKey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_OrderLineNumber] DEFAULT (' '),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Storerkey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Sku] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Lot] DEFAULT (' '),
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_UOM] DEFAULT (' '),
[UOMQty] [int] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_UOMQty] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Qty] DEFAULT ((0)),
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_Packkey] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_WaveKey] DEFAULT (' '),
[PreAllocateStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PreAllocateStrategyKey] DEFAULT (' '),
[PreAllocatePickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PreAllocatePickCode] DEFAULT (' '),
[DoCartonize] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_DoCartonize] DEFAULT ('N'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_PickMethod] DEFAULT (' '),
[RunKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_RunKey] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PreAllocatePickDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Jul-2017  TLTING   1.1  SET Option                       */

CREATE TRIGGER [dbo].[ntrPreAllocatePickDetailAdd]
 ON  [dbo].[PreAllocatePickDetail]
 FOR INSERT
 AS
 BEGIN
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
 ,         @n_PREAllocatePickDetailSysId int       
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRPAPDA1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 UPDATE OrderDetail SET OrderDetail.QtyPreAllocated =
 OrderDetail.QtyPreAllocated + (SELECT SUM(inserted.Qty )
 FROM inserted WHERE inserted.orderkey =OrderDetail.OrderKey
 and inserted.OrderLineNumber = OrderDetail.OrderLineNumber ),
 OrderDetail.TrafficCop = NULL
 FROM OrderDetail ,inserted
 WHERE inserted.OrderKey =OrderDetail.OrderKey
 and inserted.OrderLineNumber = OrderDetail.OrderLineNumber
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78001   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PREAllocatePickDetail Failed. (ntrPreAllocatePickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
 IF @n_continue=1 or @n_continue=2
 BEGIN
 UPDATE LOT SET LOT.QtyPreAllocated =
 LOT.QtyPreAllocated + (SELECT SUM(inserted.Qty )
 FROM inserted WHERE inserted.lot =LOT.lot),
 LOT.TrafficCop = NULL
 FROM LOT,inserted
 WHERE inserted.lot = LOT.lot
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78002   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On PREAllocatePickDetail Failed. (ntrPreAllocatePickDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRPAPDA2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrPreAllocatePickDetailAdd"
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
/* 28-Jul-2017  TLTING   1.1  SET Option                       */

CREATE TRIGGER [dbo].[ntrPreAllocatePickDetailDelete]
ON  [dbo].[PreAllocatePickDetail]
FOR DELETE
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
   ,         @n_err2               int       -- For Additional Error Detection
   ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue int
   ,         @n_starttcnt          int       -- Holds the current transaction count
   ,         @c_preprocess         NVARCHAR(250) -- preprocess
   ,         @c_pstprocess         NVARCHAR(250) -- post process
   ,         @n_cnt                int
   ,         @n_PreAllocatePickDetailSysId    int
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF (select count(*) from DELETED) =  (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   -- Added By SHONG - skip when nothing to update due to Qty = 0 
   IF (SELECT SUM(Qty) FROM DELETED) = 0 
   BEGIN
      SELECT @n_continue = 4
   END
   
   /* #INCLUDE <TRPAPDD1.SQL> */
   IF @n_continue=1 or @n_continue=2
   BEGIN
      UPDATE LOT SET LOT.QtyPreAllocated =  LOT.QtyPreAllocated - (SELECT SUM(DELETED.Qty )
      FROM DELETED WHERE DELETED.lot = LOT.lot)
      FROM LOT, DELETED
      WHERE DELETED.lot =LOT.lot
      AND   DELETED.Qty > 0 
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78201   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete trigger On PreAllocatePickDetail Failed. (ntrPreAllocatePickDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
      IF @n_continue=1 or @n_continue=2
      BEGIN
         UPDATE OrderDetail SET OrderDetail.QtyPreAllocated =  OrderDetail.QtyPreAllocated - 
               (SELECT SUM(DELETED.Qty ) FROM DELETED  WHERE DELETED.OrderKey =OrderDetail.OrderKey
                AND DELETED.OrderLineNumber = OrderDetail.OrderLineNumber)
         FROM OrderDetail , DELETED
         WHERE DELETED.OrderKey = OrderDetail.OrderKey
         AND   DELETED.OrderLineNumber = OrderDetail.OrderLineNumber
         AND   DELETED.Qty > 0 
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78202   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete trigger On PreAllocatePickDetail Failed. (ntrPreAllocatePickDetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
   /* #INCLUDE <TRPAPDD2.SQL> */
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
      execute nsp_logerror @n_err, @c_errmsg, "ntrPreAllocatePickDetailDelete"
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
/***************************************************************************/
/* Trigger: ntrPreAllocatePickDetailUpdate                                 */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Input Parameters: NONE                                                  */
/*                                                                         */
/* Output Parameters: NONE                                                 */
/*                                                                         */
/* Return Status: NONE                                                     */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Local Variables:                                                        */
/*                                                                         */
/* Called By: When records updated                                         */
/*                                                                         */
/* PVCS Version: 1.3                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 17-Mar-2009  TLTING        Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING        Review Editdate column update                */
/* 24-Jul-2015  LEONG         Revise Update Lot.QtyPreAllocated (Copy logic*/
/*                            from ntrPickDetaipUpdate. (Leong01)          */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrPreAllocatePickDetailUpdate]
ON  [dbo].[PreAllocatePickDetail]
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
   
   DECLARE @b_debug INT
   SELECT @b_debug = 0

   DECLARE
        @b_Success            INT       -- Populated by calls to stored procedures - was the proc successful?
      , @n_err                INT       -- Error number returned by stored procedure OR this trigger
      , @n_err2               INT       -- For Additional Error Detection
      , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
      , @n_continue           INT
      , @n_starttcnt          INT       -- Holds the current transaction count
      , @c_preprocess         NVARCHAR(250) -- preprocess
      , @c_pstprocess         NVARCHAR(250) -- post process
      , @n_cnt                INT
      , @n_PreAllocatePickDetailSysId INT

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @b_debug = 1
   BEGIN
      SELECT "Reduce PreAllocated QTY in All tables"
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Leong01 (Start)
      CREATE TABLE #tLOT  (
         LOT             NVARCHAR(10) NOT NULL,
         QtyPreAllocated INT
         PRIMARY KEY CLUSTERED (LOT)
         )
   
      INSERT INTO #tLOT ( LOT, QtyPreAllocated )
      SELECT LOT,
             SUM (Qty) AS QtyPreAllocated
      FROM INSERTED
      GROUP BY LOT
   
      UPDATE tLOT
         SET QtyPreAllocated = tLOT.QtyPreAllocated + DEL_LOT.QtyPreAllocated
      FROM  #tLOT tLOT
      JOIN (SELECT LOT,
             SUM (Qty * -1) AS QtyPreAllocated
            FROM DELETED
            GROUP BY LOT) AS DEL_LOT ON DEL_LOT.LOT = tLOT.LOT
   
      INSERT INTO #tLOT  ( LOT, QtyPreAllocated )
      SELECT DELETED.LOT,
             SUM (Qty * -1) AS QtyPreAllocated
      FROM DELETED
      LEFT OUTER JOIN #tLOT LOT ON LOT.LOT = DELETED.LOT
      WHERE LOT.LOT IS NULL
      GROUP BY DELETED.LOT
   
      UPDATE LOT WITH (ROWLOCK)
      SET  LOT.QtyPreAllocated = (LOT.QtyPreAllocated + tL.QtyPreAllocated),
           LOT.EditDate = GETDATE(),   --tlting
           LOT.EditWho = SUSER_SNAME()
      FROM LOT
      JOIN #tLOT tL ON tL.LOT = LOT.LOT
   
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
        SELECT @n_continue = 3
        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78101
        SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update trigger On LOT Failed. (ntrPreAllocatePickDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '
      END
   
      -- UPDATE LOT with (ROWLOCK)
      -- SET  LOT.QtyPreAllocated = LOT.QtyPreAllocated - (SELECT SUM(DELETED.Qty )
      --                                                   FROM DELETED WHERE DELETED.lot = LOT.lot)
      --                                                + (SELECT SUM(INSERTED.Qty )
      --                                                   FROM INSERTED WHERE INSERTED.lot = LOT.lot),
      --      EditDate = GETDATE(),   --tlting
      --      EditWho = SUSER_SNAME()
      -- FROM LOT join DELETED on lot.lot = DELETED.lot
      --          join INSERTED on lot.lot = INSERTED.lot
      -- SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      -- IF @n_err <> 0
      -- BEGIN
      --    SELECT @n_continue = 3
      --    SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      --    SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update trigger On PreAllocatePickDetail Failed. (ntrPreAllocatePickDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      -- END
      -- Leong01 (End)
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         UPDATE ORDERDETAIL with (ROWLOCK)
            SET ORDERDETAIL.QtyPreAllocated = ORDERDETAIL.QtyPreAllocated - ( SELECT SUM(DELETED.Qty )
                                                                              FROM DELETED
                                                                              WHERE DELETED.OrderKey =ORDERDETAIL.OrderKey
                                                                              AND DELETED.OrderLineNumber = ORDERDETAIL.OrderLineNumber )
                                            + ( SELECT SUM(INSERTED.Qty )
                                                FROM INSERTED
                                                WHERE INSERTED.OrderKey =ORDERDETAIL.OrderKey
                                                AND INSERTED.OrderLineNumber = ORDERDETAIL.OrderLineNumber ),
                ORDERDETAIL.Trafficcop = NULL,
                ORDERDETAIL.EditDate   = GETDATE(),   --tlting
                ORDERDETAIL.EditWho    = SUSER_SNAME()
         FROM ORDERDETAIL
         JOIN DELETED ON DELETED.OrderKey = ORDERDETAIL.OrderKey
              AND DELETED.OrderLineNumber = ORDERDETAIL.OrderLineNumber
         JOIN INSERTED ON INSERTED.OrderKey = ORDERDETAIL.OrderKey
          AND INSERTED.OrderLineNumber = ORDERDETAIL.OrderLineNumber
   
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 78102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update trigger On PreAllocatePickDetail Failed. (ntrPreAllocatePickDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
 
   IF @b_debug = 1
   BEGIN
      SELECT "If OK To Continue, Update The EditDate and EditWho On The Order Headers"
   END
 
   IF ( @n_continue = 1 OR @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE PreAllocatePickDetail
         SET EditDate   = GETDATE(),
             EditWho    = SUSER_SNAME(),
             Trafficcop = NULL
      FROM PreAllocatePickDetail, INSERTED
      WHERE PreAllocatePickDetail.PreAllocatePickDetailKey = INSERTED.PreAllocatePickDetailKey
   
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=78105   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On PreAllocatePickDetail. (ntrPreAllocatePickDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END

   IF @n_continue = 3  -- Error Occured - Process And Return
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPreAllocatePickDetailUpdate"
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
ALTER TABLE [dbo].[PreAllocatePickDetail] WITH NOCHECK ADD CONSTRAINT [CK_PAPD_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[PreAllocatePickDetail] ADD CONSTRAINT [PKPreAllocatePickDetail] PRIMARY KEY CLUSTERED ([PreAllocatePickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PAPD_ORDERKEY] ON [dbo].[PreAllocatePickDetail] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PreAllocatePickDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Packkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying pre-allocated pick.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'PreAllocatePickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pre-allocate picking detail.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'PreAllocatePickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying pre-allocated strategy.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'PreAllocateStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product associated.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying running.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'RunKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'PreAllocatePickDetail', 'COLUMN', N'WaveKey'
GO
