CREATE TABLE [dbo].[UCC]
(
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qty] [int] NULL,
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sourcetype] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Userdefined01] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined01] DEFAULT (''),
[Userdefined02] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined02] DEFAULT (''),
[Userdefined03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined03] DEFAULT (''),
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Status] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_UCC_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_UCC_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_EditWho] DEFAULT (suser_sname()),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_LOT] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_LOC] DEFAULT (''),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_ID] DEFAULT (''),
[Receiptkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Receiptkey] DEFAULT (' '),
[ReceiptLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_ReceiptLineNumber] DEFAULT (' '),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Orderkey] DEFAULT (' '),
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_OrderLineNumber] DEFAULT (' '),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_WaveKey] DEFAULT (' '),
[PickDetailKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_PickDetailKey] DEFAULT (' '),
[Userdefined04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined04] DEFAULT (''),
[Userdefined05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined05] DEFAULT (''),
[Userdefined06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined06] DEFAULT (''),
[Userdefined07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined07] DEFAULT (''),
[Userdefined08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined08] DEFAULT (''),
[Userdefined09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined09] DEFAULT (''),
[Userdefined10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UCC_Userdefined10] DEFAULT (''),
[UCC_RowRef] [int] NOT NULL IDENTITY(1, 1),
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************/     
/* Trigger: ntrUCCDelete                                                */     
/* Creation Date:                                                       */     
/* Copyright: IDS                                                       */     
/* Written by:                                                          */     
/*                                                                      */     
/* Purpose:  Delete UCC.                                                */     
/*                                                                      */     
/* Return Status:                                                       */     
/*                                                                      */     
/* Usage:                                                               */     
/*                                                                      */     
/* Called By: When records Deleted                                      */     
/*                                                                      */     
/* PVCS Version: 1.0                                                    */     
/*                                                                      */     
/* Version: 5.4                                                         */     
/*                                                                      */     
/* Modifications:                                                       */     
/* Date         Author   Ver  Purposes                                  */     
/* 14-Jul-2011  KHLim02  1.2  GetRight for Delete log                   */  
/* 14-Nov-2011  KHLim03  1.3  Add primary keys                          */  
/* 16-May-2014  TLTING   1.4  Add primary key                           */  
/* 19-Aug-2014  TLTING   1.4  Add ArchiveCop & TrrafficCop              */     
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrUCCDelete]
ON [dbo].[UCC]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF (SELECT count(*) FROM DELETED) =
   (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

      /* #INCLUDE <TRCONHD1.SQL> */     
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
               ,@c_errmsg = 'ntrUCCDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.UCC_DELLOG ( UCCNo, Storerkey, SKU, UCC_RowRef ) -- KHLim03
         SELECT UCCNo, Storerkey, SKU, UCC_RowRef FROM DELETED -- KHLim03

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table UCC Failed. (ntrUCCDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRCOND2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrUCCDelete'
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/************************************************************************/  
/* Trigger: ntrUCCUpdate                                                */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Update UCC.                                                */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/* 07-Jun-2012 KHLim01   1.1  prefix rdt. if come from RDT              */
/* 24-08-2012  ChewKP    1.2  SOS#253989 Update UCC information to      */  
/*                            Traceinfo (ChewKP01)                      */
/* 28-Oct-2013 TLTING    1.3  Review Editdate column update             */
/* 01-11-2013  Shong     1.3  Remove TraceInfo and Do not update        */
/*                            EditDate if already update                */  
/* 16-05-2014  TLTING    1.3  New primary key UCC_RowRef                */  
/* 19-08-2014  TLTING    1.4  Add ArchiveCop & TrrafficCop              */  
/************************************************************************/  
CREATE TRIGGER [dbo].[ntrUCCUpdate]  
ON  [dbo].[UCC]   
FOR UPDATE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET ANSI_WARNINGS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF   
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
         , @n_IsRDT INT            -- KHLim01
         , @c_PreUN varchar(5)     -- KHLim01
           
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF UPDATE(ArchiveCop)      --KH01
   BEGIN
      SELECT @n_continue = 4
   END

   IF UPDATE(TrafficCop)      --KH01
   BEGIN
      SELECT @n_continue = 4
   END

   IF (@n_continue = 1 OR @n_continue = 2) AND NOT UPDATE(EditDate)  
   BEGIN 
      -- KHLim01 start
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
      IF @n_IsRDT = 1 
      BEGIN
         SET @c_PreUN = 'rdt.' 
      END
      ELSE
      BEGIN
         SET @c_PreUN = ''
      END
      -- KHLim01 end
             
      UPDATE UCC  with (RowLock)
         SET EditDate = GETDATE(),  
             EditWho = @c_PreUN + SUSER_SNAME() -- KHLim01
        FROM UCC, INSERTED  
       WHERE UCC.UCC_RowRef = INSERTED.UCC_RowRef
 
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table UCC. (ntrUCCUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
   /* END Added */
  
 
   /* #INCLUDE <TRPU_2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrUCCUpdate'  
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
ALTER TABLE [dbo].[UCC] ADD CONSTRAINT [PK_UCC] PRIMARY KEY NONCLUSTERED ([UCC_RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_LOC] ON [dbo].[UCC] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_LOTxLOCxID] ON [dbo].[UCC] ([Lot], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_Pickdetailkey] ON [dbo].[UCC] ([PickDetailKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_Receipt] ON [dbo].[UCC] ([Receiptkey], [ReceiptLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_SourceKey] ON [dbo].[UCC] ([Sourcekey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_ExternKey] ON [dbo].[UCC] ([Storerkey], [ExternKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_StorerKey_LOC_ID] ON [dbo].[UCC] ([Storerkey], [Loc], [Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_StorerKey_SKU] ON [dbo].[UCC] ([Storerkey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_UCC_SKU_LOT_LOC] ON [dbo].[UCC] ([Storerkey], [SKU], [Lot], [Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_Storerkey_Status_Userdefined05_Userdefined06] ON [dbo].[UCC] ([Storerkey], [Status], [Userdefined05], [Userdefined06]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UCC_StorerKey_Userdefined04] ON [dbo].[UCC] ([Storerkey], [Userdefined04]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX_UCC_UCCNo] ON [dbo].[UCC] ([UCCNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[UCC] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[UCC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UCC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UCC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UCC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Uniform Commercial Code (UCC) provides a global standard in identification of pallets/cartons of products, rolls, drums etc.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External reference number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'ExternKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet id (if any)', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location of the Commodity in the facility', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot number associated to the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment order number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment order line number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'OrderLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Detail.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock on hand', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN/receipt number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Receiptkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ASN/receipt line number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'ReceiptLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique identifier for the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifier associated with the source document creating the transaction, usually a combination of the document number plus the line number', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of source document creating the transaction; usually the internal name of the trigger or stored procedure that generated the transaction', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Sourcetype'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Status  0 - New  1 - Received  3 - Allocated   4 - Pick in progress  6 - Complete', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Owner of the goods/Commodity', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique number to identify the carton or pallet which is standard and will be used from suppliers to customers', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined01 - can be used to store references', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Userdefined01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined02 - can be used to store references', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Userdefined02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined03 - can be used to store references', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'Userdefined03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'UCC', 'COLUMN', N'WaveKey'
GO
