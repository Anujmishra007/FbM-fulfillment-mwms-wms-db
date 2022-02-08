CREATE TABLE [dbo].[PickingVoice]
(
[PickingVoiceKey] [int] NOT NULL IDENTITY(1, 1),
[Pickslipno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_Pickslipno] DEFAULT (''),
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_Facility] DEFAULT (''),
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pickdetailkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL CONSTRAINT [DF_PickingVoice_Qty] DEFAULT ((0)),
[StartTime] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_Starttime] DEFAULT (getdate()),
[EndTime] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_EndTime] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PickingVoice_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PickingVoice_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/  
/* Trigger: ntrPickingVoiceUpdate                                          */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:  trace modified log                                            */  
/* Called By: When update records                                          */  
/*                                                                         */   
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date         Author  Ver.  Purposes                                     */  
/* 31-03-21     kocy  1.0    Updates EditDate & EditWho                    */
/*                            On PickingVoice Table                        */ 
/***************************************************************************/ 

CREATE TRIGGER [dbo].[ntrPickingVoiceUpdate]
ON [dbo].[PickingVoice] FOR UPDATE
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

   --IF UPDATE(ArchiveCop)    
   --BEGIN    
   --   SELECT @n_continue = 4     
   --END    
  
   IF ( @n_continue = 1 or @n_continue=2 )
   BEGIN  
      UPDATE [dbo].[PickingVoice]  
      SET EditDate = GETDATE(),  
          EditWho = SUSER_SNAME()  
      FROM [dbo].[PickingVoice] WITH (NOLOCK), INSERTED (NOLOCK)  
      WHERE [dbo].[PickingVoice].PickingVoiceKey = INSERTED.PickingVoiceKey 


      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

       IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table PickingVoice. (ntrPickingVoiceUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
      END
   END

 --  IF UPDATE(TrafficCop)
	--BEGIN
	--	SELECT @n_continue = 4 
	--END

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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrPickingVoiceUpdate'  
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
ALTER TABLE [dbo].[PickingVoice] ADD CONSTRAINT [PK__PickingV__D40815CBD7FBE2F7] PRIMARY KEY CLUSTERED ([PickingVoiceKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PickingVoice_Pickslipno] ON [dbo].[PickingVoice] ([Pickslipno], [UserID], [SKU], [LOC]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date Time User Add the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Add the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Admin flag for Data housekeep ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Last Date Time User Update the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Last User who Update the record ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Finish Picking time ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Facility code', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU Location bin code', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'LOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order Document Number', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Orderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pickdetail table unique key', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Pickdetailkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Table unique running number', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'PickingVoiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PickSlip number', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Pickslipno'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picked quantity', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'SKU Stock code', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Start Picking time ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picking task status ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Storer Owner key', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Admin flag for Skip trigger process ', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Picker user ID', 'SCHEMA', N'dbo', 'TABLE', N'PickingVoice', 'COLUMN', N'UserID'
GO
