
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/  
/* Trigger: ntrRDTMobRecDelete                                          */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Called By: When rdtmobrec record deleted                             */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/* Date         Author    Ver Purposes                                  */  
/* 05-Jul-2018  James     1.0 Add logging (james01)                     */  
/************************************************************************/  
  
CREATE OR ALTER TRIGGER [RDT].[ntrRDTMobRecDelete] ON [RDT].[RDTMOBREC]   
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

   IF EXISTS(SELECT 1 FROM DELETED   
             JOIN rdtXML ON DELETED.Mobile = rdtXML.Mobile)  
   BEGIN  
      DELETE rdtXML  
      FROM rdtXML  
      JOIN DELETED ON DELETED.Mobile = rdtXML.Mobile  
  
      DELETE rdtXML_Elm  
      FROM rdtXML_Elm  
      JOIN DELETED ON DELETED.Mobile = rdtXML_Elm.Mobile  
  
      DELETE rdtXML_Root  
      FROM rdtXML_Root  
      JOIN DELETED ON DELETED.Mobile = rdtXML_Root.Mobile  
  
      DELETE rdtSessionData  
      FROM rdtSessionData  
      JOIN DELETED ON DELETED.Mobile = rdtSessionData.Mobile  
   END  

   INSERT INTO rdt.RDTMobRec_LOG ( 
      Mobile, Func, Scn, Step, Menu
   ,Lang_Code, InputKey, ErrMsg, StorerKey, Facility
   ,UserName, Printer, MsgQueueNo, V_ReceiptKey, V_POKey
   ,V_LoadKey, V_OrderKey, V_PickSlipNo, V_Zone, V_Loc, V_SKU
   ,V_UOM, V_ID, V_ConsigneeKey, V_CaseID, V_SKUDescr, V_QTY, V_UCC, V_Lot
   ,V_Lottable01, V_Lottable02, V_Lottable03, V_Lottable04, V_Lottable05
   ,V_Lottable06, V_Lottable07, V_Lottable08, V_Lottable09, V_Lottable10
   ,V_Lottable11, V_Lottable12, V_Lottable13, V_Lottable14, V_Lottable15
   ,V_LottableLabel01, V_LottableLabel02, V_LottableLabel03, V_LottableLabel04, V_LottableLabel05
   ,V_LottableLabel06, V_LottableLabel07, V_LottableLabel08, V_LottableLabel09, V_LottableLabel10
   ,V_LottableLabel11, V_LottableLabel12, V_LottableLabel13, V_LottableLabel14, V_LottableLabel15
   ,I_Field01, I_Field02, I_Field03, I_Field04, I_Field05
   ,I_Field06, I_Field07, I_Field08, I_Field09, I_Field10
   ,I_Field11, I_Field12, I_Field13, I_Field14, I_Field15
   ,O_Field01, O_Field02, O_Field03, O_Field04, O_Field05
   ,O_Field06, O_Field07, O_Field08, O_Field09, O_Field10
   ,O_Field11, O_Field12, O_Field13, O_Field14, O_Field15
   ,V_String1, V_String2, V_String3, V_String4, V_String5
   ,V_String6, V_String7, V_String8, V_String9, V_String10
   ,V_String11, V_String12, V_String13, V_String14, V_String15
   ,V_String16, V_String17, V_String18, V_String19, V_String20
   ,V_String21, V_String22, V_String23, V_String24, V_String25
   ,V_String26, V_String27, V_String28, V_String29, V_String30
   ,V_String31, V_String32, V_String33, V_String34, V_String35
   ,V_String36, V_String37, V_String38, V_String39, V_String40
   ,FieldAttr01, FieldAttr02, FieldAttr03, FieldAttr04, FieldAttr05
   ,FieldAttr06, FieldAttr07, FieldAttr08, FieldAttr09, FieldAttr10
   ,FieldAttr11, FieldAttr12, FieldAttr13, FieldAttr14, FieldAttr15
   ,AddDate, EditDate, Printer_Paper, MenuStack, V_TaskDetailKey
   ,V_Max, RemotePrint, DeviceID, LightMode, StorerGroup
   ,V_StorerKey, V_String41, V_String42, V_String43, V_String44
   ,V_String45, V_String46, V_String47, V_String48, V_String49
   ,V_String50, V_WaveKey, [Status], AppName, ProcID, UserNameAfterLog 
   ,V_Cartonno, V_PUOM_Div, V_MQTY, V_PQTY, V_FromScn
   ,V_FromStep, V_MTaskQty, V_PTaskQty, V_TaskQTY, V_Integer1
   ,V_Integer2, V_Integer3, V_Integer4, V_Integer5, V_Integer6
   ,V_Integer7, V_Integer8, V_Integer9, V_Integer10, V_Integer11
   ,V_Integer12, V_Integer13, V_Integer14, V_Integer15, V_DateTime1
   ,V_DateTime2, V_DateTime3, V_DateTime4, V_DateTime5, I_Field16
   ,I_Field17, I_Field18, I_Field19, I_Field20, O_Field16
   ,O_Field17, O_Field18, O_Field19, O_Field20, FieldAttr16
   ,FieldAttr17, FieldAttr18, FieldAttr19, FieldAttr20, V_DropID)     
   SELECT 
    Mobile, Func, Scn, Step, Menu
   ,Lang_Code, InputKey, ErrMsg, StorerKey, Facility
   ,UserName, Printer, MsgQueueNo, V_ReceiptKey, V_POKey
   ,V_LoadKey, V_OrderKey, V_PickSlipNo, V_Zone, V_Loc, V_SKU
   ,V_UOM, V_ID, V_ConsigneeKey, V_CaseID, V_SKUDescr, V_QTY, V_UCC, V_Lot
   ,V_Lottable01, V_Lottable02, V_Lottable03, V_Lottable04, V_Lottable05
   ,V_Lottable06, V_Lottable07, V_Lottable08, V_Lottable09, V_Lottable10
   ,V_Lottable11, V_Lottable12, V_Lottable13, V_Lottable14, V_Lottable15
   ,V_LottableLabel01, V_LottableLabel02, V_LottableLabel03, V_LottableLabel04, V_LottableLabel05
   ,V_LottableLabel06, V_LottableLabel07, V_LottableLabel08, V_LottableLabel09, V_LottableLabel10
   ,V_LottableLabel11, V_LottableLabel12, V_LottableLabel13, V_LottableLabel14, V_LottableLabel15
   ,I_Field01, I_Field02, I_Field03, I_Field04, I_Field05
   ,I_Field06, I_Field07, I_Field08, I_Field09, I_Field10
   ,I_Field11, I_Field12, I_Field13, I_Field14, I_Field15
   ,O_Field01, O_Field02, O_Field03, O_Field04, O_Field05
   ,O_Field06, O_Field07, O_Field08, O_Field09, O_Field10
   ,O_Field11, O_Field12, O_Field13, O_Field14, O_Field15
   ,V_String1, V_String2, V_String3, V_String4, V_String5
   ,V_String6, V_String7, V_String8, V_String9, V_String10
   ,V_String11, V_String12, V_String13, V_String14, V_String15
   ,V_String16, V_String17, V_String18, V_String19, V_String20
   ,V_String21, V_String22, V_String23, V_String24, V_String25
   ,V_String26, V_String27, V_String28, V_String29, V_String30
   ,V_String31, V_String32, V_String33, V_String34, V_String35
   ,V_String36, V_String37, V_String38, V_String39, V_String40
   ,FieldAttr01, FieldAttr02, FieldAttr03, FieldAttr04, FieldAttr05
   ,FieldAttr06, FieldAttr07, FieldAttr08, FieldAttr09, FieldAttr10
   ,FieldAttr11, FieldAttr12, FieldAttr13, FieldAttr14, FieldAttr15
   ,AddDate, EditDate, Printer_Paper, MenuStack, V_TaskDetailKey
   ,V_Max, RemotePrint, DeviceID, LightMode, StorerGroup
   ,V_StorerKey, V_String41, V_String42, V_String43, V_String44
   ,V_String45, V_String46, V_String47, V_String48, V_String49
   ,V_String50, V_WaveKey, '2', APP_NAME(), OBJECT_NAME( @@PROCID), UserName 
   ,V_Cartonno, V_PUOM_Div, V_MQTY, V_PQTY, V_FromScn
   ,V_FromStep, V_MTaskQty, V_PTaskQty, V_TaskQTY, V_Integer1
   ,V_Integer2, V_Integer3, V_Integer4, V_Integer5, V_Integer6
   ,V_Integer7, V_Integer8, V_Integer9, V_Integer10, V_Integer11
   ,V_Integer12, V_Integer13, V_Integer14, V_Integer15, V_DateTime1
   ,V_DateTime2, V_DateTime3, V_DateTime4, V_DateTime5, I_Field16
   ,I_Field17, I_Field18, I_Field19, I_Field20, O_Field16
   ,O_Field17, O_Field18, O_Field19, O_Field20, FieldAttr16
   ,FieldAttr17, FieldAttr18, FieldAttr19, FieldAttr20, V_DropID
   FROM DELETED  
END
GO

ALTER TABLE [RDT].[RDTMOBREC] ENABLE TRIGGER [ntrRDTMobRecDelete]
GO


