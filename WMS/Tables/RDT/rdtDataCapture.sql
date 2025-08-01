IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[rdtDataCapture]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[rdtDataCapture]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[V_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_Zone] DEFAULT (''),
[V_Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_Loc] DEFAULT (''),
[V_SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_SKU] DEFAULT (''),
[V_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_UOM] DEFAULT (''),
[V_ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_ID] DEFAULT (''),
[V_ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_ConsigneeKey] DEFAULT (''),
[V_CaseID] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_CaseID] DEFAULT (''),
[V_SKUDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_SKUDescr] DEFAULT (''),
[V_QTY] [int] NULL CONSTRAINT [DF_RDTDataCapture_V_QTY] DEFAULT ((0)),
[V_UCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_UCC] DEFAULT (''),
[V_Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_Lottable01] DEFAULT (''),
[V_Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_Lottable02] DEFAULT (''),
[V_Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_Lottable03] DEFAULT (''),
[V_Lottable04] [datetime] NULL,
[V_Lottable05] [datetime] NULL,
[V_String1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String1] DEFAULT (''),
[V_String2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String2] DEFAULT (''),
[V_String3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String3] DEFAULT (''),
[V_String4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String4] DEFAULT (''),
[V_String5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String5] DEFAULT (''),
[V_String6] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String6] DEFAULT (''),
[V_String7] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String7] DEFAULT (''),
[V_String8] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String8] DEFAULT (''),
[V_String9] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String9] DEFAULT (''),
[V_String10] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RDTDataCapture_V_String10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTDataCapture_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTDataCapture_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTDataCapture_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTDataCapture_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V_Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable06] DEFAULT (''),
[V_Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable07] DEFAULT (''),
[V_Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable08] DEFAULT (''),
[V_Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable09] DEFAULT (''),
[V_Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable10] DEFAULT (''),
[V_Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable11] DEFAULT (''),
[V_Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtDataCapture_V_Lottable12] DEFAULT (''),
[V_Lottable13] [datetime] NULL,
[V_Lottable14] [datetime] NULL,
[V_Lottable15] [datetime] NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtDataCapture_SerialNo] DEFAULT (''),
[InitialWeight] [float] NULL CONSTRAINT [DF_rdtDataCapture_InitialWeight] DEFAULT ((0))
) ON [PRIMARY]

ALTER TABLE [RDT].[rdtDataCapture] ADD CONSTRAINT [PKRDTDataCapture] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IDX_rdtDataCapture_serialno] ON [RDT].[rdtDataCapture] ([SerialNo]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Idx_RDTDataCapture_StorerKey_Facility] ON [RDT].[rdtDataCapture] ([StorerKey], [Facility]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [Idx_RDTDataCapture_V_String1] ON [RDT].[rdtDataCapture] ([V_String1]) ON [PRIMARY]

--GRANT SELECT ON  [RDT].[rdtDataCapture] TO [JReportRole]

GRANT DELETE ON  [RDT].[rdtDataCapture] TO [NSQL]

GRANT INSERT ON  [RDT].[rdtDataCapture] TO [NSQL]

GRANT SELECT ON  [RDT].[rdtDataCapture] TO [NSQL]

GRANT UPDATE ON  [RDT].[rdtDataCapture] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', N'Capture Serial No', 'SCHEMA', N'RDT', 'TABLE', N'rdtDataCapture', 'COLUMN', N'SerialNo'

END 

ELSE 
BEGIN 

		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE NAME ='InitialWeight' AND object_id = OBJECT_ID (N'[RDT].[rdtDataCapture]'))
		BEGIN
		ALTER TABLE [RDT].[rdtDataCapture]
		ADD [InitialWeight] [float] NULL CONSTRAINT [DF_rdtDataCapture_InitialWeight] DEFAULT ((0))
		EXEC sp_addextendedproperty N'MS_Description', N'InitialWeight', 'SCHEMA', N'RDT', 'TABLE', N'rdtDataCapture', 'COLUMN', N'InitialWeight'

END 
END


--SET QUOTED_IDENTIFIER OFF
--GO
--SET ANSI_NULLS OFF
--GO
--/* 28-Oct-2013  TLTING     Review Editdate column update                */

--CREATE TRIGGER [RDT].[ntrRDTDataCaptureUpdate]
--ON  [RDT].[rdtDataCapture]
--FOR UPDATE
--AS
--IF @@ROWCOUNT = 0
--BEGIN
--RETURN
--END
--   SET NOCOUNT ON
--   SET ANSI_NULLS OFF   
--   SET QUOTED_IDENTIFIER OFF
--	SET CONCAT_NULL_YIELDS_NULL OFF

--   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
--            @n_err         int,       -- Error number returned by stored procedure or this trigger
--            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
--            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
--            @n_starttcnt   int,       -- Holds the current transaction count
--            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.

--   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT
	 
--   IF UPDATE( TrafficCop) OR
--      UPDATE( ArchiveCop)
--      RETURN

--   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
--   BEGIN
--      UPDATE RDT.RDTDataCapture SET
--         EditWho  = sUser_sName(),
--         EditDate = GETDATE()
--      FROM RDT.RDTDataCapture
--         INNER JOIN INSERTED ON RDT.RDTDataCapture.RowRef = INSERTED.RowRef
--	   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

--	   IF @n_err <> 0
--	   BEGIN
--		   SELECT @n_continue = 3
--		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
--		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDT.RDTDataCapture. (ntrRDTDataCaptureUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
--	   END
--   END      