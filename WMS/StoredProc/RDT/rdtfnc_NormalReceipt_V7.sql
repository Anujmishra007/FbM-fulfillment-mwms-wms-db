SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
    
/*********************************************************************************/    
/* Store procedure: rdtfnc_NormalReceipt_V7                                      */    
/* Copyright      : LFLogistics                                                  */    
/*                                                                               */    
/* Purpose: Mirgrated from normal receiving                                      */    
/*                                                                               */    
/* Date       Rev  Author   Purposes                                             */    
/* 2015-02-29 1.0  Ung      SOS315262 Migrated from 550                          */    
/* 2015-07-08 1.1  Ung      SOS347332 Show non English SKU descr in correct width*/    
/* 2015-08-03 1.2  Ung      SOS347397 Dynamic verify SKU                         */    
/* 2015-06-10 1.3  Ung      SOS315262 Expand QTY to 7 digits                     */    
/*                          Add StorerGroup                                      */    
/* 2015-11-23 1.4  Ung      SOS357362 ReceiptConfirm_SP add RDLineNo output      */    
/* 2016-04-19 1.5  Ung      SOS368437 Add standard DecodeSP                      */    
/* 2016-05-17 1.6  Ung      SOS370219 Migrate DecodeSP to Exceed                 */    
/* 2016-06-28 1.7  Ung      SOS372692 Remove DecodeSP error                      */    
/* 2016-09-30 1.8  Ung      Performance tuning                                   */    
/* 2017-10-24 1.9  AikLiang Initialize cPalletRecv (AL01)                        */    
/* 2016-12-14 2.0  Ung      WMS-783 Support 2D barcode                           */    
/* 2017-08-29 2.1  James    WMS2715 Use new printing method (james01)            */    
/* 2018-01-26 2.2  James    WMS3756 Change config DisAllowDuplicateIdsOnRFRcpt   */    
/*                          to RDT config CheckIDInUse (james02)                 */    
/* 2018-03-13 2.3  James    WMS4211-Add auto match SKU in Doc (james03)          */    
/* 2018-10-12 2.4  ChewKP   WMS-6565 - Add EventLog  (ChewKP01)                  */    
/* 2019-03-07 2.5  YeeKung  WMS8169-Add Loc Prefix (yeekung01)                   */        
/* 2018-06-07 2.6  James    WMS5313 Add rdt_decode for ToID & SKU(james04)       */      
/* 2018-10-26 2.7  James    WMS6623 Add direct flow thru screen (james05)        */  
/* 2020-03-12 2.8  YeeKung  WMS12309 Add multisku doctype (yeekung02)            */    
/* 2020-11-09 2.9  YeeKung  WMS15597 Add serialno (yeekung03)                    */     
/* 2021-01-11 3.0  Chermain WMS-15955 add @cScanBarcode to V_String42  (cc01)    */  
/* 2021-02-02 3.1  Chermain WMS-16136 Add FlowThruScreen At scn6 (cc02)          */  
/* 2021-08-19 3.2  SYChua   Bug Fix: Uncomment ActionType (SY01)                 */  
/* 2021-11-12 3.3  Chermain WMS-18067 Change goto Step_5_Fail in st5 ExtInfo(cc03)*/  
/* 2021-11-15 3.4  YeeKung  JSM-33035 Bug Fix correct step (yeekung04)            */
/* 2022-06-29 3.5  James    JSM-77967 Add skustatus for rdt_GetSKU (james06)     */
/*********************************************************************************/    
    
CREATE OR ALTER PROCEDURE [RDT].[rdtfnc_NormalReceipt_V7] (    
   @nMobile    INT,    
   @nErrNo     INT  OUTPUT,    
   @cErrMsg    NVARCHAR( 20) OUTPUT    
) AS    
    
SET NOCOUNT ON    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS OFF    
SET CONCAT_NULL_YIELDS_NULL OFF    
    
-- Misc variable    
DECLARE    
   @b_Success      INT,    
   @n_Err          INT,    
   @c_ErrMsg       NVARCHAR( 250),    
    
   @cChkFacility   NVARCHAR( 5),    
   @cChkLOC        NVARCHAR( 10),     
   @nMorePage      INT,    
   @cOption        NVARCHAR( 1),    
   @cSQL           NVARCHAR( MAX),    
   @cSQLParam      NVARCHAR( MAX),    
   @tPalletLabel   VariableTable    
       
-- Session variable    
DECLARE    
   @nFunc        INT,    
   @nScn         INT,    
   @nStep        INT,    
   @cLangCode    NVARCHAR( 3),    
   @nInputKey    INT,    
   @nMenu        INT,    
   @cUserName    NVARCHAR( 18),    
   @cPrinter     NVARCHAR( 10),    
   @cStorerGroup NVARCHAR( 20),    
   @cStorerKey   NVARCHAR( 15),    
   @cFacility    NVARCHAR( 5),    
    
   @cPUOM   NVARCHAR(  1),    
   @cReceiptKey  NVARCHAR( 10),    
   @cPOKey       NVARCHAR( 10),    
   @cLOC         NVARCHAR( 20),    
   @cID          NVARCHAR( 18),    
   @cSKU         NVARCHAR( 20),    
   @cSKUDesc     NVARCHAR( 60),    
   @cLottable01  NVARCHAR( 18),    
   @cLottable02  NVARCHAR( 18),    
   @cLottable03  NVARCHAR( 18),    
   @dLottable04  DATETIME,    
   @dLottable05  DATETIME,    
   @cLottable06  NVARCHAR( 30),    
   @cLottable07  NVARCHAR( 30),    
   @cLottable08  NVARCHAR( 30),    
   @cLottable09  NVARCHAR( 30),    
   @cLottable10  NVARCHAR( 30),    
   @cLottable11  NVARCHAR( 30),    
   @cLottable12  NVARCHAR( 30),    
   @dLottable13  DATETIME,    
   @dLottable14  DATETIME,    
   @dLottable15  DATETIME,    
   @cMax         NVARCHAR( MAX),     
    
   @cRefNo              NVARCHAR( 20),    
   @cIVAS               NVARCHAR( 20),    
   @cLottableCode       NVARCHAR( 30),    
   @cReasonCode         NVARCHAR( 10),     
   @cSuggToLOC          NVARCHAR( 10),     
   @cFinalLOC           NVARCHAR( 10),     
   @cReceiptLineNumber  NVARCHAR( 5),     
   @cPalletRecv         NVARCHAR( 1),     
   @cSerialNoCapture    NVARCHAR(1),  --(yeekung02)  
  
   @cPUOM_Desc          NCHAR( 5),    
   @cMUOM_Desc          NCHAR( 5),    
   @nPUOM_Div           INT,    
   @nPQTY               INT,    
   @nMQTY               INT,    
   @nQTY                INT,    
   @nFromScn            INT,    
   @nPABookingKey       INT,    
    
   @cPOKeyDefaultValue  NVARCHAR( 10),    
   @cDefaultToLOC       NVARCHAR( 20),    
   @cCheckPLTID         NVARCHAR( 1),    
   @cAutoGenID          NVARCHAR( 1),    
   @cGetReceiveInfoSP   NVARCHAR( 20),    
   @cDecodeSP           NVARCHAR( 20),    
   @cAddSKUtoASN        NVARCHAR( 1),    
   @cVerifySKU          NVARCHAR( 1),    
   @cPalletRecvSP       NVARCHAR( 20),    
   @cExtendedValidateSP NVARCHAR( 20),    
   @cExtendedUpdateSP   NVARCHAR( 20),    
   @cRcptConfirmSP      NVARCHAR( 20),    
   @cExtendedInfoSP     NVARCHAR( 20),    
   @cExtendedInfo       NVARCHAR( 20),    
   @cPutawaySP          NVARCHAR( 20),    
   @cPutaway            NVARCHAR( 1),    
   @cPalletLabel        NVARCHAR( 20),    
   @cPrinter_Paper      NVARCHAR( 10),    
   @cCheckIDInUse       NVARCHAR( 20),    
   @cMultiSKUBarcode    NVARCHAR(1),    
   @nEventNo1           INT,     
   @nEventNo2           INT,    
   @nEventNo3           INT,    
   @nEventNo4           INT,    
   @nEventNo5           INT,    
   @cLOCLookupSP        NVARCHAR(20), --(yeekung01)      
   @cUserDefine01       NVARCHAR( 60),      
   @cUserDefine02       NVARCHAR( 60),      
   @cUserDefine03       NVARCHAR( 60),      
   @cUserDefine04       NVARCHAR( 60),      
   @cUserDefine05       NVARCHAR( 60),      
   @nTempQTY            INT,    
   @cFlowThruScreen     NVARCHAR( 1),  
   @cDocType            NVARCHAR( 1),   
   @cSerialNo           NVARCHAR( 30),    
   @nSerialQTY          INT,    
   @nMoreSNO            INT,    
   @nBulkSNO            INT,    
   @nBulkSNOQTY         INT,    
   @cScanBarcode        NVARCHAR( 2000),  --(cc01)  
       
   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    
    
@cFieldAttr01 NVARCHAR( 1), @cFieldAttr02 NVARCHAR( 1),    
   @cFieldAttr03 NVARCHAR( 1), @cFieldAttr04 NVARCHAR( 1),    
   @cFieldAttr05 NVARCHAR( 1), @cFieldAttr06 NVARCHAR( 1),    
   @cFieldAttr07 NVARCHAR( 1), @cFieldAttr08 NVARCHAR( 1),    
   @cFieldAttr09 NVARCHAR( 1), @cFieldAttr10 NVARCHAR( 1),    
   @cFieldAttr11 NVARCHAR( 1), @cFieldAttr12 NVARCHAR( 1),    
   @cFieldAttr13 NVARCHAR( 1), @cFieldAttr14 NVARCHAR( 1),    
   @cFieldAttr15 NVARCHAR( 1)    
    
-- Load RDT.RDTMobRec    
SELECT    
   @nFunc      = Func,    
   @nScn       = Scn,    
   @nStep      = Step,    
   @nInputKey  = InputKey,    
   @nMenu      = Menu,    
   @cLangCode  = Lang_code,    
    
   @cStorerGroup = StorerGroup,     
   @cFacility  = Facility,    
   @cPrinter   = Printer,    
   @cUserName  = UserName,    
   @cPrinter_Paper = Printer_Paper,    
    
   @cStorerKey  = V_StorerKey,    
   @cPUOM       = V_UOM,    
   @cReceiptKey = V_Receiptkey,    
   @cPOKey      = V_POKey,    
   @cLOC        = V_Loc,    
   @cID         = V_ID,    
   @cSKU        = V_SKU,    
   @cSKUDesc    = V_SKUDescr,    
   @nQTY        = V_QTY,    
   @cLottable01 = V_Lottable01,    
   @cLottable02 = V_Lottable02,    
   @cLottable03 = V_Lottable03,    
   @dLottable04 = V_Lottable04,    
   @dLottable05 = V_Lottable05,    
   @cLottable06 = V_Lottable06,    
   @cLottable07 = V_Lottable07,    
   @cLottable08 = V_Lottable08,    
   @cLottable09 = V_Lottable09,    
   @cLottable10 = V_Lottable10,    
   @cLottable11 = V_Lottable11,    
   @cLottable12 = V_Lottable12,    
   @dLottable13 = V_Lottable13,    
   @dLottable14 = V_Lottable14,    
   @dLottable15 = V_Lottable15,    
   @cMax        = V_Max,    
    
   @cRefNo              = V_String1,    
   @cIVAS               = V_String2,    
   @cLottableCode       = V_String3,    
   @cReasonCode         = V_String4,    
   @cSuggToLOC          = V_String5,    
   @cFinalLOC           = V_String6,    
   @cReceiptLineNumber  = V_String7,    
   @cPalletRecv         = V_String8,    
   @cFlowThruScreen     = V_String9,      
   @cMUOM_Desc          = V_String10,    
   @cPUOM_Desc          = V_String11,    
   @nPUOM_Div           = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String12, 5), 0) = 1 THEN LEFT( V_String12, 5) ELSE 0 END,    
   @nPQTY               = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String13, 7), 0) = 1 THEN LEFT( V_String13, 7) ELSE 0 END,    
   @nMQTY               = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String14, 7), 0) = 1 THEN LEFT( V_String14, 7) ELSE 0 END,    
   @nQTY                = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String15, 7), 0) = 1 THEN LEFT( V_String15, 7) ELSE 0 END,    
   @nFromScn            = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String16, 5), 0) = 1 THEN LEFT( V_String16, 5) ELSE 0 END,    
   @nPABookingKey       = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String17, 10), 0) = 1 THEN LEFT( V_String17, 10) ELSE 0 END,    
    
   @cPOKeyDefaultValue  = V_String21,    
   @cDefaultToLOC       = V_String22,    
   @cCheckPLTID         = V_String23,    
   @cAutoGenID          = V_String24,    
   @cGetReceiveInfoSP   = V_String25,    
   @cDecodeSP           = V_String26,    
   @cAddSKUtoASN        = V_String27,    
   @cVerifySKU          = V_String28,    
   @cPalletRecvSP       = V_String29,    
   @cExtendedValidateSP = V_String30,    
   @cExtendedUpdateSP   = V_String31,    
   @cRcptConfirmSP      = V_String32,    
   @cExtendedInfoSP     = V_String33,    
   @cExtendedInfo       = V_String34,    
   @cPutawaySP          = V_String35,    
   @cPutaway            = V_String36,    
   @cPalletLabel        = V_String37,    
   @cCheckIDInUse       = V_String38,    
   @cMultiSKUBarcode    = V_String39,    
   @cLOCLookUPSP        = V_String40,  
   @cDocType            = V_String41,      
   @cSerialNoCapture    = V_String42,   
   @cScanBarcode        = V_String43, --(cc01)  
    
   @cInField01 = I_Field01,   @cOutField01 = O_Field01,    
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,    
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,    
@cInField04 = I_Field04,   @cOutField04 = O_Field04,    
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,    
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,    
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,    
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,    
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,    
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,    
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,    
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,    
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,    
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,    
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,    
    
   @cFieldAttr01 = FieldAttr01,    @cFieldAttr02 = FieldAttr02,    
   @cFieldAttr03 = FieldAttr03,    @cFieldAttr04 = FieldAttr04,    
   @cFieldAttr05 = FieldAttr05,    @cFieldAttr06 = FieldAttr06,    
   @cFieldAttr07 = FieldAttr07,    @cFieldAttr08 = FieldAttr08,    
   @cFieldAttr09 = FieldAttr09,    @cFieldAttr10 = FieldAttr10,    
   @cFieldAttr11 = FieldAttr11,    @cFieldAttr12 = FieldAttr12,    
   @cFieldAttr13 = FieldAttr13,    @cFieldAttr14 = FieldAttr14,    
   @cFieldAttr15 = FieldAttr15    
    
FROM RDT.RDTMOBREC WITH (NOLOCK)    
WHERE Mobile = @nMobile    
    
-- Redirect to respective screen    
IF @nFunc = 600    
BEGIN    
   IF @nStep = 0 GOTO Step_0   -- Func = 600. Menu    
   IF @nStep = 1 GOTO Step_1   -- Scn = 4030. ASN, PO, CONT NO    
   IF @nStep = 2 GOTO Step_2   -- Scn = 4031. LOC    
   IF @nStep = 3 GOTO Step_3   -- Scn = 4032. ID    
   IF @nStep = 4 GOTO Step_4   -- Scn = 4033. SKU    
   IF @nStep = 5 GOTO Step_5   -- Scn = 3490. Lottable    
   IF @nStep = 6 GOTO Step_6   -- Scn = 4035. QTY, COND    
   IF @nStep = 7 GOTO Step_7   -- Scn = 4036. Message. successful received    
   IF @nStep = 8 GOTO Step_8   -- Scn = 4037. Option. Add SKU not in ASN?    
   IF @nStep = 9 GOTO Step_9   -- Scn = 4038. Option. Print pallet label?    
   IF @nStep = 10 GOTO Step_10 -- Scn = 3950. Verify SKU    
   IF @nStep = 11 GOTO Step_11 -- Scn = 4040. Refno lookup    
   IF @nStep = 12 GOTO Step_12 -- Scn = 4041. Putaway    
   IF @nStep = 13 GOTO Step_13 -- Scn = 3570. Multi SKU Barocde   
   IF @nStep = 14 GOTO Step_14 -- Scn = 4831. Serial no    
END    
RETURN -- Do nothing if incorrect step    
    
    
/********************************************************************************    
Step 0. func = 550. Menu    
   @nStep = 0    
********************************************************************************/    
Step_0:    
BEGIN    
   -- Get default UOM    
   SELECT @cPUOM = DefaultUOM FROM rdt.rdtUser WITH (NOLOCK) WHERE UserName = @cUserName    
    
   -- Get storer config    
   SET @cPOKeyDefaultValue = rdt.RDTGetConfig( @nFunc, 'ReceivingPOKeyDefaultValue', @cStorerKey)    
   IF @cPOKeyDefaultValue = '0'    
      SET @cPOKeyDefaultValue = ''    
    
   SET @cPalletLabel = rdt.RDTGetConfig( @nFunc, 'PalletLabel', @cStorerKey)    
   IF @cPalletLabel = '0'    
      SET @cPalletLabel = ''    
    
  -- Get Loc Prefix        
   SET @cLOCLookUPSP = rdt.rdtGetConfig(@nFunc,'LOCLookupSP',@cStorerKey)      
   SET @cMultiSKUBarcode = rdt.RDTGetConfig( @nFunc, 'MultiSKUBarcode', @cStorerKey)    
   SET @cSerialNoCapture = rdt.RDTGetConfig( @nFunc, 'SerialNoCapture', @cStorerKey)    
       
   -- EventLog    
   EXEC RDT.rdt_STD_EventLog    
      @cActionType = '1', -- Sign-in    
      @cUserID     = @cUserName,    
      @nMobileNo   = @nMobile,    
      @nFunctionID = @nFunc,    
      @cFacility   = @cFacility,    
      @cStorerKey  = @cStorerKey    
    
   -- Init var (due to var pass out by decodeSP, GetReceiveInfoSP is not reset)    
   SELECT @cID = '', @cSKU = '', @nQTY = 0,    
      @cLottable01 = '', @cLottable02 = '', @cLottable03 = '', @dLottable04 = 0,  @dLottable05 = 0,    
      @cLottable06 = '', @cLottable07 = '', @cLottable08 = '', @cLottable09 = '', @cLottable10 = '',    
      @cLottable11 = '', @cLottable12 = '', @dLottable13 = 0,  @dLottable14 = 0,  @dLottable15 = 0    
    
   -- Prepare next screen var    
   SET @cOutField01 = '' -- ASN    
   SET @cOutField02 = @cPOKeyDefaultValue    
   SET @cOutField03 = '' -- ContainerNo    
    
   SET @cPalletRecv = ''    
    
   -- Set the entry point    
   SET @nScn = 4030    
   SET @nStep = 1    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 1. Scn = 4030. ASN, PO, Container No screen    
   ASN          (field01, input)    
   PO           (field02, input)    
   REF NO       (field03, input)    
********************************************************************************/    
Step_1:    
BEGIN    
   IF @nInputKey = 1 -- Yes or Send    
   BEGIN    
      DECLARE @cChkReceiptKey NVARCHAR( 10)    
      DECLARE @cReceiptStatus NVARCHAR( 10)    
      DECLARE @cChkStorerKey NVARCHAR( 15)    
      DECLARE @nRowCount INT    
    
      -- Screen mapping    
      SET @cReceiptKey = @cInField01    
      SET @cPOKey = @cInField02    
      SET @cRefNo = @cInField03    
    
      -- Check ref no    
      IF @cRefNo <> '' AND @cReceiptKey = ''    
      BEGIN    
         -- Get storer config    
         DECLARE @cFieldName NVARCHAR(20)    
         SET @cFieldName = rdt.RDTGetConfig( @nFunc, 'RefNoLookupColumn', @cStorerKey)    
             
         -- Get lookup field data type    
         DECLARE @cDataType NVARCHAR(128)    
         SET @cDataType = ''    
         SELECT @cDataType = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Receipt' AND COLUMN_NAME = @cFieldName    
             
         IF @cDataType <> ''    
         BEGIN    
            IF @cDataType = 'nvarchar' SET @n_Err = 1                                ELSE    
            IF @cDataType = 'datetime' SET @n_Err = rdt.rdtIsValidDate( @cRefNo)     ELSE     
            IF @cDataType = 'int'      SET @n_Err = rdt.rdtIsInteger(   @cRefNo)     ELSE     
            IF @cDataType = 'float'    SET @n_Err = rdt.rdtIsValidQTY(  @cRefNo, 20)    
                                  
            -- Check data type    
            IF @n_Err = 0    
            BEGIN    
               SET @nErrNo = 59440    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid RefNo    
               EXEC rdt.rdtSetFocusField @nMobile, 3 -- RefNo    
               GOTO Quit    
            END    
                
            DECLARE @tReceipt TABLE    
            (    
               RowRef     INT IDENTITY( 1, 1),    
               ReceiptKey NVARCHAR( 10) NOT NULL    
            )    
       
            SET @cSQL =     
               ' SELECT ReceiptKey ' +     
               ' FROM dbo.Receipt WITH (NOLOCK) ' +     
               ' WHERE Facility = ' + QUOTENAME( @cFacility, '''') +     
                  ' AND ISNULL( ' + @cFieldName + CASE WHEN @cDataType IN ('int', 'float') THEN ',0)' ELSE ','''')' END + ' = ' + QUOTENAME( @cRefNo, '''') +     
               ' ORDER BY ReceiptKey '     
       
            -- Get ASN by RefNo    
            INSERT INTO @tReceipt (ReceiptKey)    
            EXEC (@cSQL)    
            SELECT @nErrNo = @@ERROR, @nRowCount = @@ROWCOUNT    
            IF @nErrNo <> 0    
               GOTO Quit    
       
            -- Check RefNo in ASN    
            IF @nRowCount = 0    
            BEGIN    
               SET @nErrNo = 59401    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --RefNo NotInASN    
               EXEC rdt.rdtSetFocusField @nMobile, 3 -- ContainerKey    
               GOTO Quit    
            END    
            SET @cOutField03 = @cRefNo    
       
            -- Only 1 ASN. Auto retrieve the ASN    
            IF @nRowCount = 1    
            BEGIN    
               SELECT @cReceiptKey = ReceiptKey FROM @tReceipt    
               SET @cOutField01 = @cReceiptKey    
            END    
       
            -- Multi ASN found, prompt user to select    
            IF @nRowCount > 1    
            BEGIN    
               DECLARE   
                  @cMsg1 NVARCHAR(20), @cMsg2 NVARCHAR(20), @cMsg3 NVARCHAR(20), @cMsg4 NVARCHAR(20), @cMsg5 NVARCHAR(20),    
                  @cMsg6 NVARCHAR(20), @cMsg7 NVARCHAR(20), @cMsg8 NVARCHAR(20), @cMsg9 NVARCHAR(20), @cMsg  NVARCHAR(20)    
               SELECT    
                  @cMsg1 = '', @cMsg2 = '', @cMsg3 = '', @cMsg4 = '', @cMsg5 = '',    
                  @cMsg6 = '', @cMsg7 = '', @cMsg8 = '', @cMsg9 = '', @cMsg = ''    
       
               SELECT    
                  @cMsg1 = CASE WHEN RowRef = 1 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg1 END,    
                  @cMsg2 = CASE WHEN RowRef = 2 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg2 END,    
                  @cMsg3 = CASE WHEN RowRef = 3 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg3 END,    
                  @cMsg4 = CASE WHEN RowRef = 4 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg4 END,    
                  @cMsg5 = CASE WHEN RowRef = 5 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg5 END,    
                  @cMsg6 = CASE WHEN RowRef = 6 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg6 END,    
                  @cMsg7 = CASE WHEN RowRef = 7 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg7 END,    
                  @cMsg8 = CASE WHEN RowRef = 8 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg8 END,    
                  @cMsg9 = CASE WHEN RowRef = 9 THEN CAST( RowRef AS NVARCHAR(2)) + '. ' + ReceiptKey ELSE @cMsg9 END    
               FROM @tReceipt    
       
               SET @cOutField01 = @cMsg1    
               SET @cOutField02 = @cMsg2    
               SET @cOutField03 = @cMsg3    
               SET @cOutField04 = @cMsg4    
               SET @cOutField05 = @cMsg5    
               SET @cOutField06 = @cMsg6    
               SET @cOutField07 = @cMsg7    
               SET @cOutField08 = @cMsg8    
               SET @cOutField09 = @cMsg9    
               SET @cOutField10 = '' -- Option    
                   
               -- Go to Lookup    
               SET @nScn = @nScn + 10    
               SET @nStep = @nStep + 10    
       
               GOTO Quit    
            END    
         END    
      END    
    
      -- Validate at least one field must key-in    
      IF (@cReceiptKey = '' OR @cReceiptKey IS NULL) AND    
         (@cPOKey = '' OR @cPOKey IS NULL OR @cPOKey = 'NOPO') -- SOS76264    
      BEGIN    
         SET @nErrNo = 59402    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need ASN or PO    
         GOTO Step_1_Fail    
      END    
    
      -- Both ASN & PO keyed-in    
      IF NOT (@cReceiptKey = '' OR @cReceiptKey IS NULL) AND    
         NOT (@cPOKey = '' OR @cPOKey IS NULL) AND    
         NOT (@cPOKey = 'NOPO')    
      BEGIN    
         -- Get the ASN    
         SELECT    
            @cChkFacility = R.Facility,    
            @cChkStorerKey = R.StorerKey,    
            @cChkReceiptKey = R.ReceiptKey,    
            @cReceiptStatus = R.Status,  
            @cDocType       = R.DocType  --(yeekung02)  
         FROM dbo.Receipt R WITH (NOLOCK)    
            INNER JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON R.ReceiptKey  = RD.ReceiptKey    
         WHERE R.ReceiptKey = @cReceiptKey    
            AND RD.POKey = @cPOKey    
         SET @nRowCount = @@ROWCOUNT    
    
         -- No row returned, either ASN or PO not exists    
         IF @nRowCount = 0    
         BEGIN    
            DECLARE @nASNExist INT    
            DECLARE @nPOExist  INT    
            DECLARE @nPOInASN  INT    
    
            SET @nASNExist = 0    
            SET @nPOExist = 0    
            SET @nPOInASN = 0    
    
            -- Check ASN exists    
            IF EXISTS (SELECT 1 FROM dbo.Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey)    
               SET @nASNExist = 1    
    
            -- Check PO exists    
            IF EXISTS (SELECT 1 FROM dbo.PO WITH (NOLOCK) WHERE POKey = @cPOKey)    
               SET @nPOExist = 1    
    
            -- Check PO in ASN    
            IF EXISTS( SELECT 1 FROM dbo.ReceiptDetail RD WITH (NOLOCK) WHERE RD.ReceiptKey = @cReceiptKey AND RD.POKey = @cPOKey)    
               SET @nPOInASN = 1    
    
            -- Both ASN & PO also not exists    
            IF @nASNExist = 0 AND @nPOExist = 0    
            BEGIN    
               SET @nErrNo = 59403    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASN&PONotExist    
               SET @cOutField01 = '' -- ReceiptKey    
               SET @cOutField02 = '' -- POKey    
               SET @cReceiptKey = ''    
               SET @cPOKey = ''    
               EXEC rdt.rdtSetFocusField @nMobile, 1    
               GOTO Quit    
            END    
    
            -- Only ASN not exists    
            ELSE IF @nASNExist = 0    
            BEGIN    
               SET @nErrNo = 59404    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASN Not Exist    
               SET @cOutField01 = '' -- ReceiptKey    
               SET @cOutField02 = @cPOKey -- POKey    
               SET @cReceiptKey = ''    
               EXEC rdt.rdtSetFocusField @nMobile, 1    
               GOTO Quit    
            END    
    
            -- Only PO not exists    
            ELSE IF @nPOExist = 0    
            BEGIN    
               SET @nErrNo = 59405    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PO Not Exist    
               SET @cOutField01 = @cReceiptKey    
               SET @cOutField02 = '' -- POKey    
               SET @cPOKey = ''    
               EXEC rdt.rdtSetFocusField @nMobile, 2    
               GOTO Quit    
            END    
    
            -- PO not in ASN    
            ELSE IF @nPOInASN = 0    
            BEGIN    
               SET @nErrNo = 59406    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PO Not In ASN    
               SET @cOutField01 = @cReceiptKey    
               SET @cOutField02 = '' -- POKey    
               SET @cPOKey = ''    
               EXEC rdt.rdtSetFocusField @nMobile, 2    
               GOTO Quit    
            END    
         END    
      END    
      ELSE    
         -- Only ASN key-in (POKey = blank or NOPO)    
         IF (@cReceiptKey <> '' AND @cReceiptKey IS NOT NULL)    
         BEGIN    
            -- Validate whether ASN have multiple PO    
            DECLARE @cChkPOKey NVARCHAR( 10)    
            SELECT DISTINCT    
               @cChkPOKey = RD.POKey,    
               @cChkFacility = R.Facility,    
               @cChkStorerKey = R.StorerKey,    
               @cReceiptStatus = R.Status    
            FROM dbo.Receipt R WITH (NOLOCK)    
               INNER JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON R.ReceiptKey  = RD.ReceiptKey    
            WHERE RD.ReceiptKey = @cReceiptKey    
            -- If return multiple row, the last row is taken & assign into var.    
            -- We want blank POKey to be assigned if multiple row returned, hence using the DESC    
            ORDER BY RD.POKey DESC    
            SET @nRowCount = @@ROWCOUNT    
    
            -- No row returned, either ASN or ASN detail not exist    
            IF @nRowCount = 0    
            BEGIN    
               SELECT    
                   @cChkFacility = R.Facility,    
                   @cChkStorerKey = R.StorerKey,    
                   @cReceiptStatus = R.Status    
               FROM dbo.Receipt R WITH (NOLOCK)    
               WHERE R.ReceiptKey = @cReceiptKey    
               SET @nRowCount = @@ROWCOUNT    
    
               -- Check ASN exist    
               IF @nRowCount = 0    
               BEGIN    
                  SET @nErrNo = 59407    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASN not exist    
                  SET @cOutField01 = '' -- ReceiptKey    
                  SET @cReceiptKey = ''    
   EXEC rdt.rdtSetFocusField @nMobile, 1    
                  GOTO Quit    
               END    
            END    
    
            -- Auto retrieve PO, if only 1 PO in ASN    
            ELSE IF @nRowCount = 1    
            BEGIN    
               IF @cPOKey <> 'NOPO'    
                  SET @cPOKey = @cChkPOKey    
            END    
    
            -- Check multi PO in ASN    
            ELSE IF @nRowCount > 1    
            BEGIN    
               IF @cPOKey <> 'NOPO'    
               BEGIN    
                  SET @cPOKey = ''    
                  SET @nErrNo = 59408    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiPO In ASN    
                  SET @cOutField01 = @cReceiptKey    
                  SET @cOutField02 = ''    
                  SET @cPOKey = ''    
                  EXEC rdt.rdtSetFocusField @nMobile, 2    
                  GOTO Quit    
               END    
            END    
         END    
         ELSE    
            -- Only PO key-in (POKey not blank or NOPO)    
            IF @cPOKey <> '' AND @cPOKey IS NOT NULL AND    
               @cPOKey <> 'NOPO'    
            BEGIN    
               -- Validate whether PO have multiple ASN    
               SELECT DISTINCT    
                  @cChkFacility = R.Facility,    
                  @cChkStorerKey = R.StorerKey,    
                  @cReceiptKey = R.ReceiptKey,    
                  @cReceiptStatus = R.Status    
               FROM dbo.Receipt R WITH (NOLOCK)    
                  INNER JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON R.ReceiptKey  = RD.ReceiptKey    
               WHERE RD.POKey = @cPOKey    
               SET @nRowCount = @@ROWCOUNT    
    
               IF @nRowCount = 0    
               BEGIN    
                  SET @nErrNo = 59409    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PO not exist    
                  SET @cOutField02 = '' -- POKey    
                  SET @cPOKey = ''    
                  EXEC rdt.rdtSetFocusField @nMobile, 2    
                  GOTO Quit    
               END    
    
               IF @nRowCount > 1    
               BEGIN    
                  SET @nErrNo = 59410    
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiASN in PO    
                  SET @cOutField01 = '' -- ReceiptKey    
                  SET @cOutField02 = @cPOKey    
                  SET @cReceiptKey = ''    
                  EXEC rdt.rdtSetFocusField @nMobile, 1    
                  GOTO Quit    
               END    
            END    
    
    
      -- Validate ASN in different facility    
      IF @cFacility <> @cChkFacility    
      BEGIN    
         SET @nErrNo = 59412    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff facility    
         SET @cOutField01 = '' -- ReceiptKey    
         SET @cReceiptKey = ''    
         EXEC rdt.rdtSetFocusField @nMobile, 1    
         GOTO Quit    
      END    
    
      -- Check storer group    
      IF @cStorerGroup <> ''    
      BEGIN    
         -- Check storer not in storer group    
         IF NOT EXISTS (SELECT 1 FROM StorerGroup WITH (NOLOCK) WHERE StorerGroup = @cStorerGroup AND StorerKey = @cChkStorerKey)    
         BEGIN    
            SET @nErrNo = 59444    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NotInStorerGrp    
            SET @cOutField01 = '' -- ReceiptKey    
            SET @cReceiptKey = ''    
            EXEC rdt.rdtSetFocusField @nMobile, 1    
            GOTO Quit    
         END    
    
         -- Set session storer    
         SET @cStorerKey = @cChkStorerKey    
      END    
    
      -- Validate ASN belong to the storer    
      IF @cStorerKey <> @cChkStorerKey    
      BEGIN    
         SET @nErrNo = 59413    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff storer    
         SET @cOutField01 = '' -- ReceiptKey    
         SET @cReceiptKey = ''    
         EXEC rdt.rdtSetFocusField @nMobile, 1    
         GOTO Quit    
      END    
    
      -- Validate ASN status    
      IF @cReceiptStatus = '9'    
      BEGIN    
         SET @nErrNo = 59414    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASN is closed    
         SET @cOutField01 = '' -- ReceiptKey    
         SET @cReceiptKey = ''    
         EXEC rdt.rdtSetFocusField @nMobile, 1    
         GOTO Quit    
      END    
       
      -- Get storer config    
      SET @cCheckPLTID = rdt.RDTGetConfig( @nFunc, 'CheckPLTID', @cStorerKey)    
      SET @cAutoGenID = rdt.RDTGetConfig( @nFunc, 'AutoGenID', @cStorerKey)    
      SET @cAddSKUtoASN = rdt.RDTGetConfig( @nFunc, 'RDTAddSKUtoASN', @cStorerKey)    
      SET @cVerifySKU = rdt.RDTGetConfig( @nFunc, 'VerifySKU', @cStorerKey)    
      SET @cDefaultToLOC = rdt.RDTGetConfig( @nFunc, 'ReceiveDefaultToLoc', @cStorerKey)    
      IF @cDefaultToLOC = '0'    
         SET @cDefaultToLOC = ''    
      SET @cRcptConfirmSP = rdt.RDTGetConfig( @nFunc, 'ReceiptConfirm_SP', @cStorerKey)    
      IF @cRcptConfirmSP = '0'    
         SET @cRcptConfirmSP = ''    
      SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)    
      IF @cExtendedValidateSP = '0'    
         SET @cExtendedValidateSP = ''    
      SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)    
      IF @cExtendedInfoSP = '0'    
         SET @cExtendedInfoSP = ''    
      SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)    
      IF @cExtendedUpdateSP = '0'    
         SET @cExtendedUpdateSP = ''    
      SET @cPalletRecvSP = rdt.RDTGetConfig( @nFunc, 'PalletRecvSP', @cStorerKey)    
      IF @cPalletRecvSP = '0'    
         SET @cPalletRecvSP = ''    
      SET @cGetReceiveInfoSP = rdt.RDTGetConfig( @nFunc, 'GetReceiveInfoSP', @cStorerKey)    
      IF @cGetReceiveInfoSP = '0'    
         SET @cGetReceiveInfoSP = ''    
      SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)    
      IF @cDecodeSP = '0'    
         SET @cDecodeSP = ''    
      SET @cPutawaySP = rdt.RDTGetConfig( @nFunc, 'PutawaySP', @cStorerKey)    
      IF @cPutawaySP = '0'    
         SET @cPutawaySP = ''    
      -- (james02)    
      SET @cCheckIDInUse = rdt.RDTGetConfig( @nFunc, 'CheckIDInUse', @cStorerKey)    
      IF @cCheckIDInUse = '0'    
         SET @cCheckIDInUse = ''    
    
      SET @cFlowThruScreen = rdt.RDTGetConfig( @nFunc, 'FlowThruScreen', @cStorerKey)    
    
      -- DefaultToLOC, by facility    
      IF @cDefaultToLOC = ''    
      BEGIN    
         DECLARE @c_authority NVARCHAR(1)    
         SELECT @b_success = 0    
         EXECUTE nspGetRight    
        @cFacility,    
            @cStorerKey,    
            NULL, -- @cSKU    
            'ASNReceiptLocBasedOnFacility',    
            @b_success   OUTPUT,    
            @c_authority OUTPUT,    
            @n_err       OUTPUT,    
            @c_errmsg    OUTPUT    
       
         IF @b_success = '1' AND @c_authority = '1'    
            SELECT @cDefaultToLOC = UserDefine04    
            FROM Facility WITH (NOLOCK)    
            WHERE Facility = @cFacility    
      END    
          
      -- EventLog -- (ChewKP01)     
      EXEC RDT.rdt_STD_EventLog    
         @cUserID     = @cUserName,    
         @nMobileNo   = @nMobile,    
         @nFunctionID = @nFunc,    
         @cFacility   = @cFacility,    
         @cStorerKey  = @cStorerKey,    
         @nStep       = @nStep,    
         @cReceiptKey = @cReceiptKey,    
         @cPOKey      = @cPOKey,    
         @cRefNo1     = @cRefNo    
          
    
      -- Prepare next screen var    
      SET @cOutField01 = @cReceiptKey    
      SET @cOutField02 = @cPOKey    
      SET @cOutField03 = @cDefaultToLOC    
    
      -- Go to next screen    
      SET @nScn = @nScn + 1    
      SET @nStep = @nStep + 1    
   END    
    
   IF @nInputKey = 0 -- Esc or No    
   BEGIN    
      -- EventLog    
      EXEC RDT.rdt_STD_EventLog    
         @cActionType = '9', -- Sign-Out    
         @cUserID     = @cUserName,    
         @nMobileNo   = @nMobile,    
         @nFunctionID = @nFunc,    
         @cFacility   = @cFacility,    
         @cStorerKey  = @cStorerKey    
    
      -- Back to menu    
      SET @nFunc = @nMenu    
      SET @nScn  = @nMenu    
      SET @nStep = 0    
    
      SET @cOutField01 = ''    
   END    
   GOTO Quit    
    
   Step_1_Fail:    
   BEGIN    
      -- Reset this screen var    
      SET @cOutField01 = '' -- ReceiptKey    
      SET @cOutField02 = '' -- POKey    
      SET @cReceiptKey = ''    
      SET @cPOKey = ''    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 2. Scn = 4031. Location screen    
   ASN   (field01)    
   PO    (field02)    
   TOLOC (field03, input)    
********************************************************************************/    
Step_2:    
BEGIN    
   IF @nInputKey = 1 -- Yes or Send    
   BEGIN    
      -- Screen mapping    
      SET @cLOC = @cInField03 -- LOC    
    
      -- Validate compulsary field    
      IF @cLOC = '' OR @cLOC IS NULL    
      BEGIN    
         SET @nErrNo = 59415    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need LOC    
         GOTO Step_2_Fail    
      END    
    
  --Loc Prefix        
  IF @cLOCLookupSP = 1           
  BEGIN            
   EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,             
   @cLOC      OUTPUT,             
   @nErrNo      OUTPUT,             
   @cErrMsg     OUTPUT            
   IF @nErrNo <> 0            
    GOTO Step_2_Fail            
  END    
      
      -- Get the location    
      SET @cChkLOC = ''    
      SET @cChkFacility = ''    
      SELECT    
         @cChkLOC = LOC,    
         @cChkFacility = Facility    
      FROM dbo.LOC WITH (NOLOCK)    
      WHERE LOC = @cLOC    
    
      -- Validate location    
      IF @cChkLOC = ''    
      BEGIN    
         SET @nErrNo = 59416    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid LOC    
         GOTO Step_2_Fail    
      END    
    
      -- Validate location not in facility    
      IF @cChkFacility <> @cFacility    
      BEGIN    
         SET @nErrNo = 59417    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff facility    
         GOTO Step_2_Fail    
      END    
    
      -- Auto generate ID    
      SET @cID = ''    
      IF @cAutoGenID = '1'    
      BEGIN    
          EXECUTE dbo.nspg_GetKey    
                  'ID',    
                  10 ,    
                  @cID               OUTPUT,    
                  @b_success         OUTPUT,    
                  @n_err             OUTPUT,    
                  @c_errmsg          OUTPUT    
         IF @b_success <> 1    
         BEGIN    
            SET @nErrNo = 59418    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --AutoGenID Fail    
            GOTO Step_2_Fail    
         END    
      END    
    
      -- Prepare next screen var    
      SET @cOutField01 = @cLOC    
      SET @cOutField02 = @cID    
    
      -- Go to next screen    
      SET @nScn  = @nScn + 1    
      SET @nStep = @nStep + 1    
   END    
    
   IF @nInputKey = 0 -- Esc or No    
   BEGIN    
      -- Prepare prev screen var    
      SET @cOutField01 = @cReceiptKey    
      SET @cOutField02 = @cPOKey    
      SET @cOutField03 = @cRefNo    
    
      SET @nScn = @nScn - 1    
      SET @nStep = @nStep - 1    
   END    
   GOTO Quit    
    
   Step_2_Fail:    
   BEGIN    
      -- Reset this screen var    
      SET @cOutField03 = '' -- LOC    
      SET @cLOC = ''    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 3. Scn = 4032. Pallet ID screen    
   TO LOC (field01)    
   TO ID  (field02, input)    
********************************************************************************/    
Step_3:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      DECLARE @cIDBarcode NVARCHAR( 60)    
    
      -- Screen mapping    
      SET @cID = LEFT( @cInField02, 18) -- ID    
      SET @cIDBarcode = @cInField02    
    
      -- Check barcode format    
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'ID', @cIDBarcode) = 0    
      BEGIN    
         SET @nErrNo = 59419    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format    
         GOTO Step_3_Fail    
      END    
    
      SET @cSKU = ''    
      -- Decode      
      -- Standard decode      
      IF @cDecodeSP = '1'      
      BEGIN      
         EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cIDBarcode,       
            @cID     = @cID     OUTPUT,       
            @nErrNo  = @nErrNo  OUTPUT,       
            @cErrMsg = @cErrMsg OUTPUT,      
            @cType   = 'ID'      
      
         IF @nErrNo <> 0      
            GOTO Step_3_Fail      
      END      
      ELSE      
      BEGIN    
         IF @cDecodeSP <> ''    
         BEGIN    
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')    
            BEGIN    
               SELECT @cSKU = '', @nQTY = 0,    
                  @cLottable01 = '', @cLottable02 = '', @cLottable03 = '', @dLottable04 = 0,  @dLottable05 = 0,    
                  @cLottable06 = '', @cLottable07 = '', @cLottable08 = '', @cLottable09 = '', @cLottable10 = '',    
                  @cLottable11 = '', @cLottable12 = '', @dLottable13 = 0,  @dLottable14 = 0,  @dLottable15 = 0    
    
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +    
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cBarcode, @cFieldName, ' +    
                  ' @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT, ' +    
                  ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT, ' +    
                  ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT, ' +    
                  ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT, ' +    
                  ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'    
               SET @cSQLParam =    
                  ' @nMobile      INT,             ' +    
                  ' @nFunc        INT,             ' +    
                  ' @cLangCode    NVARCHAR( 3),    ' +    
                  ' @nStep        INT,             ' +    
                  ' @nInputKey    INT,             ' +    
                  ' @cStorerKey   NVARCHAR( 15),   ' +    
                  ' @cReceiptKey  NVARCHAR( 10),   ' +    
                  ' @cPOKey       NVARCHAR( 10),   ' +    
                  ' @cLOC         NVARCHAR( 10),   ' +    
                  ' @cBarcode     NVARCHAR( 2000), ' +    
                  ' @cFieldName   NVARCHAR( 10),   ' +    
                  ' @cID          NVARCHAR( 18)  OUTPUT, ' +    
                  ' @cSKU         NVARCHAR( 20)  OUTPUT, ' +    
  ' @nQTY         INT            OUTPUT, ' +    
                  ' @cLottable01  NVARCHAR( 18)  OUTPUT, ' +    
                  ' @cLottable02  NVARCHAR( 18)  OUTPUT, ' +    
                  ' @cLottable03  NVARCHAR( 18)  OUTPUT, ' +    
                  ' @dLottable04  DATETIME       OUTPUT, ' +    
                  ' @dLottable05  DATETIME       OUTPUT, ' +    
                  ' @cLottable06  NVARCHAR( 30)  OUTPUT, ' +    
                  ' @cLottable07  NVARCHAR( 30)  OUTPUT, ' +    
                  ' @cLottable08  NVARCHAR( 30)  OUTPUT, ' +    
                  ' @cLottable09  NVARCHAR( 30)  OUTPUT, ' +    
                  ' @cLottable10  NVARCHAR( 30)  OUTPUT, ' +    
                  ' @cLottable11  NVARCHAR( 30)  OUTPUT, ' +    
                  ' @cLottable12  NVARCHAR( 30)  OUTPUT, ' +    
           ' @dLottable13  DATETIME       OUTPUT, ' +    
                  ' @dLottable14  DATETIME       OUTPUT, ' +    
                  ' @dLottable15  DATETIME       OUTPUT, ' +    
                  ' @nErrNo       INT            OUTPUT, ' +    
                  ' @cErrMsg      NVARCHAR( 20)  OUTPUT'    
    
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cIDBarcode, 'ID',    
                  @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT,    
                  @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,    
                  @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,    
                  @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,    
                  @nErrNo      OUTPUT, @cErrMsg     OUTPUT    
    
               IF @nErrNo <> 0    
                  GOTO Step_3_Fail    
            END    
         END    
      END    
      /*    
      DECLARE @cAuthority NVARCHAR(1)    
      EXECUTE nspGetRight    
         @cFacility,    
         @cStorerKey,    
         NULL, -- @cSKU    
         'DisAllowDuplicateIdsOnRFRcpt',    
         @b_Success   OUTPUT,    
         @cAuthority  OUTPUT,    
         @nErrNo      OUTPUT,    
         @cErrMsg     OUTPUT    
    
      -- Check ID in used    
      IF @cAuthority = '1' AND @cID <> ''    
      BEGIN    
         IF EXISTS( SELECT [ID]    
            FROM dbo.LOTxLOCxID LOTxLOCxID WITH (NOLOCK)    
               INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC)    
            WHERE [ID] = @cID    
               AND QTY > 0    
               AND LOC.Facility = @cFacility)    
         BEGIN    
            SET @nErrNo = 59420    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicate ID    
            GOTO Step_3_Fail    
         END    
      END    
      */    
    
      -- Validate pallet id received. If config turn on then not allow reuse    
      IF @cCheckIDInUse = '1'    
      BEGIN    
         IF EXISTS( SELECT [ID]    
            FROM dbo.LOTxLOCxID LOTxLOCxID WITH (NOLOCK)    
            INNER JOIN dbo.LOC LOC WITH (NOLOCK) ON (LOTxLOCxID.LOC = LOC.LOC)    
            WHERE [ID] = @cID    
            AND   QTY > 0    
            AND   StorerKey = @cStorerKey    
            AND   LOC.Facility = @cFacility)    
         BEGIN    
            SET @nErrNo = 59420    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Duplicate ID    
            GOTO Step_3_Fail    
         END    
      END    
    
      -- Check pallet received    
      IF @cCheckPLTID = '1'    
      BEGIN    
         IF EXISTS (SELECT 1 FROM  dbo.ReceiptDetail RD WITH (NOLOCK)    
                    WHERE RD.ReceiptKey = @cReceiptKey    
                    AND RD.StorerKey = @cStorerKey    
                    AND RD.ToID = RTRIM(@cID)    
                    AND RD.BeforeReceivedQty > 0)    
         BEGIN    
            SET @nErrNo = 59421    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ID received    
            GOTO Step_3_Fail    
         END    
      END    
    
      -- Extended validate          
      IF @cExtendedValidateSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile      INT,           ' +    
               '@nFunc        INT,           ' +    
               '@cLangCode    NVARCHAR( 3),  ' +    
               '@nStep        INT,           ' +    
               '@nInputKey    INT,           ' +    
               '@cFacility    NVARCHAR( 5),  ' +     
               '@cStorerKey   NVARCHAR( 15), ' +    
               '@cReceiptKey  NVARCHAR( 10), ' +    
               '@cPOKey       NVARCHAR( 10), ' +    
               '@cLOC         NVARCHAR( 10), ' +    
               '@cID          NVARCHAR( 18), ' +    
               '@cSKU         NVARCHAR( 20), ' +    
               '@cLottable01  NVARCHAR( 18), ' +    
               '@cLottable02  NVARCHAR( 18), ' +    
               '@cLottable03  NVARCHAR( 18), ' +    
               '@dLottable04  DATETIME,      ' +    
               '@dLottable05  DATETIME,      ' +    
               '@cLottable06  NVARCHAR( 30), ' +    
               '@cLottable07  NVARCHAR( 30), ' +    
               '@cLottable08  NVARCHAR( 30), ' +    
               '@cLottable09  NVARCHAR( 30), ' +    
               '@cLottable10  NVARCHAR( 30), ' +    
               '@cLottable11  NVARCHAR( 30), ' +    
               '@cLottable12  NVARCHAR( 30), ' +    
               '@dLottable13  DATETIME,      ' +    
               '@dLottable14  DATETIME,      ' +    
               '@dLottable15  DATETIME,      ' +    
               '@nQTY         INT,           ' +    
               '@cReasonCode  NVARCHAR( 10), ' +    
               '@cSuggToLOC   NVARCHAR( 10), ' +    
               '@cFinalLOC    NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10), ' +    
               '@nErrNo             INT            OUTPUT, ' +    
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @nErrNo OUTPUT, @cErrMsg OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Step_3_Fail     
         END    
      END    
    
      -- Init next screen var    
      SET @cOutField01 = @cID    
      SET @cMax = @cSKU -- SKU    
      SET @cOutField03 = '' -- SKUDesc1    
      SET @cOutField04 = '' -- SKUDesc2    
    
      -- Go to next screen    
      SET @nScn  = @nScn + 1    
      SET @nStep = @nStep + 1    
   END    
    
   IF @nInputKey = 0 -- Esc or No    
   BEGIN    
      -- Prepare prev screen var    
      SET @cOutField01 = @cReceiptKey    
      SET @cOutField02 = @cPOKey    
      SET @cOutField03 = @cLOC    
    
      SET @nScn = @nScn - 1    
      SET @nStep = @nStep - 1    
    
      GOTO Quit    
   END    
    
   -- If need direct flow thru screen then must have turn on decode    
   -- If already acruired next screen required value then go next screen    
   IF @cFlowThruScreen = '1'    
   BEGIN    
      IF @cDecodeSP <> ''    
      BEGIN    
         IF ISNULL( @cSKU, '') <> ''    
         BEGIN    
            SET @cMax = @cSKU    
    
            GOTO Step_4    
         END    
      END    
   END    
    
   GOTO Quit    
    
   Step_3_Fail:    
   BEGIN    
      -- Reset this screen var    
      SET @cOutField02 = '' -- ID    
      SET @cID = ''    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 4. Scn = 4033. SKU screen    
   TO ID    (field01)    
   SKU      (field02, intput)    
   SKU desc (field03)    
   SKU desc (field04)    
********************************************************************************/    
Step_4:    
BEGIN    
   IF @nInputKey = 1 -- Yes or Send    
   BEGIN    
      DECLARE @cSKUBarcode NVARCHAR( 2000)    
      DECLARE @cUPC NVARCHAR(30)    
    
      -- Screen mapping    
      SET @cUPC = SUBSTRING( @cMax, 1, 30) -- SKU    
      SET @cSKUBarcode = SUBSTRING( @cMax, 1, 2000)    
    
      -- Validate compulsary field    
      IF @cSKUBarcode = '' OR @cSKUBarcode IS NULL    
      BEGIN    
         SET @nErrNo = 59422    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU is require    
         GOTO Step_4_Fail    
      END    
    
      -- Decode    
      IF @cDecodeSP <> ''    
      BEGIN    
         SET @nTempQTY = @nQty    
         SET @nQty = 0    
    
         -- Standard decode    
         IF @cDecodeSP = '1'    
         BEGIN    
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cSKUBarcode,     
               @cID         OUTPUT, @cUPC        OUTPUT, @nQTY        OUTPUT,     
               @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,    
               @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,    
               @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,    
               @cUserDefine01 OUTPUT, @cUserDefine02 OUTPUT, @cUserDefine03 OUTPUT, @cUserDefine04 OUTPUT, @cUserDefine05 OUTPUT,      
               @cType   = 'UPC'      
         END    
             
         -- Customize decode    
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cBarcode, @cFieldName, ' +    
               ' @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT, ' +    
               ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT, ' +    
               ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT, ' +    
               ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT, ' +    
               ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'    
            SET @cSQLParam =    
               ' @nMobile      INT,             ' +    
               ' @nFunc        INT,             ' +    
               ' @cLangCode    NVARCHAR( 3),    ' +    
               ' @nStep        INT,             ' +    
               ' @nInputKey    INT,             ' +    
               ' @cStorerKey   NVARCHAR( 15),   ' +    
               ' @cReceiptKey  NVARCHAR( 10),   ' +    
               ' @cPOKey       NVARCHAR( 10),   ' +    
               ' @cLOC         NVARCHAR( 10),   ' +    
               ' @cBarcode     NVARCHAR( 2000), ' +    
               ' @cFieldName   NVARCHAR( 10),   ' +    
               ' @cID          NVARCHAR( 18)  OUTPUT, ' +    
               ' @cSKU         NVARCHAR( 20)  OUTPUT, ' +    
               ' @nQTY         INT            OUTPUT, ' +    
               ' @cLottable01  NVARCHAR( 18)  OUTPUT, ' +    
               ' @cLottable02  NVARCHAR( 18)  OUTPUT, ' +    
               ' @cLottable03  NVARCHAR( 18)  OUTPUT, ' +    
               ' @dLottable04  DATETIME       OUTPUT, ' +    
               ' @dLottable05  DATETIME       OUTPUT, ' +    
               ' @cLottable06  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable07  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable08  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable09  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable10  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable11  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable12  NVARCHAR( 30)  OUTPUT, ' +    
               ' @dLottable13  DATETIME       OUTPUT, ' +    
               ' @dLottable14  DATETIME       OUTPUT, ' +    
               ' @dLottable15  DATETIME       OUTPUT, ' +    
               ' @nErrNo       INT            OUTPUT, ' +    
               ' @cErrMsg      NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cSKUBarcode, 'SKU',    
               @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT,    
               @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,    
               @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,    
               @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,    
               @nErrNo      OUTPUT, @cErrMsg     OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Step_4_Fail    
                   
            IF @cSKU <> ''    
               SET @cUPC = @cSKU    
               SET @cScanBarcode = @cSKUBarcode --(cc01)  
         END    
    
         -- Check something returned from decode    
         IF ISNULL( @nQty, 0) = 0    
            SET @nQty = @nTempQty   -- Assign back the original value if any    
      END    
    
      -- Get SKU    
      DECLARE @nSKUCnt INT , @bSuccess NVARCHAR(1)  
      SET @nSKUCnt = 0    
      --SELECT    
      --   @nSKUCnt = COUNT( DISTINCT A.SKU),    
      --   @cSKU = MIN( A.SKU) -- Just to bypass SQL aggregrate checking    
      --FROM    
      --(    
      --   SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.SKU = @cUPC    
      --   UNION ALL    
      --   SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.AltSKU = @cUPC    
      --   UNION ALL    
      --   SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.RetailSKU = @cUPC    
      --   UNION ALL    
      --   SELECT StorerKey, SKU FROM dbo.SKU SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU.ManufacturerSKU = @cUPC    
      --   UNION ALL    
      --   SELECT StorerKey, SKU FROM dbo.UPC UPC WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND UPC.UPC = @cUPC    
      --) A    
    
      -- Check SKU    
  
      EXEC RDT.rdt_GetSKUCNT            
      @cStorerKey  = @cStorerKey            
      ,@cSKU        = @cUPC            
      ,@nSKUCnt     = @nSKUCnt   OUTPUT            
      ,@bSuccess    = @bSuccess  OUTPUT            
      ,@nErr        = @nErrNo    OUTPUT            
      ,@cErrMsg     = @cErrMsg   OUTPUT    
      ,@cSKUStatus  = 'ACTIVE'  
  
  
      IF @nSKUCnt = 0    
      BEGIN    
         SET @nErrNo = 59423    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU    
         GOTO Step_4_Fail    
      END    
  
      IF @nSKUCnt = 1    
      BEGIN    
         EXEC [RDT].[rdt_GETSKU]    
         @cStorerKey  = @cStorerKey    
         ,@cSKU        = @cUPC          OUTPUT    
         ,@bSuccess    = @b_Success     OUTPUT    
         ,@nErr        = @nErrNo        OUTPUT    
         ,@cErrMsg     = @cErrMsg       OUTPUT   
         ,@cSKUStatus  = 'ACTIVE' -- (james06)

         SET @cSKU = @cUPC  
      END   
    
      -- Check barcode return multi SKU    
      IF @nSKUCnt > 1    
      BEGIN    
         -- (james03)    
         IF @cMultiSKUBarcode IN ('1', '2')    
         BEGIN    
            EXEC rdt.rdt_MultiSKUBarcode @nMobile, @nFunc, @cLangCode,    
               @cInField01 OUTPUT,  @cOutField01 OUTPUT,    
               @cInField02 OUTPUT,  @cOutField02 OUTPUT,    
               @cInField03 OUTPUT,  @cOutField03 OUTPUT,    
@cInField04 OUTPUT,  @cOutField04 OUTPUT,    
               @cInField05 OUTPUT,  @cOutField05 OUTPUT,    
               @cInField06 OUTPUT,  @cOutField06 OUTPUT,    
               @cInField07 OUTPUT,  @cOutField07 OUTPUT,    
               @cInField08 OUTPUT,  @cOutField08 OUTPUT,    
               @cInField09 OUTPUT,  @cOutField09 OUTPUT,    
               @cInField10 OUTPUT,  @cOutField10 OUTPUT,    
               @cInField11 OUTPUT,  @cOutField11 OUTPUT,    
               @cInField12 OUTPUT,  @cOutField12 OUTPUT,    
               @cInField13 OUTPUT,  @cOutField13 OUTPUT,    
               @cInField14 OUTPUT,  @cOutField14 OUTPUT,    
               @cInField15 OUTPUT,  @cOutField15 OUTPUT,    
               'POPULATE',    
               @cMultiSKUBarcode,    
               @cStorerKey,    
               @cUPC     OUTPUT,    
               @nErrNo   OUTPUT,    
               @cErrMsg  OUTPUT,    
               'ASN',    -- DocType    
               @cReceiptKey    
    
            IF @nErrNo = 0 -- Populate multi SKU screen    
            BEGIN    
               -- Go to Multi SKU screen    
               SET @nFromScn = @nScn    
               SET @nScn = 3570    
               SET @nStep = @nStep + 9    
               GOTO Quit    
            END    
            IF @nErrNo = -1 -- Found in Doc, skip multi SKU screen    
            BEGIN    
               SET @nErrNo = 0    
               SET @cSKU = @cUPC    
            END  
              
            IF @nErrNo = 2 --(yeekung02)        
            BEGIN     
                 
               DECLARE @cAllow_OverReceipt NVARCHAR (1)  
                   
               -- Storer config 'Allow_OverReceipt'    
               EXECUTE dbo.nspGetRight    
                  NULL, -- Facility    
                  @cStorerKey,    
                  @cSKU,    
                  'Allow_OverReceipt',    
                  @b_success             OUTPUT,    
                  @cAllow_OverReceipt    OUTPUT,    
                  @nErrNo                OUTPUT,    
                  @cErrMsg               OUTPUT    
               IF @b_success <> 1    
               BEGIN    
                  SET @nErrNo = 59444    
                  SET @cErrMsg = rdt.rdtgetmessage( 60301, @cLangCode, 'DSP') --'nspGetRight'    
                  GOTO Step_4_Fail    
               END   
  
               -- Not allow over receive, by DocType (follow Exceed way in ntrReceiptDetailUpdate)    
               IF NOT(@cAllow_OverReceipt IN ('0', '') OR                   -- Not allow for all doc type    
                  (@cAllow_OverReceipt = '2' AND @cDocType <> 'R') OR   -- Not allow, except return (means only return is allow)    
                  (@cAllow_OverReceipt = '3' AND @cDocType <> 'A') OR   -- Not allow, except normal (means only normal is allow)    
                  (@cAllow_OverReceipt = '4' AND @cDocType <> 'X') )     -- Not allow, except xdock  (means only xdoc   is allow)    
                  AND (rdt.RDTGetConfig( @nFunc, 'SkipCheckingSKUNotInASN', @cStorerKey) = '1')  -- SKUNotinASN  
               BEGIN   
                  EXEC rdt.rdt_MultiSKUBarcode @nMobile, @nFunc, @cLangCode,            
                  @cInField01 OUTPUT,  @cOutField01 OUTPUT,            
                  @cInField02 OUTPUT,  @cOutField02 OUTPUT,            
                  @cInField03 OUTPUT,  @cOutField03 OUTPUT,            
                  @cInField04 OUTPUT,  @cOutField04 OUTPUT,            
                  @cInField05 OUTPUT,  @cOutField05 OUTPUT,            
                  @cInField06 OUTPUT,  @cOutField06 OUTPUT,            
                  @cInField07 OUTPUT,  @cOutField07 OUTPUT,            
                  @cInField08 OUTPUT,  @cOutField08 OUTPUT,            
                  @cInField09 OUTPUT,  @cOutField09 OUTPUT,            
                  @cInField10 OUTPUT,  @cOutField10 OUTPUT,            
                  @cInField11 OUTPUT,  @cOutField11 OUTPUT,            
                  @cInField12 OUTPUT,  @cOutField12 OUTPUT,            
                  @cInField13 OUTPUT,  @cOutField13 OUTPUT,            
                  @cInField14 OUTPUT,  @cOutField14 OUTPUT,            
                  @cInField15 OUTPUT,  @cOutField15 OUTPUT,            
                  'POPULATE',            
                  @cMultiSKUBarcode,            
                  @cStorerKey,            
                  @cUPC     OUTPUT,            
                  @nErrNo   OUTPUT,            
                  @cErrMsg  OUTPUT            
            
                  IF @nErrNo = 0 -- Populate multi SKU screen            
                  BEGIN            
                     -- Go to Multi SKU screen            
                     --SET @cErrMsg=@cUPC                
                     SET @nFromScn = @nScn            
                     SET @nScn = 3570    
                     SET @nStep = @nStep + 9          
                     GOTO Quit            
                  END            
                  IF @nErrNo = -1 -- Found in Doc, skip multi SKU screen            
                  BEGIN            
                     SET @nErrNo = 0            
                     SET @cSKU = @cUPC            
                  END         
                  IF @nErrNo = 2 --No sku found           
                  BEGIN            
                     SET @nErrNo = 59445          
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSkuFound          
                     GOTO Step_4_Fail              
                  END        
               END        
               ELSE        
               BEGIN            
                  SET @nErrNo = 59446          
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSkuFound          
                  GOTO Step_4_Fail              
               END         
            END    
         END    
         ELSE    
         BEGIN    
            SET @nErrNo = 59425    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod    
            GOTO Step_4_Fail    
         END    
    
      END    
  
      -- Get SKU info    
      SET @cSKUDesc = ''    
      SELECT     
         @cSKUDesc = ISNULL( DescR, ''),     
         @cLottableCode = LottableCode    
      FROM dbo.SKU WITH (NOLOCK)    
      WHERE StorerKey = @cStorerKey    
         AND SKU = @cSKU    
    
      -- Retain value    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2    
    
      -- Check SKU in PO    
      IF @cPOKey <> '' AND @cPOKey <> 'NOPO'    
      BEGIN    
         IF NOT EXISTS (SELECT 1 FROM dbo.PODetail WITH (NOLOCK) WHERE POKey = @cPOKey AND StorerKey = @cStorerKey AND SKU = @cSKU)    
         BEGIN    
            SET @nErrNo = 59426    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not in PO    
            GOTO Step_4_Fail    
         END    
      END    
    
      -- Check SKU in ASN    
      DECLARE @nSKUNotInASN INT    
      IF NOT EXISTS( SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND StorerKey = @cStorerKey AND SKU = @cSKU)    
      BEGIN    
         SET @nSKUNotInASN = 1    
         IF @cAddSKUtoASN <> '1'    
         BEGIN    
            SET @nErrNo = 59424    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU not in ASN    
            GOTO Step_4_Fail    
         END    
      END    
    
      -- Verify SKU    
      IF @cVerifySKU = '1'    
      BEGIN    
         EXEC rdt.rdt_VerifySKU_V7 @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cSKU, @cSKUDesc, 'CHECK',    
            @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,        
            @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,        
            @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,        
            @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,        
            @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,        
            @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,       
            @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,       
            @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,       
            @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,       
            @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,       
            @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,      
            @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,      
            @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,      
            @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,      
            @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,      
            @nErrNo     OUTPUT,    
            @cErrMsg    OUTPUT    
    
         IF @nErrNo <> 0    
         BEGIN    
            -- Go to verify SKU screen    
            SET @nFromScn = @nScn    
            SET @nScn = 3951    
            SET @nStep = @nStep + 6    
    
            GOTO Quit    
         END    
      END    
    
      -- Get receiving info    
      IF @cGetReceiveInfoSP = ''    
      BEGIN    
         SELECT TOP 1    
            @cLottable01 = Lottable01,    
            @cLottable02 = Lottable02,    
            @cLottable03 = Lottable03,    
            @dLottable04 = Lottable04,    
            @dLottable05 = Lottable05,    
            @cLottable06 = Lottable06,    
            @cLottable07 = Lottable07,    
            @cLottable08 = Lottable08,    
            @cLottable09 = Lottable09,    
            @cLottable10 = Lottable10,    
            @cLottable11 = Lottable11,    
            @cLottable12 = Lottable12,    
            @dLottable13 = Lottable13,    
            @dLottable14 = Lottable14,    
            @dLottable15 = Lottable15    
         FROM dbo.ReceiptDetail WITH (NOLOCK)    
         WHERE ReceiptKey = @cReceiptKey    
            AND POKey = CASE WHEN @cPOKey = 'NOPO' THEN POKey ELSE @cPOKey END    
            AND SKU = @cSKU    
         ORDER BY    
            CASE WHEN @cID = ToID THEN 0 ELSE 1 END,    
            CASE WHEN QTYExpected > 0 AND QTYExpected > BeforeReceivedQTY THEN 0 ELSE 1 END,    
            ReceiptLineNumber    
      END    
      ELSE    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cGetReceiveInfoSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetReceiveInfoSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, ' +    
               ' @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT, ' +    
               ' @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT, ' +    
               ' @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT, ' +    
               ' @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT, ' +    
               ' @nErrNo      OUTPUT, @cErrMsg     OUTPUT'    
            SET @cSQLParam =    
               ' @nMobile      INT,           ' +    
               ' @nFunc        INT,           ' +    
               ' @cLangCode    NVARCHAR( 3),  ' +    
               ' @nStep        INT,           ' +    
               ' @nInputKey    INT,           ' +    
               ' @cStorerKey   NVARCHAR( 15), ' +    
               ' @cReceiptKey  NVARCHAR( 10), ' +    
               ' @cPOKey       NVARCHAR( 10), ' +    
               ' @cLOC         NVARCHAR( 10), ' +    
               ' @cID          NVARCHAR( 18)  OUTPUT, ' +    
               ' @cSKU         NVARCHAR( 20)  OUTPUT, ' +    
               ' @nQTY         INT         OUTPUT, ' +    
               ' @cLottable01  NVARCHAR( 18)  OUTPUT, ' +    
               ' @cLottable02  NVARCHAR( 18)  OUTPUT, ' +    
               ' @cLottable03  NVARCHAR( 18)  OUTPUT, ' +    
               ' @dLottable04  DATETIME       OUTPUT, ' +    
               ' @dLottable05  DATETIME       OUTPUT, ' +    
               ' @cLottable06  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable07  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable08  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable09  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable10  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable11  NVARCHAR( 30)  OUTPUT, ' +    
               ' @cLottable12  NVARCHAR( 30)  OUTPUT, ' +    
               ' @dLottable13  DATETIME       OUTPUT, ' +    
               ' @dLottable14  DATETIME       OUTPUT, ' +    
               ' @dLottable15  DATETIME       OUTPUT, ' +    
               ' @nErrNo       INT            OUTPUT, ' +    
               ' @cErrMsg      NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC,    
               @cID         OUTPUT, @cSKU        OUTPUT, @nQTY        OUTPUT,    
               @cLottable01 OUTPUT, @cLottable02 OUTPUT, @cLottable03 OUTPUT, @dLottable04 OUTPUT, @dLottable05 OUTPUT,    
               @cLottable06 OUTPUT, @cLottable07 OUTPUT, @cLottable08 OUTPUT, @cLottable09 OUTPUT, @cLottable10 OUTPUT,    
               @cLottable11 OUTPUT, @cLottable12 OUTPUT, @dLottable13 OUTPUT, @dLottable14 OUTPUT, @dLottable15 OUTPUT,    
               @nErrNo      OUTPUT, @cErrMsg     OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Step_4_Fail    
         END    
      END    
    
      -- Extended validate    
      IF @cExtendedValidateSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile      INT,           ' +    
               '@nFunc        INT,           ' +    
               '@cLangCode    NVARCHAR( 3),  ' +    
               '@nStep        INT,           ' +    
               '@nInputKey    INT,           ' +    
               '@cFacility    NVARCHAR( 5),  ' +     
               '@cStorerKey   NVARCHAR( 15), ' +    
               '@cReceiptKey  NVARCHAR( 10), ' +    
               '@cPOKey       NVARCHAR( 10), ' +    
               '@cLOC         NVARCHAR( 10), ' +    
               '@cID          NVARCHAR( 18), ' +    
               '@cSKU         NVARCHAR( 20), ' +    
               '@cLottable01  NVARCHAR( 18), ' +    
               '@cLottable02  NVARCHAR( 18), ' +    
               '@cLottable03  NVARCHAR( 18), ' +    
               '@dLottable04  DATETIME,      ' +    
               '@dLottable05  DATETIME,      ' +    
               '@cLottable06  NVARCHAR( 30), ' +    
               '@cLottable07  NVARCHAR( 30), ' +    
               '@cLottable08  NVARCHAR( 30), ' +    
               '@cLottable09  NVARCHAR( 30), ' +    
               '@cLottable10  NVARCHAR( 30), ' +    
               '@cLottable11  NVARCHAR( 30), ' +    
               '@cLottable12  NVARCHAR( 30), ' +    
               '@dLottable13  DATETIME,      ' +    
               '@dLottable14  DATETIME,      ' +    
               '@dLottable15  DATETIME,      ' +    
               '@nQTY         INT,           ' +    
               '@cReasonCode  NVARCHAR( 10), ' +    
               '@cSuggToLOC   NVARCHAR( 10), ' +    
               '@cFinalLOC    NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10), ' +    
               '@nErrNo             INT            OUTPUT, ' +    
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @nErrNo OUTPUT, @cErrMsg OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Step_4_Fail     
         END    
      END    
    
      -- Add SKU to ASN    
      IF @nSKUNotInASN = 1 AND @cAddSKUtoASN = '1'    
      BEGIN    
         -- Prepare next screen var    
         SET @cOutField01 = '' -- Option    
    
         -- Go to Add SKU to ASN screen    
         SET @nFromScn = @nScn    
         SET @nScn  = @nScn + 4    
         SET @nStep = @nStep + 4    
    
         GOTO Quit    
      END    
    
      -- Dynamic lottable    
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,     
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,    
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,    
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,    
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,    
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,    
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,    
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,    
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,    
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,    
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,    
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,    
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,    
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,    
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,    
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,    
         @nMorePage   OUTPUT,    
         @nErrNo      OUTPUT,    
         @cErrMsg     OUTPUT,    
         @cReceiptKey,    
         @nFunc    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      IF @nMorePage = 1 -- Yes    
      BEGIN    
         -- Go to dynamic lottable screen    
         SET @nFromScn = @nScn    
         SET @nScn = 3990    
         SET @nStep = @nStep + 1    
      END    
      ELSE    
      BEGIN    
         -- Get SKU info    
         SELECT    
            @cSKUDesc = IsNULL( DescR, ''),    
            @cIVAS = IsNULL( IVAS, ''),    
            @cLottableCode = LottableCode,    
            @cMUOM_Desc = Pack.PackUOM3,    
            @cPUOM_Desc =    
               CASE @cPUOM    
                  WHEN '2' THEN Pack.PackUOM1 -- Case    
                  WHEN '3' THEN Pack.PackUOM2 -- Inner pack    
                  WHEN '6' THEN Pack.PackUOM3 -- Master unit    
                  WHEN '1' THEN Pack.PackUOM4 -- Pallet    
                  WHEN '4' THEN Pack.PackUOM8 -- Other unit 1    
                  WHEN '5' THEN Pack.PackUOM9 -- Other unit 2    
               END,    
               @nPUOM_Div = CAST( IsNULL(    
               CASE @cPUOM    
                  WHEN '2' THEN Pack.CaseCNT    
                  WHEN '3' THEN Pack.InnerPack    
                  WHEN '6' THEN Pack.QTY    
                  WHEN '1' THEN Pack.Pallet    
                  WHEN '4' THEN Pack.OtherUnit1    
                  WHEN '5' THEN Pack.OtherUnit2    
               END, 1) AS INT)    
         FROM dbo.SKU SKU WITH (NOLOCK)    
            INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)    
         WHERE SKU.StorerKey = @cStorerKey    
            AND SKU.SKU = @cSKU    
    
         -- Convert to prefer UOM QTY    
         IF @cPUOM = '6' OR -- When preferred UOM = master unit    
            @nPUOM_Div = 0  -- UOM not setup    
         BEGIN    
            SET @cPUOM_Desc = ''    
            SET @nPQTY = 0    
            SET @nMQTY = @nQTY    
            SET @cFieldAttr08 = 'O' -- @nPQTY    
         END    
         ELSE    
         BEGIN    
            SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM    
            SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit    
            SET @cFieldAttr08 = '' -- @nPQTY    
         END    
    
         -- Prepare next screen variable    
         SET @cOutField01 = @cSKU    
         SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
         SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
         SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)    
         SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END    
         SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)    
         SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)    
         SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY    
         SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY    
         SET @cOutField10 = '' -- Reason    
         SET @cOutField15 = '' -- ExtendedInfo    
    
         IF @cFieldAttr08 = ''    
            EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY    
    
         -- Go to QTY screen    
         SET @nScn = @nScn + 2    
         SET @nStep = @nStep + 2    
    
         -- Extended info    
         IF @cExtendedInfoSP <> ''    
         BEGIN    
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')    
            BEGIN    
               SET @cExtendedInfo = ''    
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +    
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
                  ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
                  ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
                  ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
                  ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
                  ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'    
               SET @cSQLParam =    
                  '@nMobile       INT,           ' +    
                  '@nFunc         INT,           ' +    
                  '@cLangCode     NVARCHAR( 3),  ' +    
                  '@nStep         INT,           ' +    
                  '@nAfterStep    INT,           ' +     
                  '@nInputKey     INT,           ' +    
                  '@cFacility     NVARCHAR( 5),  ' +     
                  '@cStorerKey    NVARCHAR( 15), ' +    
                  '@cReceiptKey   NVARCHAR( 10), ' +    
                  '@cPOKey        NVARCHAR( 10), ' +    
                  '@cLOC          NVARCHAR( 10), ' +    
                  '@cID           NVARCHAR( 18), ' +    
                  '@cSKU          NVARCHAR( 20), ' +    
                  '@cLottable01   NVARCHAR( 18), ' +    
                  '@cLottable02   NVARCHAR( 18), ' +    
                  '@cLottable03   NVARCHAR( 18), ' +    
                  '@dLottable04   DATETIME,      ' +    
                  '@dLottable05   DATETIME,      ' +    
                  '@cLottable06   NVARCHAR( 30), ' +    
                  '@cLottable07   NVARCHAR( 30), ' +    
                  '@cLottable08   NVARCHAR( 30), ' +    
                  '@cLottable09   NVARCHAR( 30), ' +    
                  '@cLottable10   NVARCHAR( 30), ' +    
                  '@cLottable11   NVARCHAR( 30), ' +    
                  '@cLottable12   NVARCHAR( 30), ' +    
                  '@dLottable13   DATETIME,      ' +    
                  '@dLottable14   DATETIME,      ' +    
                  '@dLottable15   DATETIME,      ' +    
                  '@nQTY          INT,           ' +    
                  '@cReasonCode   NVARCHAR( 10), ' +    
                  '@cSuggToLOC    NVARCHAR( 10), ' +    
                  '@cFinalLOC     NVARCHAR( 10), ' +    
                  '@cReceiptLineNumber NVARCHAR( 10),   ' +    
                  '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +     
                  '@nErrNo        INT           OUTPUT, ' +    
                  '@cErrMsg       NVARCHAR( 20) OUTPUT'    
       
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
                  @nMobile, @nFunc, @cLangCode, 4, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
                  @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
                  @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
                  @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
                  @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
                  @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT    
       
               IF @nErrNo <> 0    
                  GOTO Step_3_Fail    
       
               SET @cOutField15 = @cExtendedInfo    
            END    
         END    
      END    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      -- Check if pallet label setup    
      IF EXISTS( SELECT 1 FROM RDT.RDTReport WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ReportType IN ('PalletLBL'))    
      BEGIN    
         -- Prepare next screen var    
         SET @cOutField01 = '' -- Option    
    
         -- Go to print pallet label screen    
         SET @nScn = @nScn + 5    
         SET @nStep = @nStep + 5    
      END    
      ELSE    
      BEGIN    
         -- Prepare next screen var    
         SET @cOutField01 = @cLOC    
         SET @cOutField02 = '' -- @cID    
    
         -- Go to ID screen    
         SET @nScn = @nScn - 1    
         SET @nStep = @nStep - 1    
      END    
          
      GOTO Quit    
   END    
       
   -- If need direct flow thru screen then must have turn on decode    
   -- If already acruired next screen required value then go next screen    
   IF @cFlowThruScreen = '1'    
   BEGIN    
      IF @cDecodeSP <> ''    
      BEGIN    
         IF ISNULL( @nQty, 0) > 0    
         BEGIN    
            SET @cInField09 = @nQty    
            SET @cInField10 = 'OK'    
    
            GOTO Step_6    
         END    
      END    
   END    
    
   GOTO Quit      
    
   Step_4_Fail:    
   BEGIN    
      -- Reset this screen var    
      SET @cMax = '' -- SKU    
      SET @cSKU = ''    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 5. Scn = 3490. Dynamic lottables    
   Label01    (field01)    
   Lottable01 (field02, input)    
   Label02    (field03)    
   Lottable02 (field04, input)    
   Label03    (field05)    
   Lottable03 (field06, input)    
   Label04    (field07)    
   Lottable04 (field08, input)    
   Label05    (field09)    
   Lottable05 (field10, input)    
********************************************************************************/    
Step_5:    
BEGIN    
   IF @nInputKey = 1 -- Yes or Send    
   BEGIN    
      -- Dynamic lottable    
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'CHECK', 5, 1,     
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,    
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,    
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,    
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,    
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,    
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,    
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,    
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,    
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,    
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,    
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,    
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,    
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,    
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,    
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,    
         @nMorePage   OUTPUT,    
         @nErrNo      OUTPUT,    
         @cErrMsg     OUTPUT,    
         @cReceiptKey,    
         @nFunc    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      IF @nMorePage = 1 -- Yes    
         GOTO Quit    
    
      -- Enable field    
      SET @cFieldAttr02 = '' -- Dynamic lottable 1..5    
      SET @cFieldAttr04 = ''    
      SET @cFieldAttr06 = ''    
      SET @cFieldAttr08 = ''    
      SET @cFieldAttr10 = ''    
    
      -- Get SKU info    
      SELECT    
         @cSKUDesc = IsNULL( DescR, ''),    
         @cIVAS = IsNULL( IVAS, ''),    
         @cLottableCode = LottableCode,    
         @cMUOM_Desc = Pack.PackUOM3,    
         @cPUOM_Desc =    
            CASE @cPUOM    
               WHEN '2' THEN Pack.PackUOM1 -- Case    
               WHEN '3' THEN Pack.PackUOM2 -- Inner pack    
               WHEN '6' THEN Pack.PackUOM3 -- Master unit    
               WHEN '1' THEN Pack.PackUOM4 -- Pallet    
               WHEN '4' THEN Pack.PackUOM8 -- Other unit 1    
               WHEN '5' THEN Pack.PackUOM9 -- Other unit 2    
            END,    
            @nPUOM_Div = CAST( IsNULL(    
            CASE @cPUOM    
               WHEN '2' THEN Pack.CaseCNT    
               WHEN '3' THEN Pack.InnerPack    
               WHEN '6' THEN Pack.QTY    
               WHEN '1' THEN Pack.Pallet    
               WHEN '4' THEN Pack.OtherUnit1    
               WHEN '5' THEN Pack.OtherUnit2    
            END, 1) AS INT)    
      FROM dbo.SKU SKU WITH (NOLOCK)    
         INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)    
      WHERE SKU.StorerKey = @cStorerKey    
         AND SKU.SKU = @cSKU    
    
      -- Convert to prefer UOM QTY    
      IF @cPUOM = '6' OR -- When preferred UOM = master unit    
         @nPUOM_Div = 0  -- UOM not setup    
      BEGIN             SET @cPUOM_Desc = ''    
         SET @nPQTY = 0    
         SET @nMQTY = @nQTY    
         SET @cFieldAttr08 = 'O' -- @nPQTY    
      END    
      ELSE    
      BEGIN    
         SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM    
         SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit    
         SET @cFieldAttr08 = '' -- @nPQTY    
      END    
    
      -- Prepare next screen variable    
      SET @cOutField01 = @cSKU    
      SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
      SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)    
      SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END    
      SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)    
      SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)    
      SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY    
      SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY    
      SET @cOutField10 = '' -- Reason    
      SET @cOutField15 = '' -- ExtendedInfo    
    
      IF @cFieldAttr08 = ''    
         EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY    
    
      -- Go to QTY screen    
      SET @nScn  = @nFromScn + 2    
      SET @nStep = @nStep + 1    
          
      -- Extended info    
      IF @cExtendedInfoSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')    
         BEGIN    
            SET @cExtendedInfo = ''    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
    '@nMobile       INT,           ' +    
               '@nFunc         INT,           ' +    
               '@cLangCode     NVARCHAR( 3),  ' +    
               '@nStep         INT,           ' +    
               '@nAfterStep    INT,           ' +     
               '@nInputKey     INT,           ' +    
               '@cFacility     NVARCHAR( 5),  ' +     
               '@cStorerKey    NVARCHAR( 15), ' +    
               '@cReceiptKey   NVARCHAR( 10), ' +    
               '@cPOKey        NVARCHAR( 10), ' +    
               '@cLOC          NVARCHAR( 10), ' +    
               '@cID           NVARCHAR( 18), ' +    
               '@cSKU          NVARCHAR( 20), ' +    
               '@cLottable01   NVARCHAR( 18), ' +    
               '@cLottable02   NVARCHAR( 18), ' +    
               '@cLottable03   NVARCHAR( 18), ' +    
               '@dLottable04   DATETIME,      ' +    
               '@dLottable05   DATETIME,      ' +    
               '@cLottable06   NVARCHAR( 30), ' +    
               '@cLottable07   NVARCHAR( 30), ' +    
               '@cLottable08   NVARCHAR( 30), ' +    
               '@cLottable09   NVARCHAR( 30), ' +    
               '@cLottable10   NVARCHAR( 30), ' +    
               '@cLottable11   NVARCHAR( 30), ' +    
               '@cLottable12   NVARCHAR( 30), ' +    
               '@dLottable13   DATETIME,      ' +    
               '@dLottable14   DATETIME,      ' +    
               '@dLottable15   DATETIME,      ' +    
               '@nQTY          INT,           ' +    
               '@cReasonCode   NVARCHAR( 10), ' +    
               '@cSuggToLOC    NVARCHAR( 10), ' +    
        '@cFinalLOC     NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10),   ' +    
               '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +     
               '@nErrNo        INT           OUTPUT, ' +    
               '@cErrMsg       NVARCHAR( 20) OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, 5, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT    
    
            IF @nErrNo <> 0    
               --GOTO Step_3_Fail    
               GOTO Step_5_Fail --(cc03)  
    
            SET @cOutField15 = @cExtendedInfo    
         END    
      END    
   END    
    
   IF @nInputKey = 0 -- Esc or No    
   BEGIN    
      -- Dynamic lottable    
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,     
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,    
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,    
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,    
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,    
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,    
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,    
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,    
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,    
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,    
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,    
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,    
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,    
     @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,    
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,    
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,    
         @nMorePage   OUTPUT,    
         @nErrNo      OUTPUT,    
         @cErrMsg     OUTPUT,    
         @cReceiptKey,    
         @nFunc    
    
      IF @nMorePage = 1 -- Yes    
         GOTO Quit    
    
      -- Enable field    
      SET @cFieldAttr02 = '' -- Dynamic lottable 1..5    
      SET @cFieldAttr04 = '' --    
      SET @cFieldAttr06 = '' --    
      SET @cFieldAttr08 = '' --    
      SET @cFieldAttr10 = '' --    
    
      -- Load prev screen var    
      SET @cOutField01 = @cID    
      SET @cMax = '' -- @cSKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2    
    
      -- Go back to prev screen    
      SET @nScn = @nFromScn    
      SET @nStep = @nStep - 1    
   END    
   GOTO Quit    
    
   Step_5_Fail:    
    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 6. Scn = 4035. QTY screen    
   SKU       (field01)    
   SKU desc  (field02)    
   SKU desc  (field03)    
   IVAS      (field04)    
   UOM ratio (field05)    
   PUOM      (field06)    
   MUOM   (field07)    
   PQTY      (field08, input)    
   MQTY      (field09, input)    
   Reason    (field10, input)    
********************************************************************************/    
Step_6:    
BEGIN    
   IF @nInputKey = 1 -- Yes or Send    
   BEGIN    
      DECLARE @cPQTY       NVARCHAR( 7)    
      DECLARE @cMQTY       NVARCHAR( 7)    
    
      -- Screen mapping    
      SET @cPQTY = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE @cInField08 END    
      SET @cMQTY = CASE WHEN @cFieldAttr09 = 'O' THEN @cOutField09 ELSE @cInField09 END    
      SET @cReasonCode = @cInField10    
    
      -- Retain value    
      SET @cOutField08 = CASE WHEN @cFieldAttr08 = 'O' THEN @cOutField08 ELSE @cInField08 END -- PQTY    
      SET @cOutField09 = CASE WHEN @cFieldAttr09 = 'O' THEN @cOutField09 ELSE @cInField09 END -- MQTY    
    
      -- Validate PQTY    
      IF @cPQTY <> '' AND RDT.rdtIsValidQTY( @cPQTY, 0) = 0    
      BEGIN    
         SET @nErrNo = 59427    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY    
         EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY    
         GOTO Step_6_Fail    
      END    
      SET @nPQTY = CAST( @cPQTY AS INT)    
    
      -- Validate MQTY    
      IF @cMQTY <> '' AND RDT.rdtIsValidQTY( @cMQTY, 0) = 0    
      BEGIN    
         SET @nErrNo = 59428    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid QTY    
         EXEC rdt.rdtSetFocusField @nMobile, 9 -- MQTY    
         GOTO Step_6_Fail    
      END    
      SET @nMQTY = CAST( @cMQTY AS INT)    
    
      -- Calc total QTY in master UOM    
      SET @nQTY = rdt.rdtConvUOMQTY( @cStorerKey, @cSKU, @cPQTY, @cPUOM, 6) -- Convert to QTY in master UOM    
      SET @nQTY = @nQTY + @nMQTY    
    
      -- Validate reason code exists    
      IF @cReasonCode <> '' AND @cReasonCode IS NOT NULL    
         IF NOT EXISTS( SELECT Code    
            FROM dbo.CodeLKUP WITH (NOLOCK)    
            WHERE ListName = 'ASNREASON'    
               AND Code = @cReasonCode)    
         BEGIN    
            SET @nErrNo = 59429    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad ReasonCode    
            SET @cReasonCode = ''    
            EXEC rdt.rdtSetFocusField @nMobile, 10    
            GOTO Step_6_Fail    
         END    
    
      -- Extended validate    
      IF @cExtendedValidateSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile      INT,           ' +    
               '@nFunc        INT,           ' +    
               '@cLangCode    NVARCHAR( 3),  ' +    
               '@nStep        INT,           ' +    
               '@nInputKey    INT,           ' +    
               '@cFacility    NVARCHAR( 5),  ' +     
               '@cStorerKey   NVARCHAR( 15), ' +    
               '@cReceiptKey  NVARCHAR( 10), ' +    
               '@cPOKey       NVARCHAR( 10), ' +    
               '@cLOC         NVARCHAR( 10), ' +    
               '@cID          NVARCHAR( 18), ' +    
               '@cSKU         NVARCHAR( 20), ' +    
               '@cLottable01  NVARCHAR( 18), ' +    
               '@cLottable02  NVARCHAR( 18), ' +    
               '@cLottable03  NVARCHAR( 18), ' +    
               '@dLottable04  DATETIME,      ' +    
               '@dLottable05  DATETIME,      ' +    
               '@cLottable06  NVARCHAR( 30), ' +    
               '@cLottable07  NVARCHAR( 30), ' +    
               '@cLottable08  NVARCHAR( 30), ' +    
               '@cLottable09  NVARCHAR( 30), ' +    
               '@cLottable10  NVARCHAR( 30), ' +    
               '@cLottable11  NVARCHAR( 30), ' +    
               '@cLottable12  NVARCHAR( 30), ' +    
               '@dLottable13  DATETIME,      ' +    
               '@dLottable14  DATETIME,      ' +    
               '@dLottable15  DATETIME,      ' +    
               '@nQTY         INT,           ' +    
               '@cReasonCode  NVARCHAR( 10), ' +    
               '@cSuggToLOC   NVARCHAR( 10), ' +    
               '@cFinalLOC    NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10), ' +    
               '@nErrNo             INT            OUTPUT, ' +    
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @nErrNo OUTPUT, @cErrMsg OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Step_6_Fail    
         END    
      END    
    
      -- Get UOM    
      DECLARE @cUOM NVARCHAR(10)    
      SELECT @cUOM = PackUOM3    
      FROM dbo.SKU WITH (NOLOCK)    
         JOIN dbo.Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)    
      WHERE StorerKey = @cStorerKey    
         AND SKU = @cSKU    
    
      -- NOPO flag    
      DECLARE @nNOPOFlag INT    
      SET @nNOPOFlag = CASE WHEN @cPOkey = 'NOPO' THEN 1 ELSE 0 END    
    
      -- Reason code    
      IF @cReasonCode = ''    
         SET @cReasonCode = 'OK'    
  
      IF @cSerialNoCapture IN ('1', '2')  -- 1 = INBOUND & OUTBOUND; 2 = INBOUND ONLY; 3 = OUTBOUND ONLY    
      BEGIN    
         EXEC rdt.rdt_SerialNo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cSKU, @cSKUDesc, @nQTY, 'CHECK', 'ASN', @cReceiptKey,    
            @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,    
            @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,    
            @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,    
            @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,    
            @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,    
            @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,    
            @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,    
            @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,    
            @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,    
            @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,    
            @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,    
            @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,    
            @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,    
            @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,    
            @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,    
            @nMoreSNO   OUTPUT,  @cSerialNo   OUTPUT,  @nSerialQTY   OUTPUT,    
            @nErrNo     OUTPUT,  @cErrMsg     OUTPUT    
    
         IF @nErrNo <> 0    
            GOTO Quit    
    
         IF @nMoreSNO = 1    
         BEGIN    
            -- Go to Serial No screen    
            SET @nFromScn = @nScn    
            SET @nScn = 4831    
            SET @nStep = @nStep + 8 --(yeekung04)
            SET @cInField04=''  
            GOTO Quit    
         END    
      END    
    
      -- Custom receiving logic    
      IF @cRcptConfirmSP <> ''    
      BEGIN    
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cRcptConfirmSP) +    
            ' @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cReceiptKey, @cPOKey, @cToLOC, @cToID, ' +    
            ' @cSKUCode, @cSKUUOM, @nSKUQTY, @cUCC, @cUCCSKU, @nUCCQTY, @cCreateUCC, ' +    
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
            ' @nNOPOFlag, @cConditionCode, @cSubreasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cReceiptLineNumberOutput OUTPUT '    
    
         SET @cSQLParam =    
            '@nFunc          INT,            ' +    
            '@nMobile        INT,            ' +    
            '@cLangCode      NVARCHAR( 3),   ' +    
            '@cStorerKey     NVARCHAR( 15),  ' +    
            '@cFacility      NVARCHAR( 5),   ' +    
            '@cReceiptKey    NVARCHAR( 10),  ' +    
            '@cPOKey         NVARCHAR( 10),  ' +    
            '@cToLOC         NVARCHAR( 10),  ' +    
            '@cToID          NVARCHAR( 18),  ' +    
            '@cSKUCode       NVARCHAR( 20),  ' +    
            '@cSKUUOM        NVARCHAR( 10),  ' +    
            '@nSKUQTY        INT,            ' +    
            '@cUCC           NVARCHAR( 20),  ' +    
            '@cUCCSKU        NVARCHAR( 20),  ' +    
            '@nUCCQTY        INT,            ' +    
            '@cCreateUCC     NVARCHAR( 1),   ' +    
            '@cLottable01    NVARCHAR( 18),  ' +    
            '@cLottable02    NVARCHAR( 18),  ' +    
            '@cLottable03    NVARCHAR( 18),  ' +    
            '@dLottable04    DATETIME,       ' +    
            '@dLottable05    DATETIME,       ' +    
            '@cLottable06    NVARCHAR( 30),  ' +    
            '@cLottable07    NVARCHAR( 30),  ' +    
            '@cLottable08    NVARCHAR( 30),  ' +    
            '@cLottable09    NVARCHAR( 30),  ' +    
            '@cLottable10    NVARCHAR( 30),  ' +    
            '@cLottable11    NVARCHAR( 30),  ' +    
            '@cLottable12    NVARCHAR( 30),  ' +    
            '@dLottable13    DATETIME,       ' +    
            '@dLottable14    DATETIME,       ' +    
            '@dLottable15    DATETIME,       ' +    
            '@nNOPOFlag      INT,            ' +    
            '@cConditionCode NVARCHAR( 10),  ' +    
            '@cSubreasonCode NVARCHAR( 10),  ' +    
            '@nErrNo         INT           OUTPUT, ' +    
            '@cErrMsg        NVARCHAR( 20) OUTPUT, ' +    
            '@cReceiptLineNumberOutput NVARCHAR( 5) OUTPUT '    
    
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
            @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cReceiptKey, @cPOKey, @cLOC, @cID,    
            @cSKU, @cUOM, @nQTY, '', '', 0, '',    
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, NULL,    
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
            @nNOPOFlag, @cReasonCode, '', @nErrNo OUTPUT, @cErrMsg OUTPUT, @cReceiptLineNumber OUTPUT    
      END    
      ELSE    
      BEGIN    
         -- Receive    
         EXEC rdt.rdt_Receive_V7    
            @nFunc         = @nFunc,    
            @nMobile       = @nMobile,    
            @cLangCode     = @cLangCode,    
            @nErrNo        = @nErrNo OUTPUT,    
            @cErrMsg       = @cErrMsg OUTPUT,    
            @cStorerKey    = @cStorerKey,    
            @cFacility     = @cFacility,    
            @cReceiptKey   = @cReceiptKey,    
            @cPOKey        = @cPoKey,  -- (ChewKP01)    
            @cToLOC        = @cLOC,    
            @cToID         = @cID,    
            @cSKUCode      = @cSKU,    
            @cSKUUOM       = @cUOM,    
            @nSKUQTY       = @nQTY,    
            @cUCC          = '',    
            @cUCCSKU       = '',    
            @nUCCQTY       = '',    
            @cCreateUCC    = '',    
            @cLottable01   = @cLottable01,    
            @cLottable02   = @cLottable02,    
            @cLottable03   = @cLottable03,    
            @dLottable04   = @dLottable04,    
            @dLottable05   = NULL,    
            @cLottable06   = @cLottable06,    
            @cLottable07   = @cLottable07,    
            @cLottable08   = @cLottable08,    
            @cLottable09   = @cLottable09,    
            @cLottable10   = @cLottable10,    
            @cLottable11   = @cLottable11,    
            @cLottable12   = @cLottable12,    
            @dLottable13   = @dLottable13,    
            @dLottable14   = @dLottable14,    
            @dLottable15   = @dLottable15,    
            @nNOPOFlag     = @nNOPOFlag,    
            @cConditionCode = @cReasonCode,    
            @cSubreasonCode = '',     
            @cReceiptLineNumberOutput = @cReceiptLineNumber OUTPUT    
      END    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      -- Extended validate    
      IF @cExtendedUpdateSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile      INT,           ' +    
               '@nFunc        INT,           ' +    
               '@cLangCode    NVARCHAR( 3),  ' +    
               '@nStep        INT,           ' +    
               '@nInputKey    INT,           ' +    
               '@cFacility    NVARCHAR( 5),  ' +     
               '@cStorerKey   NVARCHAR( 15), ' +    
               '@cReceiptKey  NVARCHAR( 10), ' +    
               '@cPOKey       NVARCHAR( 10), ' +    
               '@cLOC         NVARCHAR( 10), ' +    
               '@cID          NVARCHAR( 18), ' +    
               '@cSKU         NVARCHAR( 20), ' +    
               '@cLottable01  NVARCHAR( 18), ' +    
               '@cLottable02  NVARCHAR( 18), ' +    
               '@cLottable03  NVARCHAR( 18), ' +    
               '@dLottable04  DATETIME,      ' +    
               '@dLottable05  DATETIME,      ' +    
               '@cLottable06  NVARCHAR( 30), ' +    
               '@cLottable07  NVARCHAR( 30), ' +    
               '@cLottable08  NVARCHAR( 30), ' +    
               '@cLottable09  NVARCHAR( 30), ' +    
               '@cLottable10  NVARCHAR( 30), ' +    
               '@cLottable11  NVARCHAR( 30), ' +    
               '@cLottable12  NVARCHAR( 30), ' +    
               '@dLottable13  DATETIME,      ' +    
               '@dLottable14  DATETIME,      ' +    
               '@dLottable15  DATETIME,      ' +    
               '@nQTY         INT,           ' +    
               '@cReasonCode  NVARCHAR( 10), ' +    
               '@cSuggToLOC   NVARCHAR( 10), ' +    
               '@cFinalLOC    NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10), ' +    
               '@nErrNo             INT            OUTPUT, ' +    
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
 @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @nErrNo OUTPUT, @cErrMsg OUTPUT    
         END    
      END    
    
      -- EventLog    
      EXEC RDT.rdt_STD_EventLog    
         @cActionType   = '2', -- Receiving     --SY01  
         @cUserID       = @cUserName,    
         @nMobileNo     = @nMobile,    
         @nFunctionID   = @nFunc,    
         @cFacility     = @cFacility,    
         @cStorerKey    = @cStorerKey,    
         @cReceiptKey   = @cReceiptKey,    
         @cPOKey        = @cPOKey,     
         @cLocation     = @cLOC,    
         @cID           = @cID,    
         @cSKU          = @cSKU,    
         @cUOM          = @cUOM,    
         @nQTY          = @nQTY,    
         --@cRefNo1       = @cReceiptKey, -- Retain for backward compatible    
         --@cRefNo2       = @cPOKey,      -- Retain for backward compatible    
         --@cRefNo4       = @cReasonCode,     
         @cRefNo1       = @cRefNo, -- (ChewKP01)     
         @cReasonKey    = @cReasonCode,     
         @cLottable01   = @cLottable01,    
         @cLottable02   = @cLottable02,     
         @cLottable03   = @cLottable03,     
         @dLottable04   = @dLottable04,     
         @dLottable05   = @dLottable05,     
         @cLottable06   = @cLottable06,     
         @cLottable07   = @cLottable07,     
         @cLottable08   = @cLottable08,     
         @cLottable09   = @cLottable09,     
         @cLottable10   = @cLottable10,     
         @cLottable11   = @cLottable11,     
         @cLottable12   = @cLottable12,     
         @dLottable13   = @dLottable13,     
         @dLottable14   = @dLottable14,     
         @dLottable15   = @dLottable15    
       
    
      -- Enable field    
      SET @cFieldAttr08 = '' -- @nPQTY    
    
      SET @nScn = @nScn + 1    
      SET @nStep = @nStep + 1    
   END    
    
   IF @nInputKey = 0 -- Esc or No    
   BEGIN    
      -- Dynamic lottable    
      EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,     
         @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,    
         @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,    
         @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,    
         @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,    
         @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,    
         @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,    
         @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,    
         @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,    
         @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,    
         @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,    
         @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,    
         @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,    
         @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,    
         @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,    
         @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,    
         @nMorePage   OUTPUT,    
         @nErrNo      OUTPUT,    
         @cErrMsg     OUTPUT,    
         @cReceiptKey,    
         @nFunc    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      IF @nMorePage = 1 -- Yes    
      BEGIN    
         -- Go to dynamic lottable screen    
         SET @nScn = 3990    
         SET @nStep = @nStep - 1    
      END    
      ELSE    
      BEGIN    
         -- Enable field    
         SET @cFieldAttr02 = '' -- Dynamic lottable 1..5    
         SET @cFieldAttr04 = '' --    
         SET @cFieldAttr06 = '' --    
         SET @cFieldAttr08 = '' --    
         SET @cFieldAttr10 = '' --    
    
         -- Prepare prev screen var    
         SET @cOutField01 = @cID    
         SET @cMax = '' -- SKU    
         SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
         SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
    
         -- Go back to SKU screen    
         SET @nScn = @nScn - 2    
         SET @nStep = @nStep - 2    
      END    
      GOTO Quit  
   END    
       
   --(cc02)  
   -- If need direct flow thru screen then must have turn on decode    
   -- If already acruired next screen required value then go next screen    
   IF @cFlowThruScreen = '1'    
   BEGIN    
      IF @cDecodeSP <> ''    
      BEGIN    
         GOTO Step_7      
      END    
   END  
        
   GOTO Quit   
    
   Step_6_Fail:    
    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 7. scn = 4036. Message screen    
   Successful received    
   Press ENTER or ESC    
   to continue    
********************************************************************************/    
Step_7:    
BEGIN    
   -- Check receive pallet    
SET @cPalletRecv = ''    --(AL01)    
   IF @cPalletRecvSP = '1'    
      SET @cPalletRecv = '1'    
   ELSE    
   BEGIN    
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cPalletRecvSP AND type = 'P')    
      BEGIN    
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cPalletRecvSP) +    
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY, ' +    
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
            ' @cPalletRecv OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '    
         SET @cSQLParam =    
            '@nMobile      INT,           ' +    
            '@nFunc        INT,           ' +    
            '@cLangCode    NVARCHAR( 3),  ' +    
            '@nStep        INT,           ' +    
            '@nInputKey    INT,           ' +    
            '@cStorerKey   NVARCHAR( 15), ' +    
            '@cReceiptKey  NVARCHAR( 10), ' +    
            '@cPOKey       NVARCHAR( 10), ' +    
            '@cLOC         NVARCHAR( 10), ' +    
            '@cID          NVARCHAR( 18), ' +    
            '@cSKU         NVARCHAR( 20), ' +    
            '@nQTY         INT,           ' +    
            '@cLottable01  NVARCHAR( 18), ' +    
            '@cLottable02  NVARCHAR( 18), ' +    
            '@cLottable03  NVARCHAR( 18), ' +    
            '@dLottable04  DATETIME,      ' +    
            '@dLottable05  DATETIME,      ' +    
            '@cLottable06  NVARCHAR( 30), ' +    
            '@cLottable07  NVARCHAR( 30), ' +    
            '@cLottable08  NVARCHAR( 30), ' +    
            '@cLottable09  NVARCHAR( 30), ' +    
            '@cLottable10  NVARCHAR( 30), ' +    
            '@cLottable11  NVARCHAR( 30), ' +    
            '@cLottable12  NVARCHAR( 30), ' +    
            '@dLottable13  DATETIME,      ' +    
            '@dLottable14  DATETIME,      ' +    
            '@dLottable15  DATETIME,      ' +    
            '@cPalletRecv  NVARCHAR( 1)   OUTPUT, ' +    
            '@nErrNo       INT            OUTPUT, ' +    
            '@cErrMsg      NVARCHAR( 20)  OUTPUT'    
    
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY,    
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
            @cPalletRecv OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT    
      END    
   END    
       
   -- Check need to putaway    
   SET @cPutaway = ''    
   IF @cPutawaySP = '1' OR @cPutawaySP = '2'    
      SET @cPutaway = @cPutawaySP    
   ELSE    
   BEGIN    
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cPutawaySP AND type = 'P')    
      BEGIN    
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cPutawaySP) +    
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY, ' +    
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
            ' @cPutaway OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '    
         SET @cSQLParam =    
            '@nMobile      INT,           ' +    
            '@nFunc        INT,           ' +    
            '@cLangCode    NVARCHAR( 3),  ' +    
            '@nStep        INT,           ' +    
            '@nInputKey    INT,           ' +    
            '@cStorerKey   NVARCHAR( 15), ' +    
            '@cReceiptKey  NVARCHAR( 10), ' +    
            '@cPOKey       NVARCHAR( 10), ' +    
            '@cLOC         NVARCHAR( 10), ' +    
            '@cID          NVARCHAR( 18), ' +    
    '@cSKU         NVARCHAR( 20), ' +    
            '@nQTY         INT,           ' +    
            '@cLottable01  NVARCHAR( 18), ' +    
            '@cLottable02  NVARCHAR( 18), ' +    
            '@cLottable03  NVARCHAR( 18), ' +    
            '@dLottable04  DATETIME,      ' +    
            '@dLottable05  DATETIME,      ' +    
            '@cLottable06  NVARCHAR( 30), ' +    
            '@cLottable07  NVARCHAR( 30), ' +    
            '@cLottable08  NVARCHAR( 30), ' +    
            '@cLottable09  NVARCHAR( 30), ' +    
            '@cLottable10  NVARCHAR( 30), ' +    
            '@cLottable11  NVARCHAR( 30), ' +    
            '@cLottable12  NVARCHAR( 30), ' +    
            '@dLottable13  DATETIME,      ' +    
            '@dLottable14  DATETIME,      ' +    
            '@dLottable15  DATETIME,      ' +    
            '@cPutaway     NVARCHAR( 1)   OUTPUT, ' +    
            '@nErrNo       INT            OUTPUT, ' +    
            '@cErrMsg      NVARCHAR( 20)  OUTPUT'    
    
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
            @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY,    
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
            @cPutaway OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT    
      END    
   END    
    
   -- Putaway    
   IF @cPutaway = '1' OR @cPutaway = '2'    
   BEGIN    
      -- Suggest LOC    
      EXEC rdt.rdt_NormalReceipt_Putaway @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'SUGGEST',     
         @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY, @cReceiptLineNumber, '',     
         @cSuggToLOC    OUTPUT,     
         @nPABookingKey OUTPUT,     
         @nErrNo        OUTPUT,     
         @cErrMsg       OUTPUT    
       
      -- Prepare next screen var    
      SET @cOutField01 = @cSuggToLOC    
      SET @cOutField02 = '' --FinalLOC    
          
      -- Go to putaway screen    
      SET @nScn = @nScn + 5    
      SET @nStep = @nStep + 5    
          
      GOTO Quit    
   END    
       
   IF @cPalletRecv = '1'    
   BEGIN    
      SET @cID = ''    
    
      -- AutoGenID    
      IF @cAutoGenID = '1'    
      BEGIN    
         EXECUTE dbo.nspg_GetKey    
            'ID',    
            10 ,    
            @cID               OUTPUT,    
            @b_success         OUTPUT,    
            @n_err             OUTPUT,    
            @c_errmsg          OUTPUT    
         IF @b_success <> 1    
         BEGIN    
            SET @nErrNo = 59430    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --AutoGenID Fail    
            GOTO Quit    
         END    
      END    
    
      -- Prep next screen var    
      SET @cOutField01 = @cLOC    
      SET @cOutField02 = @cID    
    
      -- Go to ID screen    
      SET @nScn = @nScn - 4    
      SET @nStep = @nStep - 4    
   END    
   ELSE    
   BEGIN    
      -- Prep next screen var    
      SET @cOutField01 = @cID    
      SET @cMax = '' -- SKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2    
    
      -- Go to SKU screen    
      SET @nScn = @nScn - 3    
      SET @nStep = @nStep - 3    
   END    
    
   -- Reset data    
   SELECT @cSKU = '', @nQTY = 0,    
      @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL, @dLottable05 = NULL,    
      @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',   @cLottable10 = '',    
      @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL, @dLottable15 = NULL    
       
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 8. Scn = 4037. Option    
   ADD SKU NOT IN ASN?    
   1 = YES    
   2 = NO    
   OPTION: (field01, input)    
********************************************************************************/    
Step_8:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      -- Screen mapping    
      SET @cOption = @cInField01    
    
      -- Check blank    
      IF @cOption = ''    
      BEGIN    
         SET @nErrNo = 59431    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Option    
         GOTO Step_8_Fail    
      END    
    
      -- Check valid option    
      IF @cOption <> '1' AND @cOption <> '2'    
      BEGIN    
         SET @nErrNo = 59432    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option    
         GOTO Step_8_Fail    
      END    
    
      IF @cOption = '1' -- Yes    
      BEGIN    
         -- Dynamic lottable    
         EXEC rdt.rdt_Lottable @nMobile, @nFunc, @cLangCode, @nScn, @nInputKey, @cStorerKey, @cSKU, @cLottableCode, 'CAPTURE', 'POPULATE', 5, 1,     
            @cInField01  OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,  @cLottable01 OUTPUT,    
            @cInField02  OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,  @cLottable02 OUTPUT,    
            @cInField03  OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,  @cLottable03 OUTPUT,    
            @cInField04  OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,  @dLottable04 OUTPUT,    
            @cInField05  OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,  @dLottable05 OUTPUT,    
            @cInField06  OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,  @cLottable06 OUTPUT,    
            @cInField07  OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,  @cLottable07 OUTPUT,    
            @cInField08  OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,  @cLottable08 OUTPUT,    
            @cInField09  OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,  @cLottable09 OUTPUT,    
            @cInField10  OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,  @cLottable10 OUTPUT,    
            @cInField11  OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,  @cLottable11 OUTPUT,    
            @cInField12  OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,  @cLottable12 OUTPUT,    
            @cInField13  OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,  @dLottable13 OUTPUT,    
            @cInField14  OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,  @dLottable14 OUTPUT,    
            @cInField15  OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,  @dLottable15 OUTPUT,    
            @nMorePage   OUTPUT,    
            @nErrNo      OUTPUT,    
            @cErrMsg     OUTPUT,    
            @cReceiptKey,    
            @nFunc    
    
         IF @nErrNo <> 0    
            GOTO Quit    
    
         IF @nMorePage = 1 -- Yes    
         BEGIN    
            -- Go to dynamic lottable screen    
            SET @nScn = 3990    
            SET @nStep = @nStep - 3    
         END    
         ELSE    
         BEGIN    
            -- Get SKU info    
            SELECT    
               @cSKUDesc = IsNULL( DescR, ''),    
               @cIVAS = IsNULL( IVAS, ''),    
               @cLottableCode = LottableCode,    
               @cMUOM_Desc = Pack.PackUOM3,    
               @cPUOM_Desc =    
                  CASE @cPUOM    
                     WHEN '2' THEN Pack.PackUOM1 -- Case    
                     WHEN '3' THEN Pack.PackUOM2 -- Inner pack    
                     WHEN '6' THEN Pack.PackUOM3 -- Master unit    
                     WHEN '1' THEN Pack.PackUOM4 -- Pallet    
                     WHEN '4' THEN Pack.PackUOM8 -- Other unit 1    
                     WHEN '5' THEN Pack.PackUOM9 -- Other unit 2    
                  END,    
                  @nPUOM_Div = CAST( IsNULL(    
                  CASE @cPUOM    
                     WHEN '2' THEN Pack.CaseCNT    
                     WHEN '3' THEN Pack.InnerPack    
                     WHEN '6' THEN Pack.QTY    
                     WHEN '1' THEN Pack.Pallet    
                     WHEN '4' THEN Pack.OtherUnit1    
                     WHEN '5' THEN Pack.OtherUnit2    
                  END, 1) AS INT)    
            FROM dbo.SKU SKU WITH (NOLOCK)    
               INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)    
            WHERE SKU.StorerKey = @cStorerKey    
               AND SKU.SKU = @cSKU      
            -- Convert to prefer UOM QTY    
            IF @cPUOM = '6' OR -- When preferred UOM = master unit    
               @nPUOM_Div = 0  -- UOM not setup    
            BEGIN    
               SET @cPUOM_Desc = ''    
               SET @nPQTY = 0    
               SET @nMQTY = @nQTY    
               SET @cFieldAttr08 = 'O' -- @nPQTY    
            END    
            ELSE    
            BEGIN    
               SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM    
               SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit    
               SET @cFieldAttr08 = '' -- @nPQTY    
            END    
    
            -- Prepare next screen variable    
            SET @cOutField01 = @cSKU    
            SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
            SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
            SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)    
            SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END    
            SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)    
            SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)    
            SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY    
            SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY    
            SET @cOutField10 = '' -- Reason    
    
            IF @cFieldAttr08 = ''    
               EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY    
    
            -- Go to QTY screen    
            SET @nScn = @nScn - 2    
            SET @nStep = @nStep - 2    
         END    
    END    
    
      IF @cOption = '2' -- No    
      BEGIN    
         SET @cOutField01 = @cID    
         SET @cMax = '' -- SKU    
         SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
         SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
    
         -- Go back to SKU screen    
         SET @nScn = @nScn - 4    
         SET @nStep = @nStep - 4    
      END    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      SET @cOutField01 = @cID    
      SET @cMax = '' -- SKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
    
      SET @nScn = @nScn - 4    
      SET @nStep = @nStep - 4    
   END    
   GOTO Quit    
    
   Step_8_Fail:    
   BEGIN    
      -- Reset this screen var    
      SET @cOption = ''    
      SET @cOutField01 = '' -- Option    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 9. Scn = 4038. Message    
   Print pallet label?    
   1 = YES    
   2 = NO    
   OPTION   (field01, input)    
********************************************************************************/    
Step_9:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      -- Screen mapping    
      SET @cOption = @cInField01    
    
      -- Check blank    
      IF @cOption = ''    
      BEGIN    
         SET @nErrNo = 59433    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Option    
         GOTO Step_9_Fail    
      END    
    
      IF @cOption <> '1' AND @cOption <> '2'    
      BEGIN    
         SET @nErrNo = 59434    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option    
         GOTO Step_9_Fail    
      END    
    
      IF @cOption = '1' -- Yes    
      BEGIN    
         IF @cPalletLabel <> ''    
         BEGIN    
            -- Common params    
            INSERT INTO @tPalletLabel (Variable, Value) VALUES     
            ( '@cStorerKey', @cStorerKey),    
            ( '@cReceiptKey', @cReceiptKey),    
            ( '@cReceiptLineNumber_Start', @cReceiptLineNumber),    
            ( '@cReceiptLineNumber_End', @cReceiptLineNumber),    
            ( '@cPOKey', @cPOKey),    
            ( '@cToID', @cID)    
    
            -- Print label    
            EXEC RDT.rdt_Print @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cPrinter, @cPrinter_Paper,     
               @cPalletLabel, -- Report type    
               @tPalletLabel, -- Report params    
               'rdtfnc_NormalReceipt_V7',     
               @nErrNo  OUTPUT,    
               @cErrMsg OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Quit    
         END    
    
         SET @cID = ''    
         IF @cAutoGenID = '1'    
         BEGIN    
            EXECUTE dbo.nspg_GetKey    
               'ID',    
               10 ,    
               @cID               OUTPUT,    
               @b_success         OUTPUT,    
               @n_err             OUTPUT,    
               @c_errmsg          OUTPUT    
            IF @b_success <> 1    
            BEGIN    
               SET @nErrNo = 59438    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- AutoGenID Fail    
               GOTO Step_9_Fail    
            END    
         END    
    
         -- Prepare next screen    
         SET @cOutField01 = @cLOC    
         SET @cOutField02 = @cID    
    
         -- Go to ID screen    
         SET @nScn = @nScn - 6    
         SET @nStep = @nStep - 6    
      END    
    
      IF @cOption = '2' -- No    
      BEGIN    
         -- Auto generate ID    
         SET @cID = ''    
         IF @cAutoGenID = '1'    
         BEGIN    
             EXECUTE dbo.nspg_GetKey    
                     'ID',    
                     10 ,    
                     @cID               OUTPUT,    
                     @b_success         OUTPUT,    
                     @n_err        OUTPUT,    
                     @c_errmsg          OUTPUT    
            IF @b_success <> 1    
            BEGIN    
               SET @nErrNo = 59439    
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --AutoGenID Fail    
               GOTO Step_2_Fail    
            END    
         END    
    
         -- Prepare next screen    
         SET @cOutField01 = @cLOC    
         SET @cOutField02 = @cID    
    
         -- Go back to ID screen    
         SET @nScn = @nScn - 6    
         SET @nStep = @nStep - 6    
      END    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      -- Prepare next screen    
      SET @cOutField01 = @cID    
      SET @cMax = '' -- SKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
    
      -- Go back to SKU screen    
      SET @nScn = @nScn - 5    
      SET @nStep = @nStep - 5    
   END    
   GOTO Quit    
    
   Step_9_Fail:    
   BEGIN    
      -- Reset this screen var    
      SET @cOption = ''    
      SET @cOutField01 = '' -- Option    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 10. Screen = 3950. Verify SKU    
   SKU            (Field01)    
   SKUDesc1       (Field02)    
   SKUDesc2       (Field03)    
   Field label 1  (Field04)    
   Field value 1  (Field05, input)    
   Field label 2  (Field06)    
   Field value 2  (Field07, input)    
   Field label 3  (Field08)    
   Field value 3  (Field09, input)    
   Field label 4  (Field10)    
   Field value 4  (Field11, input)    
   Field label 5  (Field12)    
   Field value 5  (Field13, input)    
********************************************************************************/    
Step_10:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      -- Update SKU setting    
      EXEC rdt.rdt_VerifySKU_V7 @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cSKU, @cSKUDesc, 'UPDATE',    
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,        
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,        
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,        
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,        
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,        
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,       
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,       
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,       
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,       
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,       
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,      
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,      
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,      
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,      
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,      
         @nErrNo     OUTPUT,    
         @cErrMsg    OUTPUT    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      -- Enable field    
      SET @cFieldAttr04 = '' -- Dynamic verify SKU 1..5    
      SET @cFieldAttr06 = '' --    
      SET @cFieldAttr08 = '' --    
      SET @cFieldAttr10 = '' --    
      SET @cFieldAttr12 = '' --    
          
      -- Prepare prev screen var    
      SET @cOutField01 = @cID    
      SET @cMax = '' -- @cSKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2    
    
      -- Go back to SKU screen    
      SET @nScn = @nFromScn    
      SET @nStep = @nStep - 6    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      -- Enable field    
      SET @cFieldAttr04 = '' -- Dynamic verify SKU 1..5    
      SET @cFieldAttr06 = '' --    
      SET @cFieldAttr08 = '' --    
      SET @cFieldAttr10 = '' --    
      SET @cFieldAttr12 = '' --    
    
      -- Prepare prev screen var    
      SET @cOutField01 = @cID    
      SET @cMax = '' -- @cSKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2    
    
      -- Go back to SKU screen    
      SET @nScn = @nFromScn    
      SET @nStep = @nStep - 6    
   END    
    
   -- Enable field    
   SELECT @cFieldAttr04 = ''    
   SELECT @cFieldAttr05 = ''    
   SELECT @cFieldAttr06 = ''    
   SELECT @cFieldAttr07 = ''    
   SELECT @cFieldAttr08 = ''    
   SELECT @cFieldAttr09 = ''    
   SELECT @cFieldAttr10 = ''    
   SELECT @cFieldAttr11 = ''    
   SELECT @cFieldAttr12 = ''    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 11. Screen = 4039. Refno Lookup    
   SKU         (Field01)    
   SKUDesc1    (Field02)    
   SKUDesc2    (Field03)    
   Weight      (Field04)    
   Cube        (Field05)    
   Length      (Field06)    
   Width       (Field07)    
   Height      (Field08)    
   InnerPack   (Field09)    
   OPTION      (Field10, input)    
********************************************************************************/    
Step_11:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      -- Screen mapping    
      SET @cOption = @cInField10    
    
      -- Check blank    
      IF @cOption = ''    
      BEGIN    
         SET @nErrNo = 59441    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Option    
         GOTO Quit    
      END    
    
      -- Check valid     
      IF @cOption NOT BETWEEN '1' AND '9'    
      BEGIN    
         SET @nErrNo = 59442    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option    
         GOTO Quit    
      END    
    
      -- Check option selectable    
      IF @cOption = '1' AND @cOutField01 = '' OR    
         @cOption = '2' AND @cOutField02 = '' OR    
         @cOption = '3' AND @cOutField03 = '' OR    
         @cOption = '4' AND @cOutField04 = '' OR    
         @cOption = '5' AND @cOutField05 = '' OR    
         @cOption = '6' AND @cOutField06 = '' OR    
         @cOption = '7' AND @cOutField07 = '' OR    
         @cOption = '8' AND @cOutField08 = '' OR    
         @cOption = '9' AND @cOutField09 = ''     
      BEGIN    
         SET @nErrNo = 59443    
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Not an option    
         GOTO Quit    
      END    
          
      -- Abstract ASN    
      IF @cOption = '1' SET @cReceiptKey = SUBSTRING( @cOutField01, 4, 10) ELSE    
      IF @cOption = '2' SET @cReceiptKey = SUBSTRING( @cOutField02, 4, 10) ELSE    
      IF @cOption = '3' SET @cReceiptKey = SUBSTRING( @cOutField03, 4, 10) ELSE    
      IF @cOption = '4' SET @cReceiptKey = SUBSTRING( @cOutField04, 4, 10) ELSE    
      IF @cOption = '5' SET @cReceiptKey = SUBSTRING( @cOutField05, 4, 10) ELSE    
      IF @cOption = '6' SET @cReceiptKey = SUBSTRING( @cOutField06, 4, 10) ELSE    
      IF @cOption = '7' SET @cReceiptKey = SUBSTRING( @cOutField07, 4, 10) ELSE    
      IF @cOption = '8' SET @cReceiptKey = SUBSTRING( @cOutField08, 4, 10) ELSE    
      IF @cOption = '9' SET @cReceiptKey = SUBSTRING( @cOutField09, 4, 10)    
    
      -- Prepare prev screen var    
      SET @cOutField01 = @cReceiptKey    
      SET @cOutField02 = @cPOKey    
      SET @cOutField03 = @cRefNo    
    
      -- Go back to ASN/PO screen    
      SET @nScn = @nScn - 10    
      SET @nStep = @nStep - 10    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      -- Prepare prev screen var    
      SET @cOutField01 = @cReceiptKey    
      SET @cOutField02 = @cPOKey    
      SET @cOutField03 = @cRefNo    
    
      -- Go back to ASN/PO screen    
      SET @nScn = @nScn - 10    
      SET @nStep = @nStep - 10    
   END    
END    
GOTO Quit    
    
    
/********************************************************************************    
Step 12. Screen = 4040. Putaway    
   Suggest LOC (Field01)    
   Final LOC   (Field02, input)    
********************************************************************************/    
Step_12:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      -- Screen mapping    
      SET @cFinalLOC = @cInField02    
    
     --Loc Prefix        
     IF @cLOCLookupSP = 1            
     BEGIN            
      EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,             
      @cFinalLOC  OUTPUT,             
      @nErrNo      OUTPUT,             
      @cErrMsg     OUTPUT            
      IF @nErrNo <> 0            
       GOTO Quit            
     END      
      
      -- Putaway    
      EXEC rdt.rdt_NormalReceipt_Putaway @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'EXECUTE',     
         @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY, @cReceiptLineNumber, @cFinalLOC,     
         @cSuggToLOC    OUTPUT,     
         @nPABookingKey OUTPUT,     
         @nErrNo        OUTPUT,     
         @cErrMsg       OUTPUT    
      IF @nErrNo <> 0    
      BEGIN    
         SET @cOutField02 = ''    
         GOTO Quit    
      END    
             
      -- Extended validate    
      IF @cExtendedUpdateSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile      INT,           ' +    
               '@nFunc        INT,           ' +    
               '@cLangCode    NVARCHAR( 3),  ' +    
               '@nStep        INT,           ' +    
               '@nInputKey    INT,           ' +    
               '@cFacility    NVARCHAR( 5),  ' +     
               '@cStorerKey   NVARCHAR( 15), ' +    
               '@cReceiptKey  NVARCHAR( 10), ' +    
               '@cPOKey       NVARCHAR( 10), ' +    
               '@cLOC         NVARCHAR( 10), ' +    
               '@cID          NVARCHAR( 18), ' +    
               '@cSKU         NVARCHAR( 20), ' +    
               '@cLottable01  NVARCHAR( 18), ' +    
               '@cLottable02  NVARCHAR( 18), ' +    
               '@cLottable03  NVARCHAR( 18), ' +    
               '@dLottable04  DATETIME,      ' +    
               '@dLottable05  DATETIME,      ' +    
               '@cLottable06  NVARCHAR( 30), ' +    
               '@cLottable07  NVARCHAR( 30), ' +    
               '@cLottable08  NVARCHAR( 30), ' +    
               '@cLottable09  NVARCHAR( 30), ' +    
               '@cLottable10  NVARCHAR( 30), ' +    
               '@cLottable11  NVARCHAR( 30), ' +    
               '@cLottable12  NVARCHAR( 30), ' +    
               '@dLottable13  DATETIME,      ' +    
               '@dLottable14  DATETIME,      ' +    
               '@dLottable15  DATETIME,      ' +    
               '@nQTY         INT,           ' +    
               '@cReasonCode  NVARCHAR( 10), ' +    
               '@cSuggToLOC   NVARCHAR( 10), ' +    
               '@cFinalLOC    NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10), ' +    
               '@nErrNo           INT            OUTPUT, ' +    
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @nErrNo OUTPUT, @cErrMsg OUTPUT    
         END    
      END    
          
      EXEC RDT.rdt_STD_EventLog -- (ChewKP01)     
         @cUserID       = @cUserName,    
         @nMobileNo     = @nMobile,    
         @nFunctionID   = @nFunc,    
         @cFacility     = @cFacility,    
         @cStorerKey    = @cStorerKey,    
         @cReceiptKey   = @cReceiptKey,    
         @cPOKey        = @cPOKey,     
         @cRefNo1       = @cRefNo,         
         @cToLocation   = @cFinalLOC    
      
             
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
      -- Check compulsory putaway    
      IF @cPutaway = '1'    
         GOTO Quit       
          
      -- Cancel putaway    
      EXEC rdt.rdt_NormalReceipt_Putaway @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, 'CANCEL',     
         @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, @nQTY, @cReceiptLineNumber, @cFinalLOC,     
         @cSuggToLOC    OUTPUT,     
         @nPABookingKey OUTPUT,     
         @nErrNo        OUTPUT,     
         @cErrMsg       OUTPUT    
      IF @nErrNo <> 0    
         GOTO Quit    
   END    
    
   IF @cPalletRecv = '1'    
   BEGIN    
      SET @cID = ''    
    
      -- AutoGenID    
      IF @cAutoGenID = '1'    
      BEGIN    
         EXECUTE dbo.nspg_GetKey    
            'ID',    
            10 ,    
            @cID               OUTPUT,    
            @b_success         OUTPUT,    
            @n_err             OUTPUT,    
            @c_errmsg          OUTPUT    
         IF @b_success <> 1    
         BEGIN    
            SET @nErrNo = 59448    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --AutoGenID Fail    
            GOTO Quit    
         END    
      END    
    
      -- Prep next screen var    
      SET @cOutField01 = @cLOC    
      SET @cOutField02 = @cID    
    
      -- Go to ID screen    
      SET @nScn = @nScn - 9    
      SET @nStep = @nStep - 9    
   END    
   ELSE    
   BEGIN    
      -- Prep next screen var    
      SET @cOutField01 = @cID    
      SET @cOutField02 = '' -- SKU    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 1, 20)  -- SKU desc 1    
      SET @cOutField04 = rdt.rdtFormatString( @cSKUDesc, 21, 20) -- SKU desc 2    
    
      -- Go to SKU screen    
      SET @nScn = @nScn - 8    
      SET @nStep = @nStep - 8    
   END    
    
   -- Reset data    
   SELECT @cSKU = '', @nQTY = 0,    
      @cLottable01 = '', @cLottable02 = '', @cLottable03 = '',    @dLottable04 = NULL, @dLottable05 = NULL,    
      @cLottable06 = '', @cLottable07 = '', @cLottable08 = '',    @cLottable09 = '',   @cLottable10 = '',    
      @cLottable11 = '', @cLottable12 = '', @dLottable13 = NULL,  @dLottable14 = NULL, @dLottable15 = NULL    
       
END    
GOTO Quit    
    
/********************************************************************************    
Step 13. Screen = 3570. Multi SKU    
   SKU         (Field01)    
   SKUDesc1    (Field02)    
   SKUDesc2    (Field03)    
   SKU         (Field04)    
   SKUDesc1    (Field05)    
   SKUDesc2    (Field06)    
   SKU         (Field07)    
   SKUDesc1    (Field08)    
   SKUDesc2    (Field09)    
   Option      (Field10, input)    
********************************************************************************/    
Step_13:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      EXEC rdt.rdt_MultiSKUBarcode @nMobile, @nFunc, @cLangCode,    
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,    
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,    
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,    
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,    
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,    
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,    
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,    
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,    
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,    
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,    
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,    
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,    
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,    
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,    
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,    
         'CHECK',    
         @cMultiSKUBarcode,    
         @cStorerKey,    
         @cSKU     OUTPUT,    
         @nErrNo   OUTPUT,    
         @cErrMsg  OUTPUT    
    
      IF @nErrNo <> 0    
      BEGIN    
         IF @nErrNo = -1    
            SET @nErrNo = 0    
         GOTO Quit    
      END    
    
      -- Get SKU info    
      SELECT @cSKUDesc = Descr FROM dbo.SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU    
   END    
    
   -- Init next screen var    
   SET @cOutField01 = @cID    
   SET @cScanBarcode = @cMax --(cc01)  
   SET @cMax = @cSKU -- SKU    
   SET @cOutField03 = SUBSTRING( @cSKUDesc,  1, 20) -- SKUDesc1    
   SET @cOutField04 = SUBSTRING( @cSKUDesc, 21, 20) -- SKUDesc2    
    
   -- Go to SKU QTY screen    
   SET @nScn = @nFromScn    
   SET @nStep = @nStep - 9    
    
END    
GOTO Quit    
  
  
/********************************************************************************    
Step 14. Screen = 4831. Serial No    
   SKU            (Field01)    
   SKUDesc1       (Field02)    
   SKUDesc2       (Field03)    
   SerialNo       (Field04, input)    
   Scan           (Field05)    
********************************************************************************/    
Step_14:    
BEGIN    
   IF @nInputKey = 1 -- ENTER    
   BEGIN    
      -- Update SKU setting    
      EXEC rdt.rdt_SerialNo @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, @cSKU, @cSKUDesc, @nQTY, 'UPDATE', 'ASN', @cReceiptKey,    
         @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT,    
         @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT,    
         @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT,    
         @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT,    
         @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT,    
         @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT,    
         @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT,    
         @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT,    
         @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT,    
         @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT,    
         @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT,    
         @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT,    
         @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT,    
         @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT,    
         @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT,    
         @nMoreSNO   OUTPUT,  @cSerialNo   OUTPUT,  @nSerialQTY   OUTPUT,    
         @nErrNo     OUTPUT,  @cErrMsg     OUTPUT,  @nScn,    
         @nBulkSNO   OUTPUT,  @nBulkSNOQTY OUTPUT    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      DECLARE @nRDQTY INT    
      IF @nBulkSNO > 0    
         SET @nRDQTY = @nBulkSNOQTY    
      ELSE IF @cSerialNo <> ''    
         SET @nRDQTY = @nSerialQTY    
      ELSE    
         SET @nRDQTY = @nQTY    
         
		SELECT @cUOM = PackUOM3  
      FROM dbo.SKU WITH (NOLOCK)  
         JOIN dbo.Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)  
      WHERE StorerKey = @cStorerKey  
         AND SKU = @cSKU  
  
      -- Custom receiving logic    
      IF @cRcptConfirmSP <> ''    
      BEGIN    
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cRcptConfirmSP) +    
            ' @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cReceiptKey, @cPOKey, @cToLOC, @cToID, ' +    
            ' @cSKUCode, @cSKUUOM, @nSKUQTY, @cUCC, @cUCCSKU, @nUCCQTY, @cCreateUCC, ' +    
            ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
            ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
            ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
            ' @nNOPOFlag, @cConditionCode, @cSubreasonCode, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cReceiptLineNumberOutput OUTPUT, '+  
            '  @cSerialNo,   @nSerialQTY,@nBulkSNO,@nBulkSNOQTY    '    
    
         SET @cSQLParam =    
            '@nFunc          INT,            ' +    
            '@nMobile        INT,            ' +    
            '@cLangCode      NVARCHAR( 3),   ' +    
            '@cStorerKey     NVARCHAR( 15),  ' +    
            '@cFacility      NVARCHAR( 5),   ' +    
            '@cReceiptKey    NVARCHAR( 10),  ' +    
            '@cPOKey         NVARCHAR( 10),  ' +    
            '@cToLOC         NVARCHAR( 10),  ' +    
            '@cToID          NVARCHAR( 18),  ' +    
            '@cSKUCode       NVARCHAR( 20),  ' +    
            '@cSKUUOM        NVARCHAR( 10),  ' +    
            '@nSKUQTY        INT,            ' +    
            '@cUCC           NVARCHAR( 20),  ' +    
            '@cUCCSKU        NVARCHAR( 20),  ' +    
            '@nUCCQTY        INT,            ' +    
            '@cCreateUCC     NVARCHAR( 1),   ' +    
            '@cLottable01    NVARCHAR( 18),  ' +    
            '@cLottable02    NVARCHAR( 18),  ' +    
            '@cLottable03    NVARCHAR( 18),  ' +    
            '@dLottable04    DATETIME,       ' +    
            '@dLottable05    DATETIME,       ' +    
            '@cLottable06    NVARCHAR( 30),  ' +    
            '@cLottable07    NVARCHAR( 30),  ' +    
            '@cLottable08    NVARCHAR( 30),  ' +    
            '@cLottable09    NVARCHAR( 30),  ' +    
            '@cLottable10    NVARCHAR( 30),  ' +    
            '@cLottable11    NVARCHAR( 30),  ' +    
            '@cLottable12    NVARCHAR( 30),  ' +    
            '@dLottable13    DATETIME,       ' +    
            '@dLottable14    DATETIME,       ' +    
            '@dLottable15    DATETIME,       ' +    
            '@nNOPOFlag      INT,            ' +    
            '@cConditionCode NVARCHAR( 10),  ' +    
            '@cSubreasonCode NVARCHAR( 10),  ' +    
            '@nErrNo         INT           OUTPUT, ' +    
            '@cErrMsg        NVARCHAR( 20) OUTPUT, ' +    
            '@cReceiptLineNumberOutput NVARCHAR( 5) OUTPUT '+  
            '@cSerialNo      NVARCHAR( 30) = '', ' +  
            '@nSerialQTY     INT = 0,            ' +  
            '@nBulkSNO       INT = 0,            ' +  
            '@nBulkSNOQTY    INT = 0             '  
              
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
            @nFunc, @nMobile, @cLangCode, @cStorerKey, @cFacility, @cReceiptKey, @cPOKey, @cLOC, @cID,    
            @cSKU, @cUOM, 1, '', '', 0, '',    
            @cLottable01, @cLottable02, @cLottable03, @dLottable04, NULL,    
            @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
            @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
            @nNOPOFlag, @cReasonCode, '', @nErrNo OUTPUT, @cErrMsg OUTPUT, @cReceiptLineNumber OUTPUT,  
            @cSerialNo,   @nSerialQTY,@nBulkSNO,@nBulkSNOQTY      
      END    
      ELSE    
      BEGIN    
         -- Receive    
         EXEC rdt.rdt_Receive_V7    
            @nFunc         = @nFunc,    
            @nMobile       = @nMobile,    
            @cLangCode     = @cLangCode,    
            @nErrNo        = @nErrNo OUTPUT,    
            @cErrMsg       = @cErrMsg OUTPUT,    
            @cStorerKey    = @cStorerKey,    
            @cFacility    = @cFacility,    
            @cReceiptKey   = @cReceiptKey,    
            @cPOKey        = @cPoKey,  -- (ChewKP01)    
            @cToLOC        = @cLOC,    
            @cToID         = @cID,    
            @cSKUCode      = @cSKU,    
            @cSKUUOM       = @cUOM,    
            @nSKUQTY       = 1,    
            @cUCC          = '',    
            @cUCCSKU       = '',    
            @nUCCQTY       = '',    
            @cCreateUCC    = '',    
            @cLottable01   = @cLottable01,    
            @cLottable02   = @cLottable02,    
            @cLottable03   = @cLottable03,    
            @dLottable04   = @dLottable04,    
            @dLottable05   = NULL,    
            @cLottable06   = @cLottable06,    
            @cLottable07   = @cLottable07,    
            @cLottable08   = @cLottable08,    
            @cLottable09   = @cLottable09,    
            @cLottable10   = @cLottable10,    
            @cLottable11   = @cLottable11,    
            @cLottable12   = @cLottable12,    
            @dLottable13   = @dLottable13,    
            @dLottable14   = @dLottable14,    
            @dLottable15   = @dLottable15,    
            @nNOPOFlag     = @nNOPOFlag,    
            @cConditionCode = @cReasonCode,    
            @cSubreasonCode = '',     
            @cReceiptLineNumberOutput = @cReceiptLineNumber OUTPUT  ,  
            @cSerialNo      = @cSerialNo,     
            @nSerialQTY     = @nSerialQTY,     
            @nBulkSNO       = @nBulkSNO,     
            @nBulkSNOQTY    = @nBulkSNOQTY    
    
      END    
    
      IF @nErrNo <> 0    
         GOTO Quit    
    
      -- Extended validate    
      IF @cExtendedUpdateSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')    
         BEGIN    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile      INT,           ' +    
               '@nFunc        INT,           ' +    
               '@cLangCode    NVARCHAR( 3),  ' +    
               '@nStep        INT,           ' +    
               '@nInputKey    INT,           ' +    
               '@cFacility    NVARCHAR( 5),  ' +     
               '@cStorerKey   NVARCHAR( 15), ' +    
               '@cReceiptKey  NVARCHAR( 10), ' +    
               '@cPOKey       NVARCHAR( 10), ' +    
               '@cLOC         NVARCHAR( 10), ' +    
               '@cID          NVARCHAR( 18), ' +    
               '@cSKU         NVARCHAR( 20), ' +    
               '@cLottable01  NVARCHAR( 18), ' +    
               '@cLottable02  NVARCHAR( 18), ' +    
               '@cLottable03  NVARCHAR( 18), ' +    
               '@dLottable04  DATETIME,      ' +    
               '@dLottable05  DATETIME,      ' +    
               '@cLottable06  NVARCHAR( 30), ' +    
               '@cLottable07  NVARCHAR( 30), ' +    
               '@cLottable08  NVARCHAR( 30), ' +    
               '@cLottable09  NVARCHAR( 30), ' +    
               '@cLottable10  NVARCHAR( 30), ' +    
               '@cLottable11  NVARCHAR( 30), ' +    
               '@cLottable12  NVARCHAR( 30), ' +    
               '@dLottable13  DATETIME,      ' +    
               '@dLottable14  DATETIME,      ' +    
               '@dLottable15  DATETIME,      ' +    
               '@nQTY         INT,           ' +    
               '@cReasonCode  NVARCHAR( 10), ' +    
               '@cSuggToLOC   NVARCHAR( 10), ' +    
               '@cFinalLOC    NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10), ' +    
               '@nErrNo             INT            OUTPUT, ' +    
               '@cErrMsg            NVARCHAR( 20)  OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @nErrNo OUTPUT, @cErrMsg OUTPUT    
         END    
      END    
    
      -- EventLog    
      EXEC RDT.rdt_STD_EventLog    
         @cActionType   = '2', -- Receiving     --SY01  
         @cUserID       = @cUserName,    
         @nMobileNo     = @nMobile,    
         @nFunctionID   = @nFunc,    
         @cFacility     = @cFacility,    
         @cStorerKey    = @cStorerKey,    
         @cReceiptKey   = @cReceiptKey,    
         @cPOKey        = @cPOKey,     
         @cLocation     = @cLOC,    
         @cID           = @cID,    
         @cSKU          = @cSKU,    
         @cUOM          = @cUOM,    
         @nQTY          = @nQTY,    
         --@cRefNo1       = @cReceiptKey, -- Retain for backward compatible    
         --@cRefNo2       = @cPOKey,      -- Retain for backward compatible    
         --@cRefNo4       = @cReasonCode,     
         @cRefNo1       = @cRefNo, -- (ChewKP01)     
         @cReasonKey    = @cReasonCode,     
         @cLottable01   = @cLottable01,    
         @cLottable02   = @cLottable02,     
         @cLottable03   = @cLottable03,     
         @dLottable04   = @dLottable04,     
         @dLottable05   = @dLottable05,     
         @cLottable06   = @cLottable06,     
         @cLottable07   = @cLottable07,     
         @cLottable08   = @cLottable08,     
         @cLottable09   = @cLottable09,     
         @cLottable10   = @cLottable10,     
         @cLottable11   = @cLottable11,     
         @cLottable12   = @cLottable12,     
         @dLottable13   = @dLottable13,     
         @dLottable14   = @dLottable14,     
         @dLottable15   = @dLottable15    
       
      IF @nErrno <> 0    
         GOTO Quit      
    
     IF @nMoreSNO = 1    
         GOTO Quit    
    
      -- Go to SKU QTY screen    
      SET @nScn = @nFromScn +1    
      SET @nStep = @nStep -7    
   END    
    
   IF @nInputKey = 0 -- ESC    
   BEGIN    
       -- Get SKU info    
      SELECT    
         @cSKUDesc = IsNULL( DescR, ''),    
         @cIVAS = IsNULL( IVAS, ''),    
         @cLottableCode = LottableCode,    
         @cMUOM_Desc = Pack.PackUOM3,    
         @cPUOM_Desc =    
            CASE @cPUOM    
               WHEN '2' THEN Pack.PackUOM1 -- Case    
               WHEN '3' THEN Pack.PackUOM2 -- Inner pack    
               WHEN '6' THEN Pack.PackUOM3 -- Master unit    
               WHEN '1' THEN Pack.PackUOM4 -- Pallet    
               WHEN '4' THEN Pack.PackUOM8 -- Other unit 1    
               WHEN '5' THEN Pack.PackUOM9 -- Other unit 2    
            END,    
            @nPUOM_Div = CAST( IsNULL(    
            CASE @cPUOM    
               WHEN '2' THEN Pack.CaseCNT    
               WHEN '3' THEN Pack.InnerPack    
               WHEN '6' THEN Pack.QTY    
               WHEN '1' THEN Pack.Pallet    
               WHEN '4' THEN Pack.OtherUnit1    
               WHEN '5' THEN Pack.OtherUnit2    
            END, 1) AS INT)    
      FROM dbo.SKU SKU WITH (NOLOCK)    
         INNER JOIN dbo.Pack Pack WITH (NOLOCK) ON (SKU.PackKey = Pack.PackKey)    
      WHERE SKU.StorerKey = @cStorerKey    
         AND SKU.SKU = @cSKU    
    
      -- Convert to prefer UOM QTY    
      IF @cPUOM = '6' OR -- When preferred UOM = master unit    
         @nPUOM_Div = 0  -- UOM not setup    
      BEGIN    
         SET @cPUOM_Desc = ''    
         SET @nPQTY = 0    
         SET @nMQTY = @nQTY    
         SET @cFieldAttr08 = 'O' -- @nPQTY    
      END    
      ELSE    
      BEGIN    
         SET @nPQTY = @nQTY / @nPUOM_Div -- Calc QTY in preferred UOM    
         SET @nMQTY = @nQTY % @nPUOM_Div -- Calc the remaining in master unit    
         SET @cFieldAttr08 = '' -- @nPQTY    
      END    
    
      -- Prepare next screen variable    
      SET @cOutField01 = @cSKU    
      SET @cOutField02 = rdt.rdtFormatString( @cSKUDesc, 1, 20)    
      SET @cOutField03 = rdt.rdtFormatString( @cSKUDesc, 21, 20)    
      SET @cOutField04 = SUBSTRING( @cIVAS, 1, 20)    
      SET @cOutField05 = '1:' + CASE WHEN @nPUOM_Div > 99999 THEN '*' ELSE CAST( @nPUOM_Div AS NCHAR( 5)) END    
      SET @cOutField06 = rdt.rdtRightAlign( @cPUOM_Desc, 5)    
      SET @cOutField07 = rdt.rdtRightAlign( @cMUOM_Desc, 5)    
      SET @cOutField08 = CASE WHEN @nPQTY = 0 OR @cFieldAttr08 = 'O' THEN '' ELSE CAST( @nPQTY AS NVARCHAR( 7)) END -- PQTY    
      SET @cOutField09 = CASE WHEN @nMQTY = 0 THEN '' ELSE CAST( @nMQTY AS NVARCHAR( 7)) END -- MQTY    
      SET @cOutField10 = '' -- Reason    
      SET @cOutField15 = '' -- ExtendedInfo    
    
      IF @cFieldAttr08 = ''    
         EXEC rdt.rdtSetFocusField @nMobile, 8 -- PQTY    
    
      -- Go to QTY screen    
      SET @nScn = @nFromScn    
      SET @nStep = @nStep - 8  
          
      -- Extended info    
      IF @cExtendedInfoSP <> ''    
      BEGIN    
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')    
         BEGIN    
            SET @cExtendedInfo = ''    
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +    
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU, ' +    
               ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +    
               ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +    
               ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +    
               ' @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber, ' +     
               ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'    
            SET @cSQLParam =    
               '@nMobile       INT,           ' +    
               '@nFunc         INT,           ' +    
               '@cLangCode     NVARCHAR( 3),  ' +    
               '@nStep         INT,           ' +    
               '@nAfterStep    INT,           ' +     
               '@nInputKey     INT,           ' +    
               '@cFacility     NVARCHAR( 5),  ' +     
               '@cStorerKey    NVARCHAR( 15), ' +    
               '@cReceiptKey   NVARCHAR( 10), ' +    
               '@cPOKey        NVARCHAR( 10), ' +    
               '@cLOC          NVARCHAR( 10), ' +    
               '@cID           NVARCHAR( 18), ' +    
               '@cSKU          NVARCHAR( 20), ' +    
               '@cLottable01   NVARCHAR( 18), ' +    
               '@cLottable02   NVARCHAR( 18), ' +    
               '@cLottable03   NVARCHAR( 18), ' +    
               '@dLottable04   DATETIME,      ' +    
               '@dLottable05   DATETIME,      ' +    
               '@cLottable06   NVARCHAR( 30), ' +    
               '@cLottable07   NVARCHAR( 30), ' +    
               '@cLottable08   NVARCHAR( 30), ' +    
               '@cLottable09   NVARCHAR( 30), ' +    
               '@cLottable10   NVARCHAR( 30), ' +    
               '@cLottable11   NVARCHAR( 30), ' +    
               '@cLottable12   NVARCHAR( 30), ' +    
               '@dLottable13   DATETIME,      ' +    
               '@dLottable14   DATETIME,      ' +    
               '@dLottable15   DATETIME,      ' +    
               '@nQTY          INT,           ' +    
               '@cReasonCode   NVARCHAR( 10), ' +    
               '@cSuggToLOC    NVARCHAR( 10), ' +    
               '@cFinalLOC     NVARCHAR( 10), ' +    
               '@cReceiptLineNumber NVARCHAR( 10),   ' +    
               '@cExtendedInfo NVARCHAR(20)  OUTPUT, ' +     
               '@nErrNo        INT           OUTPUT, ' +    
               '@cErrMsg       NVARCHAR( 20) OUTPUT'    
    
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
               @nMobile, @nFunc, @cLangCode, 5, @nStep, @nInputKey, @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cLOC, @cID, @cSKU,     
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,    
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,    
               @nQTY, @cReasonCode, @cSuggToLOC, @cFinalLOC, @cReceiptLineNumber,     
               @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT    
    
            IF @nErrNo <> 0    
               GOTO Step_3_Fail    
    
            SET @cOutField15 = @cExtendedInfo   
   END    
      END  
   END    
END  
GOTO Quit    
    
/********************************************************************************    
Quit. Update back to I/O table, ready to be pick up by JBOSS    
********************************************************************************/    
Quit:    
BEGIN    
   UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET    
      EditDate = GETDATE(),     
      ErrMsg = @cErrMsg,    
      Func   = @nFunc,    
      Step   = @nStep,    
      Scn    = @nScn,    
    
      Facility     = @cFacility,    
      Printer      = @cPrinter,    
      -- UserName     = @cUserName,    
    
      V_StorerKey  = @cStorerKey,     
      V_UOM        = @cPUOM,    
      V_ReceiptKey = @cReceiptKey,    
      V_POKey      = @cPOKey,    
      V_Loc        = @cLOC,    
      V_ID         = @cID,    
      V_SKU        = @cSKU,    
      V_SKUDescr   = @cSKUDesc,    
      V_Lottable01 = @cLottable01,    
      V_Lottable02 = @cLottable02,    
      V_Lottable03 = @cLottable03,    
      V_Lottable04 = @dLottable04,    
      V_Lottable05 = @dLottable05,    
      V_Lottable06 = @cLottable06,    
      V_Lottable07 = @cLottable07,    
      V_Lottable08 = @cLottable08,    
      V_Lottable09 = @cLottable09,    
      V_Lottable10 = @cLottable10,    
      V_Lottable11 = @cLottable11,    
      V_Lottable12 = @cLottable12,    
      V_Lottable13 = @dLottable13,    
      V_Lottable14 = @dLottable14,    
      V_Lottable15 = @dLottable15,    
      V_Max        = @cMax,    
    
      V_String1    = @cRefNo,    
      V_String2    = @cIVAS,    
      V_String3    = @cLottableCode,    
      V_String4    = @cReasonCode,    
      V_String5    = @cSuggToLOC,     
      V_String6    = @cFinalLOC,     
      V_String7    = @cReceiptLineNumber,    
      V_String8    = @cPalletRecv,    
      V_String9    = @cFlowThruScreen,      
      V_String10   = @cMUOM_Desc,    
      V_String11   = @cPUOM_Desc,    
      V_String12   = @nPUOM_Div ,    
      V_String13   = @nPQTY,    
      V_String14   = @nMQTY,    
      V_String15   = @nQTY,    
      V_String16   = @nFromScn,    
      V_String17   = @nPABookingKey,    
    
      V_String21   = @cPOKeyDefaultValue,    
      V_String22   = @cDefaultToLOC,    
      V_String23   = @cCheckPLTID,    
      V_String24   = @cAutoGenID,    
      V_String25   = @cGetReceiveInfoSP,    
      V_String26   = @cDecodeSP,    
      V_String27   = @cAddSKUtoASN,    
      V_String28   = @cVerifySKU,    
      V_String29   = @cPalletRecvSP,    
      V_String30   = @cExtendedValidateSP,    
      V_String31   = @cExtendedUpdateSP,    
      V_String32   = @cRcptConfirmSP,    
      V_String33   = @cExtendedInfoSP,    
      V_String34   = @cExtendedInfo,     
      V_String35   = @cPutawaySP,    
      V_String36   = @cPutaway,    
      V_String37   = @cPalletLabel,    
      V_String38   = @cCheckIDInUse,    
      V_String39   = @cMultiSKUBarcode,    
      V_String40   = @cLOCLookupSP,      --(yeekung01)         
      V_String41   = @cDocType,     --(yeekung02)   
      V_String42   = @cSerialNoCapture,    
      V_String43   = @cScanBarcode,   --(cc01)  
    
      I_Field01 = @cInField01,  O_Field01 = @cOutField01,    
      I_Field02 = @cInField02,  O_Field02 = @cOutField02,    
      I_Field03 = @cInField03,  O_Field03 = @cOutField03,    
      I_Field04 = @cInField04,  O_Field04 = @cOutField04,    
      I_Field05 = @cInField05,  O_Field05 = @cOutField05,    
      I_Field06 = @cInField06,  O_Field06 = @cOutField06,    
      I_Field07 = @cInField07,  O_Field07 = @cOutField07,    
      I_Field08 = @cInField08,  O_Field08 = @cOutField08,    
      I_Field09 = @cInField09,  O_Field09 = @cOutField09,    
      I_Field10 = @cInField10,  O_Field10 = @cOutField10,    
      I_Field11 = @cInField11,  O_Field11 = @cOutField11,    
      I_Field12 = @cInField12,  O_Field12 = @cOutField12,    
      I_Field13 = @cInField13,  O_Field13 = @cOutField13,    
      I_Field14 = @cInField14,  O_Field14 = @cOutField14,    
      I_Field15 = @cInField15,  O_Field15 = @cOutField15,    
    
      FieldAttr01  = @cFieldAttr01,   FieldAttr02  = @cFieldAttr02,    
      FieldAttr03  = @cFieldAttr03,   FieldAttr04  = @cFieldAttr04,    
      FieldAttr05  = @cFieldAttr05,   FieldAttr06  = @cFieldAttr06,    
      FieldAttr07  = @cFieldAttr07,   FieldAttr08  = @cFieldAttr08,    
      FieldAttr09  = @cFieldAttr09,   FieldAttr10  = @cFieldAttr10,    
      FieldAttr11  = @cFieldAttr11,   FieldAttr12  = @cFieldAttr12,    
      FieldAttr13  = @cFieldAttr13,   FieldAttr14  = @cFieldAttr14,    
      FieldAttr15  = @cFieldAttr15    
    
   WHERE Mobile = @nMobile    
END    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdtfnc_NormalReceipt_V7 TO NSQL
GO