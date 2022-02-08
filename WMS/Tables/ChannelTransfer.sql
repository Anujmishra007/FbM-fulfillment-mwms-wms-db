CREATE TABLE [dbo].[ChannelTransfer]
(
[ChannelTransferKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternChannelTransferKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_ExternChannelTransferKey] DEFAULT (' '),
[FromStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_FromStorerKey] DEFAULT (' '),
[ToStorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_ToStorerKey] DEFAULT (' '),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_Type] DEFAULT (' '),
[OpenQty] [int] NOT NULL CONSTRAINT [DF_ChannelTransfer_OpenQty] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_Status] DEFAULT ('0'),
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_ReasonCode] DEFAULT (' '),
[CustomerRefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_CustomerRefNo] DEFAULT (' '),
[Remarks] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_Remarks] DEFAULT (' '),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_Facility] DEFAULT (' '),
[ToFacility] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_ToFacility] DEFAULT (' '),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ChannelTransfer_UserDefine05] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ChannelTransfer_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ChannelTransfer_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelTransfer_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************/    
/* Trigger:  ntrChannelTransferUpdate                                          */    
/* Creation Date: 16-Oct-2018                                                  */    
/* Copyright: LFL                                                              */    
/* Written by: YokeBeen                                                        */    
/*                                                                             */    
/* Purpose:  ChannelTransfer Update Trigger                                    */    
/*                                                                             */    
/* Usage: Trigger Points                                                       */    
/*                                                                             */    
/* Called By:                                                                  */    
/*                                                                             */    
/* PVCS Version: 1.0                                                           */    
/*                                                                             */    
/* Version: 1.0                                                                */    
/*                                                                             */    
/* Data Modifications:                                                         */    
/*                                                                             */    
/* Updates:                                                                    */    
/* Date         Author       Ver.   Purposes                                   */    
/* 04-March-19  kelvinongcy  1.1     WMS-8095 - JDSports - Update EditDate &   */
/*                                   EditWho in Channel related tables         */    
/*******************************************************************************/    
    
CREATE TRIGGER [dbo].[ntrChannelTransferUpdate]    
ON  [dbo].[ChannelTransfer]    
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
    
   DECLARE @b_Success               int            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err                   int            -- Error number returned by stored procedure or this trigger    
         , @n_err2                  int            -- For Additional Error Detection    
         , @c_errmsg                NVARCHAR(250)  -- Error message returned by stored procedure or this trigger    
         , @n_continue              int     
         , @n_starttcnt             int            -- Holds the current transaction count    
         , @n_cnt                   int                      
  
   DECLARE @c_ChannelTransferKey    NVARCHAR(10)     
         , @c_FromStorerKey         nvarchar(15)     
         , @c_ToStorerKey           nvarchar(15)     
         , @c_Type                  NVARCHAR(12)     
         , @c_ReasonCode            NVARCHAR(10)       
         , @c_Status                nvarchar(10)    
         , @c_TriggerName           nvarchar(120)    
         , @c_SourceTable           nvarchar(60)    
  
   SET @c_TriggerName = 'ntrChannelTransferUpdate'    
   SET @c_SourceTable = 'CHANNELTRANSFER'    
     
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT    
    
   IF UPDATE(ArchiveCop)    
   BEGIN    
      SELECT @n_continue = 4     
   END    
       
/********************************************************/    
/* Interface Trigger Points Calling Process - (Start)   */    
/********************************************************/ 
   --kelvinongcy (Start)
   IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN  
      UPDATE ChannelTransfer  
      SET EditDate = GETDATE(),  
          EditWho = SUSER_SNAME(),
          TrafficCop = NULL 
      FROM ChannelTransfer (NOLOCK), INSERTED (NOLOCK)  
      WHERE ChannelTransfer.ChannelTransferKey = INSERTED.ChannelTransferKey  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table ChannelTransfer. (ntrChannelTransferUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
      END  
   END   

   IF UPDATE(TrafficCop)    
   BEGIN    
      SELECT @n_continue = 4     
   END    
   --kelvinongcy (End)

   IF @n_continue = 1 OR @n_continue = 2     
   BEGIN     
      IF UPDATE(Status)    
      BEGIN   
         IF EXISTS (SELECT 1 FROM DELETED    
                      JOIN ChannelTransfer WITH (NOLOCK) ON (DELETED.ChannelTransferkey = ChannelTransfer.ChannelTransferkey)     
                     WHERE DELETED.[STATUS] <> '9'    
                       AND ChannelTransfer.[STATUS] = '9')    
         BEGIN    
            DECLARE Cur_ChannelTransfer_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
            -- Extract values for required variables    
             SELECT ChannelTransfer.FromStorerkey     
                  , ChannelTransfer.ToStorerkey     
                  , ChannelTransfer.ChannelTransferkey    
                  , ChannelTransfer.[Type]    
                  , ChannelTransfer.ReasonCode     
                  , ChannelTransfer.[Status]    
               FROM INSERTED     
               JOIN DELETED WITH (NOLOCK) ON (INSERTED.ChannelTransferkey = DELETED.ChannelTransferkey)     
               JOIN ChannelTransfer WITH (NOLOCK) ON (INSERTED.ChannelTransferkey = ChannelTransfer.ChannelTransferkey)     
              WHERE DELETED.[Status] <> '9'    
                AND INSERTED.[Status] = '9'    
    
            OPEN Cur_ChannelTransfer_TriggerPoints    
            FETCH NEXT FROM Cur_ChannelTransfer_TriggerPoints INTO @c_FromStorerKey, @c_ToStorerKey, @c_ChannelTransferKey    
                                                                 , @c_Type, @c_ReasonCode, @c_Status    
    
            WHILE @@FETCH_STATUS <> -1    
            BEGIN    
               -- Execute SP - isp_ITF_ntrChannelTransfer    
               EXECUTE dbo.isp_ITF_ntrChannelTransfer     
                        @c_TriggerName    
                      , @c_SourceTable    
                      , @c_FromStorerKey    
                      , @c_ToStorerKey    
                      , @c_ChannelTransferKey    
                      , @b_Success  OUTPUT    
                      , @n_err      OUTPUT    
                      , @c_errmsg   OUTPUT    
    
               FETCH NEXT FROM Cur_ChannelTransfer_TriggerPoints INTO @c_FromStorerKey, @c_ToStorerKey, @c_ChannelTransferKey    
                                                                    , @c_Type, @c_ReasonCode, @c_Status    
            END -- WHILE @@FETCH_STATUS <> -1    
            CLOSE Cur_ChannelTransfer_TriggerPoints    
            DEALLOCATE Cur_ChannelTransfer_TriggerPoints    
         END -- IF EXISTS (SELECT 1 FROM INSERTED, DELETED)    
      END -- IF UPDATE(Status)    
   END -- IF @n_continue = 1 OR @n_continue = 2     
/********************************************************/    
/* Interface Trigger Points Calling Process - (End)     */    
/********************************************************/    
    
   QUIT_TR:  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrChannelTransferUpdate'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    
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
      
END -- End PROC   
GO
ALTER TABLE [dbo].[ChannelTransfer] ADD CONSTRAINT [PKChannelTransfer] PRIMARY KEY CLUSTERED ([ChannelTransferKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelTransfer_ExternKey] ON [dbo].[ChannelTransfer] ([FromStorerKey], [ExternChannelTransferKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelTransfer] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'ChannelTransfer is one of the functions that are available in Exceed WMS to help the users to manage the flow of goods in the warehouse or facility. The ChannelTransfer ticket is used to ChannelTransfer goods between Channels and/or storers. It allows the user to ChannelTransfer goods from one storerÆs inventory to another storerÆs inventory in a single process. The inventory ChannelTransfer creates a deposit transaction and a withdrawal in the inventory module.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ChannelTransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'CustomerRefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'It''s used to identify a specific an External ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ExternChannelTransferKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The facility or warehouse where the product is originally stored', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer from whom the ownership of product is ChannelTransferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'FromStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Open Quantity', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'OpenQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason for the ChannelTransfer', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'any notes / remarks', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of the ChannelTransfer', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The facility in which the product will be ChannelTransferred to', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ToFacility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer to whom the ownership of product is ChannelTransferred', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'ToStorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of ChannelTransfer ticket', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'ChannelTransfer', 'COLUMN', N'UserDefine05'
GO
