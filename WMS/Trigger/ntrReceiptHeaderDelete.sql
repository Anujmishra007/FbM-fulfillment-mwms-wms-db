IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ntrReceiptHeaderDelete]') 
              AND OBJECTPROPERTY(id, N'IsTrigger') = 1) 
DROP trigger [dbo].[ntrReceiptHeaderDelete]

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO





/************************************************************************/
/* Trigger: ntrReceiptHeaderDelete                                      */
/* Creation Date:                                                       */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Udpate Order Header Record                           */
/*                                                                      */
/* PVCS Version: 1.30                                                   */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 14-Jul-2011  KHLim02   1.0   GetRight for Delete log                 */
/* 24-May-2012  TLTING01  1.1   Data integrity - insert dellog 4        */
/*                              status < '9'                            */ 
/* 07-Apr-2017  NJOW01    1.2   Call custom trigger stored proc         */
/* 01-Aug-20195 Wan01     1.3   WMS-9995 [CN] NIKESDC_Exceed_Hold ASN   */
/*                              for Channel                             */
/* 14-Oct-2021  KSChin    1.4   add tracker to DEL_Receipt table        */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrReceiptHeaderDelete]
 ON [dbo].[RECEIPT]
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
      /* #INCLUDE <TRRHD1.SQL> */    

 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
 
   --TLTING01
   IF EXISTS ( SELECT 1 FROM DELETED WHERE [STATUS] < '9' ) AND ( @n_continue = 1 or @n_continue = 2 )
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
               ,@c_errmsg = 'ntrReceiptHeaderDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.RECEIPT_DELLOG ( ReceiptKey )
         SELECT ReceiptKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table RECEIPT Failed. (ntrReceiptHeaderDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

 --NJOW01
 IF @n_continue=1 or @n_continue=2          
 BEGIN   	  
    IF EXISTS (SELECT 1 FROM DELETED d   ----->Put INSERTED if INSERT action
               JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey    
               JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
               WHERE  s.configkey = 'ReceiptTrigger_SP')   -----> Current table trigger storerconfig
    BEGIN        	  
       IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
          DROP TABLE #INSERTED
 
    	 SELECT * 
    	 INTO #INSERTED
    	 FROM INSERTED
        
       IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
          DROP TABLE #DELETED
 
    	 SELECT * 
    	 INTO #DELETED
    	 FROM DELETED
 
       EXECUTE dbo.isp_ReceiptTrigger_Wrapper ----->wrapper for current table trigger
                 'DELETE'  -----> @c_Action can be INSERTE, UPDATE, DELETE
               , @b_Success  OUTPUT  
               , @n_Err      OUTPUT   
               , @c_ErrMsg   OUTPUT  
 
       IF @b_success <> 1  
       BEGIN  
          SELECT @n_continue = 3  
                ,@c_errmsg = 'ntrReceiptHeaderDelete' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  -----> Put current trigger name
       END  
       
       IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
          DROP TABLE #INSERTED
 
       IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
          DROP TABLE #DELETED
    END
 END   

--(Wan01) - START 
IF @n_continue=1 or @n_continue=2          
BEGIN   	
   IF EXISTS ( SELECT 1
               FROM  DELETED WITH (NOLOCK)
               JOIN  RECEIPTDETAIL RD WITH (NOLOCK)
                     ON DELETED.ReceiptKey = RD.ReceiptKey
               WHERE DELETED.HoldChannel = '1'
               AND   RD.QtyReceived > 0
               AND   RD.FinalizeFlag = 'Y'
               AND   RD.Channel_ID > 0 
              )
   BEGIN
      SET @n_continue = 3
      SET @n_err = 68102
      SET @c_errmsg  = CONVERT(char(5),@n_err)+': ASN With Channel Hold found'
                     + '. Delete Abort. (ntrReceiptHeaderDelete)'
   END   
END
--(Wan01) - END

--added by KS Chin
  IF @n_continue = 1 or @n_continue=2  
   BEGIN
   IF EXISTS(SELECT 1 FROM DEL_RECEIPT WITH (NOLOCK) 
               JOIN DELETED ON DELETED.ReceiptKey = DEL_RECEIPT.ReceiptKey )
      BEGIN
         DELETE  DEL_RECEIPT
         FROM   DEL_RECEIPT
         JOIN   DELETED ON DELETED.ReceiptKey = DEL_RECEIPT.ReceiptKey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62401   
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete DEL_RECEIPT Failed. (ntrREceiptHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END   
   INSERT INTO DEL_RECEIPT(ReceiptKey, ExternReceiptKey, ReceiptGroup, StorerKey, ReceiptDate, POKey, 
            CarrierKey, CarrierName, CarrierAddress1, CarrierAddress2, CarrierCity, CarrierState, 
            CarrierZip, CarrierReference, WarehouseReference, OriginCountry, DestinationCountry, 
            VehicleNumber, VehicleDate, PlaceOfLoading, PlaceOfDischarge, PlaceofDelivery, IncoTerms,
            TermsNote, ContainerKey, Signatory, PlaceofIssue, OpenQty, Status, Notes, 
            EffectiveDate, AddDate, AddWho, EditDate, EditWho, TrafficCop, ArchiveCop, ContainerType, ContainerQty, 
            BilledContainerQty, RECType, ASNStatus, ASNReason, Facility, MBOLKey, Appointment_No, 
            LoadKey, xDockFlag, PROCESSTYPE, UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, 
            UserDefine06, UserDefine07, UserDefine08, UserDefine09, UserDefine10, DOCTYPE, RoutingTool, 
            CTNTYPE1, CTNTYPE2, CTNTYPE3, CTNTYPE4, CTNTYPE5, CTNTYPE6, CTNTYPE7, CTNTYPE8, CTNTYPE9, CTNTYPE10, 
            PACKTYPE1, PACKTYPE2, PACKTYPE3, PACKTYPE4, PACKTYPE5, PACKTYPE6, PACKTYPE7, PACKTYPE8, PACKTYPE9, PACKTYPE10,
	         CTNCNT1, CTNCNT2, CTNCNT3, CTNCNT4, CTNCNT5, CTNCNT6, CTNCNT7, CTNCNT8, CTNCNT9, CTNCNT10,
            CTNQTY1, CTNQTY2, CTNQTY3, CTNQTY4, CTNQTY5, CTNQTY6, CTNQTY7, CTNQTY8, CTNQTY9, CTNQTY10,
            NoOfMasterCtn, NoOfTTLUnit, NoOfPallet, Weight, WeightUnit, Cube, CubeUnit, GIS_ControlNo,
	         Cust_ISA_ControlNo, Cust_GIS_ControlNo, GIS_ProcessTime, Cust_EDIAckTime, FinalizeDate, SellerName,
            SellerCompany, SellerAddress1, SellerAddress2 ,SellerAddress3, SellerAddress4, SellerCity,
            SellerState, SellerZip, SellerCountry, SellerContact1, SellerContact2, SellerPhone1, SellerPhone2,
            SellerEmail1, SellerEmail2, SellerFax1, SellerFax2, HoldChannel, TrackingNo)
      SELECT ReceiptKey, ExternReceiptKey, ReceiptGroup, StorerKey, ReceiptDate, POKey, 
            CarrierKey, CarrierName, CarrierAddress1, CarrierAddress2, CarrierCity, CarrierState, 
            CarrierZip, CarrierReference, WarehouseReference, OriginCountry, DestinationCountry, 
            VehicleNumber, VehicleDate, PlaceOfLoading, PlaceOfDischarge, PlaceofDelivery, IncoTerms,
            TermsNote, ContainerKey, Signatory, PlaceofIssue, OpenQty, Status, Notes, 
            EffectiveDate, getdate(), suser_sname(), EditDate, EditWho, TrafficCop, ArchiveCop, ContainerType, ContainerQty, 
            BilledContainerQty, RECType, ASNStatus, ASNReason, Facility, MBOLKey, Appointment_No, 
            LoadKey, xDockFlag, PROCESSTYPE, UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, 
            UserDefine06, UserDefine07, UserDefine08, UserDefine09, UserDefine10, DOCTYPE, RoutingTool, 
            CTNTYPE1, CTNTYPE2, CTNTYPE3, CTNTYPE4, CTNTYPE5, CTNTYPE6, CTNTYPE7, CTNTYPE8, CTNTYPE9, CTNTYPE10, 
            PACKTYPE1, PACKTYPE2, PACKTYPE3, PACKTYPE4, PACKTYPE5, PACKTYPE6, PACKTYPE7, PACKTYPE8, PACKTYPE9, PACKTYPE10,
	         CTNCNT1, CTNCNT2, CTNCNT3, CTNCNT4, CTNCNT5, CTNCNT6, CTNCNT7, CTNCNT8, CTNCNT9, CTNCNT10,
            CTNQTY1, CTNQTY2, CTNQTY3, CTNQTY4, CTNQTY5, CTNQTY6, CTNQTY7, CTNQTY8, CTNQTY9, CTNQTY10,
            NoOfMasterCtn, NoOfTTLUnit, NoOfPallet, Weight, WeightUnit, Cube, CubeUnit, GIS_ControlNo,
	         Cust_ISA_ControlNo, Cust_GIS_ControlNo, GIS_ProcessTime, Cust_EDIAckTime, FinalizeDate, SellerName,
            SellerCompany, SellerAddress1, SellerAddress2 ,SellerAddress3, SellerAddress4, SellerCity,
            SellerState, SellerZip, SellerCountry, SellerContact1, SellerContact2, SellerPhone1, SellerPhone2,
            SellerEmail1, SellerEmail2, SellerFax1, SellerFax2, HoldChannel, TrackingNo FROM DELETED 
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 62401   
         SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Insert DEL_RECEIPT Failed. (ntrReceiptHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END -- Added End by KS Chin


 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 DELETE ReceiptDetail FROM ReceiptDetail, Deleted
 WHERE ReceiptDetail.ReceiptKey=Deleted.ReceiptKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63901   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table RECEIPTDETAIL Failed. (ntrReceiptHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
      /* #INCLUDE <TRRHD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrReceiptHeaderDelete"
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

ALTER TABLE [dbo].[RECEIPT] ENABLE TRIGGER [ntrReceiptHeaderDelete]
GO


