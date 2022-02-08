CREATE TABLE [dbo].[rdsOrderDetail]
(
[rdsOrderNo] [int] NOT NULL,
[rdsOrderLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Style] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_Style] DEFAULT (''),
[Color] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_Color] DEFAULT (''),
[PackIndicator] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_PackIndicator] DEFAULT (''),
[Lottable01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_Lottable01] DEFAULT (''),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_Lottable02] DEFAULT (''),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_Lottable03] DEFAULT (''),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_rdsOrderDetail_Qty] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdsOrderDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdsOrderDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsOrderDetail_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsOrderDetail_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Shong
-- Create date: 31-Mar-2008
-- Description: Delete Details if Header was deleted
/*  9-Jun-2011  KHLim01    1.1   Insert Delete log                      */
/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */
-- =============================================
CREATE TRIGGER [dbo].[ntrRDSOrderDetailDelete]
   ON  [dbo].[rdsOrderDetail]
   AFTER DELETE
AS 
BEGIN
   DECLARE @n_StartTCnt int, 
           @n_Continue  int, 
           @b_success   int,
           @n_Err       int, 
           @c_ErrMsg    NVARCHAR(215) 
         , @n_cnt       int      -- KHLim01
         , @c_authority NVARCHAR(1)  -- KHLim02

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @n_Continue = 1 

   SET @n_StartTCnt = @@TRANCOUNT 

   IF EXISTS(SELECT 1 FROM rdsOrderDetailSize WITH (NOLOCK) 
             JOIN DELETED ON DELETED.rdsOrderNo = rdsOrderDetailSize.rdsOrderNo AND
                             DELETED.rdsOrderLineNo   = rdsOrderDetailSize.rdsOrderLineNo )
   BEGIN
      DELETE rdsOrderDetailSize 
      FROM   rdsOrderDetailSize 
      JOIN DELETED ON DELETED.rdsOrderNo = rdsOrderDetailSize.rdsOrderNo AND
                      DELETED.rdsOrderLineNo   = rdsOrderDetailSize.rdsOrderLineNo
      SET @n_Err = @@ERROR
      IF @n_Err <> 0 
      BEGIN
         SET @n_Continue = 3
         SET @b_success = -1
         SET @c_ErrMsg = 'DELETE rdsOrderDetailSize Failed'
         GOTO QUIT
      END   
   END 
   
   DECLARE @n_TotalOpenQty int, 
           @n_RDSOrderNo   int 

   DECLARE Cur_OrderDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT rdsOrderNo 
      FROM   DELETED

   OPEN Cur_OrderDetail 
   
   FETCH NEXT FROM Cur_OrderDetail INTO @n_RDSOrderNo 

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SELECT @n_TotalOpenQty = SUM(Qty) 
      FROM   rdsOrderDetailSize WITH (NOLOCK)
      WHERE  rdsOrderNo = @n_RDSOrderNo

      UPDATE rdsOrders WITH (ROWLOCK)
         SET OpenQty = @n_TotalOpenQty 
      WHERE rdsOrderNo = @n_RDSOrderNo
      SET @n_Err = @@ERROR
      IF @n_Err <> 0 
      BEGIN
         SET @n_Continue = 3
         SET @b_success = -1
         SET @c_ErrMsg = 'UPDATE rdsOrders Failed'
         GOTO QUIT
      END

      FETCH NEXT FROM Cur_OrderDetail INTO @n_RDSOrderNo 
   END
   CLOSE Cur_OrderDetail
   DEALLOCATE Cur_OrderDetail

   IF (SELECT count(*) FROM DELETED) =
      (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  --KH01
   BEGIN
      SELECT @n_continue = 4
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
               ,@c_errmsg = 'ntrRDSOrderDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.rdsOrderDetail_DELLOG ( rdsOrderNo, rdsOrderLineNo )
         SELECT rdsOrderNo, rdsOrderLineNo  FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ORDERS Failed. (ntrrdsOrderDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01)

QUIT:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'nspItrnAddMove'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
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
/* Trigger: ntrRDSOrderDetailUpdate                                     */
/* Creation Date:  25-May-2012                                          */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: rdsOrderDetail Update Transaction                           */
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
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrRDSOrderDetailUpdate]
ON [dbo].[rdsOrderDetail]
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
	
	DECLARE	@n_err                int       -- Error number returned by stored procedure or this trigger
	,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue int                 
	,         @n_starttcnt int                -- Holds the current transaction count
	,         @n_cnt int                  
	
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END
   
   -- TLTING01
	IF @n_continue = 1 or @n_continue=2
	BEGIN
		UPDATE rdsOrderDetail
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM rdsOrderDetail (NOLOCK), INSERTED (NOLOCK)
		WHERE rdsOrderDetail.rdsOrderNo = INSERTED.rdsOrderNo
		AND   rdsOrderDetail.rdsOrderLineNo = INSERTED.rdsOrderLineNo  
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on rdsOrderDetail table. (ntrRDSOrderDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
		END
	END

   IF UPDATE(TrafficCop)
   BEGIN
   	SELECT @n_continue = 4 
   END   
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		execute nsp_logerror @n_err, @c_errmsg, "ntrRDSOrderDetailUpdate"
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
ALTER TABLE [dbo].[rdsOrderDetail] ADD CONSTRAINT [PK_rdsOrderDetail_1] PRIMARY KEY CLUSTERED ([rdsOrderNo], [rdsOrderLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsOrderDetail] WITH NOCHECK ADD CONSTRAINT [FK_rdsOrderDetail_rdsORDERS] FOREIGN KEY ([rdsOrderNo]) REFERENCES [dbo].[rdsORDERS] ([rdsOrderNo])
GO
GRANT DELETE ON  [dbo].[rdsOrderDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsOrderDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsOrderDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsOrderDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsOrderDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsOrderDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'rdsOrderDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'rdsOrderDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'rdsOrderDetail', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'rdsOrderDetail', 'COLUMN', N'TrafficCop'
GO
