CREATE TABLE [RDT].[rdtPreReceiveSort]
(
[Rowref] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[Func] [int] NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReceiptKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL CONSTRAINT [DF_rdtPreReceiveSort_Qty] DEFAULT ((0)),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPreReceiveSort_Status] DEFAULT (suser_sname()),
[Position] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[SourceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtPreReceiveSort_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPreReceiveSort_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtPreReceiveSort_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtPreReceiveSort_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*********************************************************************************/  
/* Store Procedure:  ntrrdtPreReceiveSortDelete                                  */  
/* Copyright: LF Logistics                                                       */  
/*                                                                               */  
/* Modification log:                                                             */  
/* Date         Author     Ver   Purposes                                        */  
/* 26-08-2020   kocy       1.0    https://jiralfl.atlassian.net/browse/WMS-14833 */
/*********************************************************************************/ 

CREATE     TRIGGER [RDT].[ntrrdtPreReceiveSortDelete]  
ON  [RDT].[rdtPreReceiveSort]  
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
               ,@c_errmsg = 'ntrrdtPreReceiveSortDelete' + RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'       
      BEGIN
         INSERT INTO RDT.rdtPreReceiveSort_DELLOG ( [RowRefSource], [Mobile], [Func], [Facility], [StorerKey], [ReceiptKey], [UCCNo], [SKU], [Qty], [Loc],
         [ID], [Status], [Position],[Lottable01], [Lottable02], [Lottable03], [Lottable04], [Lottable05], [Lottable06], [Lottable07], [Lottable08], [Lottable09],
         [Lottable10], [Lottable11], [Lottable12], [Lottable13], [Lottable14], [Lottable15], [SourceType], [UDF01], [UDF02], [UDF03], [UDF04], [UDF05], [ArchiveCop] )
         SELECT RowRef, [Mobile], [Func], [Facility], [StorerKey], [ReceiptKey], [UCCNo], [SKU], [Qty], [Loc],
         [ID], [Status], [Position],[Lottable01], [Lottable02], [Lottable03], [Lottable04], [Lottable05], [Lottable06], [Lottable07], [Lottable08], [Lottable09],
         [Lottable10], [Lottable11], [Lottable12], [Lottable13], [Lottable14], [Lottable15], [SourceType], [UDF01], [UDF02], [UDF03], [UDF04], [UDF05], [ArchiveCop]
         FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table rdtPreReceiveSort Failed. (ntrrdtPreReceiveSortDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END                  
      END
   END  
  
QUIT:  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrrdtPreReceiveSortDelete'
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
ALTER TABLE [RDT].[rdtPreReceiveSort] ADD CONSTRAINT [PK_rdtPreReceiveSort] PRIMARY KEY CLUSTERED ([Rowref]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtPreReceiveSort_ReceiptKey_Loc_Status] ON [RDT].[rdtPreReceiveSort] ([ReceiptKey], [Loc], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtPreReceiveSort_ReceiptKey_Ucc_Status] ON [RDT].[rdtPreReceiveSort] ([ReceiptKey], [UCCNo], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPreReceiveSort] TO [NSQL]
GO
