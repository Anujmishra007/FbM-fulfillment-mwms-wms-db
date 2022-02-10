CREATE TABLE [dbo].[DeviceProfile]
(
[DeviceProfileKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DeviceProfileKey] DEFAULT (''),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_IPAddress] DEFAULT (' '),
[PortNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_PortNo] DEFAULT (' '),
[DeviceType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DeviceType] DEFAULT ('0'),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DeviceID] DEFAULT ('0'),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_DevicePosition] DEFAULT ('0'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfile_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_DeviceProfile_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceProfileLogKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DeviceProfile_DeviceProfileLogKey] DEFAULT (''),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DeviceProfile_Priority] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_DeviceProfile_StorerKey] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogicalPOS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_LogicalPOS] DEFAULT (''),
[LogicalName] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DeviceProfile_LogicalName] DEFAULT (''),
[Col] [int] NOT NULL CONSTRAINT [DF_DeviceProfile_Col] DEFAULT ((0)),
[Row] [int] NOT NULL CONSTRAINT [DF_DeviceProfile_Row] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*********************************************************************************/    
/* Trigger:  ntrDeviceProfileUpdate                                              */  
/* Creation Date:                                                                */  
/* Copyright: IDS                                                                */  
/* Written by:                                                                   */  
/*                                                                               */  
/* Purpose:  Trigger point upon any Update on the DeviceProfile                  */  
/*                                                                               */  
/* Return Status:  None                                                          */  
/*                                                                               */  
/* Usage:                                                                        */  
/*                                                                               */  
/* Local Variables:                                                              */  
/*                                                                               */  
/* Called By: When records updated                                               */  
/*                                                                               */  
/* PVCS Version: 1.0                                                             */  
/*                                                                               */  
/* Version: 5.4                                                                  */  
/*                                                                               */  
/* Data Modifications:                                                           */  
/*                                                                               */  
/* Updates:                                                                      */  
/* Date         Author    Ver.  Purposes                                         */  
/* 28-Oct-2013  TLTING    1.1  Review Editdate column update                     */
/*********************************************************************************/    
  
CREATE TRIGGER [dbo].[ntrDeviceProfileUpdate]  
ON  [dbo].[DeviceProfile]  
FOR UPDATE  
AS  
BEGIN -- main  
   IF @@ROWCOUNT = 0    
   BEGIN    
      RETURN    
   END       
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err                int       -- Error number returned by stored procedure or this trigger  
         , @c_errmsg             nvarchar(250) -- Error message returned by stored procedure or this trigger  
         , @n_continue           int                   
         , @n_starttcnt          int       -- Holds the current transaction count  
         , @n_cnt                int  
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @n_cnt = 0  
  
   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4   
   END  
  
   IF (@n_continue = 1 or @n_continue = 2) AND NOT UPDATE(EditDate)  
   BEGIN  
     UPDATE DeviceProfile WITH (ROWLOCK)  
     SET DeviceProfile.EditWho = SUSER_SNAME(),  
         DeviceProfile.EditDate = GETDATE()  
     FROM DeviceProfile JOIN INSERTED ON DeviceProfile.DeviceProfileKey = INSERTED.DeviceProfileKey  
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
       IF @n_err <> 0  
       BEGIN  
          SELECT @n_continue = 3  
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 82202   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table DeviceProfile Failed. (ntrDeviceProfileDelete)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "  
       END  
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrDeviceProfileUpdate'  
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
END -- main  
GO
ALTER TABLE [dbo].[DeviceProfile] ADD CONSTRAINT [PK_DeviceProfile] PRIMARY KEY CLUSTERED ([DeviceProfileKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_DeviceProfile_Device] ON [dbo].[DeviceProfile] ([DeviceID], [DevicePosition]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DEVICEPROFILE_Loc] ON [dbo].[DeviceProfile] ([Loc]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DeviceProfile] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DeviceProfile] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DeviceProfile] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DeviceProfile] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cart matrix col setup', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'Col'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Link DevicePosition to location table', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Light logical name (easier to key-in, compare to hardware position)', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'LogicalName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Light logical position (for sorting)', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'LogicalPOS'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cart matrix row setup', 'SCHEMA', N'dbo', 'TABLE', N'DeviceProfile', 'COLUMN', N'Row'
GO
