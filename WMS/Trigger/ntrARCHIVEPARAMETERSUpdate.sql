/******************************************************************/
/* Trigger: ntrARCHIVEPARAMETERSUpdate                            */
/* Creation Date:  17-Aug-2022                                    */
/* Copyright: IDS                                                 */
/* Written by:  kelvinongcy                                       */
/*                                                                */
/* Purpose: ARCHIVEPARAMETERS Update                              */
/* Data Modifications:                                            */
/*                                                                */
/* Updates:                                                       */
/* Date         Author    	  Ver   Purposes                       */
/* 2022-08-17   kelvinongcy  1.0   Capture editwho, editdate      */
/*                                 and modification into log      */
/******************************************************************/  
  
CREATE  OR ALTER  TRIGGER [dbo].[ntrARCHIVEPARAMETERSUpdate]  
ON [dbo].[ARCHIVEPARAMETERS]  
FOR UPDATE  
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
   
   DECLARE @n_err            int       -- Error number returned by stored procedure or this trigger  
           ,@c_errmsg        NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
           ,@n_continue      int                   
           ,@n_starttcnt     int                -- Holds the current transaction count  
           ,@n_cnt           int
           ,@c_ColUpd        nvarchar(max)
   
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
  
   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4   
   END 
         
   IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)  
   BEGIN  
      UPDATE ARCHIVEPARAMETERS  
      SET EditDate = GETDATE(),  
          EditWho  = SUSER_SNAME(),  
          TrafficCop = NULL   
      FROM dbo.ARCHIVEPARAMETERS, INSERTED  
      WHERE ARCHIVEPARAMETERS.ArchiveKey = INSERTED.ArchiveKey  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  

      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Err message but I don't know how to do so.  
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on ARCHIVEPARAMETERS table. (ntrARCHIVEPARAMETERSUpdate)"   
                        + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "  
      END  
   END 

   IF (@n_continue = 1 OR @n_continue = 2)
   BEGIN
      INSERT dbo.ARCHIVEPARAMETERSLOG ([Archivekey],[CopyRowsToArchiveDatabase],[ArchiveDataBaseName],[LiveDataBaseName],[ShipNumberofDaysToRetain],[ShipActive],[ShipStorerKeyStart],[ShipStorerKeyEnd],
      [ShipSysOrdStart],[ShipSysOrdEnd],[ShipExternOrderKeyStart],[ShipExternOrderKeyEnd],[ShipOrdTypStart],[ShipOrdTypEnd],[ShipOrdGrpStart],[ShipOrdGrpEnd],[ShipToStart],[ShipToEnd],
      [ShipBillToStart],[ShipBillToEnd],[ShipmentOrderDateType],[AdjNumberofDaysToRetain],[AdjActive],[AdjStart],[AdjEnd],[AdjustmentDateType],[TranNumberofDaysToRetain],[TranActive],[TranStart],[TranEnd],[TransferDateType],
      [PONumberofDaysToRetain],[POActive],[POStorerKeyStart],[POStorerKeyEnd],[POStart],[POEnd],[PODateType],
      [ReceiptNumberofDaysToRetain],[ReceiptActive],[ReceiptStorerKeyStart],[ReceiptStorerKeyEnd],[ReceiptStart],[ReceiptEnd],[ReceiptDateType],
      [ItrnNumberofDaysToRetain],[ItrnActive],[ItrnStorerKeyStart],[ItrnStorerKeyEnd],[ItrnSkuStart],[ItrnSkuEnd],[ItrnLotStart],[ItrnLotEnd],[ItrnDateType],
      [MAWBNumberofDaysToRetain],[MAWBActive],[MAWBStart],[MAWBEnd],[MAWBDateType],[HAWBNumberofDaysToRetain],[HAWBActive],[HAWBStart],[HAWBEnd],[HAWBDateType],
      [ContainerNumberofDaysToRetain],[ContainerActive],[ContainerStart],[ContainerEnd],[ContainerDateType],[PalletNumberofDaysToRetain],[PalletActive],[PalletStart],
      [PalletEnd],[PalletDateType],[CaseMNumberofDaysToRetain],[CaseMActive],[CaseMStorerKeyStart],[CaseMStorerKeyEnd],[CaseMStart],[CaseMEnd],[CaseMDateType],[MbolNumberofDaysToRetain],
      [MbolActive],[MbolStart],[MbolEnd],[MBOLDepDateStart],[MBOLDepDateEnd],[MBOLDelDateStart],[MBOLDelDateEnd],[MbolVoyageStart],[MbolVoyageEnd],[MBOLDateType],
      [PickDateType],[AddDate],[AddWho],[EditDate],[EditWho],[TrafficCop],[ArchiveCop],
      [CCNumberofDaysToRetain],[CCActive],[CCStart],[CCEnd],[CCDateType],
      [AlertNumberofDaysToRetain],[AlertActive],[AlertStart],[AlertEnd],[AlertDateType], [RFDBLogNumberofDaysToRetain],[RFDBLogActive],[RFDBLogDateType],
      [SKULogNumberofDaysToRetain],[SKULogActive],[SKULogDateType],[ErrLogNumberofDaysToRetain],[ErrLogActive],[ErrLogDateType],
      [PackLogNumberofDaysToRetain],[PackLogActive],[PackLogStart],[PackLogEnd],[PackLogDateType],
      [TranmLogNumberofDaysToRetain],[TranmLogActive],[TranmLogStart],[TranmLogEnd],[TranmLogDateType],
      [OrdersLogNumberofDaysToRetain],[OrdersLogActive],[OrdersLogStart],[OrdersLogEnd],[OrdersLogDateType],
      [InvrptLogNumberofDaysToRetain],[InvrptLogActive],[InvrptLogStart],[InvrptLogEnd],[InvrptLogDateType],
      [TrigLogNumberofDaysToRetain],[TrigLogActive],[TrigLogStart],[TrigLogEnd],[TrigLogDateType],
      [PTraceNumberofDaysToRetain],[PTraceActive],[PTraceStart],[PTraceEnd],[PTraceDateType],
      [REPLENISHNumberofDaysToRetain],[REPLENISHActive],[REPLENISHStart],[REPLENISHEnd],[REPLENISHDateType],
      [IDActive],[IDStart],[IDEnd],[InvQCNumberofDaysToRetain],[InvQCActive],[InvQCStart],[InvQCEnd],[InvQCDateType],[InvHoldNumberofDaysToRetain],[InvHoldActive],[InvHoldStart],[InvHoldEnd],[InvHoldDateType],
      [PLSNumberofDaysToRetain],[PLSActive],[PLSStart],[PLSEnd],[PLSDateType],
      [KITNumberofDaysToRetain],[KITActive],[KITStart],[KITEnd],[KITDateType],
      [GUINumberofDaysToRetain],[GUIActive],[GUIInvoiceNoStart],[GUIInvoiceNoEnd],[GUIDateType],
      [RdsPoNumberofDaysToRetain],[RdsPodatetype],[RdsPoActive],[RdsPoStart],[RdsPoEnd],[RdsOrdersNumberofDaysToRetain],[RdsOrdersdatetype],[RdsOrdersActive],[RdsOrdersStart],[RdsOrdersEnd],
      [DailyInvNoofDaysToRetain],[DailyInvActive],[DailyInvStart],[DailyInvEnd],[DailyInvDateType],[DelPickslipNoofDaysToRetain],[DelPickslipActive],[DelPickslipStart],[DelPickslipEnd],[DelPickslipDateType],
      [SMSPODNumberofDaysToRetain],[SMSPODActive],[SMSPODDateType] )
      SELECT
      DEL.[Archivekey],DEL.[CopyRowsToArchiveDatabase],DEL.[ArchiveDataBaseName],DEL.[LiveDataBaseName],DEL.[ShipNumberofDaysToRetain],DEL.[ShipActive],DEL.[ShipStorerKeyStart],DEL.[ShipStorerKeyEnd],
      DEL.[ShipSysOrdStart],DEL.[ShipSysOrdEnd],DEL.[ShipExternOrderKeyStart],DEL.[ShipExternOrderKeyEnd],DEL.[ShipOrdTypStart],DEL.[ShipOrdTypEnd],DEL.[ShipOrdGrpStart],DEL.[ShipOrdGrpEnd],DEL.[ShipToStart],DEL.[ShipToEnd],
      DEL.[ShipBillToStart],DEL.[ShipBillToEnd],DEL.[ShipmentOrderDateType],DEL.[AdjNumberofDaysToRetain],DEL.[AdjActive],DEL.[AdjStart],DEL.[AdjEnd],DEL.[AdjustmentDateType],DEL.[TranNumberofDaysToRetain],DEL.[TranActive],
      DEL.[TranStart],DEL.[TranEnd],DEL.[TransferDateType],DEL.[PONumberofDaysToRetain],DEL.[POActive],DEL.[POStorerKeyStart],DEL.[POStorerKeyEnd],DEL.[POStart],DEL.[POEnd],DEL.[PODateType],DEL.[ReceiptNumberofDaysToRetain],
      DEL.[ReceiptActive],DEL.[ReceiptStorerKeyStart],DEL.[ReceiptStorerKeyEnd],DEL.[ReceiptStart],DEL.[ReceiptEnd],DEL.[ReceiptDateType],DEL.[ItrnNumberofDaysToRetain],DEL.[ItrnActive],DEL.[ItrnStorerKeyStart],
      DEL.[ItrnStorerKeyEnd],DEL.[ItrnSkuStart],DEL.[ItrnSkuEnd],DEL.[ItrnLotStart],DEL.[ItrnLotEnd],DEL.[ItrnDateType],DEL.[MAWBNumberofDaysToRetain],DEL.[MAWBActive],DEL.[MAWBStart],DEL.[MAWBEnd],
      DEL.[MAWBDateType],DEL.[HAWBNumberofDaysToRetain],DEL.[HAWBActive],DEL.[HAWBStart],DEL.[HAWBEnd],DEL.[HAWBDateType],DEL.[ContainerNumberofDaysToRetain],DEL.[ContainerActive],DEL.[ContainerStart],
      DEL.[ContainerEnd],DEL.[ContainerDateType],DEL.[PalletNumberofDaysToRetain],DEL.[PalletActive],DEL.[PalletStart],DEL.[PalletEnd],DEL.[PalletDateType],DEL.[CaseMNumberofDaysToRetain],
      DEL.[CaseMActive],DEL.[CaseMStorerKeyStart],DEL.[CaseMStorerKeyEnd],DEL.[CaseMStart],DEL.[CaseMEnd],DEL.[CaseMDateType],DEL.[MbolNumberofDaysToRetain],DEL.[MbolActive],
      DEL.[MbolStart],DEL.[MbolEnd],DEL.[MBOLDepDateStart],DEL.[MBOLDepDateEnd],DEL.[MBOLDelDateStart],DEL.[MBOLDelDateEnd],DEL.[MbolVoyageStart],DEL.[MbolVoyageEnd],DEL.[MBOLDateType],
      DEL.[PickDateType],GETDATE(), SUSER_NAME (), GETDATE(), SUSER_NAME (), DEL.[TrafficCop],DEL.[ArchiveCop],
      DEL.[CCNumberofDaysToRetain],DEL.[CCActive],DEL.[CCStart],DEL.[CCEnd],DEL.[CCDateType],
      DEL.[AlertNumberofDaysToRetain],DEL.[AlertActive],DEL.[AlertStart],DEL.[AlertEnd],DEL.[AlertDateType],DEL.[RFDBLogNumberofDaysToRetain],DEL.[RFDBLogActive],DEL.[RFDBLogDateType],
      DEL.[SKULogNumberofDaysToRetain],DEL.[SKULogActive],DEL.[SKULogDateType],DEL.[ErrLogNumberofDaysToRetain],DEL.[ErrLogActive], DEL.[ErrLogDateType],
      DEL.[PackLogNumberofDaysToRetain],DEL.[PackLogActive],DEL.[PackLogStart],DEL.[PackLogEnd],DEL.[PackLogDateType],
      DEL.[TranmLogNumberofDaysToRetain],DEL.[TranmLogActive],DEL.[TranmLogStart],DEL.[TranmLogEnd],DEL.[TranmLogDateType],
      DEL.[OrdersLogNumberofDaysToRetain],DEL.[OrdersLogActive],DEL.[OrdersLogStart],DEL.[OrdersLogEnd],DEL.[OrdersLogDateType],DEL.[InvrptLogNumberofDaysToRetain],DEL.[InvrptLogActive],DEL.[InvrptLogStart],
      DEL.[InvrptLogEnd],DEL.[InvrptLogDateType],DEL.[TrigLogNumberofDaysToRetain],DEL.[TrigLogActive],DEL.[TrigLogStart],DEL.[TrigLogEnd],DEL.[TrigLogDateType],
      DEL.[PTraceNumberofDaysToRetain],DEL.[PTraceActive],DEL.[PTraceStart],DEL.[PTraceEnd],DEL.[PTraceDateType],DEL.[REPLENISHNumberofDaysToRetain],DEL.[REPLENISHActive],DEL.[REPLENISHStart],DEL.[REPLENISHEnd],DEL.[REPLENISHDateType],
      DEL.[IDActive],DEL.[IDStart],DEL.[IDEnd],DEL.[InvQCNumberofDaysToRetain],DEL.[InvQCActive],DEL.[InvQCStart],DEL.[InvQCEnd],DEL.[InvQCDateType],
      DEL.[InvHoldNumberofDaysToRetain],DEL.[InvHoldActive],DEL.[InvHoldStart],DEL.[InvHoldEnd],DEL.[InvHoldDateType],
      DEL.[PLSNumberofDaysToRetain],DEL.[PLSActive],DEL.[PLSStart],DEL.[PLSEnd],DEL.[PLSDateType],
      DEL.[KITNumberofDaysToRetain],DEL.[KITActive],DEL.[KITStart],DEL.[KITEnd],DEL.[KITDateType],
      DEL.[GUINumberofDaysToRetain],DEL.[GUIActive],DEL.[GUIInvoiceNoStart],DEL.[GUIInvoiceNoEnd],DEL.[GUIDateType],
      DEL.[RdsPoNumberofDaysToRetain],DEL.[RdsPodatetype],DEL.[RdsPoActive],DEL.[RdsPoStart],DEL.[RdsPoEnd],DEL.[RdsOrdersNumberofDaysToRetain],DEL.[RdsOrdersdatetype],DEL.[RdsOrdersActive],DEL.[RdsOrdersStart],DEL.[RdsOrdersEnd],
      DEL.[DailyInvNoofDaysToRetain],DEL.[DailyInvActive],DEL.[DailyInvStart],DEL.[DailyInvEnd],DEL.[DailyInvDateType],
      DEL.[DelPickslipNoofDaysToRetain],DEL.[DelPickslipActive],DEL.[DelPickslipStart],DEL.[DelPickslipEnd],DEL.[DelPickslipDateType],
      DEL.[SMSPODNumberofDaysToRetain],DEL.[SMSPODActive],DEL.[SMSPODDateType]
      FROM DELETED DEL WITH (NOLOCK)
   END

   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4   
   END 
        
   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt  
      BEGIN  
         ROLLBACK TRAN  
      END  
      execute nsp_logerror @n_err, @c_errmsg, "ntrARCHIVEPARAMETERSUpdate"  
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



