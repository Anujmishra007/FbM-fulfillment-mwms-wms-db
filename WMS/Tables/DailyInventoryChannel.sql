CREATE TABLE [dbo].[DailyInventoryChannel]
(
[ROWRef] [bigint] NOT NULL IDENTITY(1, 1),
[Channel_ID] [bigint] NOT NULL,
[InventoryDate] [datetime] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_Channel] DEFAULT (''),
[C_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute02] DEFAULT (''),
[C_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute03] DEFAULT (''),
[C_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute04] DEFAULT (''),
[C_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DailyInventoryChannel_C_Attribute05] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_DailyInventoryChannel_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_DailyInventoryChannel_QtyAllocated] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_DailyInventoryChannel_QtyOnHold] DEFAULT ((0)),
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adddate] [datetime] NULL CONSTRAINT [DF_DailyInventoryChannel_Adddate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/  
/* Store Procedure:  ntrDailyInventoryChannelDelete                              */  
/* Copyright: LF Logistics                                                       */  
/*                                                                               */  
/* Modification log:                                                             */  
/* Date         Author        Ver   Purposes                                     */  
/* 26-08-2020   kelvinongcy   1.0   Trigger delete log                           */
/*********************************************************************************/ 
CREATE     TRIGGER [dbo].[ntrDailyInventoryChannelDelete]  
ON  [dbo].[DailyInventoryChannel]  
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
               ,@c_errmsg = 'ntrDailyInventoryChannelDelete' + RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'       
      BEGIN
         INSERT INTO dbo.DailyInventoryChannel_DELLOG ( [RowRefSource], [Channel_ID], [InventoryDate], [StorerKey], [SKU], [Facility], [Channel], 
         [C_Attribute01], [C_Attribute02], [C_Attribute03], [C_Attribute04], [C_Attribute05], [Qty], [QtyAllocated], [QtyOnHold], [ArchiveCop]  )
         SELECT RowRef, [Channel_ID], [InventoryDate], [StorerKey], [SKU], [Facility], [Channel], 
         [C_Attribute01], [C_Attribute02], [C_Attribute03], [C_Attribute04], [C_Attribute05], [Qty], [QtyAllocated], [QtyOnHold], [ArchiveCop]
         FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table DailyInventoryChannel Failed. (ntrDailyInventoryChannelDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrDailyInventoryChannelDelete'
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
ALTER TABLE [dbo].[DailyInventoryChannel] ADD CONSTRAINT [PK_DailyInventoryChannel] PRIMARY KEY CLUSTERED ([ROWRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInvChannel] ON [dbo].[DailyInventoryChannel] ([InventoryDate], [Channel_ID], [StorerKey], [SKU], [Channel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DailyInvChannel_SKU] ON [dbo].[DailyInventoryChannel] ([SKU], [StorerKey], [Channel], [Facility]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DailyInventoryChannel] TO [NSQL]
GO
