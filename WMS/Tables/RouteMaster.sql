CREATE TABLE [dbo].[RouteMaster]
(
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TruckType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Volume] [float] NULL,
[Weight] [float] NULL,
[CarrierKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_RouteMaster_AddDate] DEFAULT (getdate()),
[ZipCodeFrom] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_ZipCodeFrom] DEFAULT (' '),
[ZipCodeTo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_ZipCodeTo] DEFAULT (' '),
[SelfDelivery] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HandledByWH] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoOfDrops] [int] NULL,
[TMS_Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMS_Interface] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_TMS_Interface] DEFAULT (' '),
[ScheduleKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_ScheduleKey] DEFAULT (' '),
[EditDate] [datetime] NULL CONSTRAINT [DF_RouteMaster_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RouteMaster_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*  8-Aug-2011  KHLim01    1.0   initial creation                */

CREATE TRIGGER [dbo].[ntrRouteMasterDelete]
ON [dbo].[RouteMaster]
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
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)
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
               ,@c_errmsg = 'ntrRouteMasterDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.RouteMaster_DELLOG ( Route )
         SELECT Route FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table RouteMaster Failed. (ntrRouteMasterDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRouteMasterDelete'
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
/* Trigger: ntrRouteMasterUpdate                                        */  
/* Creation Date: 18-Dec-2015                                           */  
/* Copyright: IDS                                                       */  
/* Written by:    JayLim                                                */  
/*                                                                      */  
/* Purpose:  Update RouteMaster                                         */  
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
  
CREATE TRIGGER [dbo].[ntrRouteMasterUpdate]  
ON  [dbo].[RouteMaster]   
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
      UPDATE RouteMaster 
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM RouteMaster, INSERTED  
       WHERE RouteMaster.Route = INSERTED.Route

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table RouteMaster. (ntrRouteMasterUpdate)' + ' ( '   
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRouetMasterUpdate'  
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
ALTER TABLE [dbo].[RouteMaster] ADD CONSTRAINT [PK_RouteMaster] PRIMARY KEY CLUSTERED ([Route]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[RouteMaster] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[RouteMaster] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RouteMaster] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RouteMaster] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RouteMaster] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Setup the available delivery routes. It is used in Order Processing', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the transporter', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'CarrierDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter code. Vendor which performs the transportation', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Descr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether the warehouse will be handling the deliveries for the particular route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'HandledByWH'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total number of drops the truck will perform for the route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'NoOfDrops'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the route', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TMS interface information - not used at the moment', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'ScheduleKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates this route does not have any drops and deliveries are done by the salesman', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'SelfDelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TMS interface information - not used at the moment', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'TMS_Interface'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TMS interface information - not used at the moment', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'TMS_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of truck with capacity', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'TruckType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The max volume in which the truck carries', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Volume'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The max weight in which the truck can carry', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The starting point post code', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'ZipCodeFrom'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The destination post code  - final drop', 'SCHEMA', N'dbo', 'TABLE', N'RouteMaster', 'COLUMN', N'ZipCodeTo'
GO
