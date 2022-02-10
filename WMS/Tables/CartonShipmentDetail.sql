CREATE TABLE [dbo].[CartonShipmentDetail]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orderkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mbolkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Externorderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Buyerpo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UCCLabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonWeight] [float] NULL,
[DestinationZipCode] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassOfService] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingIdType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroundBarcodeString] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoutingCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASTRA_Barcode] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlannedServiceLevel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceTypeDescription] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialHandlingIndicators] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationAirportID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adddate] [datetime] NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Adddate] DEFAULT (getdate()),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Addwho] DEFAULT (suser_sname()),
[2dBarcode] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonCube] [float] NULL,
[FreightCharge] [float] NULL,
[InsCharge] [float] NULL,
[Editdate] [datetime] NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Editdate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CartonShipmentDetail_Editwho] DEFAULT (suser_sname()),
[PackageID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS_RoutingCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS_URCVersion] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrCartonShipmentDetailDelete                               */
/* Creation Date: 31 Jan 2012                                           */
/* Copyright: IDS                                                       */
/* Written by: KHLim                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from CartonShipmentDetail            */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author   Ver  Purposes                                  */
/*  1-Feb-2012  KHLim01       #230059 additional fields                 */
/* 13-Sep-2012  KHLim         Check ArchiveCop (KH01)                   */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrCartonShipmentDetailDelete]
ON [dbo].[CartonShipmentDetail]
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

   IF (SELECT count(*) FROM DELETED) =
      (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  --KH01
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
               ,@c_errmsg = 'ntrCartonShipmentDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.CartonShipmentDetail_DELLOG 
               ( RowRefSource, Storerkey, Orderkey, Externorderkey, CarrierCode, TrackingIDType )  -- KHLim01
         SELECT  RowRef,       Storerkey, Orderkey, Externorderkey, CarrierCode, TrackingIDType FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table CartonShipmentDetail Failed. (ntrCartonShipmentDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrCartonShipmentDetailDelete'
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
/* Trigger: ntrCartonShipmentDetailUpdate                               */  
/* Creation Date: 31 Jan 2012                                           */  
/* Copyright: IDS                                                       */  
/* Written by: KHLim                                                    */  
/*                                                                      */  
/* Purpose:  Update CartonShipmentDetail.                               */  
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
  
CREATE TRIGGER [dbo].[ntrCartonShipmentDetailUpdate]  
ON  [dbo].[CartonShipmentDetail]   
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
         , @c_errmsg Nvarchar(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess Nvarchar(250) -- preprocess  
         , @c_pstprocess Nvarchar(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN  
      UPDATE CartonShipmentDetail  with (ROWLOCK)
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM CartonShipmentDetail, INSERTED  
       WHERE CartonShipmentDetail.RowRef = INSERTED.RowRef

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(Nvarchar(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(Nvarchar(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table CartonShipmentDetail. (ntrCartonShipmentDetailUpdate)' + ' ( '   
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrCartonShipmentDetailUpdate'  
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
ALTER TABLE [dbo].[CartonShipmentDetail] ADD CONSTRAINT [PK__CartonShipmentDe__68667AF7] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CartonShipmentDetail_ExtrnOrd] ON [dbo].[CartonShipmentDetail] ([Externorderkey], [Storerkey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CartonShipmentDetail_OrdKeyLblNo] ON [dbo].[CartonShipmentDetail] ([Orderkey], [UCCLabelNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CartonShipmentDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'CartonShipmentDetail', 'COLUMN', N'Storerkey'
GO
