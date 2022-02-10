CREATE TABLE [dbo].[IDS_LP_Driver]
(
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Linenumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_LP_Driver_Linenumber] DEFAULT (' '),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDS_LP_DRIVER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_LP_DRIVER_EditWho] DEFAULT (suser_sname()),
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IDS_LP_DRIVER_MBOLKEY] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrIDS_LP_DRIVERDelete                                      */
/* Creation Date: 20 Feb 2012                                           */
/* Copyright: IDS                                                       */
/* Written by: KHLim                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from IDS_LP_DRIVER                   */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date        Author   Ver  Purposes                                   */
/* 2019-08-22  Wan01    1.1  Fixed. MBOLkey Not insert to DELLOG        */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrIDS_LP_DRIVERDelete]
ON [dbo].[IDS_LP_Driver]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int,       -- Holds the number of rows affected by the DELETE statement that fired this trigger.
            @c_authority   NVARCHAR(1)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0
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
               ,@c_errmsg = 'ntrIDS_LP_DRIVERDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.IDS_LP_DRIVER_DELLOG 
               ( Loadkey,DriverCode, MBOLKey )              --(Wan01)
         SELECT  Loadkey,DriverCode, MBOLKey FROM DELETED   --(Wan01)

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table IDS_LP_DRIVER Failed. (ntrIDS_LP_DRIVERDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrIDS_LP_DRIVERDelete'
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Trigger: ntrIDS_LP_DRIVERUpdate                                    */  
/* Creation Date: 02-Dec-2015                                           */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Update IDS_LP_DRIVER.                                      */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrIDS_LP_DRIVERUpdate]  
ON  [dbo].[IDS_LP_Driver]   
FOR UPDATE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET ANSI_WARNINGS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF   
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2  ) AND NOT UPDATE(EditDate) 
   BEGIN  
      UPDATE IDS_LP_DRIVER  
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM IDS_LP_DRIVER, INSERTED  
       WHERE IDS_LP_DRIVER.Loadkey = INSERTED.Loadkey
         AND IDS_LP_DRIVER.DriverCode = INSERTED.DriverCode  

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table IDS_LP_DRIVER. (ntrIDS_LP_DRIVERUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(LTrim(RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  

   /* #INCLUDE <TRPU_2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrIDS_LP_DRIVERUpdate'  
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
ALTER TABLE [dbo].[IDS_LP_Driver] ADD CONSTRAINT [PK_IDS_LP_Driver] PRIMARY KEY CLUSTERED ([Loadkey], [DriverCode], [MBOLKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[IDS_LP_Driver] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_LP_Driver] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying driver.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_Driver', 'COLUMN', N'DriverCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_Driver', 'COLUMN', N'Loadkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MBOL Number', 'SCHEMA', N'dbo', 'TABLE', N'IDS_LP_Driver', 'COLUMN', N'MBOLKey'
GO
