CREATE TABLE [dbo].[LOTATTRIBUTE]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_LOTTABLE01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_LOTTABLE02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_LOTTABLE03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Flag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Flag] DEFAULT (' '),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOTATTRIBUTE_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrLOTATTRIBUTEAdd                                          */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: LOTATTRIBUTE Add Transaction                                */
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
/* Called By: When records Added                                        */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 24-Apr-2014  TLTING   1.1  Add Lottable06-15                         */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrlotattributeadd]
ON [dbo].[LOTATTRIBUTE]
FOR INSERT
AS 
BEGIN
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
	
	-- to trim leading and trailing spaces of lotattributes 01, 02, 03
	-- tlting 24Apr14 trim for added lottable06-12
	IF @n_continue=1 or @n_continue=2
	BEGIN
		BEGIN TRAN
		UPDATE lotattribute
		SET lottable01 = ISNULL(LTrim(RTrim(i.lottable01)), ''),
			 lottable02 = ISNULL(LTrim(RTrim(i.lottable02)), ''),
			 lottable03 = ISNULL(LTrim(RTrim(i.lottable03)), ''),
			 lottable06 = ISNULL(LTrim(RTrim(i.lottable06)), ''), -- tlting
			 lottable07 = ISNULL(LTrim(RTrim(i.lottable07)), ''),
			 lottable08 = ISNULL(LTrim(RTrim(i.lottable08)), ''),
			 lottable09 = ISNULL(LTrim(RTrim(i.lottable09)), ''),			 			 			 			 
			 lottable10 = ISNULL(LTrim(RTrim(i.lottable10)), ''),			 			 			 			 
			 lottable11 = ISNULL(LTrim(RTrim(i.lottable11)), ''),			 			 			 			 
			 lottable12 = ISNULL(LTrim(RTrim(i.lottable12)), '')			 
		FROM lotattribute la JOIN inserted i
			ON la.lot = i.lot

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on LOTATTRIBUTE table. (ntrlotattributeadd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
		END
	END
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		execute nsp_logerror @n_err, @c_errmsg, "ntrlotattributeadd"
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
/* Trigger: ntrLOTATTRIBUTEUpdate                                       */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: LOTATTRIBUTE Update Transaction                             */
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
/* PVCS Version: 1.5                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 23 May 2012  TLTING01      DM integrity - add update editdate B4     */
/*                            TrafficCop                                */ 
/* 28-Oct-2013  TLTING        Review Editdate column update             */
/* 24-Apr-2014  TLTING   1.1  Add Lottable06-15                         */
/* 09-JAN-2015  CSCHONG  1.2  Fix RDT bugs (CS01)                       */
/* 28-Sep-2018  TLTING   1.3  Remove row lock                           */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLOTATTRIBUTEUpdate]
ON [dbo].[LOTATTRIBUTE]
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
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE LOTATTRIBUTE  
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM LOTATTRIBUTE , INSERTED (NOLOCK)
		WHERE LOTATTRIBUTE.LOT = INSERTED.LOT
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on LOTATTRIBUTE table. (ntrlotattributeupdate)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "
		END
	END

   IF UPDATE(TrafficCop)
   BEGIN
   	SELECT @n_continue = 4 
   END   
   
  /*Remove CS01 Start
   Declare @c Nvarchar(10)
   Set @c  = NULL
	Select LTRIM( rtrim(@c ))
	
	CS01 End*/

	-- to trim leading and trailing spaces of lotattributes 01, 02, 03
	-- tlting 24Apr14 trim for added lottable06-12
	IF @n_continue=1 or @n_continue=2
	BEGIN
		UPDATE LOTATTRIBUTE
		SET lottable01 = ISNULL(LTrim(RTrim(i.lottable01)), ''),
			 lottable02 = ISNULL(LTrim(RTrim(i.lottable02)), ''),
			 lottable03 = ISNULL(LTrim(RTrim(i.lottable03)), ''),
			 lottable06 = ISNULL(LTrim(RTrim(i.lottable06)), ''), -- tlting
			 lottable07 = ISNULL(LTrim(RTrim(i.lottable07)), ''),
			 lottable08 = ISNULL(LTrim(RTrim(i.lottable08)), ''),
			 lottable09 = ISNULL(LTrim(RTrim(i.lottable09)), ''),			 			 			 			 
			 lottable10 = ISNULL(LTrim(RTrim(i.lottable10)), ''),			 			 			 			 
			 lottable11 = ISNULL(LTrim(RTrim(i.lottable11)), ''),			 			 			 			 
			 lottable12 = ISNULL(LTrim(RTrim(i.lottable12)), '')
		FROM LOTATTRIBUTE la JOIN inserted i
			ON la.lot = i.lot
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on LOTATTRIBUTE table. (ntrlotattributeupdate)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "
		END
	END
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		execute nsp_logerror @n_err, @c_errmsg, "ntrlotattributeupdate"
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
ALTER TABLE [dbo].[LOTATTRIBUTE] ADD CONSTRAINT [PKLOTAttribute] PRIMARY KEY CLUSTERED ([Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_LOTATTRIBUTE_SKU_LOT] ON [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AK_LOTATTRIBUTE_01] ON [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lottable01], [Lottable02], [Lottable03], [Lottable04], [Lottable05], [Lottable06], [Lottable07], [Lottable08], [Lottable09], [Lottable10], [Lottable11], [Lottable12], [Lottable13], [Lottable14]) INCLUDE ([Lottable15]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AK_LOTATTRIBUTE02] ON [dbo].[LOTATTRIBUTE] ([StorerKey], [Sku], [Lottable01], [Lottable05]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOTATTRIBUTE] WITH NOCHECK ADD CONSTRAINT [FK_LOTATTRIBUTE_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
GRANT SELECT ON  [dbo].[LOTATTRIBUTE] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOTATTRIBUTE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'A lottable is a specific attribute about the product that makes the lot unique. When the lottable values for a product change, a new lot is assigned.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique re-populated numeric value associated with a  specific product.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity  Standard - Batch No', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity  Standard - Expiry date', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity  Standard - Incoming / Manufacturing date', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the Commodity associated with the prepopulated  lot number', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The owner of the product', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LOTATTRIBUTE', 'COLUMN', N'TrafficCop'
GO
