CREATE TABLE [dbo].[OrderInfo]
(
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderInfo01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo01] DEFAULT (' '),
[OrderInfo02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo02] DEFAULT (' '),
[OrderInfo03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo03] DEFAULT (' '),
[OrderInfo04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo04] DEFAULT (' '),
[OrderInfo05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo05] DEFAULT (' '),
[OrderInfo06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo06] DEFAULT (' '),
[OrderInfo07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo07] DEFAULT (' '),
[OrderInfo08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo08] DEFAULT (' '),
[OrderInfo09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo09] DEFAULT (' '),
[OrderInfo10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_OrderInfo10] DEFAULT (' '),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_OrderInfo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_OrderInfo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EcomOrderId] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_EcomOrderId] DEFAULT (''),
[ReferenceId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_ReferenceId] DEFAULT (''),
[StoreName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_StoreName] DEFAULT (''),
[Platform] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_Platform] DEFAULT (''),
[InvoiceType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_InvoiceType] DEFAULT (''),
[PmtDate] [datetime] NULL,
[InsuredAmount] [float] NULL CONSTRAINT [DF_OrderInfo_InsuredAmount] DEFAULT ((0)),
[CarrierCharges] [float] NULL CONSTRAINT [DF_OrderInfo_CarrierCharges] DEFAULT ((0)),
[OtherCharges] [float] NULL CONSTRAINT [DF_OrderInfo_OtherCharges] DEFAULT ((0)),
[PayableAmount] [float] NULL CONSTRAINT [DF_OrderInfo_PayableAmount] DEFAULT ((0)),
[DeliveryMode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_DeliveryMode] DEFAULT ('LTL'),
[CarrierName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_CarrierName] DEFAULT (''),
[DeliveryCategory] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_DeliveryCategory] DEFAULT ('NORMAL'),
[Notes] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_Notes] DEFAULT (''),
[Notes2] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_Notes2] DEFAULT (''),
[OTM_OrderOwner] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERINFO_OTM_OrderOwner] DEFAULT (''),
[OTM_BillTo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERINFO_OTM_BillTo] DEFAULT (''),
[OTM_NotifyParty] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ORDERINFO_OTM_NotifyParty] DEFAULT (''),
[CourierTimeStamp] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OrderInfo_CourierTimeStamp] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrOrderInfoDelete                                          */
/* Creation Date: 2 Mar 2012                                            */
/* Copyright: IDS                                                       */
/* Written by: KHLim                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from OrderInfo                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author   Ver  Purposes                                  */
/* 07-Feb-2014  TLTING   1.1  Add ArchiveCop flag                       */ 
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrOrderInfoDelete]
ON [dbo].[OrderInfo]
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

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9') 
   BEGIN
	   SELECT @n_continue = 4
   END
   
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
               ,@c_errmsg = 'ntrOrderInfoDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.OrderInfo_DELLOG 
               ( OrderKey )
         SELECT  OrderKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table OrderInfo Failed. (ntrOrderInfoDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrOrderInfoDelete'
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
/* Trigger: ntrOrderInfoUpdate                                          */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  OrderInfo Update Transaction                               */  
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
/* 28-Oct-2013  TLTING   1.1  Review Editdate column update             */
/* 07-Feb-2014  TLTING   1.2  Add ArchiveCop flag                       */ 
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrOrderInfoUpdate]  
ON  [dbo].[OrderInfo] FOR UPDATE  
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

 IF UPDATE(TrafficCop)  
 BEGIN  
 SELECT @n_continue = 4   
 END  
 IF UPDATE(ArchiveCop)  
 BEGIN  
 SELECT @n_continue = 4   
 END 
   
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate) 
 BEGIN  
  UPDATE OrderInfo with (ROWLOCK)
  SET EditDate = GETDATE(),  
      EditWho = SUSER_SNAME()  
  FROM OrderInfo, INSERTED (NOLOCK)  
  WHERE OrderInfo.Orderkey = INSERTED.Orderkey  
  
  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
  IF @n_err <> 0  
  BEGIN  
   SELECT @n_continue = 3  
   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
   SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table OrderInfo. (ntrOrderInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '  
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
  execute nsp_logerror @n_err, @c_errmsg, 'ntrOrderInfoUpdate'  
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
ALTER TABLE [dbo].[OrderInfo] ADD CONSTRAINT [PK_OrderInfo] PRIMARY KEY CLUSTERED ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[OrderInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[OrderInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OrderInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OrderInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OrderInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'OrderInfo', 'COLUMN', N'OrderKey'
GO
