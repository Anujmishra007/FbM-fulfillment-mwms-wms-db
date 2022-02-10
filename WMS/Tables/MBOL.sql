CREATE TABLE [dbo].[MBOL]
(
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Status] DEFAULT ('0'),
[ExternMbolKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_ExternMbolKey] DEFAULT (' '),
[OriginCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_origincountry] DEFAULT (' '),
[DestinationCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_DestinationCountry] DEFAULT (' '),
[VesselQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_VesselQualifier] DEFAULT ('VM'),
[Vessel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_Vessel] DEFAULT (' '),
[PlaceOfLoadingQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfLoadingQualifier] DEFAULT (' '),
[PlaceOfLoading] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfLoading] DEFAULT (' '),
[PlaceOfdischargeQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfdischargeQualifier] DEFAULT (' '),
[PlaceOfDischarge] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfDischarge] DEFAULT (' '),
[PlaceOfdeliveryQualifier] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfdeliveryQualifier] DEFAULT (' '),
[PlaceOfdelivery] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_PlaceOfdelivery] DEFAULT (' '),
[TransMethod] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_TransMethod] DEFAULT (' '),
[VoyageNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_VoyageNumber] DEFAULT (' '),
[DepartureDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_DepartureDate] DEFAULT (getdate()),
[ArrivalDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_ArrivalDate] DEFAULT (getdate()),
[ArrivalDateFinalDestination] [datetime] NOT NULL CONSTRAINT [DF_MBOL_ArrivalDateFinalDestination] DEFAULT (getdate()),
[BookingReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_BookingReference] DEFAULT (' '),
[OtherReference] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_OtherReference] DEFAULT (' '),
[CarrierKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_CarrierKey] DEFAULT (' '),
[Carrieragent] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_CarrierAgent] DEFAULT (' '),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DRIVERName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadingDate] [datetime] NULL,
[CustomerReceivedDate] [datetime] NULL,
[Remarks] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_REMARKS] DEFAULT (' '),
[TotalInvoiceValue] [float] NULL CONSTRAINT [DF_MBOL_TotalInvoiceValue] DEFAULT (' '),
[GrossWeight] [float] NULL CONSTRAINT [DF_MBOL_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_MBOL_CAPACITY] DEFAULT ((0)),
[InvoiceAmount] [float] NULL CONSTRAINT [DF_MBOL_INVOICEAMOUNT] DEFAULT ((0)),
[Weight] [float] NULL CONSTRAINT [DF_MBOL_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_MBOL_Cube] DEFAULT ((0)),
[CustCnt] [int] NULL CONSTRAINT [DF_MBOL_CustCnt] DEFAULT ((0)),
[PalletCnt] [int] NULL CONSTRAINT [DF_MBOL_PalletCnt] DEFAULT ((0)),
[CaseCnt] [int] NULL CONSTRAINT [DF_MBOL_CaseCnt] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Facility] DEFAULT ('F1'),
[COD_Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_COD_Status] DEFAULT ('0'),
[DepotStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_DepotStatus] DEFAULT ('0'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_UserDefine10] DEFAULT (' '),
[ShipCounter] [int] NULL CONSTRAINT [DF_MBOL_ShipCounter] DEFAULT ((0)),
[CTNTYPE] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoofContainer] [int] NULL,
[CTNTYPE1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNTYPE10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACKTYPE10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTNCNT1] [int] NULL,
[CTNCNT2] [int] NULL,
[CTNCNT3] [int] NULL,
[CTNCNT4] [int] NULL,
[CTNCNT5] [int] NULL,
[CTNCNT6] [int] NULL,
[CTNCNT7] [int] NULL,
[CTNCNT8] [int] NULL,
[CTNCNT9] [int] NULL,
[CTNCNT10] [int] NULL,
[CTNQTY1] [int] NULL,
[CTNQTY2] [int] NULL,
[CTNQTY3] [int] NULL,
[CTNQTY4] [int] NULL,
[CTNQTY5] [int] NULL,
[CTNQTY6] [int] NULL,
[CTNQTY7] [int] NULL,
[CTNQTY8] [int] NULL,
[CTNQTY9] [int] NULL,
[CTNQTY10] [int] NULL,
[NoOfMasterCtn] [int] NULL,
[NoOfPrepacks] [int] NULL,
[NoofReshippableCarton] [int] NULL,
[NoofCartonPacked] [int] NULL,
[NoofIDSCarton] [int] NULL,
[NoofCustomerCarton] [int] NULL,
[NoofPallets] [int] NULL,
[CartonWeight] [float] NOT NULL CONSTRAINT [DF_MBOL_CartonWeight] DEFAULT ((0)),
[WeightUnit] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonCube] [float] NOT NULL CONSTRAINT [DF_MBOL_CartonCube] DEFAULT ((0)),
[CubeUnit] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeAccountCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ConsigneeAccountCode] DEFAULT (' '),
[ContainerNo] [nvarchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ContainerNo] DEFAULT (' '),
[Equipment] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Equipment] DEFAULT (' '),
[ShipperAccountCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ShipperAccountCode] DEFAULT (' '),
[NotifyAccountCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_NotifyAccountCode] DEFAULT (' '),
[SealNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_SealNo] DEFAULT (' '),
[GIS_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_GIS_ControlNo] DEFAULT (''),
[Cust_ISA_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Cust_ISA_ControlNo] DEFAULT (''),
[Cust_GIS_ControlNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_Cust_GIS_ControlNo] DEFAULT (''),
[GIS_ProcessTime] [datetime] NULL,
[Cust_EDIAckTime] [datetime] NULL,
[CBOLKey] [bigint] NULL,
[CBOLLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDate] [datetime] NOT NULL CONSTRAINT [DF_MBOL_ShipDate] DEFAULT (getdate()),
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOL_FinalizeFlag] DEFAULT ('N'),
[ValidatedFlag] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_ValidatedFlag] DEFAULT ('N'),
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OTMShipmentID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOL_OTMShipmentID] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/***************************************************************************/  
/* Trigger:  ntrMbolHeaderAdd                                              */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:  Trigger point upon any insert MBOL                            */  
/*                                                                         */  
/* Input Parameters:                                                       */  
/*                                                                         */  
/* Output Parameters:  None                                                */  
/*                                                                         */  
/* Return Status:  None                                                    */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/* Local Variables:                                                        */  
/*                                                                         */  
/* Called By: When records Inserted                                        */  
/*                                                                         */  
/* PVCS Version: 1.1                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date         Author Ver.  Purposes                                      */  
/* 17-Mar-2009  TLTING       Change user_name() to SUSER_SNAME()           */
/***************************************************************************/  

CREATE TRIGGER [dbo].[ntrMbolHeaderAdd]
 ON  [dbo].[MBOL]
 FOR INSERT
 AS
 BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
 SET CONCAT_NULL_YIELDS_NULL OFF
  	
 DECLARE
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger
 ,         @n_err2 int              -- For Additional Error Detection
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 ,         @n_continue int                 
 ,         @n_starttcnt int                -- Holds the current transaction count
 ,         @c_preprocess NVARCHAR(250)         -- preprocess
 ,         @c_pstprocess NVARCHAR(250)         -- post process
 ,         @n_cnt int                  
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRMBOA1.SQL> */     
 -- Added By SHONG 30-Apr-2003
 -- To allow records insert from Archive DB
 IF @n_continue=1 or @n_continue=2
 BEGIN
    IF EXISTS (SELECT * FROM INSERTED WHERE ArchiveCop = "9")
    BEGIN
      SELECT @n_continue = 4
    END
 END

 IF @n_continue=1 or @n_continue=2
 BEGIN
    IF EXISTS (SELECT * FROM INSERTED WHERE Status = "9")
    BEGIN
       SELECT @n_continue = 3
       SELECT @n_err=72602
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Bad MBOL.Status. (nspMbolHeaderAdd)"
    END
 END
 -- Commented BY SHONG on 12-Jun-2003
 -- Double work, this default value already cater by Table Default Constrains
 /*
 IF @n_continue=1 or @n_continue=2
 BEGIN
    UPDATE MBOL
    SET TrafficCop = NULL,
        AddDate = GETDATE(),
        AddWho = SUSER_SNAME(),
        EditDate = GETDATE(),
        EditWho = SUSER_SNAME()
    FROM MBOL, INSERTED
    WHERE MBOL.MBOLKey = INSERTED.MBOLKey
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table MBOL. (nspMbolHeaderAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
 */
 /* #INCLUDE <TRMBOHA2.SQL> */
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrMbolHeaderAdd"
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
/* Trigger: ntrMbolHeaderDelete                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:   MBOL Header Delete Transaction                            */
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
/* Called By: When records delete                                       */
/*                                                                      */
/* PVCS Version: 1.13                                                   */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Purposes                                        */
/*  9-Jun-2011  KHLim01   1.1   Insert Delete log                       */
/* 14-Jul-2011  KHLim02   1.2   GetRight for Delete log                 */
/* 22-May-2012  TLTING01  1.3   Data integrity - insert dellog 4        */
/*                               status < '9'                           */
/* 12-Sep-2012  SHONG   1.9   Prevent Splitted Order MBOL Accidentally  */
/*                            Deleted by someone SOS#256080             */ 
/************************************************************************/


CREATE TRIGGER [dbo].[ntrMbolHeaderDelete]
 ON [dbo].[MBOL]
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

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority        NVARCHAR(1)  -- KHLim02
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      /* #INCLUDE <TRMBOHD1.SQL> */  

 if (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 select @n_continue = 4
 END
       
 -- TLTING01
 IF EXISTS ( SELECT 1 FROM DELETED WHERE [STATUS] < '9' )
 BEGIN
  -- Start (KHLim01)
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
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
               ,@c_errmsg = 'ntrMBOLDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.MBOL_DELLOG ( MbolKey )
         SELECT MbolKey FROM DELETED
         WHERE [STATUS] < '9'
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ORDERS Failed. (ntrMBOLDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01)
 END
             
 IF @n_continue=1 OR @n_continue=2
 BEGIN
     IF EXISTS (SELECT 1 FROM DELETED WHERE STATUS = '9')
     BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 72702
         SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                ": DELETE rejected. MBOL.Status = 'Shipped'. (ntrMbolHeaderDelete)"
     END
 END
 
 IF @n_continue=1 OR @n_continue=2
 BEGIN
     DELETE MBOLDetail
     FROM   MBOLDETAIL
           ,DELETED
     WHERE  MBOLDETAIL.MBOLKey = DELETED.MBOLKey
     
     SELECT @n_err = @@ERROR
           ,@n_cnt = @@ROWCOUNT
     
     IF @n_err<>0
     BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
               ,@n_err = 72701 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                ": Delete Trigger On Table MBOLDETAIL Failed. (ntrMbolHeaderDelete)" 
               +" ( "+" SQLSvr MESSAGE="+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) 
               +" ) "
     END
 END

 -- Added By SHONG on 12-Sep-2012, to Prevent Splitted Order MBOL Accidentally Deleted by someone
 IF @n_Continue = 1 OR @n_Continue = 2  
 BEGIN  
    IF EXISTS(SELECT 1 FROM RDT.RDTScanToTruck STT WITH (NOLOCK) 
              JOIN DELETED DEL ON STT.MbolKey = DEL.MBOLKey AND STT.Status = '9' 
              JOIN MBOLDETAIL MD WITH (NOLOCK) ON MD.MBOLKey = DEL.MBOLKey 
              JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = MD.OrderKey AND OD.UserDefine10 <> '' AND OD.UserDefine10 IS NOT NULL)
    BEGIN
       SELECT @n_Continue = 3  
       SELECT @n_err = 72703 
       SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': RDTScanToTruck.Status = 9. DELETE rejected. (ntrMBOLDetailDelete)'  
    END 
 END 

 /* #INCLUDE <TRMBOHD2.SQL> */
 IF @n_continue=3 -- Error Occured - Process And Return
 BEGIN
     IF @@TRANCOUNT=1
     AND @@TRANCOUNT>=@n_starttcnt
     BEGIN
         ROLLBACK TRAN
     END
     ELSE
     BEGIN
         WHILE @@TRANCOUNT>@n_starttcnt
         BEGIN
             COMMIT TRAN
         END
     END
     EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrMbolHeaderDelete"
     RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
     RETURN
 END
 ELSE
 BEGIN
     WHILE @@TRANCOUNT>@n_starttcnt
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
/*********************************************************************************/
/* Trigger:      ntrMBOLHeaderUpdate                                             */
/* Creation Date:                                                                */
/* Copyright: IDS                                                                */
/* Written by:                                                                   */
/*                                                                               */
/* Purpose:  Trigger point upon any Update on the MBOL                           */
/*                                                                               */
/* Return Status:  None                                                          */
/*                                                                               */
/* Usage:                                                                        */
/*                                                                               */
/* Local Variables:                                                              */
/*                                                                               */
/* Called By: When records updated                                               */
/*                                                                               */
/* PVCS Version: 1.5                                                             */
/*                                                                               */
/* Version: 7.0                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author    Ver.  Purposes                                         */
/* 04-Feb-2005  YokeBeen  1.0   Changed the NSCLOG.tablename FROM                */
/*                              'NIKEREGDSP' to 'NIKEREGDSW' for Pack            */
/*                              the NSC transaction on MBOL                      */
/*                              - (YokeBeen01)                                   */
/* 01-Apr-2005  Shong     1.0   Change EffectiveDate to Current Date             */
/*                              during  Updating.                                */
/* 12-Apr-2005  June      1.0   SOS34322 - bug fixes Constraints                 */
/*                              violation of PK_POD due to same order            */
/*                              with diff Loadkey appear more than one           */
/*                              time in MBOLDetail                               */
/* 30-Jun-2005  MaryVong  1.0   IDSSG CV - Auto populate receipt header          */
/*                              for ordertype 'EO' - Exchange Return             */
/*                              (SOS37009)                                       */
/* 17-Aug-2005  Shong     1.0   Convert SELECT MIN to Cursor Loop                */
/* 24-Aug-2005  June      1.0   SOS39812 - IDSPH ULP v54 bug fixed               */
/* 14-Nov-2005  June      1.0   SOS40271 - Configkey POD by Storer level         */
/* 21-Nov-2005  MaryVong  1.0   SOS41530 Restrict insert TransmitLog             */
/*                              applied only when configkey 'ULPITF'             */
/*                              turn on, so that other processes are             */
/*                              enabled for other storers, eg. KCPI with         */
/*                              'ULPProcess' turn on                             */
/* 12-Jan-2006  MaryVong  1.0   Add Storerkey in case different storers          */
/*                              using the same externorderkey                    */
/* 20-Feb-2006  Vicky     1.0   SOS46312 - Insert Ship confrim records           */
/*                              to Transmitlog3 table when 'ULPProcess'          */
/*                              Configkey is turn on                             */
/* 27-Oct-2006  June      1.0   Add Storerkey in POD table.                      */
/* 17-Jan-2007  June      1.0   SOS66030 - Remove NZSHIPCONF                     */
/* 17-Jul-2007  June      1.0   SOS39706 - IDSPH ULP v54 bug fixed.              */
/*                              (Original fixed at 22-Aug-2005. Conso            */
/*                              version FROM PVCS at 17-Jul-2007)                */
/* 13-Feb-2008  June      1.0   SOS95698 - Add SpecialHandling in POD            */
/*                              table                                            */
/* 27-Aug-2008  Shong     1.0   SOS#114620, Type 2 Orders ShipFlag not           */
/*                              updated                                          */
/* 28-Aug-2008  TLTING    1.0   SOS39706 - PH Ask for un remark                  */
/*                              (tlting01)                                       */
/* 17-Jul-2007  June      1.0   SOS39706 - IDSPH ULP v54 bug fixed.              */
/* 22-Sep-2008  Shong     1.1   SOS117003 For Orders.UderDefine08 = 2,           */
/*                              Loadkey is blank                                 */
/* 06-Nov-2008  YTWAN     1.2   SOS#120983  If Error then return                 */
/* 13-Mar-2009  YokeBeen  1.3   SOS#130509 - Remark the TrafficCop SET           */
/*                              during Loadplan header update.                   */
/*                              - (YokeBeen02)                                   */
/* 19-Jan-2010  TLTING    1.4   SOS#159536 - missing SET @n_continue=3           */
/*                              (tlting02)                                       */
/* 03-Aug-2009  GTGOH     1.5   SOS#141842 - SMSPOD                              */
/* 08-Mar-2010  GTGOH     1.6   SOS#141842 - Add in filter by facility           */
/*                              for ConfigKey = 'SMSPOD' (GOH02)                 */
/* 24-Mar-2010  KC        1.7   SOS#160522 - create backorder (KC01)             */
/* 24-Mar-2010  YokeBeen  1.8   Modified StorerConfig.ConfigKey="MBOLLOG"        */
/*                              as Generic trigger point - (YokeBeen02)          */
/* 24-Mar-2010  TLTING    1.8   Add Begin End (tlting03)                         */
/* 24-May-2010  NJOW01    1.9   168916 - Sum total carton FROM mboldetail        */
/*                              depend on userdefine09                           */
/* 28-Jul-2010  James     2.0   If config 'MBOLSHIPCLOSETOTE' turned on then     */
/*                              update DropID.Status = '9' (james01)             */
/* 30-Jul-2010  Shong     2.1   'MBOLSHIPCLOSETOTE' Should not checking Pack     */
/*                              Status (Shong01)                                 */
/* 12-Oct-2010  James     2.2   Only update dropid to '9' for Store Only(james02)*/
/* 26-Jan-2011  MCTang    2.3   FBR#191841 - Added new trigger point for         */
/*                              POSM interface with Configkey =                  */
/*                              "VMBOLLOG". (MC01)                               */
/* 04-Aug-2010  NJOW02    2.4   182082 - Update editdate follow facility         */
/*                              time zone.                                       */
/* 11-Feb-2011  NJOW03    2.5   201915 - Update container status when mbol ship  */
/* 06-Dec-2011  NJOW04    2.6   Fix error handling for AutoCreateASN             */
/* 08-Dec-2011  TLTING04  1.11  SOS231886 StorerConfig for X POD Actual Develiry */
/*                              Date                                             */
/* 13-Mar-2012  MCTang    1.112 FBR#237562 - Added new trigger point for         */
/*                              "MBOL2LOG" (MC02)                                */
/* 20-Jul-2011  YTWan     1.12  Call PopulateToASN SP if SO not exists in        */
/*                              Transmitlog.(Wan01)                              */
/* 23 May 2012  TLTING05  1.2   DM integrity - add update editdate B4            */
/*                              TrafficCop for status < '9'                      */
/* 01 Jun 2012  TLTING06  1.3   Add ShipDate                                     */
/* 29 Jun 2012  ChewKP    1.4   Change of ShipDate Update Sequence (ChewKP01)    */
/* 06-Sep-2012  KHLim     1.16  Move up ArchiveCop (KH01)                        */
/* 07-Nov-2012  KHLim     1.17  DM integrity - Update EditDate (KH02)            */
/*********************************************************************************/
/* UNICODE Version                                                               */
/******************                                                              */
/* 13-Dec-2012  YokeBeen  1.2   Added new Generic trigger point StorerConfig     */
/*                              ConfigKey = "XDOCKLOG" - (YokeBeen03)            */
/* 28-Oct-2013  TLTING    1.18  Review Editdate column update                    */
/* 21-Nov-2013  TLTING    1.19  Review Editdate and Shipdate column update       */
/* 15-Apr-2014  TLTING    2.0   SQL2012                                          */
/* 17-Jul-2014  Chee      2.1   SOS#314938 Add Sub SP to create POD (Chee01)     */
/* 05-Feb-2014  TLTING    2.2   Performance Tune- Add index temp #table          */
/* 15-Jul-2016  MCTang    2.3   Enhance Generaic Trigger Interface (MC03)        */
/* 29-Aug-2016  MCTang    2.3   Enhance OTMLOG Generaic Trigger Interface (MC04) */
/* 20-Sep-2016  TLTING    2.4   Change SetROWCOUNT 1 to TOP 1                    */
/* 30-NOV-2017  JYHBIN    2.5   INC0060084 Added storerkey                       */
/* 29-JAN-2018  Wan02     1.5   WMS-3662 - Add Externloadkey to WMS POD module   */
/* 09-FEB-2018  CHEEMUN   2.6   INC0128904- LEFT JOIN Loadplan                   */
/* 12-NOV-2018  NJOW05    2.7   Fix - Convert ITS value FROM NULL to empty       */
/* 12-NOV-2018  Leong     2.8   Include MBOLKey (L01).                           */
/* 28-Jan-2019  TLTING_ext 2.9  enlarge externorderkey field length              */
/* 15-Feb-2019  MCTang    3.0   Remove Rowcount check (MC05)                     */
/* 23-Jul-2020  TLTING07  3.1   WMS-14128 Mbol status update Lockdown            */
/*********************************************************************************/

/********************************************************************************************************
   Mohit
   We should put the required data FROM each table into temp. tables, so that we don't have to refer these
   tables again and again. As there are more than million rows in some tables and if this triggers runs for
   100 times a day then it will create heavy overhead on DISK I/O.

   So every time we can populate the temp. tables and then play with these tables for the lifetime of this
   trigger

   Right now we just just do this for [MBOLDetail] and [Orders] table
**********************************************************************************************************/

CREATE   TRIGGER [dbo].[ntrMBOLHeaderUpdate]
ON  [dbo].[MBOL]
FOR UPDATE
-- SOS27626 (ML) 14/10/04    Nuance Outbound interface - Change to use Trnasmitlog3
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

   DECLARE @b_debug int
   SELECT @b_debug = 0

   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err                int       -- Error number returned by stored procedure OR this trigger
         , @n_err2               int       -- For Additional Error Detection
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
         , @n_continue           int
         , @n_starttcnt          int       -- Holds the current transaction count
         , @c_preprocess         NVARCHAR(250) -- preprocess
         , @c_pstprocess         NVARCHAR(250) -- post process
         , @n_cnt                int
         , @c_facility           NVARCHAR(5)
         , @c_OWITF              NVARCHAR(1)
         , @c_realtmship         NVARCHAR(1)
         , @c_authority          NVARCHAR(10) -- (Chee01)
         , @c_OrderKeyShip       NVARCHAR(10)
         , @c_asn                NVARCHAR(1)  -- Added By Vicky
         , @c_ulpitf             NVARCHAR(1)  -- Added By Vicky
         , @c_externorderkey     NVARCHAR(50) --tlting_ext  -- Added By Vicky
         , @c_lastload           NVARCHAR(1)  -- Added By Vicky
         , @c_short              char (10)
         , @c_trmlogkey          NVARCHAR(10)
         , @c_NIKEREGITF         NVARCHAR(1)  -- Added by YokeBeen (SOS#15350/15353)
         , @c_LoadKey            NVARCHAR(10)
         , @c_OrdIssued          NVARCHAR(1)
         , @c_LongConfig         NVARCHAR(250)
         , @c_NZShort            char (10)      -- Added by MaryVong (NZMM - FBR18999 Shipment Confirmation Export)
         , @c_OrdGroup           NVARCHAR(10)   -- Added by SHONG for Unilever Taiwan
         , @c_ispProc            NVARCHAR(30)   -- SP for AutoCreateASN ordertype
         , @n_PickDetailQty      int
         , @c_code               NVARCHAR(30)   -- SOS#141842
         , @c_smscounter         NVARCHAR(10)   -- SOS#141842
         , @SMSPODConfig         NVARCHAR(10)   -- SOS#141842
         , @c_SMSRefKey          NVARCHAR(8)    -- SOS#141842
         , @n_PickedQty          INT
         , @n_PackedQty          INT
         , @c_PickSlipNO         NVARCHAR(10)
         , @n_facilitytimezone   int --NJOW02
         , @d_editdate           datetime --NJOW02
         , @c_SQL                NVARCHAR(MAX)  -- (Chee01)
         , @c_SQLParm            NVARCHAR(MAX)  -- (Chee01)
         , @c_MBOLKeyShipped     NVARCHAR(10)   -- (L01)
         , @c_MarkMBOLLockdown   NVARCHAR = '0'    -- (L01)

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)      --KH01
   BEGIN
      SELECT @n_continue = 4
   END

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate) --KH01
   BEGIN
      UPDATE MBOL WITH (ROWLOCK)
         SET EditDate      = GETDATE(),
             EditWho       = SUSER_SNAME(),
             EffectiveDate = ( case when MBOL.Status < '9' then GETDATE() ELSE MBOL.EffectiveDate  END ),
             Trafficcop    = NULL
        FROM MBOL
        JOIN INSERTED ON (MBOL.MBOLKey = INSERTED.MBOLKey)

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72808
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': Update Failed On Table MBOL. (ntrMBOLHeaderUpdate)'
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END

   DECLARE @b_ColumnsUpdated VARBINARY(1000)       --MC03
   SET @b_ColumnsUpdated = COLUMNS_UPDATED()       --MC03

   IF EXISTS(SELECT * FROM DELETED WHERE Status = '9') AND UPDATE(TransMethod)
   BEGIN
      SELECT @n_continue = 4
   END

   DECLARE @c_PickDetailKey NVARCHAR(10), @c_PickDetailKeyship NVARCHAR(10)

      /* #INCLUDE <TRMBOHU1.SQL> */
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF @b_debug = 1
      BEGIN
         SELECT 'Reject UPDATE when MBOL.Status already ''SHIPPED'''
      END
      IF EXISTS(SELECT * FROM DELETED WHERE Status = '9')
      BEGIN
         SET @c_MBOLKeyShipped = '' --(L01)
         SELECT TOP 1 @c_MBOLKeyShipped = MBOLKey FROM DELETED WHERE Status = '9'

         SELECT @n_continue=3
         SELECT @n_err=72800
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': UPDATE Rejected. MBOL.Status = ''SHIPPED'', MBOLKey = ' + ISNULL(RTRIM(@c_MBOLKeyShipped),'') + '.(ntrMBOLHeaderUpdate)'
      END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE @c_ConfigKey  NVARCHAR(30)

      --Mohit We can create a permanent table for [#StorerCfg] and we can also create view with the
      --following conditions so that at the execution time it will just refer to one object directly and it will be
      --much smaller because of in-built filter
      --Mohit Create base tables
      --MBOLDetail
      --ORDERS

      --mohit We can remove the orders join here, please check
      CREATE TABLE #t_MBOLDetail (
         MbolKey         NVARCHAR(10),
         MbolLineNumber  NVARCHAR(5),
         ContainerKey    NVARCHAR(20),
         OrderKey        NVARCHAR(10),
         LoadKey         NVARCHAR(10),
         UserDefine01    NVARCHAR(20),
         StorerKey       NVARCHAR(10),
         Facility        NVARCHAR(5),
         ITS             NVARCHAR(10)
      )

      INSERT INTO #t_MBOLDetail
      SELECT m.MbolKey,
             m.MbolLineNumber,
             ISNULL(m.ContainerKey,'') AS ContainerKey,
             m.OrderKey,
             ISNULL(O.LoadKey,'') AS LoadKey,
             ISNULL(M.UserDefine01,'') AS UserDefine01,
             O.StorerKey,
             O.Facility,
             ISNULL(M.ITS,'')  --NJOW05
      FROM   INSERTED I
      JOIN   MBOLDetail M WITH (NOLOCK) ON (M.MBOLKey = I.MBOLKey)
      JOIN   ORDERS O WITH (NOLOCK) ON (O.OrderKey = M.OrderKey)

      -- tlting
      CREATE INDEX IX_tt_MBOLDetail_key1 ON #t_MBOLDetail (MBOLKey, MbolLineNumber)
      CREATE INDEX IX_tt_MBOLDetail_key2 ON #t_MBOLDetail (MBOLKey, OrderKey)

      --mohit we can remove the MBOLDetail join here, please check
      -- Start : SOS34322
      -- SELECT O.* into #t_Orders
        SELECT DISTINCT O.OrderKey
              ,O.Storerkey
              ,O.ExternOrderKey
              ,O.OrderDate
              ,O.DeliveryDate
              ,O.Priority
              ,O.ConsigneeKey
              ,O.C_contact1
              ,O.C_contact2
              ,O.C_Company
              ,O.C_Address1
              ,O.C_Address2
              ,O.C_Address3
              ,O.C_Address4
              ,O.C_City
              ,O.C_State
              ,O.C_Zip
              ,O.C_Country
              ,O.C_ISOCntryCode
              ,O.C_Phone1
              ,O.C_Phone2
              ,O.C_Fax1
              ,O.C_Fax2
              ,O.C_vat
              ,O.BuyerPO
              ,O.BillToKey
              ,O.B_contact1
              ,O.B_Contact2
              ,O.B_Company
              ,O.B_Address1
              ,O.B_Address2
              ,O.B_Address3
              ,O.B_Address4
              ,O.B_City
              ,O.B_State
              ,O.B_Zip
              ,O.B_Country
              ,O.B_ISOCntryCode
              ,O.B_Phone1
              ,O.B_Phone2
              ,O.B_Fax1
              ,O.B_Fax2
              ,O.B_Vat
              ,O.IncoTerm
              ,O.PmtTerm
              ,O.OpenQty
              ,O.Status
              ,O.DischargePlace
              ,O.DeliveryPlace
              ,O.IntermodalVehicle
              ,O.CountryOfOrigin
              ,O.CountryDestination
              ,O.UpdateSource
              ,O.Type
              ,O.OrderGroup
              ,O.Door
              ,O.Route
              ,O.Stop
              ,Notes = CONVERT(CHAR(256) ,O.Notes)
              ,O.EffectiveDate
              ,O.ContainerType
              ,O.ContainerQty
              ,O.BilledContainerQty
              ,O.SOStatus
              ,O.MBOLKey
              ,O.InvoiceNo
              ,O.InvoiceAmount
              ,O.Salesman
              ,O.GrossWeight
              ,O.Capacity
              ,O.PrintFlag
              ,ISNULL(O.LoadKey,'') AS LoadKey
              ,O.Rdd
              ,O.SequenceNo
              ,O.Rds
              ,O.SectionKey
              ,O.Facility
              ,O.PrintDocDate
              ,O.LabelPrice
              ,O.POKey
              ,O.ExternPOKey
              ,O.XDockFlag
              ,O.UserDefine01
              ,O.UserDefine02
              ,O.UserDefine03
              ,O.UserDefine04
              ,O.UserDefine05
              ,O.UserDefine06
              ,O.UserDefine07
              ,O.UserDefine08
              ,O.UserDefine09
              ,O.UserDefine10
              ,O.Issued
              ,O.DeliveryNote
              ,O.PODCust
              ,O.PODArrive
              ,O.PODReject
              ,O.PODUser
              ,O.xdockpokey
              ,O.SpecialHandling
        INTO #t_Orders
        FROM  INSERTED I
        JOIN #t_MBOLDetail M ON  (M.MBOLKey=I.MBOLKey)
        JOIN ORDERS O WITH (NOLOCK) ON  (O.OrderKey=M.OrderKey)

      -- tlting
      CREATE INDEX IX_tt_Orders_key1 ON #t_Orders (OrderKey)
      CREATE INDEX IX_tt_Orders_key2 ON #t_Orders (MBOLKey, OrderKey)

      --mohit we can remove the MBOLDetail join here, please check
      CREATE TABLE #t_OrderDetail (
       OrderKey        NVARCHAR(10),
       OrderLineNumber NVARCHAR(5)
      )

      INSERT INTO #t_OrderDetail   (
       OrderKey,
       OrderLineNumber )
      SELECT O.OrderKey, O.OrderLineNumber
      FROM   INSERTED I
      JOIN   #t_MBOLDetail M ON (M.MBOLKey = I.MBOLKey)
      JOIN   OrderDetail O WITH (NOLOCK) ON (O.OrderKey = M.OrderKey)

      CREATE INDEX IX_tt_OrderDetail_key1 ON #t_OrderDetail (OrderKey, OrderLineNumber)

      CREATE TABLE #StorerCfg (
       StorerKey NVARCHAR(15),
       ConfigKey NVARCHAR(30),
         Facility  NVARCHAR(5) )

      INSERT INTO #StorerCfg
      (
       StorerKey,
       ConfigKey,
       Facility
      )
      SELECT DISTINCT O.StorerKey, S.ConfigKey, ISNULL(S.Facility,'') AS Facility
      FROM   INSERTED I
      JOIN   #t_MBOLDetail M ON (M.MBOLKey = I.MBOLKey)
      JOIN   #t_Orders O ON (O.OrderKey = M.OrderKey)
      JOIN   StorerConfig S WITH (NOLOCK) ON (S.StorerKey = O.StorerKey)
      WHERE  I.Status = '9'
      AND    S.sValue = '1'


   END

   -- SOS 6752
   -- prevent users FROM shipping MBOL IF the loadplan is not finalized (HK)
   -- wally 22.july.2002
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS (SELECT 1
                 FROM #t_MBOLDetail md
                 JOIN INSERTED i ON (md.mbolkey = i.mbolkey)
                 JOIN loadplan lp WITH (NOLOCK) ON (md.LoadKey = lp.LoadKey and lp.finalizeflag = 'N')
                 JOIN #t_Orders o ON (md.orderkey = o.orderkey)
                 JOIN #StorerCfg sc ON (o.storerkey = sc.storerkey and sc.configkey = 'OWITF')
                 JOIN #StorerCfg sc1 ON (o.storerkey = sc1.storerkey and sc1.configkey = 'FinalizeLP') )
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72801
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': Cannot Ship MBOL. LoadPlan Not Finalized. (ntrMBOLHeaderUpdate)'
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END -- @n_continue = 1 OR @n_continue = 2

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      --SOS#201915 - Container Manifest to accept Order No
      IF EXISTS (SELECT 1 FROM #StorerCfg  WHERE configkey = 'ContainerManifestByOrderKey')
      BEGIN
         --SELECT DISTINCT o.Mbolkey
         --INTO #t_mbol
         --FROM #t_Orders o
         --JOIN Inserted i ON o.mbolkey = i.mbolkey
         --JOIN #StorerCfg  c ON o.storerkey = c.storerkey
         --WHERE i.status = '9'
         --AND c.configkey = 'ContainerManifestByOrderKey'

         UPDATE CONTAINER WITH (ROWLOCK)
            SET Status = '9',
                EditDate = GETDATE(),   --tlting
                EditWho = SUSER_SNAME()
           FROM CONTAINER
           WHERE CONTAINER.Status <> '9'
           AND   CONTAINER.Mbolkey IN (
             SELECT MD.MbolKey
             FROM #t_MBOLDetail AS MD WITH(NOLOCK)
             JOIN #StorerCfg c ON MD.storerkey = c.storerkey AND c.configkey = 'ContainerManifestByOrderKey')

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72801
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                             + ': Update Failed On Table CONTAINER. (ntrMBOLHeaderUpdate)'
                             + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Added By SHONG on 29-Dec-2003
      -- For Performance Tuning
      --Mohit Trimming a column value will not make it null, so no point in checking it
      IF EXISTS( SELECT 1 FROM #t_MBOLDetail MD
                 JOIN INSERTED ON (MD.MBOLKey = INSERTED.MBOLKey)
                 WHERE INSERTED.Status = '9'
                   AND MD.ContainerKey <> ''  )
      BEGIN
         IF @b_debug = 1
         BEGIN
            SELECT 'Update CONTAINER.Status to SHIPPED'
         END

         UPDATE CONTAINER WITH (ROWLOCK)
         SET Status = '9',
               EditDate = GETDATE(),   --tlting
               EditWho = SUSER_SNAME()
         FROM CONTAINER
         JOIN #t_MBOLDetail MD ON (CONTAINER.ContainerKey = MD.ContainerKey)
         JOIN INSERTED ON (MD.MBOLKey = INSERTED.MBOLKey)
         WHERE Container.Status <> '9'
           AND INSERTED.Status = '9'
           AND MD.ContainerKey <> ''

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72806
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                             + ': Update Failed On Table CONTAINER. (ntrMBOLHeaderUpdate)'
                             + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

   /* Commented By SHONG - 01 May 2000 */
   DECLARE @c_PickOrderKey  char (10),
         @c_XmitLogKey      char (10),
         @c_PickOrderLine   char (5),
         @c_StorerKey       NVARCHAR(20),
         @c_OrderKey        NVARCHAR(10),
         @c_OrderLineNumber NVARCHAR(5),
         @c_MBOLKey         NVARCHAR(10),
         @c_OrderType       NVARCHAR(10),
         @c_OrdRoute        NVARCHAR(10),
         @c_ConsigneeKey    NVARCHAR(15)   --SOS#141842

   -- SOS 6862 : Start
   IF @n_continue = 1 OR @n_continue = 2 AND UPDATE(STATUS)
   BEGIN -- 01
      IF @b_debug = 1
      BEGIN
         SELECT 'Update ORDERS.Status to SHIPPED'
      END

      SELECT @c_MBOLKey = SPACE(10)

      DECLARE C_MBOLU_MBKey CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
       SELECT INSERTED.MBOLKEY
         FROM INSERTED
         JOIN DELETED ON (INSERTED.MBOLKEY = DELETED.MBOLKEY)
        WHERE INSERTED.Status = '9'
          AND DELETED.Status < '9'

      OPEN C_MBOLU_MBKey

      FETCH NEXT FROM C_MBOLU_MBKey INTO @c_MBOLKey
      WHILE @@FETCH_STATUS <> -1 and @n_continue = 1
      BEGIN

         -- (ChewKP01)
         IF ( @n_continue = 1 OR @n_continue = 2  )
         BEGIN
            UPDATE MBOL with (ROWLOCK)
            SET ShipDate   = Getdate(),
                EffectiveDate = GETDATE(),   -- tlting
                TrafficCop = NULL
            WHERE MBOLKey = @c_MBOLKey
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72824
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                + ': Update Failed On Table MBOL. (ntrMBOLHeaderUpdate)'
                                + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
            END
         END

         SELECT @c_OrderKey = SPACE(10)

         DECLARE C_MBOLU_OrderKey CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
          SELECT OrderKey
            FROM #t_MBOLDetail WITH (NOLOCK)
           WHERE MBOLKEY = @c_MBOLKEY

         OPEN C_MBOLU_OrderKey

         FETCH NEXT FROM C_MBOLU_OrderKey INTO @c_OrderKey

         WHILE @@FETCH_STATUS <> -1 and @n_continue = 1
         BEGIN

            SELECT @c_ExternOrderKey = #t_Orders.externorderkey,
                   @c_Storerkey = Storerkey,
                   @c_OrderType = ISNULL(RTrim(TYPE), ''),
                   @c_OrdRoute  = Route,
                   @c_Facility  = Facility,
                   @c_LoadKey   = LoadKey,
                   @c_OrdIssued = Issued,
                   @c_OrdGroup  = OrderGroup,
                   @c_ConsigneeKey  = ISNULL(RTrim(ConsigneeKey),'')     --SOS#141842
            FROM   #t_Orders
            WHERE  Orderkey =  @c_OrderKey


            -- By SHONG on 29th Dec 2003
            -- Move FROM bottom to here, to minimize updating for MBOL when realtimeship was turn on
            EXECUTE nspGetRight null,  -- facility
                     @c_Storerkey,    -- Storerkey
                     null,          -- Sku
                    'REALTIMESHIP',         -- Configkey
                     @b_success     output,
                     @c_realtmship  output,
                     @n_err         output,
                     @c_errmsg      output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)
            END

            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               IF @c_realtmship = '1'
               BEGIN
                  UPDATE PickDetail WITH (ROWLOCK)
                     SET Status = '9',
                        EditDate = GETDATE(),   --tlting
                        EditWho = SUSER_SNAME()
                     FROM PickDetail
                     JOIN #t_OrderDetail OrderDetail ON (OrderDetail.OrderKey = PickDetail.OrderKey AND
                                                         OrderDetail.OrderLineNumber = PickDetail.OrderLineNumber)
                     WHERE PickDetail.OrderKey = @c_OrderKey
                     AND OrderDetail.OrderKey = @c_OrderKey
                     AND PickDetail.Status < '9'
               END
               ELSE
               BEGIN
                  UPDATE PickDetail WITH (ROWLOCK)
                     SET ShipFlag = 'Y',
                           EditDate = GetDate(),
                           EditWho  = sUser_sName(),
                           TrafficCop = NULL
                     FROM PickDetail
                     JOIN #t_OrderDetail OrderDetail ON (OrderDetail.OrderKey = PickDetail.OrderKey AND
                                                         OrderDetail.OrderLineNumber = PickDetail.OrderLineNumber)
                     WHERE PickDetail.OrderKey  = @c_OrderKey
                     AND OrderDetail.OrderKey = @c_OrderKey
                     AND PickDetail.Status < '9'
                     AND PickDetail.ShipFlag <> 'Y'
               END

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72806
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                    + ': Update Failed On Table PickDetail. (ntrMBOLHeaderUpdate)'
                                    + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  BREAK
               END
            END -- @n_continue = 1 OR @n_continue = 2

            IF EXISTS ( SELECT OrderKey FROM OrderDetail WITH (NOLOCK)
                           WHERE OrderDetail.OrderKey = @c_OrderKey
                           AND OrderDetail.Status < '9')
            BEGIN
               UPDATE OrderDetail WITH (ROWLOCK)
                  SET Status = '9',
                        EditDate = GetDate(),
                        EditWho  = sUser_sName(),
                        TrafficCop = NULL
                  WHERE OrderDetail.OrderKey = @c_OrderKey
                  AND OrderDetail.Status < '9'

               SELECT @n_err = @@ERROR
               SELECT @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72806
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                    + ': Update Failed On Table ORDERS. (ntrMBOLHeaderUpdate)'
                                    + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  BREAK
               END
            END

            IF EXISTS ( SELECT OrderKey FROM ORDERS WITH (NOLOCK) WHERE ORDERS.OrderKey = @c_OrderKey
                           AND (ORDERS.Status < '9' OR ORDERS.SOSTATUS < '9') )
            BEGIN
               UPDATE ORDERS WITH (ROWLOCK)
                  SET Status = '9',
                      SOStatus = '9',
                      EditDate = GetDate(),
                      EditWho  = sUser_sName()
                WHERE ORDERS.OrderKey = @c_OrderKey
                  AND (ORDERS.Status < '9' OR ORDERS.SOSTATUS < '9')

               SELECT @n_err = @@ERROR
               SELECT @n_cnt = @@ROWCOUNT

               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72806
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                   + ': Update Failed On Table ORDERS. (ntrMBOLHeaderUpdate)'
                                   + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
               END
            END

            IF EXISTS ( SELECT 1 FROM LOADPLANDETAIL WITH (NOLOCK)
                         WHERE LOADPLANDETAIL.Orderkey = @c_OrderKey
                           AND LOADPLANDETAIL.Status < '9')
            BEGIN
               UPDATE LOADPLANDETAIL WITH (ROWLOCK)
                  SET STATUS   = '9',
                      EditDate = GetDate(),
                      EditWho  = sUser_sName(),
                      Trafficcop = null
                FROM LOADPLANDETAIL
                WHERE LOADPLANDETAIL.Orderkey = @c_OrderKey
                  AND LOADPLANDETAIL.Status < '9'

               SELECT @n_err = @@ERROR
               SELECT @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72806
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                   + ': Update Failed On Table LoadPlanDetail. (ntrMBOLHeaderUpdate)'
                                   + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
               END
            END

            -- Start SOS#141842
            SET @c_SMSRefKey = ''
            SET @SMSPODConfig = '0'

            SELECT @SMSPODConfig = '1'
            FROM #StorerCfg
            WHERE Storerkey = @c_StorerKey
            AND ConfigKey = 'SMSPOD' AND (ISNULL(Facility,'') = '' OR Facility = @c_Facility)  --GOH02

            IF RTRIM(@SMSPODConfig) = '1'
            BEGIN -- (tlting03)
               IF EXISTS (SELECT 1
                     FROM INSERTED Where RTRIM(INSERTED.UserDefine03) = ''
                     OR INSERTED.UserDefine03 IS NULL)
               BEGIN
                  SELECT @n_continue=3
                  SELECT @n_err=72806
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) + 'UPDATE rejected. Mobile not maintain in UserDefine03 '
                  GOTO QUIT
               END
               ELSE
               BEGIN
                 IF NOT EXISTS(SELECT TOP 1 MBOLDetail.UserDefine02
                     FROM MBOLDetail (NOLOCK)
                     JOIN ORDERS (NOLOCK) ON (ORDERS.Mbolkey = MBOLDetail.Mbolkey
                     AND Orders.Orderkey = MBOLDetail.orderkey
                     AND ORDERS.ConsigneeKey = @c_ConsigneeKey)
                     WHERE MBOLDetail.Mbolkey = @c_Mbolkey
                     AND ISNULL(MBOLDetail.UserDefine02,'') <> '')
                  BEGIN
                     SELECT @b_success = 0

                     SELECT @c_code = CONVERT(CHAR(2),CODELKUP.Code)
                        FROM CODELKUP WITH (NOLOCK)
                     WHERE ListName = 'SMSFAC'
                     AND Short =  @c_facility

                     EXECUTE nspg_getkey
                        @c_code
                        , 6
                        , @c_smscounter OUTPUT
                        , @b_success OUTPUT
                        , @n_err OUTPUT
                        , @c_errmsg OUTPUT

                        IF @b_success <> 1
                        BEGIN
                        SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)
                        END
                        ELSE
                        BEGIN
                        SET @c_SMSRefKey = LTRIM(RTRIM(@c_code)) + LTRIM(RTRIM(@c_smscounter))

                        UPDATE MBOLDetail WITH (ROWLOCK)
                        SET UserDefine02 = @c_SMSRefKey,
                           EditDate = GETDATE(),   --tlting
                           EditWho = SUSER_SNAME()
                        WHERE MBOLDetail.MBOLKey = @c_Mbolkey
                        AND EXISTS
                        (SELECT 1 FROM ORDERS (NOLOCK)
                        Where ORDERS.Mbolkey =  MBOLDetail.MBOLKey
                        AND ORDERS.OrderKey = MBOLDetail.OrderKey
                        AND ORDERS.ConsigneeKey = @c_ConsigneeKey)
                     END
                  END
                  ELSE
                  BEGIN
                     SET @c_SMSRefKey = (SELECT TOP 1 MBOLDetail.UserDefine02
                                 FROM MBOLDetail (NOLOCK)
                                 JOIN ORDERS (NOLOCK) ON (ORDERS.Mbolkey = MBOLDetail.Mbolkey
                                 AND Orders.Orderkey = MBOLDetail.orderkey
                                 AND ORDERS.ConsigneeKey = @c_ConsigneeKey)
                                 WHERE MBOLDetail.Mbolkey = @c_Mbolkey
                                 AND ISNULL(MBOLDetail.UserDefine02,'') <> '')

                     UPDATE MBOLDetail WITH (ROWLOCK)
                     SET UserDefine02 = @c_SMSRefKey,
                        EditDate = GETDATE(),   --tlting
                        EditWho = SUSER_SNAME()
                     WHERE MBOLDetail.MBOLKey = @c_Mbolkey
                     AND EXISTS
                     (SELECT 1 FROM ORDERS (NOLOCK)
                     Where ORDERS.Mbolkey =  MBOLDetail.MBOLKey
                     AND ORDERS.OrderKey = MBOLDetail.OrderKey
                     AND ORDERS.ConsigneeKey = @c_ConsigneeKey)
                  END
               END
            END -- (tlting03) IF RTRIM(@SMSPODConfig) = '1'

            -- Generate POD Records Here...................
            SELECT @b_success = 0
            EXECUTE nspGetRight @c_facility, -- facility
                     @c_storerkey, -- Storerkey -- SOS40271
                     NULL,         -- Sku
                     'POD',        -- Configkey
                     @b_success    OUTPUT,
                     @c_authority  OUTPUT,
                     @n_err        OUTPUT,
                     @c_errmsg     OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)
         END
         ELSE IF @c_authority = '1'
         BEGIN -- Added for IDSV5 by June 28.Jun.02, (extract FROM IDSHK) *** End
            IF @b_debug = 1
            BEGIN
               SELECT 'Insert Details of MBOL into POD Table'
            END

            -- tlting04
            SET @c_authority = 0
            SELECT @b_success = 0
            EXECUTE nspGetRight
                  @c_facility, -- facility
                  @c_storerkey, -- Storerkey -- SOS40271
                  null,         -- Sku
                  'PODXDeliverDate',  -- Configkey
                  @b_success    output,
                  @c_authority  output,
                  @n_err        output,
                  @c_errmsg     output
            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLHeaderUpdate' + dbo.fnc_RTrim(@c_errmsg)
            END
            ELSE
            BEGIN
               -- Changed by June 31.Mar.2004 - SOS21700, (IDSPH ULP) - 1 Order Populated into multiple MBOL
               -- IF NOT EXISTS(SELECT 1 FROM POD (NOLOCK) WHERE OrderKey = @c_OrderKey)
               IF NOT EXISTS ( SELECT 1 FROM POD WITH (NOLOCK) WHERE OrderKey = @c_OrderKey AND Mbolkey = @c_mbolkey)
               BEGIN
                  -- Modify by SHONG For New POD Version
                  -- wally 16.nov.2002
                  -- added 1 field to populate: poddef08 = MBOLDetail.ITS
                  -- Modify By SHONG on 12-Feb-2003
                  -- Do not insert into POD when POD records is exists
                  -- Use left outer join
                  INSERT INTO POD
                              (MBOLKey,         MBOLLineNumber,   LoadKey,    ExternLoadKey,    --(Wan02)
                               OrderKey,        BuyerPO,          ExternOrderKey,
                               InvoiceNo,       status,           ActualDeliveryDate,
                               InvDespatchDate, poddef08,         Storerkey,  SpecialHandling, -- SOS95698
                               TrackCol01)    --SOS#141842
                  SELECT   MBOLDetail.MBOLKey,
                           MBOLDetail.MBOLLineNumber,
                           MBOLDetail.LoadKey,
                           ISNULL(LOADPLAN.ExternLoadKey, ''),                                 --(Wan02)--INC0128904
                           ORDERS.OrderKey,
                           ORDERS.BuyerPO,
                           ORDERS.ExternOrderKey,
                           CASE WHEN wts.cnt = 1 THEN MBOLDetail.userdefine01
                                ELSE ORDERS.InvoiceNo
                           END, -- pod.invoiceno
                           '0',
                           CASE WHEN @c_authority = '1' THEN NULL ELSE GETDATE() END, -- tlting04
                           GETDATE(),
                           ISNULL(MBOLDetail.its,''),  --NJOW05
                          ORDERS.Storerkey,
                           ORDERS.SpecialHandling, -- SOS95698
                           @c_SMSRefKey            -- SOS#141842
                    FROM #t_MBOLDetail MBOLDetail
                    JOIN #t_ORDERS ORDERS ON (MBOLDetail.OrderKey = ORDERS.OrderKey)
                    JOIN ORDERS SO WITH (NOLOCK) ON (ORDERS.OrderKey = SO.OrderKey)          --(WAN02)
                    LEFT JOIN LOADPLAN LOADPLAN WITH (NOLOCK) ON (LOADPLAN.LoadKey = SO.LoadKey)  --(WAN02)--INC0128904
                    -- for WATSONS-PH: use pod.invoiceno for shipping manifest#
                    -- (Wan02)
                    LEFT OUTER JOIN (SELECT storerkey, 1 AS cnt
                                       FROM storerconfig WITH (NOLOCK)
                                      WHERE configkey = 'WTS-ITF' and svalue = '1') AS wts
                                 ON (ORDERS.storerkey = wts.storerkey)
                   WHERE ORDERS.OrderKey = @c_OrderKey
                     AND MBOLDetail.Mbolkey = @c_Mbolkey -- Add by June 31.Mar.2004 - SOS21700, IDSPH ULP

                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72807
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                      + ': Insert Failed On Table POD. (ntrMBOLHeaderUpdate)'
                                      + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  END
               END
               -- SOS#141842 Start
               ELSE
               BEGIN
                     UPDATE POD  WITH (ROWLOCK)
                     SET TrackCol01 = @c_SMSRefKey,
                        EditDate = GETDATE(),   --tlting
                        EditWho = SUSER_SNAME()
                     WHERE OrderKey = @c_OrderKey AND Mbolkey = @c_mbolkey
               END
            -- SOS#141842 End
            END
         END -- Authority = 1
         -- SOS#314938 Start (Chee01)
         -- Add Sub SP to create POD
         ELSE IF LEN(RTRIM(@c_authority)) > 1
         BEGIN
            IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_authority) AND type = 'P')
            BEGIN
               SET @c_SQL = N'
                  EXECUTE ' + @c_authority                 + CHAR(13) +
                  '  @c_MBOLKey  = @c_MBOLKey '            + CHAR(13) +
                  ', @c_OrderKey = @c_OrderKey '           + CHAR(13) +
                  ', @b_Success  = @b_Success     OUTPUT ' + CHAR(13) +
                  ', @n_Err      = @n_Err         OUTPUT ' + CHAR(13) +
                  ', @c_ErrMsg   = @c_ErrMsg      OUTPUT ' + CHAR(13) +
                  ', @b_Debug    = @b_Debug '


               SET @c_SQLParm =  N'@c_MBOLKey  NVARCHAR(10), ' +
                                  '@c_OrderKey NVARCHAR(10), ' +
                                  '@b_Success  INT           OUTPUT, ' +
                                  '@n_Err      INT           OUTPUT, ' +
                                  '@c_ErrMsg   NVARCHAR(250) OUTPUT, ' +
                                  '@b_Debug    INT '

               EXEC sp_ExecuteSQL @c_SQL, @c_SQLParm, @c_Mbolkey, @c_OrderKey,
                                  @b_Success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT, @b_debug

               IF @@ERROR <> 0 OR @b_Success <> 1
               BEGIN
                  SET @n_continue = 3
                  SET @n_err      = 72809
                  SET @c_errmsg   = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Failed to EXEC ' + @c_authority +
                                     CASE WHEN ISNULL(@c_errmsg, '') <> '' THEN ' - ' + @c_errmsg ELSE '' END + ' (ntrMBOLHeaderUpdate)'
               END
            END
         END -- IF LEN(RTRIM(@c_authority)) > 1
         -- SOS#314938 End
         -- End of POD

         -- Generate Interface File Here................
         IF @n_continue = 1 OR @n_continue = 2
         BEGIN
            SELECT @c_ConfigKey = SPACE(30)

            DECLARE C_MBOLU_StorerCfg CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
             SELECT ConfigKey
               FROM #StorerCfg
              WHERE Storerkey = @c_StorerKey
              ORDER BY ConfigKey

            OPEN C_MBOLU_StorerCfg

            FETCH NEXT FROM C_MBOLU_StorerCfg INTO @c_ConfigKey

            WHILE @@FETCH_STATUS <> -1
            BEGIN
               IF dbo.fnc_RTrim(@c_ConfigKey) IS NULL OR dbo.fnc_RTrim(@c_ConfigKey) = ''
                  BREAK

               -- Added BY SHONG
               -- For IDSHK TBL Implimentation
               -- Date: 12-May-2003
               IF @c_ConfigKey = 'NON-OW-ITS'
               BEGIN
                  EXEC ispGenTransmitLog 'NON-OW-ITS', @c_OrderKey, '', @c_StorerKey, ''
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT
               END
               IF @c_ConfigKey = 'ILSITF'
               BEGIN
                  EXEC ispGenTransmitLog 'ORDERS', @c_OrderKey, @c_StorerKey, '', ''
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT
               END

               IF @c_ConfigKey = 'MBOLSHIPITF'
               BEGIN
                  SELECT @c_LoadKey = SubString(@c_LoadKey,1,5)

                  EXEC ispGenTransmitLog 'ORDERS', @c_MBOLKey, @c_LoadKey, @c_OrderKey, @c_StorerKey
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT
               END
               IF @c_ConfigKey = 'MBOLLOG'
               BEGIN
                  EXEC ispGenTransmitLog3 'MBOLLOG', @c_MBOLKey, '', @c_StorerKey, ''  -- (YokeBeen02)
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT
               END
               --(MC02) - Start
               IF @c_ConfigKey = 'MBOL2LOG'
               BEGIN
                  EXEC ispGenTransmitLog3 'MBOL2LOG', @c_MBOLKey, '', @c_StorerKey, ''
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT
               END
               --(MC02) - End
               --(MC01) - Start
               IF @c_ConfigKey = 'VMBOLLOG'
               BEGIN
                  EXEC dbo.ispGenVitalLog  'VMBOLLOG', @c_MBOLKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
               END
               --(MC01) - End

                  -- (YokeBeen03) - Start
                  IF @c_ConfigKey = 'XDOCKLOG'
                  BEGIN
                     EXEC ispGenTransmitLog3 'XDOCKLOG', @c_MBOLKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
                  END
                  -- (YokeBeen03) - End

               IF @c_ConfigKey = 'TBLHKITF'
               BEGIN
                  IF EXISTS (SELECT 1  FROM ROUTEMASTER WITH (NOLOCK)
                              WHERE ROUTEMASTER.Route = @c_OrdRoute
                              AND   ROUTEMASTER.ZipCodeTo = 'EXP')
                  BEGIN
                     EXEC ispGenTransmitLog2 'TBLASNTODC', @c_OrderKey, '', '', ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
                  END -- route

                  IF @c_OrderType <> 'M'
                  BEGIN
                     EXEC ispGenTransmitLog2 'TBLHKSHP', @c_OrderKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
                  END -- Order type <> M

                  IF @c_OrderType = 'R'
                  BEGIN
                     EXEC ispGenTransmitLog2 'TBLREPTKT', @c_OrderKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
                  END -- Order type = 'R'
               END  --   @c_ConfigKey = 'TBLHKITF'

               IF @c_ConfigKey = 'NIKEHKITF'
               BEGIN
                  EXEC ispGenTransmitLog 'NIKESHIP', @c_OrderKey, '', @c_StorerKey, ''
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT
               END

               -- Added By SHONG on 06-Sep-2004
               -- Taiwan Unilever Project
               IF @c_ConfigKey = 'UTLITF'
               BEGIN
                  IF EXISTS ( SELECT 1 FROM Transmitlog2 WITH (NOLOCK)
                               WHERE Tablename = 'UTLALORD' AND Key1 = @c_OrderKey )
                     -- Addded By SHONG on 15-Dec-2004, Split Order
                     OR @c_OrdGroup = 'IMPORT'
                  BEGIN
                     EXEC ispGenTransmitLog2 'UTLORDSHP', @c_OrderKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err     OUTPUT
                                          , @c_errmsg  OUTPUT
                  END

                  DECLARE @cDivision NVARCHAR(5)

                    SELECT TOP 1 @cDivision = ISNULL(SUSR3, '')
                    FROM SKU WITH (NOLOCK)
                    JOIN OrderDetail WITH (NOLOCK) ON (OrderDetail.StorerKey = SKU.StorerKey AND
                                                       OrderDetail.SKU = SKU.SKU)
                   WHERE OrderDetail.OrderKey = @c_OrderKey

                  IF @c_OrdGroup = 'IMPORT'
                  BEGIN
                     EXEC ispGenTransmitLog2 'UTLSHPCFM', @c_OrderKey, @cDivision, @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err     OUTPUT
                                          , @c_errmsg  OUTPUT
                  END
               END -- @c_ConfigKey = 'UTLITF'

               IF @c_ConfigKey = 'FUJIMYITF'
               BEGIN
                  -- Changed by June 30.Mar.2004
                  -- IF @c_ExternOrderKey Like 'I%' AND
                  IF @c_ExternOrderKey NOT Like 'I%' AND
                     ( dbo.fnc_RTrim(@c_OrdIssued) IS NULL OR dbo.fnc_RTrim(@c_OrdIssued) = '' )
                  BEGIN
                     EXEC ispGenTransmitLog 'FUJIMYORD', @c_OrderKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
                  END
               END -- @c_ConfigKey = 'FUJIMYITF'

               IF @c_ConfigKey = 'NIKEREGITF'
               BEGIN
                  IF @c_OrderType <> 'M'
                  BEGIN
                     -- Modified By YokeBeen on 20-Feb-2004 For NIKE Regional (NSC) Project - (SOS#20000)
                     -- Changed to trigger records into NSCLog table with 'NSCKEY'.
                     EXEC ispGenNSCLog 'NIKEREGORD', @c_OrderKey, '', @c_StorerKey, ''
                                    , @b_success OUTPUT
                                    , @n_err OUTPUT
                                    , @c_errmsg OUTPUT
                     -- End Modified By YokeBeen on 20-Feb-2004 For NIKE Regional (NSC) Project (SOS#20000)
                  END -- Order type <> M
               END

               IF @c_ConfigKey = 'CNNIKEITF'
               BEGIN
                  IF @c_OrderType <> 'TR'
                  BEGIN
                     IF @c_OrderType = 'TF'
                     BEGIN
                        EXEC ispGenTransmitLog 'TFO', @c_OrderKey, '', @c_StorerKey, ''
                                             , @b_success OUTPUT
                                             , @n_err OUTPUT
                                             , @c_errmsg OUTPUT
                     END
                     ELSE IF @c_OrderType NOT IN ('TF', 'DES')
                     BEGIN
                        EXEC ispGenTransmitLog 'NIKESHIP', @c_OrderKey, '', @c_StorerKey, ''
                                             , @b_success OUTPUT
                                             , @n_err OUTPUT
                                             , @c_errmsg OUTPUT
                     END
                  END
               END

               IF @c_ConfigKey = 'OWITF'
               BEGIN
                  SELECT @c_LongConfig = NULL -- SOS38531

                  SELECT @c_LongConfig = LONG
                    FROM CODELKUP WITH (NOLOCK)
                   WHERE ListName = 'ORDERTYPE'
                     AND Code = @c_OrderType

                  IF NOT dbo.fnc_RTrim(@c_LongConfig) IS NULL
                  BEGIN
                     SELECT @b_success = 1

                     EXEC ispTypeLookup 'TRFORD', @c_LongConfig, @b_success OUTPUT

                     IF @b_success = 1
                     BEGIN
                         EXEC ispPopulateTSO2ASN @c_OrderKey
                     END
                  END
               END

               IF @c_ConfigKey = 'AutoCreateASN'
               BEGIN
                        -- SOS37009
                        SELECT @c_ispProc = ''

                  --SELECT @c_ispProc = Long
                  --FROM CODELKUP WITH (NOLOCK)
                  --WHERE ListName = 'ORDTYP2ASN' AND Code = @c_OrderType

                    SELECT TOP 1 @c_ispProc = ISNULL(RTRIM(Long),'')
                    FROM CODELKUP WITH (NOLOCK)
                    WHERE ListName = 'ORDTYP2ASN' AND Code = @c_OrderType
                    AND (StorerKey = @c_StorerKey OR Storerkey = '') -- INC0060084 jyhbin

                  IF @c_ispProc <> '' AND @c_ispProc IS NOT NULL
                  BEGIN
                     --(Wan01) - START
                     IF NOT EXISTS ( SELECT 1 FROM TransmitLog WITH (NOLOCK) WHERE TableName = @c_ConfigKey
                                     AND Key1 = @c_OrderKey AND Key3 = @c_Storerkey)
                     BEGIN
                        --(Wan01) - END
                        EXEC @c_ispProc @c_OrderKey

                        -- SOS#120983 YTWAN  - If Error then return - START
                        IF @@ERROR <> 0
                        BEGIN
                           GOTO QUIT
                        END
                        -- SOS#120983 YTWAN  - If Error then return - END

                        --(Wan01) - START
                        SET @b_success = 1
                        EXECUTE nspg_getkey
                        'transmitlogkey'
                        , 10
                        , @c_trmlogkey OUTPUT
                        , @b_success   OUTPUT
                        , @n_err       OUTPUT
                        , @c_errmsg    OUTPUT

                        IF NOT @b_success = 1
                        BEGIN
                           SET @n_continue = 3
                           SET @n_err=63810   -- Should Be SET To The SQL Errmessage but I don't know how to do so.
                           SET @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Unable to Obtain transmitlogkey. (ntrMBOLHeaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                           GOTO QUIT
                        END
                        ELSE
                        BEGIN
                           INSERT INTO Transmitlog (transmitlogkey, tablename, key1, key2, key3, transmitflag)
                           VALUES (@c_trmlogkey, @c_ConfigKey, @c_OrderKey, '', @c_Storerkey, '9')
                        END
                     END
                     --(Wan01) - END
                  END
               END

               -- (KC01) - begin
               IF @c_ConfigKey = 'AutoCreateOrder'
               BEGIN
                  SELECT @c_ispProc = ''

                  SELECT @c_ispProc = Long
                  FROM CODELKUP WITH (NOLOCK)
                  WHERE ListName = 'ORDTYP2SO' AND Code = @c_OrderType

                  IF @c_ispProc <> '' AND @c_ispProc IS NOT NULL
                  BEGIN
                     EXEC @c_ispProc @c_OrderKey

                     IF @@ERROR <> 0
                     BEGIN
                        GOTO QUIT
                     END
                  END
               END
               -- (KC01) - end

               -- Start : SOS66030
               /*
               -- Added by MaryVong on 09-Mar-2004 (NZMM FBR18999 Shipment Confirmation Export) -Start
               IF @c_ConfigKey = 'NZMMITF'
               BEGIN
                  -- When short='SHIP', insert a record into TransmitLog2 table
                  SELECT @c_NZShort = Short
                  FROM CODELKUP (NOLOCK)
                  WHERE ListName = 'NZMMSOCFM'
                  AND Code = @c_OrderType

                  IF @c_NZShort = 'SHIP'
                  BEGIN
                     EXEC ispGenTransmitLog2 'NZSHIPCONF', @c_OrderKey, '', @c_StorerKey, ''
                                    , @b_success OUTPUT
                                    , @n_err OUTPUT
                                    , @c_errmsg OUTPUT
                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue = 3
                     END
                  END -- @c_NZShort = 'SHIP'
               END -- @c_ConfigKey = 'NZMMITF'
               */
               -- End : SOS66030

               -- Added by MaryVong on 09-Mar-2004 (NZMM FBR18999 Shipment Confirmation Export) -End
               -- Added by MaryVong on 26-May-2004 (IDSHK - Watson Shipment Confirmation Export) -Start
               IF @c_ConfigKey = 'NWInterface'
               BEGIN
                  IF ( SELECT CONVERT(CHAR(10),codelkup.notes)
                         FROM codelkup WITH (NOLOCK)
                         JOIN #t_ORDERS ORDERS WITH (NOLOCK) ON (Codelkup.code = Orders.type)
                        WHERE Orders.Orderkey = @c_OrderKey
                          AND Codelkup.listname = 'ORDERTYPE'
                          AND Codelkup.long = @c_StorerKey ) = 'RTV'
                  BEGIN
                     EXEC ispGenTransmitLog3 'NWSHPRTV', @c_OrderKey, '', @c_StorerKey, ''           -- SOS27626
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT
                  END
                  ELSE
                  BEGIN
                     EXEC ispGenTransmitLog3 'NWSHPTRF', @c_OrderKey, '', @c_StorerKey, ''           -- SOS27626
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT

                     END

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue = 3
                     END
                  END
                  -- Added by MaryVong on 26-May-2004 (IDSHK - Watson Shipment Confirmation Export) -End

                  -- Added by MaryVong on 23-Jun-2004 (IDSHK-WTC Shipment Confirmation Export) -Start
                  IF @c_ConfigKey = 'WTCInterface'
                  BEGIN
                     EXEC ispGenTransmitLog2 'WTCSHPCF', @c_OrderKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue = 3
                     END
                  END
                  -- Added by MaryVong on 23-Jun-2004 (IDSHK-WTC Shipment Confirmation Export) -End

                  -- Added by MaryVong on 19-Aug-2004 (SOS25796-C4) - Start
                  IF @c_ConfigKey = 'C4ITF'
                  BEGIN
                     EXEC ispGenTransmitLog2 'C4SHPCF', @c_OrderKey, '', @c_StorerKey, ''
                                          , @b_success OUTPUT
                                          , @n_err OUTPUT
                                          , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue = 3
                     END
                  END
                  -- Added by MaryVong on 19-Aug-2004 (SOS25796-C4) - End

                  -- 24 Sept 2004 YTWan - FBR_JAMO007-Outbound-Shipped Confirmation - START
                  IF @n_continue = 1 OR @n_continue = 2
                  BEGIN
                     IF EXISTS( SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE StorerKey = @c_Storerkey
                                AND ConfigKey = 'JAMOSHPCFMITF' AND sValue = '1' AND @c_OrderType = 'N' )
                     BEGIN
                        EXEC ispGenTransmitLog2 'JAMOSHPCFM', @c_OrderKey, '', @c_storerkey, ''
                                                , @b_success OUTPUT
                                                , @n_err OUTPUT
                                       , @c_errmsg OUTPUT

                        IF @b_success <> 1
                        BEGIN
                           SELECT @n_continue = 3
                        END
                     END -- Valid StorerConfig,  OrderType
                  END

                  -- 24 Sept 2004 YTWan - FBR_JAMO007-Outbound-Shipped Confirmation - END
                  FETCH NEXT FROM C_MBOLU_StorerCfg INTO @c_ConfigKey
            END -- WHILE configkey
            CLOSE C_MBOLU_StorerCfg
            DEALLOCATE C_MBOLU_StorerCfg
            END -- n_continue = 1, Generate Interface
                IF @n_continue=1 OR @n_continue = 2
                BEGIN
                  -- Close Tote (james01)
                  SELECT @b_success = 0
                  EXECUTE dbo.nspGetRight @c_facility, -- facility   -- (YokeBeen01)
                           @c_Storerkey, -- Storerkey
                           NULL,         -- Sku
                           'MBOLSHIPCLOSETOTE',        -- Configkey
                           @b_success    output,
                           @c_authority  output,
                           @n_err        output,
                           @c_errmsg     output

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3, @c_errmsg = 'isp_ShipMBOL' + RTrim(@c_errmsg)
                  END
                  ELSE IF @c_authority = '1'
                  BEGIN
                     UPDATE DropID WITH (ROWLOCK) SET
                        Status = '9',
                        EditDate = GETDATE(),   --tlting
                        EditWho = SUSER_SNAME()
                     FROM dbo.PackDetail PD with (NOLOCK)
                     JOIN dbo.PackHeader PH with (NOLOCK) ON (PD.PickSlipNo = PH.PickSlipNo)
                     JOIN dbo.DropID DropID ON (PD.DropID = DropID.DropID)
                     JOIN dbo.Orders O with (NOLOCK) ON (PH.OrderKey = O.OrderKey)
                     WHERE PH.StorerKey = @c_Storerkey
                        AND PH.OrderKey = @c_OrderKey
                        AND O.UserDefine01 = '' -- (james02)
                        -- AND PH.Status = '9' (Shong01)

                     IF @@ERROR <> 0
                     BEGIN
                        SELECT @n_continue = 3, @c_errmsg = 'isp_ShipMBOL - Close Tote Failed'
                     END

                     -- (Shong01) Start
                     SELECT @n_PickedQty = SUM(Qty)
                     FROM PICKDETAIL WITH (NOLOCK)
                     WHERE OrderKey = @c_OrderKey
                     AND   STATUS = '5'

                     SELECT @n_PackedQty = SUM(PD.Qty),
                            @c_PickSlipNO = PH.PickSlipNo
                     FROM PACKHEADER PH WITH (NOLOCK)
                     JOIN  PackDetail pd WITH (NOLOCK) ON pd.PickSlipNo = PH.PickSlipNo
                     WHERE PH.OrderKey = @c_OrderKey
                     GROUP BY PH.PickSlipNo

                     IF @n_PickedQty = @n_PackedQty
                     BEGIN
                        UPDATE PackHeader
                        SET STATUS='9', ArchiveCop=NULL,
                           EditDate = GETDATE(),   --tlting
                           EditWho = SUSER_SNAME()
                           WHERE OrderKey = @c_OrderKey
                        IF @@ERROR <> 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72807   -- Should Be SET To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': UPDATE PackHeader Failed. (ntrMBOLHeaderUpdate)'
                          ROLLBACK TRAN
                        END

                        UPDATE PickingInfo
                        SET ScanOutDate=GETDATE(), TrafficCop=NULL
                        WHERE PickSlipNo = @c_PickSlipNO
                        AND   ScanOutDate IS NULL
                        IF @@ERROR <> 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72807   -- Should Be SET To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': UPDATE PickingInfo Failed. (ntrMBOLHeaderUpdate)'
                           ROLLBACK TRAN
                        END
                     END
                     -- (Shong01) End
                  END
                END -- @n_continue = 1
            FETCH NEXT FROM C_MBOLU_OrderKey INTO @c_OrderKey
         END -- WHILE orderkey
         CLOSE C_MBOLU_OrderKey
         DEALLOCATE C_MBOLU_OrderKey

         -- TLTING07
         IF @n_continue = 1 or @n_continue=2
         BEGIN
            SET @c_MarkMBOLLockdown = '0'
           EXECUTE nspGetRight 
                   NULL,          -- facility
                   @c_storerkey,  -- Storerkey
                   NULL,          -- Sku
                   'MBOLStatusLockdown',    -- Configkey
                   @b_success output,
                   @c_MarkMBOLLockdown   output,
                   @n_err         output,
                   @c_errmsg      output  
            IF @c_MarkMBOLLockdown = '1'
            BEGIN 
         
               IF Exists ( Select 1 from HolidayDetail  (NOLOCK) Where HolidayDescr like '%Financial LockDown%'  
                        AND UserDefine01  = @c_storerkey  
                        AND datepart(MONTH , HolidayDate) = datepart(MONTH , getdate() )  
                        AND getdate() >= userdefine04 and getdate() <= userdefine05)               
               AND         
               Exists ( SELECT  1
                        FROM MBOL, INSERTED, DELETED
                        WHERE MBOL.MBOLKey = INSERTED.MBOLKey
                        AND DELETED.MBOLKey = INSERTED.MBOLKey
                        AND MBOL.Status = '9' 
                        AND DELETED.Status <> MBOL.Status     )
               BEGIN

                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72807   -- Should Be SET To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': UPDATE MBOL Failed. This is Financial LockDown period. (ntrMBOLHeaderUpdate)'
                  ROLLBACK TRAN         
               END
            END
         END   


         -- When MarkShip MBOL
         -- tlting06
-- (ChewKP01)
--         IF @n_continue = 1 OR @n_continue = 2
--         BEGIN
--            UPDATE MBOL with (ROWLOCK)
--            SET ShipDate   = Getdate(),
--                TrafficCop = NULL
--            WHERE MBOLKey = @c_MBOLKey
--            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
--            IF @n_err <> 0
--            BEGIN
--               SELECT @n_continue = 3
--               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72824
--               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
--                                + ': Update Failed On Table MBOL. (ntrMBOLHeaderUpdate)'
--                                + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
--            END
--         END

         FETCH NEXT FROM C_MBOLU_MBKey INTO @c_MBOLKey
      END -- WHILE mbolkey
      CLOSE C_MBOLU_MBKey
      DEALLOCATE C_MBOLU_MBKey
   END -- 01
   /****  To Update Status of ORDERS to '9' During Shipment of MBOL ****/
   -- SOS 6862 : End


   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE @c_Status  NVARCHAR(1),
              @n_StatusCnt int

      SELECT @c_LoadKey = SPACE(10)

      DECLARE C_MBOLU_LDKey CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
       SELECT LoadKey
         FROM #t_MBOLDetail MBOLDetail
         JOIN INSERTED ON (INSERTED.MBOLKEY = MBOLDetail.MBOLKEY)
         JOIN DELETED  ON (DELETED.MBOLKEY = MBOLDetail.MBOLKEY)
        WHERE INSERTED.Status = '9'
          AND DELETED.Status < '9'
        ORDER BY LoadKey

      OPEN C_MBOLU_LDKey
      FETCH NEXT FROM C_MBOLU_LDKey INTO @c_LoadKey
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF dbo.fnc_RTrim(@c_LoadKey) IS NULL OR dbo.fnc_RTrim(@c_LoadKey) = ''
            BREAK

         SELECT @c_Status = Status,
                @n_StatusCnt = COUNT(DISTINCT Status)
         FROM   LoadplanDetail WITH (NOLOCK)
         WHERE  LoadKey = @c_LoadKey
         GROUP BY status

         IF @@ROWCOUNT = 1 AND @c_Status = '9' AND @n_StatusCnt = 1
         BEGIN
            UPDATE LoadPlan WITH (ROWLOCK)
               SET Status = '9',
                   EditDate = GetDate(),
                   EditWho  = sUser_sName()
--          TrafficCop = NULL  -- (YokeBeen02)
             WHERE LoadKey = @c_LoadKey
               AND Status < '9'
         END

         FETCH NEXT FROM C_MBOLU_LDKey INTO @c_LoadKey
      END -- WHILE LoadKey
      CLOSE C_MBOLU_LDKey
      DEALLOCATE C_MBOLU_LDKey
   END

   /* #INCLUDE <TRMBOHU2.SQL> */

   -- Added by YokeBeen on 15-Oct-2003 - Nike Regional Interface
   -- (SOS#15353) - MBOL.Status = '7' --> Delivery Status 'P' for Pack and Hold
   IF @n_continue = 1 OR @n_continue = 2 and
      EXISTS(SELECT 1 FROM INSERTED where status = '7')
   BEGIN
      SELECT @c_OrderKey = ''

      DECLARE C_MBOLU_OrderKey CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
       SELECT MBOLDetail.Orderkey
         FROM INSERTED INSERTED
         JOIN #t_MBOLDetail MBOLDetail ON (INSERTED.MBOLKey = MBOLDetail.MBOLKey)
        WHERE INSERTED.Status = '7'
        ORDER BY MBOLDetail.orderkey

      OPEN C_MBOLU_OrderKey

      FETCH NEXT FROM C_MBOLU_OrderKey INTO @c_OrderKey
      WHILE (@@FETCH_STATUS <> -1)
      BEGIN -- while
         --IF (@@ROWCOUNT = 0) OR (dbo.fnc_RTrim(@c_OrderKey) IS NULL)     --(MC05)
         IF (dbo.fnc_RTrim(@c_OrderKey) IS NULL)                           --(MC05)
         BEGIN
            BREAK
         END

         SELECT @c_storerkey = Storerkey
           FROM ORDERS ORDERS WITH (NOLOCK)
          WHERE OrderKey = @c_OrderKey

         IF EXISTS ( SELECT 1 FROM StorerConfig WITH (NOLOCK)
                      WHERE StorerKey = @c_StorerKey AND ConfigKey = 'NIKEREGITF' AND sValue = '1')
         BEGIN
            IF EXISTS (SELECT 1 FROM ORDERS WITH (NOLOCK)
                        WHERE ORDERS.Type <> 'M'
                          AND ORDERS.Status <> '9'
                          AND ORDERS.Storerkey = @c_Storerkey
                          AND ORDERS.OrderKey = @c_OrderKey)
            BEGIN
               -- Modified By YokeBeen on 20-Feb-2004 For NIKE Regional (NSC) Project - (SOS#20000)
               -- Changed to trigger records into NSCLog table with 'NSCKEY'.
               EXEC ispGenNSCLog 'NIKEREGDSW', @c_OrderKey, '', @c_StorerKey, '' -- (YokeBeen01)
                              , @b_success OUTPUT
                              , @n_err OUTPUT
                              , @c_errmsg OUTPUT

               -- End Modified By YokeBeen on 20-Feb-2004 For NIKE Regional (NSC) Project (SOS#20000)
            END -- Valid OrderKey
         END -- NIKE Regional Interface
         -- Ended by YokeBeen (SOS#15353)
         FETCH NEXT FROM C_MBOLU_OrderKey INTO @c_OrderKey
      END -- while
      CLOSE C_MBOLU_OrderKey
      DEALLOCATE C_MBOLU_OrderKey
   END

   --SOS#168916  NJOW01
   IF (@n_continue = 1 OR @n_continue = 2) AND UPDATE(userdefine09)
   BEGIN
      IF EXISTS(SELECT 1
                FROM   INSERTED I
                JOIN   #t_MBOLDetail M ON (M.MBOLKey = I.MBOLKey)
                JOIN   #t_Orders O ON (O.OrderKey = M.OrderKey)
                JOIN   StorerConfig S WITH (NOLOCK) ON (S.StorerKey = O.StorerKey)
                WHERE  S.sValue NOT IN ('0','')
                AND    S.Configkey = 'MBOLDEFAULT')
      BEGIN
         UPDATE MBOL WITH (ROWLOCK)
         SET noofidscarton = CASE WHEN I.userdefine09 = 'IDS' THEN
                                 (SELECT SUM(M.totalcartons) FROM #t_MBOLDetail M WHERE M.Mbolkey = I.Mbolkey)
                             ELSE 0 END,
             noofcustomercarton = CASE WHEN I.userdefine09 = 'CUSTOMER' THEN                                       
                           (SELECT SUM(M.totalcartons) FROM #t_MBOLDetail M WHERE M.Mbolkey = I.Mbolkey)
                                  ELSE 0 END,
             EditDate   = GETDATE(), -- KH01
             TrafficCop = NULL
         FROM MBOL JOIN INSERTED I
         ON (MBOL.Mbolkey = I.Mbolkey)
         SELECT @n_err = @@ERROR
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72816
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                             + ': Update Failed On Table MBOL. (ntrMBOLHeaderUpdate)'
                             + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

   -- (MC03) - S
   /********************************************************/
   /* Interface Trigger Points Calling Process - (Start)   */
   /********************************************************/
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE Cur_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT INS.MBOLKey, OH.StorerKey
      FROM   INSERTED INS
      JOIN   MBOLDETAIL MD WITH (NOLOCK)        ON INS.MBolKey = MD.MBolKey
      JOIN   Orders OH WITH (NOLOCK)            ON MD.OrderKey = OH.OrderKey
      JOIN   ITFTriggerConfig ITC WITH (NOLOCK) ON ITC.StorerKey = OH.StorerKey
      WHERE  ITC.SourceTable = 'MBOL'
      AND    ITC.sValue      = '1'

      OPEN Cur_TriggerPoints
      FETCH NEXT FROM Cur_TriggerPoints INTO @c_MBOLKey, @c_Storerkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         EXECUTE dbo.isp_ITF_ntrMBOL
                  @c_TriggerName    = 'ntrMBOLHeaderUpdate'
                , @c_SourceTable    = 'MBOL'
                , @c_Storerkey      = @c_Storerkey
                , @c_MBOLKey        = @c_MBOLKey
                , @b_ColumnsUpdated = @b_ColumnsUpdated
                , @b_Success        = @b_Success   OUTPUT
                , @n_err            = @n_err       OUTPUT
                , @c_errmsg         = @c_errmsg    OUTPUT

         FETCH NEXT FROM Cur_TriggerPoints INTO @c_MBOLKey, @c_Storerkey
      END -- WHILE @@FETCH_STATUS <> -1
      CLOSE Cur_TriggerPoints
      DEALLOCATE Cur_TriggerPoints

      -- (MC04) - S
      DECLARE Cur_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT INS.MBOLKey, OH.StorerKey
      FROM   INSERTED INS
      JOIN   MBOLDETAIL MD WITH (NOLOCK)        ON INS.MBolKey   = MD.MBolKey
      JOIN   Orders OH WITH (NOLOCK)            ON MD.OrderKey   = OH.OrderKey
      JOIN   ITFTriggerConfig ITC WITH (NOLOCK) ON ITC.StorerKey = 'ALL'
      JOIN   StorerConfig STC WITH (NOLOCK)     ON OH.StorerKey = STC.StorerKey AND STC.ConfigKey = ITC.ConfigKey AND STC.SValue = '1'
      WHERE  ITC.SourceTable = 'MBOL'
      AND    ITC.sValue      = '1'

      OPEN Cur_TriggerPoints
      FETCH NEXT FROM Cur_TriggerPoints INTO @c_MBOLKey, @c_Storerkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         EXECUTE dbo.isp_ITF_ntrMBOL
                  @c_TriggerName    = 'ntrMBOLHeaderUpdate'
                , @c_SourceTable    = 'MBOL'
                , @c_Storerkey      = @c_Storerkey
                , @c_MBOLKey        = @c_MBOLKey
                , @b_ColumnsUpdated = @b_ColumnsUpdated
                , @b_Success        = @b_Success   OUTPUT
                , @n_err            = @n_err       OUTPUT
                , @c_errmsg         = @c_errmsg    OUTPUT

         FETCH NEXT FROM Cur_TriggerPoints INTO @c_MBOLKey, @c_Storerkey
      END -- WHILE @@FETCH_STATUS <> -1
      CLOSE Cur_TriggerPoints
      DEALLOCATE Cur_TriggerPoints
      -- (MC04) - E
   END -- IF @n_continue = 1 OR @n_continue = 2
   /********************************************************/
   /* Interface Trigger Points Calling Process - (End)     */
   /********************************************************/
   -- (MC03) - E

   QUIT:   -- SOS#120983 YTWAN
   /***** End Add by DLIM *****/
   IF @n_continue = 3  -- Error Occured - Process And Return
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMBOLHeaderUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      --RAISERROR @n_err @c_errmsg
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
ALTER TABLE [dbo].[MBOL] ADD CONSTRAINT [CK_MBOL_Status] CHECK (([Status]='0' OR [Status]='5' OR [Status]='7' OR [Status]='9'))
GO
ALTER TABLE [dbo].[MBOL] ADD CONSTRAINT [PKMBOL] PRIMARY KEY CLUSTERED ([MbolKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MBOL_ExternMbolKey] ON [dbo].[MBOL] ([ExternMbolKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MBOL_status] ON [dbo].[MBOL] ([Status], [ShipCounter], [EffectiveDate]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[MBOL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[MBOL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MBOL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MBOL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MBOL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The MBOL is the standard outbound document that is used to record information on the shipments being transported by the same carrier. In WMS, it is via this document that user will initiate the shipment confirmation for orders that have been picked and loaded into the trucks/containers. Based on the storer configuration, shipment confirmation interface files will be generated.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'truck arrival date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ArrivalDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'truck delivery date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ArrivalDateFinalDestination'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Booking reference number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'BookingReference'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter agent', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Carrieragent'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter that delivers the goods', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CartonCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CartonWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'total case count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying CBOL', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CBOLLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cash on delivery status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'COD_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'consignee key', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ConsigneeAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Container number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ContainerNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNCNT9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton quantity 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNQTY9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', ' Carton type 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton type 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CTNTYPE9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cubic count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton cube', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CubeUnit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EDI ACK Time', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cust_EDIAckTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer GIS Control Number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cust_GIS_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer ISA Control Number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Cust_ISA_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total  orders count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CustCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of customer receiving the products.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'CustomerReceivedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'truck departure date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DepartureDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'deposited status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DepotStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country where the transported goods will be delivered', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DestinationCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'driver''s name', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'DRIVERName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', '(EQUIPMENT)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Equipment'
GO
EXEC sp_addextendedproperty N'MS_Description', 'external MBOLKey from host system', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ExternMbolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The warehouse or DC in which the location is residing', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Finalize flag', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'FinalizeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Exceed GIS Control Number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'GIS_ControlNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'GIS Process Time', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'GIS_ProcessTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice amount', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'InvoiceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the goods are loaded into the truck', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'LoadingDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity''s Description', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'MbolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of carton packed', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofCartonPacked'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of container', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofContainer'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of customer carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofCustomerCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of IDS carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofIDSCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of master carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoOfMasterCtn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total number of pallets involved in the delivery.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofPallets'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of prepacks', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoOfPrepacks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of re-shippable carton', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NoofReshippableCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'notifier key', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'NotifyAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Country from which the transported goods will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'OriginCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Other reference number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'OtherReference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTMShipmentID', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'OTMShipmentID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 6', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 7', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 8', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pack type 9', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PACKTYPE9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'total pallet count', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PalletCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfdelivery'
GO
EXEC sp_addextendedproperty N'MS_Description', 'delivery qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfdeliveryQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Place where the goods will be discharged from the vehicle', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfDischarge'
GO
EXEC sp_addextendedproperty N'MS_Description', 'discharge qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfdischargeQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Area of Truck Loading', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfLoading'
GO
EXEC sp_addextendedproperty N'MS_Description', 'loading qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'PlaceOfLoadingQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'any notes / remarks', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seal number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'SealNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment counter', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ShipCounter'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship date', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ShipDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'shipper key', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ShipperAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'MBOL Status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TimeStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total invoice value', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TotalInvoiceValue'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transport method e.g. land, air, sea etc.', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'TransMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine01', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine02', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine03', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine04', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine05', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine06 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Userdefine07 (datetime)', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine08', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine09', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'userdefine10', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Backend MBOL Validation Status', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'ValidatedFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'carrier number', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Vessel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'carrier qualifier', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'VesselQualifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'To indicate which location the goods are coming from', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'VoyageNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight Unit', 'SCHEMA', N'dbo', 'TABLE', N'MBOL', 'COLUMN', N'WeightUnit'
GO
