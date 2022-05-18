
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 

/************************************************************************/
/* Trigger: ntrRDTMobRecUpdate                                          */
/* Creation Date: 01-Jan-2011                                           */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Update RDTMobRec Trigger                                    */
/*                                                                      */
/* Called By: trigger                                                   */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 06-Jun-2011  TLTING    1.1 SOS 212003 - performance tune             */
/* 03-Jan-2012  KPChew    1.2 LCI Project changes.                      */
/* 03-Jan-2012  Leong     1.3 SOS 233333 - Add RDTCCLock deletion       */
/*                                         (james01)                    */
/* 28-Apr-2012  Shong     1.4   Transfer the Delete RDTDynamicPickLog   */
/*                              When User RESET                         */
/* 28-Oct-2013  TLTING    1.5 Review Editdate column update             */
/* 28-Mar-2015  James     1.6 SOS330761-Fix fieldattr not reset(james02)*/
/* 05-Jul-2018  James     1.7 Add logging (james03)                     */
/* 06-Jul-2018  James     1.8 Prevent batch Reset active user (james04) */
/* 03-Jun-2021  YeeKung   1.9 Remove the retired user (yeekung01)       */
/************************************************************************/

CREATE TRIGGER [RDT].[ntrRDTMobRecUpdate]
ON [RDT].[RDTMOBREC]
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
   
   DECLARE @n_continue INT,
           @n_starttcnt INT,
           @n_err         INT,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250)

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT
    
   IF NOT UPDATE(EditDate)
   BEGIN
      
      UPDATE RDTMOBREC WITH (ROWLOCK)
         SET EditDate = GETDATE()
      FROM RDTMOBREC
      JOIN INSERTED ON INSERTED.Mobile = RDTMOBREC.Mobile
   END
   
   IF UPDATE(UserName)
   BEGIN
      DECLARE @nCount INT
      SELECT @nCount = COUNT(DELETED.UserName) FROM INSERTED
                  JOIN DELETED ON INSERTED.Mobile = DELETED.Mobile 
                  WHERE INSERTED.UserName = 'RESET'
                  AND INSERTED.Mobile IS NOT NULL
                  AND DATEDIFF( MI, INSERTED.EDITDATE, GETDATE()) < 120  -- Less than 2 hours session cannot reset
                  AND INSERTED.Func > 0

      IF @nCount > 1
      BEGIN
         -- Insert data into memory table first before logging

         DECLARE @RDTMobRec_LOG_Temp TABLE (
	         [Mobile] [INT] NOT NULL,
	         [Func] [INT] NOT NULL,
	         [Scn] [INT] NOT NULL,
	         [Step] [INT] NOT NULL,
	         [Menu] [INT] NOT NULL,
	         [Lang_Code] [NVARCHAR](3) NULL,
	         [InputKey] [INT] NOT NULL,
	         [ErrMsg] [NVARCHAR](125) NULL,
	         [StorerKey] [NVARCHAR](15) NULL,
	         [Facility] [NVARCHAR](5) NULL,
	         [UserName] [NVARCHAR](18) NOT NULL,
	         [Printer] [NVARCHAR](10) NULL,
	         [MsgQueueNo] [INT] NULL,
	         [V_ReceiptKey] [NVARCHAR](10) NULL,
	         [V_POKey] [NVARCHAR](10) NULL,
	         [V_LoadKey] [NVARCHAR](10) NULL,
	         [V_OrderKey] [NVARCHAR](10) NULL,
	         [V_PickSlipNo] [NVARCHAR](10) NULL,
	         [V_Zone] [NVARCHAR](10) NULL,
	         [V_Loc] [NVARCHAR](10) NULL,
	         [V_SKU] [NVARCHAR](20) NULL,
	         [V_UOM] [NVARCHAR](10) NULL,
	         [V_ID] [NVARCHAR](20) NULL,
	         [V_ConsigneeKey] [NVARCHAR](15) NULL,
	         [V_CaseID] [NVARCHAR](20) NULL,
	         [V_SKUDescr] [NVARCHAR](60) NULL,
	         [V_QTY] [INT] NULL,
	         [V_UCC] [NVARCHAR](20) NULL,
	         [V_Lot] [NVARCHAR](10) NULL,
	         [V_Lottable01] [NVARCHAR](18) NULL,
	         [V_Lottable02] [NVARCHAR](18) NULL,
	         [V_Lottable03] [NVARCHAR](18) NULL,
	         [V_Lottable04] [DATETIME] NULL,
	         [V_Lottable05] [DATETIME] NULL,
	         [V_Lottable06] [NVARCHAR](30) NULL,
	         [V_Lottable07] [NVARCHAR](30) NULL,
	         [V_Lottable08] [NVARCHAR](30) NULL,
	         [V_Lottable09] [NVARCHAR](30) NULL,
	         [V_Lottable10] [NVARCHAR](30) NULL,
	         [V_Lottable11] [NVARCHAR](30) NULL,
	         [V_Lottable12] [NVARCHAR](30) NULL,
	         [V_Lottable13] [DATETIME] NULL,
	         [V_Lottable14] [DATETIME] NULL,
	         [V_Lottable15] [DATETIME] NULL,
	         [V_LottableLabel01] [NVARCHAR](20) NULL,
	         [V_LottableLabel02] [NVARCHAR](20) NULL,
	         [V_LottableLabel03] [NVARCHAR](20) NULL,
	         [V_LottableLabel04] [NVARCHAR](20) NULL,
	         [V_LottableLabel05] [NVARCHAR](20) NULL,
	         [V_LottableLabel06] [NVARCHAR](20) NULL,
	         [V_LottableLabel07] [NVARCHAR](20) NULL,
	         [V_LottableLabel08] [NVARCHAR](20) NULL,
	         [V_LottableLabel09] [NVARCHAR](20) NULL,
	         [V_LottableLabel10] [NVARCHAR](20) NULL,
	         [V_LottableLabel11] [NVARCHAR](20) NULL,
	         [V_LottableLabel12] [NVARCHAR](20) NULL,
	         [V_LottableLabel13] [NVARCHAR](20) NULL,
	         [V_LottableLabel14] [NVARCHAR](20) NULL,
	         [V_LottableLabel15] [NVARCHAR](20) NULL,
	         [I_Field01] [NVARCHAR](60) NULL,
	         [I_Field02] [NVARCHAR](60) NULL,
	         [I_Field03] [NVARCHAR](60) NULL,
	         [I_Field04] [NVARCHAR](60) NULL,
	         [I_Field05] [NVARCHAR](60) NULL,
	         [I_Field06] [NVARCHAR](60) NULL,
	         [I_Field07] [NVARCHAR](60) NULL,
	         [I_Field08] [NVARCHAR](60) NULL,
	         [I_Field09] [NVARCHAR](60) NULL,
	         [I_Field10] [NVARCHAR](60) NULL,
	         [I_Field11] [NVARCHAR](60) NULL,
	         [I_Field12] [NVARCHAR](60) NULL,
	         [I_Field13] [NVARCHAR](60) NULL,
	         [I_Field14] [NVARCHAR](60) NULL,
	         [I_Field15] [NVARCHAR](60) NULL,
	         [O_Field01] [NVARCHAR](60) NULL,
	         [O_Field02] [NVARCHAR](60) NULL,
	         [O_Field03] [NVARCHAR](60) NULL,
	         [O_Field04] [NVARCHAR](60) NULL,
	         [O_Field05] [NVARCHAR](60) NULL,
	         [O_Field06] [NVARCHAR](60) NULL,
	         [O_Field07] [NVARCHAR](60) NULL,
	         [O_Field08] [NVARCHAR](60) NULL,
	         [O_Field09] [NVARCHAR](60) NULL,
	         [O_Field10] [NVARCHAR](60) NULL,
	         [O_Field11] [NVARCHAR](60) NULL,
	         [O_Field12] [NVARCHAR](60) NULL,
	         [O_Field13] [NVARCHAR](60) NULL,
	         [O_Field14] [NVARCHAR](60) NULL,
	         [O_Field15] [NVARCHAR](60) NULL,
	         [V_String1] [NVARCHAR](20) NULL,
	         [V_String2] [NVARCHAR](20) NULL,
	         [V_String3] [NVARCHAR](20) NULL,
	         [V_String4] [NVARCHAR](20) NULL,
	         [V_String5] [NVARCHAR](20) NULL,
	         [V_String6] [NVARCHAR](20) NULL,
	         [V_String7] [NVARCHAR](20) NULL,
	         [V_String8] [NVARCHAR](20) NULL,
	         [V_String9] [NVARCHAR](20) NULL,
	         [V_String10] [NVARCHAR](20) NULL,
	         [V_String11] [NVARCHAR](20) NULL,
	         [V_String12] [NVARCHAR](20) NULL,
	         [V_String13] [NVARCHAR](20) NULL,
	         [V_String14] [NVARCHAR](20) NULL,
	         [V_String15] [NVARCHAR](20) NULL,
	         [V_String16] [NVARCHAR](20) NULL,
	         [V_String17] [NVARCHAR](20) NULL,
	         [V_String18] [NVARCHAR](20) NULL,
	         [V_String19] [NVARCHAR](20) NULL,
	         [V_String20] [NVARCHAR](20) NULL,
	         [V_String21] [NVARCHAR](20) NULL,
	         [V_String22] [NVARCHAR](20) NULL,
	         [V_String23] [NVARCHAR](20) NULL,
	         [V_String24] [NVARCHAR](20) NULL,
	         [V_String25] [NVARCHAR](20) NULL,
	         [V_String26] [NVARCHAR](20) NULL,
	         [V_String27] [NVARCHAR](20) NULL,
	         [V_String28] [NVARCHAR](20) NULL,
	         [V_String29] [NVARCHAR](20) NULL,
	         [V_String30] [NVARCHAR](20) NULL,
	         [V_String31] [NVARCHAR](20) NULL,
	         [V_String32] [NVARCHAR](20) NULL,
	         [V_String33] [NVARCHAR](20) NULL,
	         [V_String34] [NVARCHAR](20) NULL,
	         [V_String35] [NVARCHAR](20) NULL,
	         [V_String36] [NVARCHAR](20) NULL,
	         [V_String37] [NVARCHAR](20) NULL,
	         [V_String38] [NVARCHAR](20) NULL,
	         [V_String39] [NVARCHAR](20) NULL,
	         [V_String40] [NVARCHAR](20) NULL,
	         [FieldAttr01] [NVARCHAR](1) NULL,
	         [FieldAttr02] [NVARCHAR](1) NULL,
	         [FieldAttr03] [NVARCHAR](1) NULL,
	         [FieldAttr04] [NVARCHAR](1) NULL,
	         [FieldAttr05] [NVARCHAR](1) NULL,
	         [FieldAttr06] [NVARCHAR](1) NULL,
	         [FieldAttr07] [NVARCHAR](1) NULL,
	         [FieldAttr08] [NVARCHAR](1) NULL,
	         [FieldAttr09] [NVARCHAR](1) NULL,
	         [FieldAttr10] [NVARCHAR](1) NULL,
	         [FieldAttr11] [NVARCHAR](1) NULL,
	         [FieldAttr12] [NVARCHAR](1) NULL,
	         [FieldAttr13] [NVARCHAR](1) NULL,
	         [FieldAttr14] [NVARCHAR](1) NULL,
	         [FieldAttr15] [NVARCHAR](1) NULL,
	         [AddDate] [DATETIME] NULL,
	         [EditDate] [DATETIME] NULL,
	         [Printer_Paper] [NVARCHAR](10) NULL,
	         [MenuStack] [NVARCHAR](60) NULL,
	         [V_TaskDetailKey] [NVARCHAR](10) NULL,
	         [V_Max] [NVARCHAR](MAX) NOT NULL,
	         [RemotePrint] [INT] NULL,
	         [DeviceID] [NVARCHAR](20) NULL,
	         [LightMode] [NVARCHAR](10) NULL,
	         [StorerGroup] [NVARCHAR](20) NOT NULL,
	         [V_StorerKey] [NVARCHAR](15) NOT NULL,
	         [V_String41] [NVARCHAR](60) NOT NULL,
	         [V_String42] [NVARCHAR](60) NOT NULL,
	         [V_String43] [NVARCHAR](60) NOT NULL,
	         [V_String44] [NVARCHAR](60) NOT NULL,
	         [V_String45] [NVARCHAR](60) NOT NULL,
	         [V_String46] [NVARCHAR](60) NOT NULL,
	         [V_String47] [NVARCHAR](60) NOT NULL,
	         [V_String48] [NVARCHAR](60) NOT NULL,
	         [V_String49] [NVARCHAR](60) NOT NULL,
	         [V_String50] [NVARCHAR](60) NOT NULL,
	         [V_WaveKey] [NVARCHAR](10) NOT NULL,
            [Status] [NVARCHAR](10) NOT NULL,
            [AppName] [NVARCHAR](1000) NOT NULL,
            [ProcID] [NVARCHAR](1000) NOT NULL,
            [UserNameAfterLog] [NVARCHAR](18) NOT NULL,
            [V_Cartonno] [INT] NULL,          
            [V_PUOM_Div] [INT] NULL,          
            [V_MQTY] [INT] NULL,              
            [V_PQTY] [INT] NULL,              
            [V_FromScn] [INT] NULL,           
            [V_FromStep] [INT] NULL,          
            [V_MTaskQty] [INT] NULL,          
            [V_PTaskQty] [INT] NULL,          
            [V_TaskQTY] [INT] NULL,           
            [V_Integer1] [INT] NULL,          
            [V_Integer2] [INT] NULL,          
            [V_Integer3] [INT] NULL,          
            [V_Integer4] [INT] NULL,          
            [V_Integer5] [INT] NULL,          
            [V_Integer6] [INT] NULL,          
            [V_Integer7] [INT] NULL,          
            [V_Integer8] [INT] NULL,          
            [V_Integer9] [INT] NULL,          
            [V_Integer10] [INT] NULL,         
            [V_Integer11] [INT] NULL,         
            [V_Integer12] [INT] NULL,         
            [V_Integer13] [INT] NULL,         
            [V_Integer14] [INT] NULL,         
            [V_Integer15] [INT] NULL,         
            [V_DateTime1] [DATETIME] NULL,    
            [V_DateTime2] [DATETIME] NULL,    
            [V_DateTime3] [DATETIME] NULL,    
            [V_DateTime4] [DATETIME] NULL,    
            [V_DateTime5] [DATETIME] NULL,    
            [I_Field16] [NVARCHAR](60) NULL,  
            [I_Field17] [NVARCHAR](60) NULL,  
            [I_Field18] [NVARCHAR](60) NULL,  
            [I_Field19] [NVARCHAR](60) NULL,  
            [I_Field20] [NVARCHAR](60) NULL,  
            [O_Field16] [NVARCHAR](60) NULL,  
            [O_Field17] [NVARCHAR](60) NULL,  
            [O_Field18] [NVARCHAR](60) NULL,  
            [O_Field19] [NVARCHAR](60) NULL,  
            [O_Field20] [NVARCHAR](60) NULL,  
            [FieldAttr16] [NVARCHAR](1) NULL, 
            [FieldAttr17] [NVARCHAR](1) NULL, 
            [FieldAttr18] [NVARCHAR](1) NULL, 
            [FieldAttr19] [NVARCHAR](1) NULL, 
            [FieldAttr20] [NVARCHAR](1) NULL, 
            [V_DropID] [NVARCHAR](20) NULL)

         INSERT INTO @RDTMobRec_LOG_Temp (
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
            ,FieldAttr17, FieldAttr18, FieldAttr19,FieldAttr20, V_DropID)
         SELECT 
             DELETED.Mobile, DELETED.Func, DELETED.Scn, DELETED.Step, DELETED.Menu
            ,DELETED.Lang_Code, DELETED.InputKey, DELETED.ErrMsg, DELETED.StorerKey, DELETED.Facility
            ,DELETED.UserName, DELETED.Printer, DELETED.MsgQueueNo, DELETED.V_ReceiptKey, DELETED.V_POKey
            ,DELETED.V_LoadKey, DELETED.V_OrderKey, DELETED.V_PickSlipNo, DELETED.V_Zone, DELETED.V_Loc, DELETED.V_SKU
            ,DELETED.V_UOM, DELETED.V_ID, DELETED.V_ConsigneeKey, DELETED.V_CaseID, DELETED.V_SKUDescr, DELETED.V_QTY, DELETED.V_UCC, DELETED.V_Lot
            ,DELETED.V_Lottable01, DELETED.V_Lottable02, DELETED.V_Lottable03, DELETED.V_Lottable04, DELETED.V_Lottable05
            ,DELETED.V_Lottable06, DELETED.V_Lottable07, DELETED.V_Lottable08, DELETED.V_Lottable09, DELETED.V_Lottable10
            ,DELETED.V_Lottable11, DELETED.V_Lottable12, DELETED.V_Lottable13, DELETED.V_Lottable14, DELETED.V_Lottable15
            ,DELETED.V_LottableLabel01, DELETED.V_LottableLabel02, DELETED.V_LottableLabel03, DELETED.V_LottableLabel04, DELETED.V_LottableLabel05
            ,DELETED.V_LottableLabel06, DELETED.V_LottableLabel07, DELETED.V_LottableLabel08, DELETED.V_LottableLabel09, DELETED.V_LottableLabel10
            ,DELETED.V_LottableLabel11, DELETED.V_LottableLabel12, DELETED.V_LottableLabel13, DELETED.V_LottableLabel14, DELETED.V_LottableLabel15
            ,DELETED.I_Field01, DELETED.I_Field02, DELETED.I_Field03, DELETED.I_Field04, DELETED.I_Field05
            ,DELETED.I_Field06, DELETED.I_Field07, DELETED.I_Field08, DELETED.I_Field09, DELETED.I_Field10
            ,DELETED.I_Field11, DELETED.I_Field12, DELETED.I_Field13, DELETED.I_Field14, DELETED.I_Field15
            ,DELETED.O_Field01, DELETED.O_Field02, DELETED.O_Field03, DELETED.O_Field04, DELETED.O_Field05
            ,DELETED.O_Field06, DELETED.O_Field07, DELETED.O_Field08, DELETED.O_Field09, DELETED.O_Field10
            ,DELETED.O_Field11, DELETED.O_Field12, DELETED.O_Field13, DELETED.O_Field14, DELETED.O_Field15
            ,DELETED.V_String1, DELETED.V_String2, DELETED.V_String3, DELETED.V_String4, DELETED.V_String5
            ,DELETED.V_String6, DELETED.V_String7, DELETED.V_String8, DELETED.V_String9, DELETED.V_String10
            ,DELETED.V_String11, DELETED.V_String12, DELETED.V_String13, DELETED.V_String14, DELETED.V_String15
            ,DELETED.V_String16, DELETED.V_String17, DELETED.V_String18, DELETED.V_String19, DELETED.V_String20
            ,DELETED.V_String21, DELETED.V_String22, DELETED.V_String23, DELETED.V_String24, DELETED.V_String25
            ,DELETED.V_String26, DELETED.V_String27, DELETED.V_String28, DELETED.V_String29, DELETED.V_String30
            ,DELETED.V_String31, DELETED.V_String32, DELETED.V_String33, DELETED.V_String34, DELETED.V_String35
            ,DELETED.V_String36, DELETED.V_String37, DELETED.V_String38, DELETED.V_String39, DELETED.V_String40
            ,DELETED.FieldAttr01, DELETED.FieldAttr02, DELETED.FieldAttr03, DELETED.FieldAttr04, DELETED.FieldAttr05
            ,DELETED.FieldAttr06, DELETED.FieldAttr07, DELETED.FieldAttr08, DELETED.FieldAttr09, DELETED.FieldAttr10
            ,DELETED.FieldAttr11, DELETED.FieldAttr12, DELETED.FieldAttr13, DELETED.FieldAttr14, DELETED.FieldAttr15
            ,DELETED.AddDate, DELETED.EditDate, DELETED.Printer_Paper, DELETED.MenuStack, DELETED.V_TaskDetailKey
            ,DELETED.V_Max, DELETED.RemotePrint, DELETED.DeviceID, DELETED.LightMode, DELETED.StorerGroup
            ,DELETED.V_StorerKey, DELETED.V_String41, DELETED.V_String42, DELETED.V_String43, DELETED.V_String44
            ,DELETED.V_String45, DELETED.V_String46, DELETED.V_String47, DELETED.V_String48, DELETED.V_String49
            ,DELETED.V_String50, DELETED.V_WaveKey, '1', APP_NAME(), OBJECT_NAME( @@PROCID), INSERTED.UserName
            ,DELETED.V_Cartonno, DELETED.V_PUOM_Div, DELETED.V_MQTY, DELETED.V_PQTY, DELETED.V_FromScn
            ,DELETED.V_FromStep, DELETED.V_MTaskQty, DELETED.V_PTaskQty, DELETED.V_TaskQTY, DELETED.V_Integer1
            ,DELETED.V_Integer2, DELETED.V_Integer3, DELETED.V_Integer4, DELETED.V_Integer5, DELETED.V_Integer6
            ,DELETED.V_Integer7, DELETED.V_Integer8, DELETED.V_Integer9, DELETED.V_Integer10, DELETED.V_Integer11
            ,DELETED.V_Integer12, DELETED.V_Integer13, DELETED.V_Integer14, DELETED.V_Integer15, DELETED.V_DateTime1
            ,DELETED.V_DateTime2, DELETED.V_DateTime3, DELETED.V_DateTime4, DELETED.V_DateTime5, DELETED.I_Field16
            ,DELETED.I_Field17, DELETED.I_Field18, DELETED.I_Field19, DELETED.I_Field20, DELETED.O_Field16
            ,DELETED.O_Field17, DELETED.O_Field18, DELETED.O_Field19, DELETED.O_Field20, DELETED.FieldAttr16
            ,DELETED.FieldAttr17, DELETED.FieldAttr18, DELETED.FieldAttr19, DELETED.FieldAttr20, DELETED.V_DropID            
         FROM INSERTED
         JOIN DELETED ON INSERTED.Mobile = DELETED.Mobile 
         WHERE INSERTED.UserName = 'RESET'
         AND INSERTED.Mobile IS NOT NULL
         AND DATEDIFF( MI, INSERTED.EDITDATE, GETDATE()) < 120  -- Less than 2 hours session cannot reset
         AND INSERTED.Func > 0

		   SELECT @n_continue = 3
		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Reset > 1 active user not allowed. (ntrRDTMobRecUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END

      IF @n_continue = 1
      BEGIN
         IF EXISTS ( SELECT 1 FROM RDT.RDTPickLock RPL WITH (NOLOCK)
                     JOIN INSERTED INSERTED ON INSERTED.Mobile = RPL.Mobile
                     WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
                     AND INSERTED.Mobile IS NOT NULL
                     AND RPL.Status = '1')
         BEGIN
            DELETE RPL WITH (ROWLOCK)
            FROM RDT.RDTPickLock RPL
            JOIN INSERTED INSERTED ON INSERTED.Mobile = RPL.Mobile
            WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
            AND INSERTED.Mobile IS NOT NULL
            AND RPL.Status = '1'
         END

         IF EXISTS (     Select 1 FROM RDT.RDTDynamicPickLog RPL (NOLOCK)  
               JOIN DELETED DELETED ON DELETED.UserName = RPL.AddWho  
               JOIN INSERTED INSERTED ON DELETED.MOBILE = INSERTED.MOBILE
               WHERE INSERTED.UserName IN ('RESET', 'RETIRED')  
               AND INSERTED.Mobile IS NOT NULL  )
         BEGIN
            DELETE RPL WITH (ROWLOCK) 
            FROM RDT.RDTDynamicPickLog RPL 
            JOIN DELETED DELETED ON DELETED.UserName = RPL.AddWho
            JOIN INSERTED INSERTED ON DELETED.Mobile = INSERTED.Mobile
            WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
            AND INSERTED.Mobile IS NOT NULL
         END
      
         IF EXISTS ( SELECT 1 FROM RDT.RDTCCLOCK CCL WITH (NOLOCK)
                     JOIN INSERTED INSERTED ON INSERTED.Mobile = CCL.Mobile
                     WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
                     AND INSERTED.Mobile IS NOT NULL
                     AND CCL.Status < '9')
         BEGIN
            -- delete rdtcclock when doing reset (james01)
            DELETE CCL WITH (ROWLOCK)
            FROM RDT.RDTCCLOCK CCL
            JOIN INSERTED INSERTED ON INSERTED.Mobile = CCL.Mobile
            WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
            AND INSERTED.Mobile IS NOT NULL
            AND CCL.Status < '9'
         END

         IF EXISTS ( SELECT 1 FROM RDT.RDTMobRec RDTMOB WITH (NOLOCK)
                     JOIN INSERTED INSERTED ON INSERTED.Mobile = RDTMOB.Mobile
                     WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
                     AND INSERTED.Mobile IS NOT NULL )
         BEGIN
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
            ,FieldAttr17, FieldAttr18, FieldAttr19,FieldAttr20, V_DropID)     
             SELECT 
             DELETED.Mobile, DELETED.Func, DELETED.Scn, DELETED.Step, DELETED.Menu
            ,DELETED.Lang_Code, DELETED.InputKey, DELETED.ErrMsg, DELETED.StorerKey, DELETED.Facility
            ,DELETED.UserName, DELETED.Printer, DELETED.MsgQueueNo, DELETED.V_ReceiptKey, DELETED.V_POKey
            ,DELETED.V_LoadKey, DELETED.V_OrderKey, DELETED.V_PickSlipNo, DELETED.V_Zone, DELETED.V_Loc, DELETED.V_SKU
            ,DELETED.V_UOM, DELETED.V_ID, DELETED.V_ConsigneeKey, DELETED.V_CaseID, DELETED.V_SKUDescr, DELETED.V_QTY, DELETED.V_UCC, DELETED.V_Lot
            ,DELETED.V_Lottable01, DELETED.V_Lottable02, DELETED.V_Lottable03, DELETED.V_Lottable04, DELETED.V_Lottable05
            ,DELETED.V_Lottable06, DELETED.V_Lottable07, DELETED.V_Lottable08, DELETED.V_Lottable09, DELETED.V_Lottable10
            ,DELETED.V_Lottable11, DELETED.V_Lottable12, DELETED.V_Lottable13, DELETED.V_Lottable14, DELETED.V_Lottable15
            ,DELETED.V_LottableLabel01, DELETED.V_LottableLabel02, DELETED.V_LottableLabel03, DELETED.V_LottableLabel04, DELETED.V_LottableLabel05
            ,DELETED.V_LottableLabel06, DELETED.V_LottableLabel07, DELETED.V_LottableLabel08, DELETED.V_LottableLabel09, DELETED.V_LottableLabel10
            ,DELETED.V_LottableLabel11, DELETED.V_LottableLabel12, DELETED.V_LottableLabel13, DELETED.V_LottableLabel14, DELETED.V_LottableLabel15
            ,DELETED.I_Field01, DELETED.I_Field02, DELETED.I_Field03, DELETED.I_Field04, DELETED.I_Field05
            ,DELETED.I_Field06, DELETED.I_Field07, DELETED.I_Field08, DELETED.I_Field09, DELETED.I_Field10
            ,DELETED.I_Field11, DELETED.I_Field12, DELETED.I_Field13, DELETED.I_Field14, DELETED.I_Field15
            ,DELETED.O_Field01, DELETED.O_Field02, DELETED.O_Field03, DELETED.O_Field04, DELETED.O_Field05
            ,DELETED.O_Field06, DELETED.O_Field07, DELETED.O_Field08, DELETED.O_Field09, DELETED.O_Field10
            ,DELETED.O_Field11, DELETED.O_Field12, DELETED.O_Field13, DELETED.O_Field14, DELETED.O_Field15
            ,DELETED.V_String1, DELETED.V_String2, DELETED.V_String3, DELETED.V_String4, DELETED.V_String5
            ,DELETED.V_String6, DELETED.V_String7, DELETED.V_String8, DELETED.V_String9, DELETED.V_String10
            ,DELETED.V_String11, DELETED.V_String12, DELETED.V_String13, DELETED.V_String14, DELETED.V_String15
            ,DELETED.V_String16, DELETED.V_String17, DELETED.V_String18, DELETED.V_String19, DELETED.V_String20
            ,DELETED.V_String21, DELETED.V_String22, DELETED.V_String23, DELETED.V_String24, DELETED.V_String25
            ,DELETED.V_String26, DELETED.V_String27, DELETED.V_String28, DELETED.V_String29, DELETED.V_String30
            ,DELETED.V_String31, DELETED.V_String32, DELETED.V_String33, DELETED.V_String34, DELETED.V_String35
            ,DELETED.V_String36, DELETED.V_String37, DELETED.V_String38, DELETED.V_String39, DELETED.V_String40
            ,DELETED.FieldAttr01, DELETED.FieldAttr02, DELETED.FieldAttr03, DELETED.FieldAttr04, DELETED.FieldAttr05
            ,DELETED.FieldAttr06, DELETED.FieldAttr07, DELETED.FieldAttr08, DELETED.FieldAttr09, DELETED.FieldAttr10
            ,DELETED.FieldAttr11, DELETED.FieldAttr12, DELETED.FieldAttr13, DELETED.FieldAttr14, DELETED.FieldAttr15
            ,DELETED.AddDate, DELETED.EditDate, DELETED.Printer_Paper, DELETED.MenuStack, DELETED.V_TaskDetailKey
            ,DELETED.V_Max, DELETED.RemotePrint, DELETED.DeviceID, DELETED.LightMode, DELETED.StorerGroup
            ,DELETED.V_StorerKey, DELETED.V_String41, DELETED.V_String42, DELETED.V_String43, DELETED.V_String44
            ,DELETED.V_String45, DELETED.V_String46, DELETED.V_String47, DELETED.V_String48, DELETED.V_String49
            ,DELETED.V_String50, DELETED.V_WaveKey, '1', APP_NAME(), OBJECT_NAME( @@PROCID), MOBREC.UserName
            ,DELETED.V_Cartonno, DELETED.V_PUOM_Div, DELETED.V_MQTY, DELETED.V_PQTY, DELETED.V_FromScn
            ,DELETED.V_FromStep, DELETED.V_MTaskQty, DELETED.V_PTaskQty, DELETED.V_TaskQTY, DELETED.V_Integer1
            ,DELETED.V_Integer2, DELETED.V_Integer3, DELETED.V_Integer4, DELETED.V_Integer5, DELETED.V_Integer6
            ,DELETED.V_Integer7, DELETED.V_Integer8, DELETED.V_Integer9, DELETED.V_Integer10, DELETED.V_Integer11
            ,DELETED.V_Integer12, DELETED.V_Integer13, DELETED.V_Integer14, DELETED.V_Integer15, DELETED.V_DateTime1
            ,DELETED.V_DateTime2, DELETED.V_DateTime3, DELETED.V_DateTime4, DELETED.V_DateTime5, DELETED.I_Field16
            ,DELETED.I_Field17, DELETED.I_Field18, DELETED.I_Field19, DELETED.I_Field20, DELETED.O_Field16
            ,DELETED.O_Field17, DELETED.O_Field18, DELETED.O_Field19, DELETED.O_Field20, DELETED.FieldAttr16
            ,DELETED.FieldAttr17, DELETED.FieldAttr18, DELETED.FieldAttr19, DELETED.FieldAttr20, DELETED.V_DropID            
            FROM RDT.RDTMOBREC MOBREC WITH (NOLOCK)
            JOIN DELETED DELETED ON MOBREC.Mobile = DELETED.Mobile
            WHERE MOBREC.UserName IN ('RESET', 'RETIRED')
            AND DELETED.Mobile IS NOT NULL

            --delete the reset and retired user in rdtmobrec

            DELETE   RDTMOB 
            FROM  RDT.RDTMobRec RDTMOB JOIN INSERTED INSERTED ON INSERTED.Mobile = RDTMOB.Mobile
            WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
            AND INSERTED.Mobile IS NOT NULL

            ---- If perform RESET, force user go back to main menu to
            ---- avoid user from continue using RESET as username
            --UPDATE RDTMOB WITH (ROWLOCK) SET
            --   Func = 0,
            --   Scn  = 0,
            --   Step = 0,
            --   Menu = 0,
            --   ErrMsg = '',
            --   RDTMOB.I_Field01 = '',
            --   RDTMOB.I_Field02 = '',
            --   RDTMOB.I_Field03 = '',
            --   RDTMOB.I_Field04 = '',
            --   RDTMOB.O_Field01 = '',
            --   RDTMOB.O_Field02 = '',
            --   RDTMOB.O_Field03 = '',
            --   RDTMOB.O_Field04 = '',
            --   RDTMOB.FieldAttr01 = '', -- (james02)
            --   RDTMOB.FieldAttr02 = '', 
            --   RDTMOB.FieldAttr03 = '', 
            --   RDTMOB.FieldAttr04 = '', 
            --   RDTMOB.FieldAttr05 = ''  
            --FROM RDT.RDTMobRec RDTMOB
            --JOIN INSERTED INSERTED ON INSERTED.Mobile = RDTMOB.Mobile
            --WHERE INSERTED.UserName IN ('RESET', 'RETIRED')
            --AND INSERTED.Mobile IS NOT NULL
         END
      END
   END

   IF @n_continue = 1
   BEGIN
      IF UPDATE(Func)
      BEGIN
         IF EXISTS ( SELECT 1 FROM DELETED DELETED WITH (NOLOCK)
                     JOIN INSERTED INSERTED ON DELETED.Mobile = INSERTED.Mobile
                     WHERE INSERTED.Mobile IS NOT NULL 
                     AND INSERTED.Func = 0
                     AND DELETED.Func > 500) 
         BEGIN
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
            ,FieldAttr17, FieldAttr18, FieldAttr19,FieldAttr20, V_DropID)     
             SELECT 
             DELETED.Mobile, DELETED.Func, DELETED.Scn, DELETED.Step, DELETED.Menu
            ,DELETED.Lang_Code, DELETED.InputKey, DELETED.ErrMsg, DELETED.StorerKey, DELETED.Facility
            ,DELETED.UserName, DELETED.Printer, DELETED.MsgQueueNo, DELETED.V_ReceiptKey, DELETED.V_POKey
            ,DELETED.V_LoadKey, DELETED.V_OrderKey, DELETED.V_PickSlipNo, DELETED.V_Zone, DELETED.V_Loc, DELETED.V_SKU
            ,DELETED.V_UOM, DELETED.V_ID, DELETED.V_ConsigneeKey, DELETED.V_CaseID, DELETED.V_SKUDescr, DELETED.V_QTY, DELETED.V_UCC, DELETED.V_Lot
            ,DELETED.V_Lottable01, DELETED.V_Lottable02, DELETED.V_Lottable03, DELETED.V_Lottable04, DELETED.V_Lottable05
            ,DELETED.V_Lottable06, DELETED.V_Lottable07, DELETED.V_Lottable08, DELETED.V_Lottable09, DELETED.V_Lottable10
            ,DELETED.V_Lottable11, DELETED.V_Lottable12, DELETED.V_Lottable13, DELETED.V_Lottable14, DELETED.V_Lottable15
            ,DELETED.V_LottableLabel01, DELETED.V_LottableLabel02, DELETED.V_LottableLabel03, DELETED.V_LottableLabel04, DELETED.V_LottableLabel05
            ,DELETED.V_LottableLabel06, DELETED.V_LottableLabel07, DELETED.V_LottableLabel08, DELETED.V_LottableLabel09, DELETED.V_LottableLabel10
            ,DELETED.V_LottableLabel11, DELETED.V_LottableLabel12, DELETED.V_LottableLabel13, DELETED.V_LottableLabel14, DELETED.V_LottableLabel15
            ,DELETED.I_Field01, DELETED.I_Field02, DELETED.I_Field03, DELETED.I_Field04, DELETED.I_Field05
            ,DELETED.I_Field06, DELETED.I_Field07, DELETED.I_Field08, DELETED.I_Field09, DELETED.I_Field10
            ,DELETED.I_Field11, DELETED.I_Field12, DELETED.I_Field13, DELETED.I_Field14, DELETED.I_Field15
            ,DELETED.O_Field01, DELETED.O_Field02, DELETED.O_Field03, DELETED.O_Field04, DELETED.O_Field05
            ,DELETED.O_Field06, DELETED.O_Field07, DELETED.O_Field08, DELETED.O_Field09, DELETED.O_Field10
            ,DELETED.O_Field11, DELETED.O_Field12, DELETED.O_Field13, DELETED.O_Field14, DELETED.O_Field15
            ,DELETED.V_String1, DELETED.V_String2, DELETED.V_String3, DELETED.V_String4, DELETED.V_String5
            ,DELETED.V_String6, DELETED.V_String7, DELETED.V_String8, DELETED.V_String9, DELETED.V_String10
            ,DELETED.V_String11, DELETED.V_String12, DELETED.V_String13, DELETED.V_String14, DELETED.V_String15
            ,DELETED.V_String16, DELETED.V_String17, DELETED.V_String18, DELETED.V_String19, DELETED.V_String20
            ,DELETED.V_String21, DELETED.V_String22, DELETED.V_String23, DELETED.V_String24, DELETED.V_String25
            ,DELETED.V_String26, DELETED.V_String27, DELETED.V_String28, DELETED.V_String29, DELETED.V_String30
            ,DELETED.V_String31, DELETED.V_String32, DELETED.V_String33, DELETED.V_String34, DELETED.V_String35
            ,DELETED.V_String36, DELETED.V_String37, DELETED.V_String38, DELETED.V_String39, DELETED.V_String40
            ,DELETED.FieldAttr01, DELETED.FieldAttr02, DELETED.FieldAttr03, DELETED.FieldAttr04, DELETED.FieldAttr05
            ,DELETED.FieldAttr06, DELETED.FieldAttr07, DELETED.FieldAttr08, DELETED.FieldAttr09, DELETED.FieldAttr10
            ,DELETED.FieldAttr11, DELETED.FieldAttr12, DELETED.FieldAttr13, DELETED.FieldAttr14, DELETED.FieldAttr15
            ,DELETED.AddDate, DELETED.EditDate, DELETED.Printer_Paper, DELETED.MenuStack, DELETED.V_TaskDetailKey
            ,DELETED.V_Max, DELETED.RemotePrint, DELETED.DeviceID, DELETED.LightMode, DELETED.StorerGroup
            ,DELETED.V_StorerKey, DELETED.V_String41, DELETED.V_String42, DELETED.V_String43, DELETED.V_String44
            ,DELETED.V_String45, DELETED.V_String46, DELETED.V_String47, DELETED.V_String48, DELETED.V_String49
            ,DELETED.V_String50, DELETED.V_WaveKey, '1', APP_NAME(), OBJECT_NAME( @@PROCID), INSERTED.UserName
            ,DELETED.V_Cartonno, DELETED.V_PUOM_Div, DELETED.V_MQTY, DELETED.V_PQTY, DELETED.V_FromScn
            ,DELETED.V_FromStep, DELETED.V_MTaskQty, DELETED.V_PTaskQty, DELETED.V_TaskQTY, DELETED.V_Integer1
            ,DELETED.V_Integer2, DELETED.V_Integer3, DELETED.V_Integer4, DELETED.V_Integer5, DELETED.V_Integer6
            ,DELETED.V_Integer7, DELETED.V_Integer8, DELETED.V_Integer9, DELETED.V_Integer10, DELETED.V_Integer11
            ,DELETED.V_Integer12, DELETED.V_Integer13, DELETED.V_Integer14, DELETED.V_Integer15, DELETED.V_DateTime1
            ,DELETED.V_DateTime2, DELETED.V_DateTime3, DELETED.V_DateTime4, DELETED.V_DateTime5, DELETED.I_Field16
            ,DELETED.I_Field17, DELETED.I_Field18, DELETED.I_Field19, DELETED.I_Field20, DELETED.O_Field16
            ,DELETED.O_Field17, DELETED.O_Field18, DELETED.O_Field19, DELETED.O_Field20, DELETED.FieldAttr16
            ,DELETED.FieldAttr17, DELETED.FieldAttr18, DELETED.FieldAttr19, DELETED.FieldAttr20, DELETED.V_DropID            
            FROM DELETED DELETED WITH (NOLOCK)
            JOIN INSERTED INSERTED ON INSERTED.Mobile = INSERTED.Mobile
            WHERE INSERTED.Mobile IS NOT NULL 
            AND INSERTED.Func = 0
            AND DELETED.Func > 500
         END
      END
   END

   /* #INCLUDE <TRAHU2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
   
         -- Raise error with severity = 10, instead of the default severity 16. 
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR 
   
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDTMobRecUpdate'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      END

      INSERT INTO RDT.RDTMobRec_LOG (
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
         ,FieldAttr17, FieldAttr18, FieldAttr19,FieldAttr20, V_DropID)
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
         ,V_String50, V_WaveKey, '3' AS [Status], AppName, ProcID, UserNameAfterLog
         ,V_Cartonno, V_PUOM_Div, V_MQTY, V_PQTY, V_FromScn
         ,V_FromStep, V_MTaskQty, V_PTaskQty, V_TaskQTY, V_Integer1
         ,V_Integer2, V_Integer3, V_Integer4, V_Integer5, V_Integer6
         ,V_Integer7, V_Integer8, V_Integer9, V_Integer10, V_Integer11
         ,V_Integer12, V_Integer13, V_Integer14, V_Integer15, V_DateTime1
         ,V_DateTime2, V_DateTime3, V_DateTime4, V_DateTime5, I_Field16
         ,I_Field17, I_Field18, I_Field19, I_Field20, O_Field16
         ,O_Field17, O_Field18, O_Field19, O_Field20, FieldAttr16
         ,FieldAttr17, FieldAttr18, FieldAttr19,FieldAttr20, V_DropID
      FROM @RDTMobRec_LOG_Temp 

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

ALTER TABLE [RDT].[ntrRDTMobRecUpdate] ENABLE TRIGGER [ntrRDTMobRecUpdate]
GO
