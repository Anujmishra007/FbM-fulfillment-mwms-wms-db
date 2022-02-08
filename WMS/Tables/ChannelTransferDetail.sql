CREATE TABLE [dbo].[ChannelTransferDetail]
(
[ChannelTransferKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChannelTransferLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ChannelTransferLineNumber] DEFAULT (' '),
[ExternChannelTransferKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ExternChannelTransferKey] DEFAULT (' '),
[ExternChannelTransferLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ExternChannelTransferLineNo] DEFAULT (' '),
[FromStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromStorerKey] DEFAULT (' '),
[FromSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromSku] DEFAULT (' '),
[FromQty] [int] NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromQty] DEFAULT ((0)),
[FromPackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromPackKey] DEFAULT ('STD'),
[FromUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromUOM] DEFAULT (' '),
[ToStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToStorerKey] DEFAULT (' '),
[ToSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToSku] DEFAULT (' '),
[ToQty] [int] NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToQty] DEFAULT ((0)),
[ToPackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToPackKey] DEFAULT ('STD'),
[ToUOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToUOM] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_Status] DEFAULT ((0)),
[FromChannel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromChannel] DEFAULT (' '),
[ToChannel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToChannel] DEFAULT (' '),
[FromChannel_ID] [bigint] NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromChannel_ID] DEFAULT ((0)),
[ToChannel_ID] [bigint] NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToChannel_ID] DEFAULT ((0)),
[FromC_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromC_Attribute01] DEFAULT (' '),
[FromC_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromC_Attribute02] DEFAULT (' '),
[FromC_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromC_Attribute03] DEFAULT (' '),
[FromC_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromC_Attribute04] DEFAULT (' '),
[FromC_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_FromC_Attribute05] DEFAULT (' '),
[ToC_Attribute01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToC_Attribute01] DEFAULT (' '),
[ToC_Attribute02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToC_Attribute02] DEFAULT (' '),
[ToC_Attribute03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToC_Attribute03] DEFAULT (' '),
[ToC_Attribute04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToC_Attribute04] DEFAULT (' '),
[ToC_Attribute05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_ToC_Attribute05] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransferDetail_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransferDetail_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransferDetail_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransferDetail_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransferDetail_UserDefine05] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ChannelTransferDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ChannelTransferDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransferDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************************************************/  
/* Trigger: ntrChannelTransferDetailUpdate                                                                        */  
/* Creation Date:                                                                                                 */  
/* Copyright: IDS                                                                                                 */  
/* Written by:                                                                                                    */  
/*                                                                                                                */  
/* Purpose:  ChannelTransferDetail Update                                                                         */  
/*                                                                                                                */  
/* Input Parameters:                                                                                              */  
/*                                                                                                                */  
/* Output Parameters:                                                                                             */  
/*                                                                                                                */  
/* Return Status:                                                                                                 */  
/*                                                                                                                */  
/* Usage:                                                                                                         */  
/*                                                                                                                */  
/* Local Variables:                                                                                               */  
/*                                                                                                                */  
/* Called By: When update records                                                                                 */  
/*                                                                                                                */  
/* PVCS Version: 1.1                                                                                              */  
/*                                                                                                                */  
/* Version:                                                                                                       */  
/*                                                                                                                */  
/* Data Modifications:                                                                                            */  
/*                                                                                                                */  
/* Updates:                                                                                                       */  
/* Date         Author  Ver.  Purposes                                                                            */  
/* 04-March-2019  kelvinongcy  1.0   WMS-8095 - JDSports - Update EditDate & EditWho in Channel related tables    */ 
/******************************************************************************************************************/  
CREATE TRIGGER [dbo].[ntrChannelTransferDetailUpdate]  
ON  [dbo].[ChannelTransferDetail] FOR UPDATE  
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
      UPDATE ChannelTransferDetail  
      SET EditDate = GETDATE(),  
          EditWho = SUSER_SNAME(),
          TrafficCop = NULL 
      FROM ChannelTransferDetail (NOLOCK), INSERTED (NOLOCK)  
      WHERE ChannelTransferDetail.ChannelTransferKey = INSERTED.ChannelTransferKey  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table ChannelTransferDetail. (ntrChannelTransferDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
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
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > @n_starttcnt  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
      execute nsp_logerror @n_err, @c_errmsg, 'ntrChannelTransferDetailUpdate'  
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
ALTER TABLE [dbo].[ChannelTransferDetail] ADD CONSTRAINT [PKChannelTransferDetail] PRIMARY KEY CLUSTERED ([ChannelTransferKey], [ChannelTransferLineNumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelTransferDetail_ExternKey] ON [dbo].[ChannelTransferDetail] ([FromStorerKey], [ExternChannelTransferKey], [ExternChannelTransferLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelTransferDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelTransferDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelTransferDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelTransferDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying ChannelTransfer ticket.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ChannelTransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ChannelTransferLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific an External ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ExternChannelTransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify detail line number in sequence of an External ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ExternChannelTransferLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Channel Attribute 1', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromC_Attribute01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Channel Attribute 2', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromC_Attribute02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Channel Attribute 3', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromC_Attribute03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Channel Attribute 4', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromC_Attribute04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'From Channel Attribute 5', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromC_Attribute05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'FromChannel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromChannel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'FromChannel_ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromChannel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pack key that are available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromPackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of product to be transferred in the Master UOM', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Commodity being transferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromSku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer from whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measure available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'FromUOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Channel Attribute 1', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToC_Attribute01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Channel Attribute 2', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToC_Attribute02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Channel Attribute 3', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToC_Attribute03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Channel Attribute 4', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToC_Attribute04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'To Channel Attribute 5', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToC_Attribute05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ToChannel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToChannel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ToChannel_ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToChannel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pack codes that are available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToPackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Final quantity value of the transferred commodity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Commodity to be transferred to', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToSku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer to whom the ownership of product is transferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measure available for the selected Commodity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'ToUOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransferDetail', 'COLUMN', N'UserDefine05'
GO
