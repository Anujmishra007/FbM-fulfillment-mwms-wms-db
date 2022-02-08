CREATE TABLE [dbo].[ChannelInv]
(
[Channel_ID] [bigint] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_Channel] DEFAULT (''),
[C_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute02] DEFAULT (''),
[C_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute03] DEFAULT (''),
[C_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute04] DEFAULT (''),
[C_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInv_C_Attribute05] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_ChannelInv_Qty] DEFAULT ((0)),
[QtyAllocated] [int] NOT NULL CONSTRAINT [DF_ChannelInv_QtyAllocated] DEFAULT ((0)),
[QtyOnHold] [int] NOT NULL CONSTRAINT [DF_ChannelInv_QtyOnHold] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_ChannelInv_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelInv_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_ChannelInv_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelInv_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrChannelInvDelete                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records delete from ChannelInv                       */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/

CREATE   TRIGGER [dbo].[ntrChannelInvDelete]
ON [dbo].[ChannelInv]
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
   
   DECLARE @b_Success  int,       -- Populated by calls to stored procedures - was the proc successful?
   @n_err              int,       -- Error number returned by stored procedure or this trigger
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
   @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
   @n_starttcnt        int,       -- Holds the current transaction count
   @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
  ,@c_authority        NVARCHAR(1)  -- KHLim02


   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

    
   IF EXISTS ( SELECT 1 FROM DELETED WHERE  Qty > 0 )
   BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = 62726 --67201
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': DELETE not allowed. (ntrChannelInvDelete)'
   END

       

   /* #INCLUDE <TRADD2.SQL> */   
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrChannelInvDelete'
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

/********************************************************************************/  
/* Trigger: ntrChannelInvUpdate                                                 */  
/* Creation Date:                                                               */  
/* Copyright: IDS                                                               */  
/* Written by: kelvinongcy                                                      */  
/*                                                                              */  
/* Purpose:  ChannelInv Update                                                  */                                                        
/* Called By: When update records                                               */  
/*                                                                              */  
/* PVCS Version: 1.1                                                            */  
/*                                                                              */  
/* Version:                                                                     */  
/*                                                                              */  
/* Data Modifications:                                                          */  
/*                                                                              */  
/* Updates:                                                                     */  
/* Date          Author  Ver.  Purposes                                         */  
/* 04-March-2019 kocy  1.0   WMS-8095 - JDSports - Update EditDate              */
/*                            & EditWho in Channel related tables               */
/********************************************************************************/  
CREATE TRIGGER [dbo].[ntrChannelInvUpdate]  
ON  [dbo].[ChannelInv] FOR UPDATE  
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
         , @c_errmsg     char(250) -- Error message returned by stored procedure or this trigger  
         , @n_continue   int                   
         , @n_starttcnt  int       -- Holds the current transaction count  
         , @c_preprocess char(250) -- preprocess  
         , @c_pstprocess char(250) -- post process  
         , @n_cnt        int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF UPDATE(ArchiveCop)    
   BEGIN    
      SELECT @n_continue = 4     
   END    
  
   IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN  
      UPDATE ChannelInv  
      SET EditDate = GETDATE(),  
          EditWho = SUSER_SNAME()  
      FROM ChannelInv (NOLOCK), INSERTED (NOLOCK)  
      WHERE ChannelInv.Channel_ID = INSERTED.Channel_ID  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table ChannelInv. (ntrChannelInvUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
      END  
   END 

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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrChannelInvUpdate'  
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
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_Qty] CHECK (([Qty]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_QtyAllocated] CHECK (([QtyAllocated]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_QtyOnHold] CHECK ((([Qty]-[QtyAllocated])-[QtyonHold]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [CK_ChannelInv_QtyOnHold2] CHECK (([QtyonHold]>=(0)))
GO
ALTER TABLE [dbo].[ChannelInv] ADD CONSTRAINT [PK_ChannelInv] PRIMARY KEY CLUSTERED ([Channel_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChannelInv_sku] ON [dbo].[ChannelInv] ([SKU], [Channel]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelInv] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelInv] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelInv] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelInv] TO [NSQL]
GO
