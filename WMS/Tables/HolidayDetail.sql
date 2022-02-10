CREATE TABLE [dbo].[HolidayDetail]
(
[HolidayKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HolidayDate] [datetime] NOT NULL,
[HolidayDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [datetime] NULL,
[UserDefine05] [datetime] NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_HolidayDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_HolidayDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_HolidayDetail_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
    
  
/************************************************************************/  
/* Trigger: ntrHolidayDetailUpdate                                      */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  HolidayDetail Update Transaction                           */  
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
  
CREATE TRIGGER [dbo].[ntrHolidayDetailUpdate]  
ON  [dbo].[HolidayDetail] FOR UPDATE  
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
  UPDATE HolidayDetail with (ROWLOCK)
  SET EditDate = GETDATE(),  
      EditWho = SUSER_SNAME()  
  FROM HolidayDetail, INSERTED (NOLOCK)  
  WHERE HolidayDetail.HolidayKey  = INSERTED.HolidayKey  
  AND   HolidayDetail.HolidayDate = INSERTED.HolidayDate  
  
  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
  IF @n_err <> 0  
  BEGIN  
   SELECT @n_continue = 3  
   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
   SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table HolidayDetail. (ntrHolidayDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '  
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
  execute nsp_logerror @n_err, @c_errmsg, 'ntrHolidayDetailUpdate'  
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
ALTER TABLE [dbo].[HolidayDetail] ADD CONSTRAINT [PK_HolidayDetail] PRIMARY KEY CLUSTERED ([HolidayKey], [HolidayDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HolidayDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[HolidayDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[HolidayDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[HolidayDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Individual date that is a holiday', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'HolidayDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the holiday e.g. National Day or Christmas etc', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'HolidayDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Holiday.', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'HolidayKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine01', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine02', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine03', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine04', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'HDuserdefine05', 'SCHEMA', N'dbo', 'TABLE', N'HolidayDetail', 'COLUMN', N'UserDefine05'
GO
