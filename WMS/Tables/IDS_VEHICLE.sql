CREATE TABLE [dbo].[IDS_VEHICLE]
(
[VehicleNumber] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleDescr] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL,
[Volume] [float] NULL,
[Method] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrierkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Agent] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_IDS_VEHICLE_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_VEHICLE_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_IDS_VEHICLE_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IDS_VEHICLE_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrIDS_VEHICLEDelete                                        */
/* Creation Date: 20 Feb 2012                                           */
/* Copyright: IDS                                                       */
/* Written by: KHLim                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from IDS_VEHICLE                     */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author   Ver  Purposes                                  */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrIDS_VEHICLEDelete]
ON [dbo].[IDS_VEHICLE]
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
               ,@c_errmsg = 'ntrIDS_VEHICLEDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.IDS_VEHICLE_DELLOG 
               ( VehicleNumber )
         SELECT  VehicleNumber FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table IDS_VEHICLE Failed. (ntrIDS_VEHICLEDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrIDS_VEHICLEDelete'
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
/* Trigger: ntrIDS_VEHICLEUpdate                                        */  
/* Creation Date: 20 Feb 2012                                           */  
/* Copyright: IDS                                                       */  
/* Written by: KHLim                                                    */  
/*                                                                      */  
/* Purpose:  Update IDS_VEHICLE.                                        */  
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
/* 28-Oct-2013  TLTING   1.1  Review Editdate column update             */
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrIDS_VEHICLEUpdate]  
ON  [dbo].[IDS_VEHICLE]   
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

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate) 
   BEGIN  
      UPDATE IDS_VEHICLE with (ROWLOCK) 
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM IDS_VEHICLE, INSERTED  
       WHERE IDS_VEHICLE.VehicleNumber = INSERTED.VehicleNumber

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table IDS_VEHICLE. (ntrIDS_VEHICLEUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrIDS_VEHICLEUpdate'  
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
ALTER TABLE [dbo].[IDS_VEHICLE] ADD CONSTRAINT [PK_IDS_VEHICLE] PRIMARY KEY CLUSTERED ([VehicleNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[IDS_VEHICLE] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the vehicles or transports details for automatic load planning calculation', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Carrier.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'Carrierkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the vehicle.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'VehicleDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying the vehicle.', 'SCHEMA', N'dbo', 'TABLE', N'IDS_VEHICLE', 'COLUMN', N'VehicleNumber'
GO
