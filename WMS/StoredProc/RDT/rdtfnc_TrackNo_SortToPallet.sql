SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store procedure: rdtfnc_TrackNo_SortToPallet                         */  
/* Copyright      : IDS                                                 */  
/*                                                                      */  
/* Purpose: Sort trackno to pallet                                      */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date         Rev  Author   Purposes                                  */  
/* 2020-08-0`   1.0  James    WMS-14248. Created                        */  
/* 2021-07-09   1.1  James    WMS17425-Add check pallet format (james01)*/
/*                            Add check 1 mbol 1 pallet(externmbolkey)  */
/* 2021-08-12   1.2  James    WMS-17486. Add retrieve orderkey (james02)*/  
/*                            Extend TrackNo to 40 chars                */
/* 2021-10-21   1.3  James    WMS-18222 Add config to prevent user scan */
/*                            diff shipperkey onto same pallet (james03)*/
/* 2021-11-18   1.4  James    WMS-18350 Add ExtendedInfoSP to step      */
/*                            scan/show pallet key (james04)            */
/* 2021-11-24   1.5  James    WMS-18315 Add palletkey format check      */
/*                            to trackno and close pallet scn (james05) */
/* 2022-01-03   1.6  James    WMS-18616 Fix SKU null error when insert  */
/*                            palletdetail record (james06)             */
/* 2022-02-07   1.7  LZG      JSM-49257 - Cleared @cLabelNo value after */  
/*                            error to fix no error shown bug (ZG01)    */  
/* 2022-04-28   1.8  James    WMS-18616 Extend the length of barcode    */
/*                            to 100 chars (james07)                    */
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdtfnc_TrackNo_SortToPallet] (  
   @nMobile    int,  
   @nErrNo     int  OUTPUT,  
   @cErrMsg    NVARCHAR(125) OUTPUT  
) AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
-- RDT.RDTMobRec variable  
DECLARE  
   @nFunc       INT,  
   @nScn        INT,  
   @nStep       INT,  
   @nAfterStep  INT,  
   @cLangCode   NVARCHAR( 3),  
   @nInputKey   INT,  
   @nMenu       INT,  
   @nMorePage   INT,  
   @bSuccess    INT,  
   @nTranCount  INT,  
  
   @cStorerKey  NVARCHAR( 15),  
   @cFacility   NVARCHAR( 5),  
   @cSKU        NVARCHAR( 20),  
   @cUserName           NVARCHAR( 18),  
   @cOrderKey           NVARCHAR( 10),  
   @cSQL                NVARCHAR( MAX),   
   @cSQLParam           NVARCHAR( MAX),   
  
   @cExtendedInfo       NVARCHAR( 20),  
   @cExtendedInfoSP     NVARCHAR( 20),  
   @cExtendedValidateSP NVARCHAR( 20),  
   @cExtendedUpdateSP   NVARCHAR( 20),  
   @tExtValidVar        VariableTable,  
   @tExtUpdateVar       VariableTable,  
   @tExtInfoVar         VariableTable,        
  
  
   @cInTrackNo          NVARCHAR( 40),  
   @cTrackNo            NVARCHAR( 40),  
   @cDecodeSP           NVARCHAR( 20),  
   @cBarcode            NVARCHAR( 100),  
   @cUserDefine01       NVARCHAR( 60),  
   @cPalletKey          NVARCHAR( 20),  
   @cSuggPalletKey      NVARCHAR( 20),  
   @cMBOLKey            NVARCHAR( 10),  
   @cLoadKey            NVARCHAR( 10),  
   @cPalletCloseStatus  NVARCHAR( 10),  
   @cOrderInfo04        NVARCHAR( 30),  
   @cOption             NVARCHAR( 1),  
   @cPalletLineNumber   NVARCHAR( 5),  
   @nQty_Picked         INT,  
   @nQty_Packed         INT,  
   @curDel              CURSOR,  
   @dOrderDate          DATETIME,  
   @dDeliveryDate       DATETIME,  
   @cExternOrderKey     NVARCHAR( 50),  
   @nCtnCnt1            INT,   
   @cLabelNo            NVARCHAR( 20),
   @cPalletNotAllowMixShipperKey NVARCHAR( 1),
   @cCur_ShipperKey   NVARCHAR( 15),
   @cNew_ShipperKey   NVARCHAR( 15),
   @cCur_OrderKey     NVARCHAR( 10),

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),    @cFieldAttr01 NVARCHAR( 1),  
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),    @cFieldAttr02 NVARCHAR( 1),  
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),    @cFieldAttr03 NVARCHAR( 1),  
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),    @cFieldAttr04 NVARCHAR( 1),  
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),    @cFieldAttr05 NVARCHAR( 1),  
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),    @cFieldAttr06 NVARCHAR( 1),  
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),    @cFieldAttr07 NVARCHAR( 1),  
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),    @cFieldAttr08 NVARCHAR( 1),  
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),    @cFieldAttr09 NVARCHAR( 1),  
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),    @cFieldAttr10 NVARCHAR( 1),  
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),    @cFieldAttr11 NVARCHAR( 1),  
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),    @cFieldAttr12 NVARCHAR( 1),  
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),    @cFieldAttr13 NVARCHAR( 1),  
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),    @cFieldAttr14 NVARCHAR( 1),  
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),    @cFieldAttr15 NVARCHAR( 1)  
  
-- Getting Mobile information  
SELECT  
   @nFunc       = Func,  
   @nScn        = Scn,  
   @nStep       = Step,  
   @nInputKey   = InputKey,  
   @nMenu       = Menu,  
   @cLangCode   = Lang_code,  
  
   @cStorerKey  = StorerKey,  
   @cFacility   = Facility,  
   @cUserName   = UserName,  
   @cOrderKey   = V_OrderKey,  
        
   @cLabelNo         = V_String1,
   @cPalletKey       = V_String2,  
   @cMBOLKey         = V_String3,  
   @cPalletCloseStatus = V_String4,  
     
   @cDecodeSP              =  V_String20,  
   @cExtendedInfoSP        =  V_String21,  
   @cExtendedValidateSP    =  V_String22,  
   @cExtendedUpdateSP      =  V_String23,  
   @cPalletNotAllowMixShipperKey = V_String24,
   
   @cTrackNo         = V_String41,
   
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
   @cInField15 = I_Field15,   @cOutField15 = O_Field15  
  
FROM rdt.RDTMOBREC (NOLOCK)  
WHERE Mobile = @nMobile  
  
-- Screen constant  
DECLARE  
   @nStep_TrackNo       INT,  @nScn_TrackNo        INT,  
   @nStep_ScanPalletID  INT,  @nScn_ScanPalletID   INT,  
   @nStep_ShowPalletID  INT,  @nScn_ShowPalletID   INT,  
   @nStep_ClosePallet   INT,  @nScn_ClosePallet    INT  
  
SELECT  
   @nStep_TrackNo       = 1,   @nScn_TrackNo       = 5800,  
   @nStep_ScanPalletID  = 2,   @nScn_ScanPalletID  = 5801,  
   @nStep_ShowPalletID  = 3,   @nScn_ShowPalletID  = 5802,  
   @nStep_ClosePallet   = 4,   @nScn_ClosePallet   = 5803  
     
  
IF @nFunc = 1653 -- TrackNo Sort To Pallet   
BEGIN  
   -- Redirect to respective screen  
   IF @nStep = 0 GOTO Step_0              -- Func = PRE CARTONIZE PRINT LABEL  
   IF @nStep = 1 GOTO Step_TrackNo        -- Scn = 5800. TRACK NO  
   IF @nStep = 2 GOTO Step_ScanPalletID   -- Scn = 5801. SCAN PALLET ID  
   IF @nStep = 3 GOTO Step_ShowPalletID   -- Scn = 5802. SHOW PALLET ID  
   IF @nStep = 4 GOTO Step_ClosePallet  
END  
  
RETURN -- Do nothing if incorrect step  
  
/********************************************************************************  
Step 0. func = 1653. Menu  
********************************************************************************/  
Step_0:  
BEGIN  
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)  
   IF @cExtendedInfoSP IN ('0', '')  
      SET @cExtendedInfoSP = ''  
  
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerkey)  
   IF @cExtendedValidateSP IN ('0', '')  
      SET @cExtendedValidateSP = ''  
  
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerkey)  
   IF @cExtendedUpdateSP IN ('0', '')  
      SET @cExtendedUpdateSP = ''  
  
   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerkey)  
   IF @cDecodeSP IN ('0', '')  
      SET @cDecodeSP = ''  
  
   SET @cPalletCloseStatus = rdt.RDTGetConfig( @nFunc, 'PalletCloseStatus', @cStorerkey)  
   IF @cPalletCloseStatus = '0'  
      SET @cPalletCloseStatus = '9'  

   SET @cPalletNotAllowMixShipperKey = rdt.RDTGetConfig( @nFunc, 'PalletNotAllowMixShipperKey', @cStorerkey)  

   -- Initialize value  
   SET @cTrackNo = ''  
   SET @cOption = ''  
  
   EXEC rdt.rdtSetFocusField @nMobile, 1          
     
   -- Prep next screen var  
   SET @cOutField01 = '' -- Track No  
   SET @cOutField02 = '' -- Option  
     
   SET @nScn = @nScn_TrackNo  
   SET @nStep = @nStep_TrackNo  
  
   -- EventLog  
   EXEC RDT.rdt_STD_EventLog  
      @cActionType = '1', -- Sign-in  
      @cUserID     = @cUserName,  
      @nMobileNo   = @nMobile,  
      @nFunctionID = @nFunc,  
      @cFacility   = @cFacility,  
      @cStorerKey  = @cStorerKey,  
      @nStep       = @nStep  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 1. Scn = 5800  
   TRACK NO    (field01, input)  
********************************************************************************/  
Step_TrackNo:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Screen mapping  
      SET @cInTrackNo = @cInField01  
      SET @cBarcode = @cInField01  
      SET @cOption = @cInField02  
  
      IF @cOption <> ''  
      BEGIN  
         IF @cOption <> '1'  
         BEGIN  
            SET @nErrNo = 156351  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Option  
            GOTO Step_TrackNo_Fail  
         END  
           
         SET @cOutField01 = ''  
         SET @nScn = @nScn_ClosePallet  
         SET @nStep = @nStep_ClosePallet  
         GOTO Quit  
      END  
        
      IF ISNULL( @cInTrackNo, '') = ''   
      BEGIN  
         SET @nErrNo = 156352  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need TrackNo  
         GOTO Step_TrackNo_Fail  
      END  
  
      -- Validate SKU  
      IF @cBarcode <> ''  
      BEGIN  
         -- Decode  
         IF @cDecodeSP <> ''  
         BEGIN              
            -- Standard decode  
            IF @cDecodeSP = '1'  
            BEGIN                 
               SET @cUserDefine01 = ''  
               EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,   
                  @cUserDefine01 = @cUserDefine01  OUTPUT,   
                  @nErrNo        = @nErrNo         OUTPUT,   
                  @cErrMsg       = @cErrMsg        OUTPUT  
               IF @nErrNo <> 0  
                  GOTO Quit  
                 
               SET @cTrackNo = @cUserDefine01  
            END  
              
            -- Customize decode  
            ELSE IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cDecodeSP AND type = 'P')  
            BEGIN  
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +  
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode, ' +  
                  ' @cTrackNo OUTPUT, @cOrderKey OUTPUT, @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '  
               SET @cSQLParam =  
                  ' @nMobile        INT,           ' +  
                  ' @nFunc          INT,           ' +  
                  ' @cLangCode      NVARCHAR( 3),  ' +  
                  ' @nStep          INT,           ' +  
                  ' @nInputKey      INT,           ' +  
                  ' @cFacility      NVARCHAR( 5),  ' +  
                  ' @cStorerKey     NVARCHAR( 15), ' +  
                  ' @cBarcode       NVARCHAR( 100),  ' +  
                  ' @cTrackNo       NVARCHAR( 40)  OUTPUT, ' +  
                  ' @cOrderKey      NVARCHAR( 10)  OUTPUT, ' +  
                  ' @cLabelNo       NVARCHAR( 20)  OUTPUT, ' +
                  ' @nErrNo         INT            OUTPUT, ' +  
                  ' @cErrMsg        NVARCHAR( 20)  OUTPUT'  
     
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cBarcode,   
                  @cTrackNo OUTPUT, @cOrderKey OUTPUT, @cLabelNo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT   
     
               IF @nErrNo <> 0  
                  GOTO Step_TrackNo_Fail  
            END  
         END     
         ELSE
         BEGIN
            SELECT @cLabelNo = LabelNo
            FROM dbo.CartonTrack WITH (NOLOCK)
            WHERE KeyName = @cStorerKey
            AND   Trackingno = @cBarcode 
      
            SELECT TOP 1 @cOrderKey = PH.OrderKey
            FROM dbo.PackDetail PD WITH (NOLOCK)
            JOIN dbo.PackHeader PH WITH (NOLOCK) ON ( PD.PickSlipNo = PH.PickSlipNo)
            WHERE PD.StorerKey = @cStorerKey
            AND   PD.LabelNo = @cLabelNo
            ORDER BY 1

            SET @cTrackNo = @cInTrackNo
         END

         -- Check barcode format  
         IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'TrackingNo', @cBarcode) = 0  
         BEGIN  
            SET @nErrNo = 156374  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format  
            GOTO Step_TrackNo_Fail  
         END  
      END  
  
      IF ISNULL( @cOrderKey, '') = ''  
      BEGIN  
         SET @nErrNo = 156353  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --No Orders  
         GOTO Step_TrackNo_Fail  
      END  
  
      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +   
               ' @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtValidVar, ' +  
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +  
               ' @nFunc          INT,           ' +  
               ' @cLangCode      NVARCHAR( 3),  ' +  
               ' @nStep          INT,           ' +  
               ' @nInputKey      INT,           ' +  
               ' @cFacility      NVARCHAR( 5),  ' +  
               ' @cStorerKey     NVARCHAR( 15), ' +  
               ' @cTrackNo       NVARCHAR( 40), ' +  
               ' @cOrderKey      NVARCHAR( 20),' +  
               ' @cPalletKey     NVARCHAR( 20), ' +  
               ' @cMBOLKey       NVARCHAR( 10), ' +  
               ' @tExtValidVar   VariableTable READONLY, ' +   
               ' @nErrNo         INT           OUTPUT, ' +  
               ' @cErrMsg        NVARCHAR( 20) OUTPUT  '  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,   
               @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtValidVar,   
               @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0   
               GOTO Step_TrackNo_Fail  
         END  
      END  
        
      SET @cMBOLKey = ''  
      SET @nErrNo = 0
      EXEC [RDT].[rdt_TrackNo_SortToPallet_GetMbolKey]   
         @nMobile       = @nMobile,  
         @nFunc         = @nFunc,  
         @cLangCode     = @cLangCode,  
         @nStep         = @nStep,  
         @nInputKey     = @nInputKey,  
         @cFacility     = @cFacility,  
         @cStorerKey    = @cStorerKey,  
         @cTrackNo      = @cTrackNo,  
         @cOrderKey     = @cOrderKey,  
         @cPalletKey    = @cPalletKey  OUTPUT,  
         @cMBOLKey      = @cMBOLKey    OUTPUT,  
         @nErrNo        = @nErrNo      OUTPUT,  
         @cErrMsg       = @cErrMsg     OUTPUT  

      IF @nErrNo <> 0
         GOTO Quit
         
      -- Check if pallet closed  
      IF EXISTS ( SELECT 1 FROM dbo.Pallet WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND [Status] >= '5')   
         SET @cMBOLKey = ''  
  
      IF ISNULL( @cMBOLKey, '') <> ''  
      BEGIN  
         SET @cOutField01 = @cTrackNo  
         SET @cOutField02 = @cOrderKey  
         SET @cOutField03 = @cPalletKey  
         SET @cOutField04 = ''  
           
         SET @nScn  = @nScn_ShowPalletID  
         SET @nStep = @nStep_ShowPalletID  
      END     
      ELSE  
      BEGIN  
         -- Prep next screen var  
         SET @cOutField01 = @cTrackNo  
         SET @cOutField02 = @cOrderKey  
         SET @cOutField03 = ''  
  
         -- Goto scan pallet screen  
         SET @nScn  = @nScn_ScanPalletID  
         SET @nStep = @nStep_ScanPalletID  
      END  
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
         @cStorerKey  = @cStorerKey,  
         @nStep       = @nStep  
  
      -- Back to menu  
      SET @nFunc = @nMenu  
      SET @nScn  = @nMenu  
      SET @nStep = 0  
      SET @cOutField01 = ''  
   END  
   GOTO Quit  
     
   Step_TrackNo_Fail:  
   BEGIN  
      SET @cTrackNo = ''  
      SET @cOrderKey = ''  
      SET @cLabelNo = ''   -- ZG01  
      SET @cInTrackNo = ''  
      SET @cOutField01 = ''  
   END  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 2. Scn = 5801.   
   TRACK NO       (field01)  
   ORDERKEY       (field02)  
   PALLET ID      (field03, input)  
********************************************************************************/  
Step_ScanPalletID:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Initialize value  
      SET @cPalletKey = @cInField03  
      SET @cBarcode = @cInField03  
        
      IF ISNULL( @cPalletKey, '') = ''  
      BEGIN  
         SET @nErrNo = 156354  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Pallet ID  
         GOTO Step_ScanPalletID_Fail  
      END  
  
      -- Check barcode format  
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'PalletKey', @cBarcode) = 0  
      BEGIN  
         SET @nErrNo = 156367  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format  
         GOTO Step_ScanPalletID_Fail  
      END  
      
      IF @cPalletNotAllowMixShipperKey = '1'
      BEGIN
         -- Get shipperkey from newly scanned orderkey (tracking no)
         SELECT @cNew_ShipperKey = ShipperKey
         FROM dbo.ORDERS WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
      
         -- Get orderkey from existing pallet
         SELECT TOP 1 @cCur_OrderKey = UserDefine01
         FROM dbo.PALLETDETAIL WITH (NOLOCK)
         WHERE PalletKey = @cPalletKey
         AND   StorerKey = @cStorerKey
         AND   [Status] = '0'
         ORDER BY 1
         
         IF @@ROWCOUNT = 1
         BEGIN
            -- Get shipperkey from orders on existing pallet
            SELECT @cCur_ShipperKey = ShipperKey
            FROM dbo.ORDERS WITH (NOLOCK)
            WHERE OrderKey = @cCur_OrderKey
         
            -- Validate if same shipperkey
            IF @cCur_ShipperKey <> @cNew_ShipperKey
            BEGIN
               SET @nErrNo = 156373  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PltDiffShipper  
               GOTO Step_ScanPalletID_Fail  
            END
         END
      END
      
      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +   
               ' @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtValidVar, ' +  
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +  
               ' @nFunc          INT,           ' +  
               ' @cLangCode      NVARCHAR( 3),  ' +  
               ' @nStep          INT,           ' +  
               ' @nInputKey      INT,           ' +  
               ' @cFacility      NVARCHAR( 5),  ' +  
               ' @cStorerKey     NVARCHAR( 15), ' +  
               ' @cTrackNo       NVARCHAR( 40), ' +  
               ' @cOrderKey      NVARCHAR( 20),' +  
               ' @cPalletKey     NVARCHAR( 20), ' +  
               ' @cMBOLKey       NVARCHAR( 10), ' +  
               ' @tExtValidVar   VariableTable READONLY, ' +   
               ' @nErrNo         INT           OUTPUT, ' +  
               ' @cErrMsg        NVARCHAR( 20) OUTPUT  '  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,   
               @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtValidVar,   
               @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0   
               GOTO Step_ScanPalletID_Fail  
         END  
      END  
  
      SET @nTranCount = @@TRANCOUNT  
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN rdt_CreateMbol -- For rollback or commit only our own transaction  
      SET @nErrNo = 0  
  
      -- Pallet  
      IF NOT EXISTS( SELECT 1 FROM Pallet WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND Status = '0')  
      BEGIN  
         IF EXISTS ( SELECT 1 FROM dbo.PALLET WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND Status = '9')  
         BEGIN  
            SET @curDel = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
            SELECT PalletLineNumber  
            FROM dbo.PalletDetail WITH (NOLOCK)  
            WHERE PalletKey = @cPalletKey  
            OPEN @curDel  
            FETCH NEXT FROM @curDel INTO @cPalletLineNumber  
            WHILE @@FETCH_STATUS = 0  
            BEGIN  
               UPDATE PALLETDETAIL SET ArchiveCop = '9'   
               WHERE PalletKey = @cPalletKey  
               AND PalletLineNumber = @cPalletLineNumber  
   
               DELETE FROM PALLETDETAIL  
               WHERE PalletKey = @cPalletKey  
               AND PalletLineNumber = @cPalletLineNumber  
  
               IF @@ERROR <> 0  
               BEGIN  
                  SET @nErrNo = 156371  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltDtl Err  
                  EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @nErrNo, @cErrMsg  
                  GOTO RollBackTran_CreateMbol  
               END  
                 
               FETCH NEXT FROM @curDel INTO @cPalletLineNumber  
            END  
  
            UPDATE PALLET SET ArchiveCop = '9' WHERE PalletKey = @cPalletKey  
  
            DELETE FROM PALLET WHERE PalletKey = @cPalletKey  
  
            IF @@ERROR <> 0  
            BEGIN  
               SET @nErrNo = 156372  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Del PltHdr Err  
               EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @nErrNo, @cErrMsg  
               GOTO RollBackTran_CreateMbol  
            END  
  
         END  
           
         INSERT INTO Pallet (PalletKey, StorerKey, Status)  
         VALUES (@cPalletKey, @cStorerKey, '0')  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 156355  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PalletFail  
            EXEC rdt.rdtInsertMsgQueue @nMobile, 0, '', @nErrNo, @cErrMsg  
            GOTO RollBackTran_CreateMbol  
         END  
      END  
        
      -- PalletDetail  
      IF NOT EXISTS( SELECT 1 FROM PalletDetail WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND CaseID = @cLabelNo)  
      BEGIN  
         SELECT TOP 1 @cSKU = SKU  
         FROM dbo.PackDetail WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND   LabelNo = @cTrackNo  
         ORDER BY 1  

         IF ISNULL( @cSKU, '') = ''
            SELECT TOP 1 @cSKU = SKU  
            FROM dbo.PackDetail PD WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey  
            AND   EXISTS ( SELECT 1 FROM dbo.CartonTrack CT WITH (NOLOCK)
                           WHERE PD.LabelNo = CT.LabelNo
                           AND   CT.TrackingNo = @cTrackNo)  
            ORDER BY 1  
         
         IF ISNULL( @cSKU, '') = ''
            SET @cSKU = ''
            
         INSERT INTO dbo.PalletDetail  
            (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, QTY, Status, UserDefine01, UserDefine02)  
         VALUES  
            (@cPalletKey, '0', @cLabelNo, @cStorerKey, @cSKU, 'HM-QI', 0, '0', @cOrderKey, @cTrackNo)  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 156356  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PLDtl Fail  
            GOTO RollBackTran_CreateMbol  
         END  
      END  

      -- (james01)
      IF @cMBOLKey = ''
         -- 1 Mbol 1 ExternMbolKey
         SELECT @cMBOLKey = MbolKey
         FROM dbo.MBOL WITH (NOLOCK)
         WHERE ExternMbolKey = @cPalletKey
         AND   [Status] = '0'

      -- Insert MBOL  
      IF NOT EXISTS( SELECT 1 FROM MBOL WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND [Status] = '0')  
      BEGIN  
         SELECT @bSuccess = 0  
         EXECUTE nspg_GetKey  
                  'MBOL',  
                  10,  
                  @cMBOLKey OUTPUT,  
                  @bSuccess OUTPUT,  
                  @nErrNo   OUTPUT,  
                  @cErrMsg  OUTPUT  
  
         IF @bSuccess <> 1  
         BEGIN  
            SET @nErrNo = 156368  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GetKey Fail  
            GOTO RollBackTran_CreateMbol  
         END  
  
         INSERT INTO MBOL (MBOLKey, ExternMBOLKey, Facility, Status) VALUES (@cMBOLKey, @cPalletKey, @cFacility, '0')  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 156357  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBOL Fail  
            GOTO RollBackTran_CreateMbol  
         END  
      END  
        
      -- Insert MBOLDetail  
      IF NOT EXISTS( SELECT 1 FROM MBOLDetail WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND OrderKey = @cOrderKey)  
      BEGIN  
         -- Check MBOL shipped (temporary workaround, instead of changing ntrMBOLDetailAdd trigger)  
         IF EXISTS( SELECT 1 FROM dbo.MBOL WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND Status = '9')  
         BEGIN  
            SET @nErrNo = 156358  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL Shipped  
            GOTO RollBackTran_CreateMbol  
         END  
           
         SELECT @cLoadKey = LoadKey,   
                @dOrderDate = OrderDate,   
                @cExternOrderKey = ExternOrderKey,   
                @dDeliveryDate = DeliveryDate  
         FROM dbo.ORDERS WITH (NOLOCK)   
         WHERE OrderKey = @cOrderKey  
        
         SELECT @nCtnCnt1 = CtnCnt1  
         FROM dbo.PackHeader WITH (NOLOCK)  
         WHERE OrderKey = @cOrderKey  
           
         INSERT INTO dbo.MBOLDetail   
            (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, AddWho, AddDate, EditWho, EditDate, Weight, Cube,   
             OrderDate, ExternOrderKey, DeliveryDate, CtnCnt1, CtnCnt2, CtnCnt3, CtnCnt4, CtnCnt5,  
             UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, UserDefine09, UserDefine10)  
         VALUES   
            (@cMBOLKey, '00000', @cOrderKey, @cLoadKey, 'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE(), 0, 0,   
             @dOrderDate, @cExternOrderKey, @dDeliveryDate, @nCtnCnt1, 0, 0, 0, 0,   
             '', '', '', '', '', '', '')  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 156359  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBDtl Fail  
            GOTO RollBackTran_CreateMbol  
         END  
      END  
  
      COMMIT TRAN rdt_CreateMbol  
  
      GOTO Quit_CreateMbol  
  
      RollBackTran_CreateMbol:  
         ROLLBACK TRAN -- Only rollback change made here  
      Quit_CreateMbol:  
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
            COMMIT TRAN  
        
      IF @nErrNo <> 0  
         GOTO Step_ScanPalletID_Fail  
  
      -- Prep next screen var  
      SET @cOutField01 = '' -- Track No  
      SET @cOutField02 = '' -- Option  
     
      EXEC rdt.rdtSetFocusField @nMobile, 1        
        
      SET @nScn = @nScn_TrackNo  
      SET @nStep = @nStep_TrackNo  
   END  
     
   IF @nInputKey = 0 -- Esc or No  
   BEGIN  
      -- Initialize value  
      SET @cTrackNo = ''  
      SET @cOrderKey = ''  
  
      -- Prep next screen var  
      SET @cOutField01 = '' -- Track No  
      SET @cOutField02 = '' -- Option  
     
      EXEC rdt.rdtSetFocusField @nMobile, 1          
  
      SET @nScn = @nScn_TrackNo  
      SET @nStep = @nStep_TrackNo  
   END  

   -- Extended info  
   IF @cExtendedInfoSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, ' +   
            ' @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtInfoVar, @cExtendedInfo OUTPUT'   
  
         SET @cSQLParam =  
            ' @nMobile        INT,           ' +  
            ' @nFunc          INT,           ' +  
            ' @cLangCode      NVARCHAR( 3),  ' +  
            ' @nStep          INT,           ' +  
            ' @nAfterStep     INT,           ' +
            ' @nInputKey      INT,           ' +  
            ' @cFacility      NVARCHAR( 5),  ' +  
            ' @cStorerKey     NVARCHAR( 15), ' +  
            ' @cTrackNo       NVARCHAR( 40), ' +  
            ' @cOrderKey      NVARCHAR( 20),' +  
            ' @cPalletKey     NVARCHAR( 20), ' +  
            ' @cMBOLKey       NVARCHAR( 10), ' +  
            ' @tExtInfoVar    VariableTable READONLY, ' +   
            ' @cExtendedInfo  NVARCHAR( 20) OUTPUT  '   
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep_ScanPalletID, @nStep, @nInputKey, @cFacility, @cStorerKey,   
            @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtInfoVar, @cExtendedInfo OUTPUT   
              
         IF @cExtendedInfo <> ''
            SET @cOutField15 = @cExtendedInfo  
      END  
   END  
      
   GOTO Quit  
     
   Step_ScanPalletID_Fail:  
   BEGIN  
      SET @cPalletKey = ''  
      SET @cOutField03 = ''  
   END  
END  
GOTO Quit  
  
/********************************************************************************  
Step 3. Scn = 5802.   
   TRACK NO       (field01)  
   ORDERKEY       (field02)  
   PALLET ID      (field03, input)  
********************************************************************************/  
Step_ShowPalletID:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Initialize value  
      SET @cSuggPalletKey = @cOutField03  
      SET @cPalletKey = @cInField04  
  
      IF ISNULL( @cPalletKey, '') = ''  
      BEGIN  
         SET @nErrNo = 156360  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Pallet ID  
         GOTO Step_ShowPalletID_Fail  
      END  
  
      IF @cSuggPalletKey <> @cPalletKey  
      BEGIN  
         SET @nErrNo = 156361  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Pallet Not Match  
         GOTO Step_ShowPalletID_Fail  
      END  
  
      -- Extended validate  
      IF @cExtendedValidateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +   
               ' @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtValidVar, ' +  
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +  
               ' @nFunc          INT,           ' +  
               ' @cLangCode      NVARCHAR( 3),  ' +  
               ' @nStep          INT,           ' +  
               ' @nInputKey      INT,           ' +  
               ' @cFacility      NVARCHAR( 5),  ' +  
               ' @cStorerKey     NVARCHAR( 15), ' +  
               ' @cTrackNo       NVARCHAR( 40), ' +  
               ' @cOrderKey      NVARCHAR( 20),' +  
               ' @cPalletKey     NVARCHAR( 20), ' +  
               ' @cMBOLKey       NVARCHAR( 10), ' +  
               ' @tExtValidVar   VariableTable READONLY, ' +   
               ' @nErrNo         INT           OUTPUT, ' +  
               ' @cErrMsg        NVARCHAR( 20) OUTPUT  '  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,   
               @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtValidVar,   
               @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0   
               GOTO Step_TrackNo_Fail  
         END  
      END  
  
      SET @nTranCount = @@TRANCOUNT  
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN rdt_CreateMbolDetail -- For rollback or commit only our own transaction  
      SET @nErrNo = 0  
  
      -- PalletDetail  
      IF NOT EXISTS( SELECT 1 FROM PalletDetail WITH (NOLOCK) WHERE PalletKey = @cPalletKey AND CaseID = @cLabelNo)  
      BEGIN  
         SELECT TOP 1 @cSKU = SKU  
         FROM dbo.PackDetail WITH (NOLOCK)  
         WHERE StorerKey = @cStorerKey  
         AND   LabelNo = @cTrackNo  
         ORDER BY 1  

         IF ISNULL( @cSKU, '') = ''
            SELECT TOP 1 @cSKU = SKU  
            FROM dbo.PackDetail PD WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey  
            AND   EXISTS ( SELECT 1 FROM dbo.CartonTrack CT WITH (NOLOCK)
                           WHERE PD.LabelNo = CT.LabelNo
                           AND   CT.TrackingNo = @cTrackNo)  
            ORDER BY 1  

         IF ISNULL( @cSKU, '') = ''
            SET @cSKU = ''
            
         INSERT INTO dbo.PalletDetail  
            (PalletKey, PalletLineNumber, CaseID, StorerKey, SKU, LOC, QTY, Status, UserDefine01, UserDefine02)  
         VALUES  
            (@cPalletKey, '0', @cLabelNo, @cStorerKey, @cSKU, 'HM-QI', 0, '0', @cOrderKey, @cTrackNo)  
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 156362  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS PLDtl Fail  
            GOTO RollBackTran_CreateMbolDetail  
         END  
      END  
  
      -- Insert MBOLDetail  
      IF NOT EXISTS( SELECT 1 FROM MBOLDetail WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND OrderKey = @cOrderKey)  
      BEGIN  
         -- Check MBOL shipped (temporary workaround, instead of changing ntrMBOLDetailAdd trigger)  
         IF EXISTS( SELECT 1 FROM dbo.MBOL WITH (NOLOCK) WHERE MBOLKey = @cMBOLKey AND Status = '9')  
         BEGIN  
            SET @nErrNo = 156363  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MBOL Shipped  
            GOTO RollBackTran_CreateMbolDetail  
         END  
  
        SELECT @cLoadKey = LoadKey,   
                @dOrderDate = OrderDate,   
                @cExternOrderKey = ExternOrderKey,   
                @dDeliveryDate = DeliveryDate  
         FROM dbo.ORDERS WITH (NOLOCK)   
         WHERE OrderKey = @cOrderKey  
        
         SELECT @nCtnCnt1 = CtnCnt1  
         FROM dbo.PackHeader WITH (NOLOCK)  
         WHERE OrderKey = @cOrderKey  
                 
         INSERT INTO dbo.MBOLDetail   
            (MBOLKey, MBOLLineNumber, OrderKey, LoadKey, AddWho, AddDate, EditWho, EditDate, Weight, Cube,   
             OrderDate, ExternOrderKey, DeliveryDate, CtnCnt1, CtnCnt2, CtnCnt3, CtnCnt4, CtnCnt5,  
             UserDefine01, UserDefine02, UserDefine03, UserDefine04, UserDefine05, UserDefine09, UserDefine10)  
         VALUES   
            (@cMBOLKey, '00000', @cOrderKey, @cLoadKey, 'rdt.' + SUSER_SNAME(), GETDATE(), 'rdt.' + SUSER_SNAME(), GETDATE(), 0, 0,   
             @dOrderDate, @cExternOrderKey, @dDeliveryDate, @nCtnCnt1, 0, 0, 0, 0,   
             '', '', '', '', '', '', '')  
               
         IF @@ERROR <> 0  
         BEGIN  
            SET @nErrNo = 156364  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --INS MBDtl Fail  
            GOTO RollBackTran_CreateMbolDetail  
         END  
      END  
  
      COMMIT TRAN rdt_CreateMbolDetail  
  
      GOTO Quit_CreateMbolDetail  
  
      RollBackTran_CreateMbolDetail:  
         ROLLBACK TRAN rdt_CreateMbolDetail -- Only rollback change made here  
      Quit_CreateMbolDetail:  
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
            COMMIT TRAN  
        
      IF @nErrNo <> 0  
         GOTO Step_ShowPalletID_Fail  
  
      -- Prep next screen var  
      SET @cOutField01 = '' -- Track No  
      SET @cOutField02 = '' -- Option  
     
      EXEC rdt.rdtSetFocusField @nMobile, 1        
        
      SET @nScn = @nScn_TrackNo  
      SET @nStep = @nStep_TrackNo  
   END  
     
   IF @nInputKey = 0 -- Esc or No  
   BEGIN  
      -- Initialize value  
      SET @cTrackNo = ''  
      SET @cOrderKey = ''  
  
      -- Prep next screen var  
      SET @cOutField01 = '' -- Track No  
      SET @cOutField02 = ''  
        
      SET @nScn = @nScn_TrackNo  
      SET @nStep = @nStep_TrackNo  
   END  

   -- Extended info  
   IF @cExtendedInfoSP <> ''  
   BEGIN  
      IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
      BEGIN  
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, ' +   
            ' @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtInfoVar, @cExtendedInfo OUTPUT'   
  
         SET @cSQLParam =  
            ' @nMobile        INT,           ' +  
            ' @nFunc          INT,           ' +  
            ' @cLangCode      NVARCHAR( 3),  ' +  
            ' @nStep          INT,           ' +  
            ' @nAfterStep     INT,           ' +
            ' @nInputKey      INT,           ' +  
            ' @cFacility      NVARCHAR( 5),  ' +  
            ' @cStorerKey     NVARCHAR( 15), ' +  
            ' @cTrackNo       NVARCHAR( 40), ' +  
            ' @cOrderKey      NVARCHAR( 20),' +  
            ' @cPalletKey     NVARCHAR( 20), ' +  
            ' @cMBOLKey       NVARCHAR( 10), ' +  
            ' @tExtInfoVar    VariableTable READONLY, ' +   
            ' @cExtendedInfo  NVARCHAR( 20) OUTPUT  '   
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
            @nMobile, @nFunc, @cLangCode, @nStep_ShowPalletID, @nStep, @nInputKey, @cFacility, @cStorerKey,   
            @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtInfoVar, @cExtendedInfo OUTPUT   
              
         IF @cExtendedInfo <> ''
            SET @cOutField15 = @cExtendedInfo  
      END  
   END  

   GOTO Quit  
     
   Step_ShowPalletID_Fail:  
   BEGIN  
      SET @cPalletKey = ''  
      SET @cOutField04 = ''  
   END  
END  
GOTO Quit  
  
/********************************************************************************  
Step 4. Scn = 5803  
   PALLETKEY    (field01, input)  
********************************************************************************/  
Step_ClosePallet:  
BEGIN  
   IF @nInputKey = 1 -- Yes or Send  
   BEGIN  
      -- Screen mapping  
      SET @cPalletKey = @cInField01  
      SET @cBarcode = @cInField01
      
      IF ISNULL( @cPalletKey, '') = ''  
      BEGIN  
         SET @nErrNo = 156365  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Pallet ID  
         GOTO Step_ClosePallet_Fail  
      END  

      -- Check barcode format  
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'PalletKey', @cBarcode) = 0  
      BEGIN  
         SET @nErrNo = 156375  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Format  
         GOTO Step_ClosePallet_Fail  
      END  

      SET @cMBOLKey = ''  
      SELECT @cMBOLKey = MBOLKey  
      FROM dbo.MBOL WITH (NOLOCK)  
      WHERE ExternMbolKey = @cPalletKey  
      AND   [Status] = '0'  
        
      IF ISNULL( @cMBOLKey, '') = ''  
      BEGIN  
         SET @nErrNo = 156366  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inv Pallet ID  
         GOTO Step_ClosePallet_Fail  
      END  
  
      SET @nTranCount = @@TRANCOUNT  
      BEGIN TRAN  -- Begin our own transaction  
      SAVE TRAN rdt_UpdateMbol -- For rollback or commit only our own transaction  
      SET @nErrNo = 0  
  
      UPDATE dbo.PalletDetail SET   
         [Status] = '9',  
         EditDate = GETDATE(),  
         EditWho = SUSER_SNAME()  
      WHERE PalletKey = @cPalletKey  
        
      IF @@ERROR <> 0  
      BEGIN  
         SET @nErrNo = 156369  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Close PltD Err  
         GOTO RollBackTran_UpdateMbol  
      END  
  
      UPDATE dbo.Pallet SET   
         [Status] = @cPalletCloseStatus,  
         EditDate = GETDATE(),  
         EditWho = SUSER_SNAME()  
      WHERE PalletKey = @cPalletKey  
        
      IF @@ERROR <> 0  
      BEGIN  
         SET @nErrNo = 156370  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Close Plt Err  
         GOTO RollBackTran_UpdateMbol  
      END  
        
      -- Extended update  
      IF @cExtendedUpdateSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, ' +   
               ' @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtUpdateVar, ' +  
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +  
               ' @nFunc          INT,           ' +  
               ' @cLangCode      NVARCHAR( 3),  ' +  
               ' @nStep          INT,           ' +  
               ' @nInputKey      INT,           ' +  
               ' @cFacility      NVARCHAR( 5),  ' +  
               ' @cStorerKey     NVARCHAR( 15), ' +  
               ' @cTrackNo       NVARCHAR( 40), ' +  
               ' @cOrderKey      NVARCHAR( 20),' +  
               ' @cPalletKey     NVARCHAR( 20), ' +  
               ' @cMBOLKey       NVARCHAR( 10), ' +  
               ' @tExtUpdateVar  VariableTable READONLY, ' +   
               ' @nErrNo         INT           OUTPUT, ' +  
               ' @cErrMsg        NVARCHAR( 20) OUTPUT  '  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey,   
               @cTrackNo, @cOrderKey, @cPalletKey, @cMBOLKey, @tExtUpdateVar,   
               @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0   
               GOTO RollBackTran_UpdateMbol  
         END  
      END  
  
      COMMIT TRAN rdt_UpdateMbol  
  
      GOTO Quit_UpdateMbol  
  
      RollBackTran_UpdateMbol:  
         ROLLBACK TRAN rdt_UpdateMbol -- Only rollback change made here  
      Quit_UpdateMbol:  
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
            COMMIT TRAN  
        
      IF @nErrNo <> 0  
         GOTO Step_ShowPalletID_Fail  
  
      -- Prep next screen var  
      SET @cOutField01 = '' -- Track No  
      SET @cOutField02 = '' -- Option  
        
      EXEC rdt.rdtSetFocusField @nMobile, 1        
        
      SET @nScn = @nScn_TrackNo  
      SET @nStep = @nStep_TrackNo  
   END  
     
   IF @nInputKey = 0 -- Esc or No  
   BEGIN  
      -- Initialize value  
      SET @cTrackNo = ''  
      SET @cOrderKey = ''  
  
      -- Prep next screen var  
      SET @cOutField01 = '' -- Track No  
      SET @cOutField02 = '' -- Option  
        
      SET @nScn = @nScn_TrackNo  
      SET @nStep = @nStep_TrackNo  
   END  
   GOTO Quit  
     
   Step_ClosePallet_Fail:  
   BEGIN  
      SET @cPalletKey = ''  
      SET @cOutField04 = ''  
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
  
      StorerKey = @cStorerKey,  
      Facility  = @cFacility,  
      UserName  = @cUserName,  
      V_OrderKey= @cOrderKey,  
     
      V_String1   = @cLabelNo,  
      V_String2   = @cPalletKey,  
      V_String3   = @cMBOLKey,  
      V_String4   = @cPalletCloseStatus,  
     
      V_String20 = @cDecodeSP,  
      V_String21 = @cExtendedInfoSP,  
      V_String22 = @cExtendedValidateSP,  
      V_String23 = @cExtendedUpdateSP,  
      V_String24 = @cPalletNotAllowMixShipperKey,

      V_String41 = @cTrackNo,
     
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
      I_Field15 = @cInField15,  O_Field15 = @cOutField15  
   WHERE Mobile = @nMobile  
END  
GO
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdtfnc_TrackNo_SortToPallet] TO nSQL
GO

