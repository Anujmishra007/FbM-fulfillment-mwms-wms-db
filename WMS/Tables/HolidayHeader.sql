CREATE TABLE [dbo].[HolidayHeader]
(
[HolidayKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HolidayDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [datetime] NULL,
[UserDefine05] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayHeader_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_HolidayHeader_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayHeader_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_HolidayHeader_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
    
  
/************************************************************************/  
/* Trigger: ntrHolidayHeaderUpdate                                      */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  HolidayHeader Update Transaction                           */  
/*                                                                      */  
/* Input Parameters:                                                    */  
/*                                                                      */  
/* Output Parameters:                                                   */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Local Variables:                                                     */  
/*                                                                      */  
/* Called By: When update records                                       */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrHolidayHeaderUpdate]  
ON  [dbo].[HolidayHeader] FOR UPDATE  
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
   , @c_errmsg     nvarchar(250) -- Error message returned by stored procedure or this trigger  
   , @n_continue   int                   
   , @n_starttcnt  int       -- Holds the current transaction count  
   , @c_preprocess nvarchar(250) -- preprocess  
   , @c_pstprocess nvarchar(250) -- post process  
   , @n_cnt        int                    
  
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
   
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate) 
 BEGIN  
  UPDATE HolidayHeader with (ROWLOCK)
  SET EditDate = GETDATE(),  
      EditWho = SUSER_SNAME()  
  FROM HolidayHeader, INSERTED (NOLOCK)  
  WHERE HolidayHeader.HolidayKey  = INSERTED.HolidayKey
  
  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
  IF @n_err <> 0  
  BEGIN  
   SELECT @n_continue = 3  
   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
   SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table HolidayHeader. (ntrHolidayHeaderUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '  
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
  execute nsp_logerror @n_err, @c_errmsg, 'ntrHolidayHeaderUpdate'  
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
ALTER TABLE [dbo].[HolidayHeader] ADD CONSTRAINT [PK_HolidayHeader] PRIMARY KEY CLUSTERED ([HolidayKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HolidayHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HolidayHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HolidayHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HolidayHeader] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the holiday code e.g. Malaysia Holidays', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'HolidayDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the collection of holidays', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'HolidayKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine01', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine02', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine03', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine04', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HHuserdefine05', 'SCHEMA', N'dbo', 'TABLE', N'HolidayHeader', 'COLUMN', N'UserDefine05'
GO
