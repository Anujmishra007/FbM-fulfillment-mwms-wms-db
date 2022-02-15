CREATE TABLE [RDT].[RDTPPA]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Refkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickSlipno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Store] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PQty] [int] NULL,
[CQty] [int] NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTPPA_AddDate] DEFAULT (getdate()),
[NoofCheck] [int] NULL,
[UOMQty] [int] NULL,
[UCC] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPPA_UCC] DEFAULT (''),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPPA_OrderKey] DEFAULT (''),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPPA_DropID] DEFAULT (''),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDTPPA_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTPPA_EditWho] DEFAULT (suser_sname()),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPPA_ID] DEFAULT (''),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable01] DEFAULT (''),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable02] DEFAULT (''),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable03] DEFAULT (''),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPPA_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPPA_TaskDetailKey] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/  
/* Store Procedure:  ntrRDTPPADelete                                          */  
/* Copyright: LF Logistics                                                    */  
/*                                                                            */  
/* Modification log:                                                          */  
/* Date         Author     Ver   Purposes                                     */  
/* 12-Jan-2014  KHLim      1.0   Created                                      */
/******************************************************************************/  

CREATE TRIGGER [RDT].[ntrRDTPPADelete]  
ON  [RDT].[RDTPPA]  
FOR DELETE  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_debug int  
   SELECT @b_debug = 0  
  
   DECLARE  
      @b_Success            int           -- Populated by calls to stored procedures - was the proc successful?  
     ,@n_err                int           -- Error number returned by stored procedure or this trigger  
     ,@n_err2               int           -- For Additional Error Detection  
     ,@c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
     ,@n_continue           int  
     ,@n_starttcnt          int           -- Holds the current transaction count  
     ,@c_preprocess         NVARCHAR(250) -- preprocess  
     ,@c_pstprocess         NVARCHAR(250) -- post process  
     ,@profiler             NVARCHAR(80)
     ,@n_cnt                INT
     ,@c_authority          NVARCHAR(1)
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
  
   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN  
    SELECT @n_continue = 4  
   END  
    
   IF @n_continue = 1 OR @n_continue=2    
   BEGIN  
      SELECT @b_success = 0         --    Start
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
               ,@c_errmsg = 'ntrRDTPPADelete' + RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'       
      BEGIN
         INSERT INTO RDT.RDTPPA_DELLOG ( RowRefSource )
         SELECT RowRef FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table SerialNo Failed. (ntrRDTPPADelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END                  
      END
   END  
  
QUIT:  
   /* #INCLUDE <TRRDA2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
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
         execute nsp_logerror @n_err, @c_errmsg, "ntrRDTPPADelete"  
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
/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [RDT].[ntrRDTPPAUpdate]
ON [RDT].[RDTPPA]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  

   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
	   UPDATE [RDT].[RDTPPA] 
	   SET EditDate = GETDATE(),
	       EditWho  = SUSER_SNAME()
	   FROM [RDT].[RDTPPA] (NOLOCK), INSERTED (NOLOCK)
	   WHERE [RDT].[RDTPPA].RowRef = INSERTED.RowRef

	   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	   IF @n_err <> 0
	   BEGIN
		   SELECT @n_continue = 3
		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDTPPA. (ntrRDTPPAUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	   END
   END


   /* #INCLUDE <TRAHU2.SQL> */
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDTPPAUpdate'
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
ALTER TABLE [RDT].[RDTPPA] ADD CONSTRAINT [PK_RDTPPA] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_rdtPPA_LoadKey] ON [RDT].[RDTPPA] ([LoadKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RDTPPA_SKUPickSlipNo] ON [RDT].[RDTPPA] ([Sku], [StorerKey], [PickSlipno]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RDTPPA_SKURef] ON [RDT].[RDTPPA] ([Sku], [StorerKey], [Refkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rdtppa_dropid] ON [RDT].[RDTPPA] ([StorerKey], [DropID]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
GRANT SELECT ON  [RDT].[RDTPPA] TO [JReportRole]
GO
GRANT DELETE ON  [RDT].[RDTPPA] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTPPA] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTPPA] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTPPA] TO [NSQL]
GO
EXEC sp_addextendedproperty N'Lottable01', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'Lottable02', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'Lottable03', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'Lottable04', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'Lottable05', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'Lottable06', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'Lottable07', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'Lottable08', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'Lottable09', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'Lottable10', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'Lottable11', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'Lottable12', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'Lottable13', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'Lottable14', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'Lottable15', N'Lottable01', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store TaskDetailKey Value', 'SCHEMA', N'RDT', 'TABLE', N'RDTPPA', 'COLUMN', N'TaskDetailKey'
GO
