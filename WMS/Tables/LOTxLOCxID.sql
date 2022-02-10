CREATE TABLE [dbo].[LOTxLOCxID]
(
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_Lot] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_Loc] DEFAULT ('UNKNOWN'),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_ID] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_StorerKey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_Sku] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyPicked] DEFAULT ((0)),
[QtyExpected] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyExpected] DEFAULT ((0)),
[QtyPickInProcess] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_QtyPickInProcess] DEFAULT ((0)),
[PendingMoveIN] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_PendingMoveIN] DEFAULT ((0)),
[ArchiveQty] [int] NOT NULL CONSTRAINT [DF_LOTxLOCxID_ArchiveQty] DEFAULT ((0)),
[ArchiveDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxLOCxID_ArchiveDate] DEFAULT ('01/01/1901'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyReplen] [int] NULL CONSTRAINT [DF_lotxlocxid_QtyReplen] DEFAULT ((0)),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTxLOCxID_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOTxLOCxID_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[LOTxLOCxID] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOTxLOCxID] TO [NSQL]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

/************************************************************************/
/* Trigger: ntrLOTxLOCxIDdelete                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from LOTxLOCxID                      */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 09-May-2006  MaryVong      Add in RDT compatible error message       */
/* 13-Sep-2011  KHLim02       GetRight for Delete log                   */
/* 18-Jan-2012  KHLim03       check ArchiveCop                          */
/* 27-Jul-2017  TLTING        SET Option                                */
/* 27-Oct-2017  TLTING        Move up dellog                            */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLOTxLOCxIDdelete]
ON [dbo].[LOTxLOCxID]
FOR DELETE
AS 
BEGIN
   IF @@ROWCOUNT = 0 -- KHLim03
   BEGIN
	   RETURN
   END
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF
	
   DECLARE @n_err int,
         @c_errmsg NVARCHAR(250),
         @n_continue int,
         @n_starttcnt int
        ,@b_Success     int
        ,@n_cnt         int
        ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  -- KHLim02

   IF @n_continue = 1 or @n_continue = 2   --    Start (KHLim02)
   BEGIN
      SELECT @b_success = 0
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
               ,@c_errmsg = 'ntrLOTxLOCxIDdelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.LOTxLOCxID_DELLOG ( Lot, Loc, Id )
         SELECT Lot, Loc, Id FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table LOTxLOCxID Failed. (ntrLOTxLOCxIDdelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END                                     --    End   (KHLim02)


   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9') -- KHLim03
   BEGIN
	   SELECT @n_continue = 4
   END

   IF EXISTS (SELECT 1 
              FROM DELETED
              WHERE Qty > 0
                 OR QtyAllocated > 0
                 OR QtyPicked > 0)
   BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = 60976 --63210
      SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + ': Delete Not Allowed on Active Records (ntrLOTxLOCxIDdelete)'
   END

 
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
   
      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
   
         -- Raise error with severity = 10, instead of the default severity 16. 
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR 
   
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLOTxLOCxIDdelete'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
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
/* Trigger: ntrLOTXLOCXIDUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose:  LOTXLOCXID Update                                          */
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
/* 23 May 2012  TLTING01  DM integrity - add update editdate B4         */
/*                        TrafficCop                                    */ 
/* 28-Oct-2013  TLTING    Review Editdate column update                 */
/* 28-Sep-2018  TLTING    remove row lock                               */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLOTXLOCXIDUpdate]
ON  [dbo].[LOTxLOCxID] FOR UPDATE
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

	DECLARE @b_Success    int       -- Populated by calls to stored procedures - was the proc successful?
			, @n_err        int       -- Error number returned by stored procedure or this trigger
			, @n_err2       int       -- For Additional Error Detection
			, @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
			, @n_continue   int                 
			, @n_starttcnt  int       -- Holds the current transaction count
			, @c_preprocess NVARCHAR(250) -- preprocess
			, @c_pstprocess NVARCHAR(250) -- post process
			, @n_cnt        int                  

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

	IF UPDATE(ArchiveCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	
   -- tlting01
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE LOTXLOCXID  
		SET EditDate = GETDATE(),
		    EditWho = SUSER_SNAME(),
		    TrafficCop = NULL
		FROM LOTXLOCXID , INSERTED (NOLOCK)
		WHERE LOTXLOCXID.LOT = INSERTED.LOT
		AND LOTXLOCXID.LOC = INSERTED.LOC
		AND LOTXLOCXID.ID = INSERTED.ID
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LOTXLOCXID. (ntrLOTXLOCXIDUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END

	IF UPDATE(TrafficCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	   /* #INCLUDE <TRTHU1.SQL> */     

      /* #INCLUDE <TRTHU2.SQL> */
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
		execute nsp_logerror @n_err, @c_errmsg, 'ntrLOTXLOCXIDUpdate'
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
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_01] CHECK (([Qty]+[QtyExpected]>=([QtyAllocated]+[QtyPicked])))
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_QtyAllocated] CHECK (([QtyAllocated]>=(0)))
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [CK_LOTxLOCxID_QtyPicked] CHECK (([QtyPicked]>=(0)))
GO
ALTER TABLE [dbo].[LOTxLOCxID] ADD CONSTRAINT [PKLOTxLOCxID] PRIMARY KEY CLUSTERED ([Lot], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOTxLOCxID_ID] ON [dbo].[LOTxLOCxID] ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOTxLOCxID_LOC] ON [dbo].[LOTxLOCxID] ([Loc], [Id], [Qty], [QtyPicked]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LOTxLOCxIDQty] ON [dbo].[LOTxLOCxID] ([Lot], [Loc], [Id], [Qty], [QtyAllocated], [QtyPicked]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOTxLOCxID_SKU] ON [dbo].[LOTxLOCxID] ([Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [FK_LOTxLOCxID_ID_01] FOREIGN KEY ([Id]) REFERENCES [dbo].[ID] ([Id])
GO
ALTER TABLE [dbo].[LOTxLOCxID] ADD CONSTRAINT [FK_LOTxLOCxID_LOC_01] FOREIGN KEY ([Loc]) REFERENCES [dbo].[LOC] ([Loc])
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [FK_LOTxLOCxID_LOT_01] FOREIGN KEY ([Lot]) REFERENCES [dbo].[LOT] ([Lot])
GO
ALTER TABLE [dbo].[LOTxLOCxID] WITH NOCHECK ADD CONSTRAINT [FK_LOTxLOCxID_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'pallet id of the goods', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'physical location of the goods', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique re-populated numeric value associated with a  specific product.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'unit of quantity', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'allocated quantity', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', 'expected quantity to be replenish', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyExpected'
GO
EXEC sp_addextendedproperty N'MS_Description', 'picked quantity', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyPicked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'quantity pick in progress', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyPickInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the Commodity replenished in the Location.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'QtyReplen'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Owner of the good.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LOTxLOCxID', 'COLUMN', N'TrafficCop'
GO
