SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

  
/******************************************************************************/  
/* Store procedure: rdtfnc_PTLPieceAudit                                      */  
/* Copyright: LF Logistics                                                    */  
/*                                                                            */  
/* Date       Rev  Author     Purposes                                        */  
/* 2021-07-28 1.0  Chermaine  WMS-17446 Created                               */  
/******************************************************************************/  
  
CREATE OR ALTER PROC rdt.rdtfnc_PTLPieceAudit (  
   @nMobile    int,  
   @nErrNo     int  OUTPUT,  
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 NVARCHAR max  
)  
AS  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
-- Misc variable  
DECLARE  
   @i             INT,   
   @nCount        INT,  
   @bSuccess      INT,  
   @nTranCount    INT,  
   @cSQL          NVARCHAR( MAX),  
   @cSQLParam     NVARCHAR( MAX),  
   @cIPAddress    NVARCHAR( 40),   
   @cPosition     NVARCHAR( 10),   
   @cOption       NVARCHAR( 1),   
        
   @cResult01  NVARCHAR( 20),  
   @cResult02  NVARCHAR( 20),  
   @cResult03  NVARCHAR( 20),  
   @cResult04  NVARCHAR( 20),  
   @cResult05  NVARCHAR( 20),  
   @cResult06  NVARCHAR( 20),  
   @cResult07  NVARCHAR( 20),  
   @cResult08  NVARCHAR( 20),  
   @cResult09  NVARCHAR( 20),  
   @cResult10  NVARCHAR( 20),  
   @cResult11  NVARCHAR( 20),  
   @cResult12  NVARCHAR( 20),  
   @cResult13  NVARCHAR( 20)  
  
-- RDT.RDTMobRec variable  
DECLARE  
   @nFunc         INT,  
   @nScn          INT,  
   @nStep         INT,  
   @nFromScn      INT,  
   @nFromStep     INT,  
   @cLangCode     NVARCHAR( 3),  
   @nInputKey     INT,  
   @nMenu         INT,  
  
   @cStorerKey    NVARCHAR( 15),  
   @cFacility     NVARCHAR( 5),  
   @cPrinter      NVARCHAR( 20),  
   @cUserName     NVARCHAR( 18),  
   @cDeviceID     NVARCHAR( 20),  
  
   @cSKU          NVARCHAR(20),  
   @cLoc          NVARCHAR(10),  
   @cWaveKey      NVARCHAR(10),  
   @cBatchKey     NVARCHAR(10),    
   @cUPC          NVARCHAR(30),  
   @cBarcode      NVARCHAR(60),  
  
   @cStation      NVARCHAR(10),  
   @cMethod       NVARCHAR(1),  
   @nCurrentPage  INT,  
  
   @cDecodeSP     NVARCHAR( 20),  
   @cGetStatSP    NVARCHAR( 20),  
   @cLight        NVARCHAR( 1),  
     
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
   @cFieldAttr15 NVARCHAR( 1),  
  
   @cErrMsg1    NVARCHAR( 20), @cErrMsg2    NVARCHAR( 20),  
   @cErrMsg3    NVARCHAR( 20), @cErrMsg4    NVARCHAR( 20),  
   @cErrMsg5    NVARCHAR( 20), @cErrMsg6    NVARCHAR( 20),  
   @cErrMsg7    NVARCHAR( 20), @cErrMsg8    NVARCHAR( 20),  
   @cErrMsg9    NVARCHAR( 20), @cErrMsg10   NVARCHAR( 20),  
   @cErrMsg11   NVARCHAR( 20), @cErrMsg12   NVARCHAR( 20),  
   @cErrMsg13   NVARCHAR( 20), @cErrMsg14   NVARCHAR( 20),  
   @cErrMsg15   NVARCHAR( 20)   
  
-- Load RDT.RDTMobRec  
SELECT  
   @nFunc      = Func,  
   @nScn       = Scn,  
   @nStep      = Step,  
   @nInputKey  = InputKey,  
   @nMenu      = Menu,  
   @cLangCode  = Lang_code,  
  
   @cStorerKey = StorerKey,  
   @cFacility  = Facility,  
   @cPrinter   = Printer,  
   @cUserName  = UserName,  
   @cDeviceID  = DeviceID,  
  
   @cSKU        = V_SKU,  
     
   @nFromScn    = V_Integer1,  
   @nFromStep   = V_Integer2,  
   @nCurrentPage = V_Integer3,  
  
   @cStation         = V_String1,  
   @cMethod          = V_String2,  
   @cIPAddress       = V_String3,  
   @cPosition        = V_String4,  
   @cLoc             = V_String5,  
   @cWaveKey         = V_String6,  
   @cBatchKey        = V_String7,  
   @cDecodeSP        = V_String8,  
   @cLight           = V_String9,  
   @cGetStatSP       = V_String10,  
  
  
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
  
   @cFieldAttr01  = FieldAttr01,    @cFieldAttr02   = FieldAttr02,  
   @cFieldAttr03 =  FieldAttr03,    @cFieldAttr04   = FieldAttr04,  
   @cFieldAttr05 =  FieldAttr05,    @cFieldAttr06   = FieldAttr06,  
   @cFieldAttr07 =  FieldAttr07,    @cFieldAttr08   = FieldAttr08,  
   @cFieldAttr09 =  FieldAttr09,    @cFieldAttr10   = FieldAttr10,  
   @cFieldAttr11 =  FieldAttr11,    @cFieldAttr12   = FieldAttr12,  
   @cFieldAttr13 =  FieldAttr13,    @cFieldAttr14   = FieldAttr14,  
   @cFieldAttr15 =  FieldAttr15  
  
FROM rdt.rdtMobRec (NOLOCK)  
WHERE Mobile = @nMobile  
  
IF @nFunc = 1857  -- rdtfnc_PTLPieceAudit  
BEGIN  
   -- Redirect to respective screen  
   IF @nStep = 0 GOTO Step_0   -- rdtfnc_PTLPieceAudit  
   IF @nStep = 1 GOTO Step_1   -- Scn = 5940. Station, Method  
   IF @nStep = 2 GOTO Step_2   -- Scn = 5941. SKU  
   IF @nStep = 3 GOTO Step_3   -- Scn = 5942. LOC  
   IF @nStep = 4 GOTO Step_4   -- Scn = 5943. Statisics  
END  
RETURN -- Do nothing if incorrect step  
  
  
/********************************************************************************  
Step 0. func = 1857. Menu  
********************************************************************************/  
Step_0:  
BEGIN  
   -- Get storer config  
   SET @cDecodeSP = rdt.rdtGetConfig( @nFunc, 'DecodeSP', @cStorerKey)  
   IF @cDecodeSP = '0'  
      SET @cDecodeSP = ''  
        
    -- Get storer configure  
   SET @cGetStatSP = rdt.RDTGetConfig( @nFunc, 'GetStatSP', @cStorerKey)  
   IF @cGetStatSP = '0'  
      SET @cGetStatSP = ''  
     
   -- Get storer config  
   DECLARE @cBypassTCPSocket NVARCHAR(1)  
   SET @cBypassTCPSocket = ''  
   EXECUTE nspGetRight  
      NULL,  
      @cStorerKey,  
      NULL,  
      'BypassTCPSocketClient',  
      @bSuccess         OUTPUT,  
      @cBypassTCPSocket OUTPUT,  
      @nErrNo           OUTPUT,  
      @cErrMsg          OUTPUT  
  
   -- Light  
   IF @cDeviceID <> '' AND @cBypassTCPSocket <> '1'  
      SET @cLight = '1' -- Use light  
   ELSE  
      SET @cLight = '0' -- Not use  
        
    -- Off all lights  
   IF @cLight = '1'  
   BEGIN  
      -- Clear light  
      EXEC PTL.isp_PTL_TerminateModule  
            @cStorerKey  
            ,@nFunc  
            ,@cStation  
            ,'STATION'  
            ,@bSuccess    OUTPUT  
            ,@nErrNo      --OUTPUT -- Prevent PTL overwrite RDT error  
            ,@cErrMsg     --OUTPUT -- Prevent PTL overwrite RDT error  
      IF @nErrNo <> 0  
         GOTO Quit  
   END  
  
   -- EventLog  
   EXEC RDT.rdt_STD_EventLog  
     @cActionType = '1', -- Sign-in  
     @cUserID     = @cUserName,  
     @nMobileNo   = @nMobile,  
     @nFunctionID = @nFunc,  
     @cFacility   = @cFacility,  
     @cStorerKey  = @cStorerkey  
  
   -- Init var  
   SET @nCurrentPage = 0  
  
     -- Set the entry point  
   SET @nScn = 5940  
   SET @nStep = 1  
  
   EXEC rdt.rdtSetFocusField @nMobile, 1  
END  
GOTO Quit  
  
  
/********************************************************************************  
Step 1. Scn = 5940.  
   Station  (Field01, input)  
   Method   (Field02, input)  
********************************************************************************/  
Step_1:  
BEGIN  
   IF @nInputKey = 1 --ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cStation = @cInField01  
      SET @cMethod = @cInField02  
  
      -- Validate blank  
      IF @cStation = ''  
      BEGIN  
         SET @nErrNo = 172251  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need station  
         EXEC rdt.rdtSetFocusField @nMobile, 1  
         GOTO Quit  
      END  
  
      -- Check station valid  
      IF NOT EXISTS( SELECT 1 FROM dbo.DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'STATION' AND DeviceID <> '' AND DeviceID = @cStation)  
      BEGIN  
         SET @nErrNo = 172252  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidStation  
         EXEC rdt.rdtSetFocusField @nMobile, 1  
         GOTO Quit  
      END  
        
      IF NOT EXISTS (SELECT TOP 1 1 FROM rdt.rdtPTLPieceLog WITH (NOLOCK) WHERE station = @cStation)  
      BEGIN  
       SET @nErrNo = 172253  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTaskAssigned  
         EXEC rdt.rdtSetFocusField @nMobile, 1  
         GOTO Quit  
      END  
                   
      -- Check blank  
      IF @cMethod = ''  
      BEGIN  
         SET @nErrNo = 172254  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need method  
         EXEC rdt.rdtSetFocusField @nMobile, 2  
         GOTO Quit  
      END  
  
      IF @cMethod NOT IN ('1','2','3')  
      BEGIN  
         SET @nErrNo = 172255  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid method  
         EXEC rdt.rdtSetFocusField @nMobile, 2  
         GOTO Quit  
      END  
        
      SET @cOutField01 = @cStation  
      SET @cOutField02 = '' --sku/loc  
      SET @nFromScn = @nScn  
      SET @nFromStep = @nStep  
        
      IF @cMethod = '1'  
      BEGIN  
       SET @nScn = @nScn + 1  
         SET @nStep = @nStep + 1  
         GOTO Quit  
      END  
      ELSE IF @cMethod = '2'  
      BEGIN  
       SET @nScn = @nScn + 2  
         SET @nStep = @nStep + 2  
         GOTO Quit  
      END  
      ELSE  
      BEGIN  
       --Get statistic  
         IF @cGetStatSP <> ''  
         BEGIN  
            IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cGetStatSP AND type = 'P')  
            BEGIN  
               SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetStatSP) +  
                  ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight,  ' +  
                  ' @nCurrentPage   , ' +  
                  ' @cOutField01    OUTPUT, ' +  
                  ' @cOutField02    OUTPUT, ' +   
                  ' @cOutField03    OUTPUT, ' +   
                  ' @cOutField04    OUTPUT, ' +   
                  ' @cOutField05    OUTPUT, ' +    
                  ' @cOutField06    OUTPUT, ' +   
                  ' @cOutField07    OUTPUT, ' +    
                  ' @cOutField08    OUTPUT, ' +    
                  ' @cOutField09    OUTPUT, ' +    
                  ' @cOutField10    OUTPUT, ' +   
                  ' @cOutField11    OUTPUT, ' +   
                  ' @cOutField12    OUTPUT, ' +   
                  ' @cOutField13    OUTPUT, ' +   
                  ' @cOutField14    OUTPUT, ' +   
                  ' @cOutField15    OUTPUT, ' +   
                  ' @nErrNo         OUTPUT, ' +  
                  ' @cErrMsg        OUTPUT '  
  
               SET @cSQLParam =  
                  ' @nMobile        INT,           ' +   
                  ' @nFunc          INT,           ' +   
                  ' @cLangCode      NVARCHAR( 3),  ' +   
                  ' @nStep          INT,           ' +   
                  ' @nInputKey      INT,           ' +   
                  ' @cFacility      NVARCHAR( 5),  ' +   
                  ' @cStorerKey     NVARCHAR( 15), ' +     
                  ' @cStation       NVARCHAR( 10), ' +  
                  ' @cMethod        NVARCHAR( 10), ' +    
                  ' @cSKU           NVARCHAR( 20), ' +     
                  ' @cLoc           NVARCHAR( 10), ' +  
                  ' @cLight         NVARCHAR( 1),  ' +        
                  ' @nCurrentPage   INT            , ' +   
                  ' @cOutField01    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField02    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField03    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField04    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField05    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField06    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField07    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField08    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField09    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField10    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField11    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField12    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField13    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField14    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @cOutField15    NVARCHAR( 60)  OUTPUT, ' +  
                  ' @nErrNo         INT            OUTPUT, ' +   
                  ' @cErrMsg        NVARCHAR(250)  OUTPUT  '  
              
               EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                  @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight,  
                  @nCurrentPage  ,  
                  @cOutField01   OUTPUT,  
                  @cOutField02   OUTPUT,  
                  @cOutField03   OUTPUT,  
                  @cOutField04   OUTPUT,  
                  @cOutField05   OUTPUT,  
                  @cOutField06   OUTPUT,  
                  @cOutField07   OUTPUT,  
                  @cOutField08   OUTPUT,  
                  @cOutField09   OUTPUT,  
                  @cOutField10   OUTPUT,  
                  @cOutField11   OUTPUT,  
                  @cOutField12   OUTPUT,  
                  @cOutField13   OUTPUT,  
                  @cOutField14   OUTPUT,  
                  @cOutField15   OUTPUT,  
                  @nErrNo        OUTPUT,  
                  @cErrMsg       OUTPUT  
               IF @nErrNo <> 0  
                  GOTO Step_3_Fail  
            END  
         END  
           
         SET @nScn = @nScn + 3     
         SET @nStep = @nStep + 3  
      END  
   END  
  
   IF @nInputKey = 0  
   BEGIN  
      -- EventLog  
      EXEC RDT.rdt_STD_EventLog  
         @cActionType = '9', -- Sign-out  
         @cUserID     = @cUserName,  
         @nMobileNo   = @nMobile,  
         @nFunctionID = @nFunc,  
         @cFacility   = @cFacility,  
         @cStorerKey  = @cStorerkey  
  
      -- Back to main menu  
      SET @nFunc = @nMenu  
      SET @nScn  = @nMenu  
      SET @nStep = 0  
      SET @cOutField01 = ''  
      SET @cOutField02 = ''  
   END  
END  
GOTO QUIT  
  
/********************************************************************************  
Step 2. Scn = 5941.  
   Station  (Field01)  
  SKU      (Field02, input)  
********************************************************************************/  
Step_2:  
BEGIN  
   IF @nInputKey = 1 --ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cBarcode = @cInField02 -- SKU  
      SET @cUPC = LEFT( @cInField02, 30)  
  
      -- Check blank  
  IF @cBarcode = ''  
      BEGIN  
         SET @nErrNo = 172256  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need SKU  
         GOTO Step_2_Fail  
      END  
     
      -- Decode  
      IF @cDecodeSP <> ''  
      BEGIN  
         -- Standard decode  
         IF @cDecodeSP = '1'  
         BEGIN  
            EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,   
               @cUPC    = @cUPC     OUTPUT,   
               @nErrNo  = @nErrNo   OUTPUT,   
               @cErrMsg = @cErrMsg  OUTPUT  
         END  
           
         -- Customize decode  
         ELSE IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cDecodeSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cDecodeSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cBarcode, ' +  
               ' @cUPC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
            SET @cSQLParam =  
               ' @nMobile      INT,           ' +  
               ' @nFunc        INT,           ' +  
               ' @cLangCode    NVARCHAR( 3),  ' +  
               ' @nStep        INT,           ' +  
               ' @nInputKey    INT,           ' +  
               ' @cFacility    NVARCHAR( 5),  ' +  
               ' @cStorerKey   NVARCHAR( 15), ' +  
               ' @cStation     NVARCHAR( 10), ' +  
               ' @cMethod      NVARCHAR( 10), ' +  
               ' @cBarcode     NVARCHAR( 60), ' +  
               ' @cUPC         NVARCHAR( 30)  OUTPUT, ' +  
               ' @nErrNo       INT            OUTPUT, ' +  
               ' @cErrMsg      NVARCHAR( 20)  OUTPUT'  
  
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cBarcode,   
               @cUPC OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
  
            IF @nErrNo <> 0  
               GOTO Step_2_Fail  
         END  
      END  
  
      -- Get SKU count  
      DECLARE @nSKUCnt INT  
      SET @nSKUCnt = 0  
      EXEC RDT.rdt_GetSKUCNT  
          @cStorerKey  = @cStorerKey  
         ,@cSKU        = @cUPC  
         ,@nSKUCnt     = @nSKUCnt   OUTPUT  
         ,@bSuccess    = @bSuccess  OUTPUT  
         ,@nErr        = @nErrNo    OUTPUT  
         ,@cErrMsg     = @cErrMsg   OUTPUT  
  
      -- Check SKU valid  
      IF @nSKUCnt = 0  
      BEGIN  
         SET @nErrNo = 172257  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU  
         GOTO Step_2_Fail  
      END  
  
      IF @nSKUCnt = 1  
         EXEC rdt.rdt_GetSKU  
             @cStorerKey  = @cStorerKey  
            ,@cSKU        = @cUPC      OUTPUT  
            ,@bSuccess    = @bSuccess  OUTPUT  
            ,@nErr        = @nErrNo    OUTPUT  
            ,@cErrMsg     = @cErrMsg   OUTPUT  
  
      -- Check barcode return multi SKU  
      IF @nSKUCnt > 1  
      BEGIN  
         SET @nErrNo = 172258  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiSKUBarcod  
         GOTO Step_2_Fail  
      END  
      SET @cSKU = @cUPC  
        
      --IF NOT EXISTS (SELECT TOP 1 1   
      --               FROM rdt.rdtPTLPieceLog PTL WITH (NOLOCK)   
      --               JOIN PickDetail PD WITH (NOLOCK) WITH (PD.OrderKey = PTL.OrderKey)  
      --               WHERE PTL.Station = @cStation   
      --               AND PD.SKU = @cSKU   
      --               AND BatchKey = @cBatchKey)  
      --BEGIN  
      -- SET @nErrNo = 172259  
      --   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoTaskAssigned  
      --   GOTO Step_2_Fail  
      --END  
  
   --Get statistic  
      IF @cGetStatSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cGetStatSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetStatSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight,  ' +  
               ' @nCurrentPage   , ' +  
               ' @cOutField01    OUTPUT, ' +  
               ' @cOutField02    OUTPUT, ' +   
               ' @cOutField03    OUTPUT, ' +   
               ' @cOutField04    OUTPUT, ' +   
               ' @cOutField05    OUTPUT, ' +    
               ' @cOutField06    OUTPUT, ' +   
               ' @cOutField07    OUTPUT, ' +    
               ' @cOutField08    OUTPUT, ' +    
               ' @cOutField09    OUTPUT, ' +    
               ' @cOutField10    OUTPUT, ' +   
               ' @cOutField11    OUTPUT, ' +   
               ' @cOutField12    OUTPUT, ' +   
               ' @cOutField13    OUTPUT, ' +   
               ' @cOutField14    OUTPUT, ' +   
               ' @cOutField15    OUTPUT, ' +   
               ' @nErrNo         OUTPUT, ' +  
               ' @cErrMsg        OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +   
               ' @nFunc          INT,           ' +   
               ' @cLangCode      NVARCHAR( 3),  ' +   
               ' @nStep          INT,           ' +   
               ' @nInputKey      INT,           ' +   
               ' @cFacility      NVARCHAR( 5),  ' +   
               ' @cStorerKey     NVARCHAR( 15), ' +     
               ' @cStation       NVARCHAR( 10), ' +  
               ' @cMethod        NVARCHAR( 10), ' +    
               ' @cSKU           NVARCHAR( 20), ' +     
               ' @cLoc           NVARCHAR( 10), ' +  
               ' @cLight         NVARCHAR( 1),  ' +        
               ' @nCurrentPage   INT            , ' +   
               ' @cOutField01    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField02    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField03    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField04    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField05    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField06    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField07    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField08    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField09    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField10    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField11    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField12    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField13    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField14    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField15    NVARCHAR( 60)  OUTPUT, ' +  
               ' @nErrNo         INT            OUTPUT, ' +   
               ' @cErrMsg        NVARCHAR(250)  OUTPUT  '  
              
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight,  
               @nCurrentPage  ,  
               @cOutField01   OUTPUT,  
               @cOutField02   OUTPUT,  
               @cOutField03   OUTPUT,  
               @cOutField04   OUTPUT,  
               @cOutField05   OUTPUT,  
               @cOutField06   OUTPUT,  
               @cOutField07   OUTPUT,  
               @cOutField08   OUTPUT,  
               @cOutField09   OUTPUT,  
               @cOutField10   OUTPUT,  
               @cOutField11   OUTPUT,  
               @cOutField12   OUTPUT,  
               @cOutField13   OUTPUT,  
               @cOutField14   OUTPUT,  
               @cOutField15   OUTPUT,  
               @nErrNo        OUTPUT,  
               @cErrMsg       OUTPUT  
            IF @nErrNo <> 0  
               GOTO Step_2_Fail  
         END  
      END  
  
      ---- Prepare next screen var  
      --SET @cOutField01 = @cResult01  
      --SET @cOutField02 = @cResult02  
      --SET @cOutField03 = @cResult03  
      --SET @cOutField04 = @cResult04  
      --SET @cOutField05 = @cResult05  
      --SET @cOutField06 = @cResult06  
      --SET @cOutField07 = @cResult07  
      --SET @cOutField08 = @cResult08  
      --SET @cOutField09 = @cResult09  
      --SET @cOutField10 = @cResult10  
      --SET @cOutField11 = @cResult11  
      --SET @cOutField12 = @cResult12  
      --SET @cOutField12 = @cResult13  
        
      -- goto statistic screen  
      SET @nFromScn = @nScn  
      SET @nFromStep = @nStep  
      SET @nScn = @nScn + 2  
      SET @nStep = @nStep + 2   
        
   END  
  
   IF @nInputKey = 0  
   BEGIN  
    SET @cOutField01 = ''  
      SET @cOutField02 = ''  
        
    -- back to station,method screen  
      SET @nScn = @nScn - 1  
      SET @nStep = @nStep - 1    
   END  
   GOTO Quit  
  
   Step_2_Fail:  
   BEGIN  
      -- Blank the matrix   
      SET @cOutField01 = @cStation  
      SET @cOutField02 = ''  
  
   END  
END  
GOTO QUIT  
  
/********************************************************************************  
Step 3. Scn = 5942.  
   Station  (Field01)  
   LOC      (Field02, input)  
********************************************************************************/  
Step_3:  
BEGIN  
   IF @nInputKey = 1 --ENTER  
   BEGIN  
      -- Screen mapping  
      SET @cLoc = @cInField02   
  
      -- Check blank  
  IF @cLoc = ''  
      BEGIN  
         SET @nErrNo = 172260  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need Loc  
         GOTO Step_3_Fail  
      END  
        
      IF NOT EXISTS (SELECT TOP 1 1 FROM DeviceProfile WITH (NOLOCK) WHERE DeviceType = 'STATION' AND DeviceID <> '' AND DeviceID = @cStation AND Loc = @cLoc)  
      BEGIN  
         SET @nErrNo = 172261  
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Loc  
         GOTO Step_3_Fail  
      END  
      ELSE  
      BEGIN  
       SELECT   
          @cPosition = DevicePosition  
       FROM DeviceProfile WITH (NOLOCK)  
       WHERE DeviceType = 'STATION'   
       AND DeviceID <> ''   
       AND DeviceID = @cStation   
       AND Loc = @cLoc  
      END  
     
      --Get statistic  
      IF @cGetStatSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cGetStatSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetStatSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight, ' +  
               ' @nCurrentPage   , ' +  
               ' @cOutField01    OUTPUT, ' +  
               ' @cOutField02    OUTPUT, ' +   
               ' @cOutField03    OUTPUT, ' +   
               ' @cOutField04    OUTPUT, ' +   
               ' @cOutField05    OUTPUT, ' +    
               ' @cOutField06    OUTPUT, ' +   
               ' @cOutField07    OUTPUT, ' +    
               ' @cOutField08    OUTPUT, ' +    
               ' @cOutField09    OUTPUT, ' +    
               ' @cOutField10    OUTPUT, ' +   
               ' @cOutField11    OUTPUT, ' +   
               ' @cOutField12    OUTPUT, ' +   
               ' @cOutField13    OUTPUT, ' +   
               ' @cOutField14    OUTPUT, ' +   
               ' @cOutField15    OUTPUT, ' +   
               ' @nErrNo         OUTPUT, ' +  
               ' @cErrMsg        OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +   
               ' @nFunc          INT,           ' +   
               ' @cLangCode      NVARCHAR( 3),  ' +   
               ' @nStep          INT,           ' +   
               ' @nInputKey      INT,           ' +   
               ' @cFacility      NVARCHAR( 5),  ' +   
               ' @cStorerKey     NVARCHAR( 15), ' +     
               ' @cStation       NVARCHAR( 10), ' +  
               ' @cMethod        NVARCHAR( 10), ' +    
               ' @cSKU           NVARCHAR( 20), ' +     
             ' @cLoc           NVARCHAR( 10), ' +  
               ' @cLight         NVARCHAR( 1),  ' +        
               ' @nCurrentPage   INT            , ' +   
               ' @cOutField01    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField02    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField03    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField04    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField05    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField06    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField07    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField08    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField09    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField10    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField11    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField12    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField13    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField14    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField15    NVARCHAR( 60)  OUTPUT, ' +  
               ' @nErrNo         INT            OUTPUT, ' +   
               ' @cErrMsg        NVARCHAR(250)  OUTPUT  '  
              
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight,  
               @nCurrentPage  ,  
               @cOutField01   OUTPUT,  
               @cOutField02   OUTPUT,  
               @cOutField03   OUTPUT,  
               @cOutField04   OUTPUT,  
               @cOutField05   OUTPUT,  
               @cOutField06   OUTPUT,  
               @cOutField07   OUTPUT,  
               @cOutField08   OUTPUT,  
               @cOutField09   OUTPUT,  
               @cOutField10   OUTPUT,  
               @cOutField11   OUTPUT,  
               @cOutField12   OUTPUT,  
               @cOutField13   OUTPUT,  
               @cOutField14   OUTPUT,  
               @cOutField15   OUTPUT,  
               @nErrNo        OUTPUT,  
               @cErrMsg       OUTPUT  
            IF @nErrNo <> 0  
               GOTO Step_3_Fail  
         END  
      END  
  
      ---- Prepare next screen var  
      --SET @cOutField01 = @cResult01  
      --SET @cOutField02 = @cResult02  
      --SET @cOutField03 = @cResult03  
      --SET @cOutField04 = @cResult04  
      --SET @cOutField05 = @cResult05  
      --SET @cOutField06 = @cResult06  
      --SET @cOutField07 = @cResult07  
      --SET @cOutField08 = @cResult08  
      --SET @cOutField09 = @cResult09  
      --SET @cOutField10 = @cResult10  
      --SET @cOutField11 = @cResult11  
      --SET @cOutField12 = @cResult12  
      --SET @cOutField12 = @cResult13  
        
      -- goto statistic screen  
      SET @nFromScn = @nScn  
      SET @nFromStep = @nStep  
      SET @nScn = @nScn + 1  
      SET @nStep = @nStep + 1   
        
   END  
  
   IF @nInputKey = 0  
   BEGIN  
    SET @cOutField01 = ''  
      SET @cOutField02 = ''  
        
    -- back to station,method screen  
      SET @nScn = @nScn - 2  
      SET @nStep = @nStep - 2    
   END  
   GOTO Quit  
  
   Step_3_Fail:  
   BEGIN  
      -- Blank the matrix   
      SET @cOutField01 = @cStation  
      SET @cOutField02 = ''  
  
   END  
END  
GOTO QUIT  
  
/********************************************************************************  
Step 4. Scn = 5942. Statistics screen  
   Result01 (Field01)  
   Result02 (Field02)  
   Result03 (Field03)  
   Result04 (Field04)  
   Result05 (Field05)  
   Result06 (Field06)  
   Result07 (Field07)  
   Result08 (Field08)  
   Result09 (Field09)  
   Result10 (Field10)  
   Result11 (Field11)  
   Result12 (Field12)  
   Result13 (Field13)  
********************************************************************************/  
Step_4:  
BEGIN  
   IF @nInputKey = 1 --ENTER  
   BEGIN  
    SET @nCurrentPage = @nCurrentPage + 1  
      --Get statistic  
      IF @cGetStatSP <> ''  
      BEGIN  
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cGetStatSP AND type = 'P')  
         BEGIN  
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cGetStatSP) +  
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight, ' +  
               ' @nCurrentPage   , ' +  
               ' @cOutField01    OUTPUT, ' +  
               ' @cOutField02    OUTPUT, ' +   
               ' @cOutField03    OUTPUT, ' +   
               ' @cOutField04    OUTPUT, ' +   
               ' @cOutField05    OUTPUT, ' +    
               ' @cOutField06    OUTPUT, ' +   
               ' @cOutField07    OUTPUT, ' +    
               ' @cOutField08    OUTPUT, ' +    
               ' @cOutField09    OUTPUT, ' +    
               ' @cOutField10    OUTPUT, ' +   
               ' @cOutField11    OUTPUT, ' +   
               ' @cOutField12    OUTPUT, ' +   
               ' @cOutField13    OUTPUT, ' +   
               ' @cOutField14    OUTPUT, ' +   
               ' @cOutField15    OUTPUT, ' +   
               ' @nErrNo         OUTPUT, ' +  
               ' @cErrMsg        OUTPUT '  
  
            SET @cSQLParam =  
               ' @nMobile        INT,           ' +   
               ' @nFunc          INT,           ' +   
               ' @cLangCode      NVARCHAR( 3),  ' +   
               ' @nStep          INT,           ' +   
               ' @nInputKey      INT,           ' +   
               ' @cFacility      NVARCHAR( 5),  ' +   
               ' @cStorerKey     NVARCHAR( 15), ' +     
               ' @cStation       NVARCHAR( 10), ' +  
               ' @cMethod        NVARCHAR( 10), ' +    
               ' @cSKU           NVARCHAR( 20), ' +     
               ' @cLoc           NVARCHAR( 10), ' +  
               ' @cLight         NVARCHAR( 1),  ' +        
               ' @nCurrentPage   INT            , ' +   
               ' @cOutField01    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField02    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField03    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField04    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField05    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField06    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField07    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField08    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField09    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField10    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField11    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField12    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField13    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField14    NVARCHAR( 60)  OUTPUT, ' +  
               ' @cOutField15    NVARCHAR( 60)  OUTPUT, ' +  
               ' @nErrNo         INT            OUTPUT, ' +   
               ' @cErrMsg        NVARCHAR(250)  OUTPUT  '  
              
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerKey, @cStation, @cMethod, @cSKU, @cLoc, @cLight,  
               @nCurrentPage  ,  
               @cOutField01   OUTPUT,  
               @cOutField02   OUTPUT,  
               @cOutField03   OUTPUT,  
               @cOutField04   OUTPUT,  
               @cOutField05   OUTPUT,  
               @cOutField06   OUTPUT,  
               @cOutField07   OUTPUT,  
               @cOutField08   OUTPUT,  
               @cOutField09   OUTPUT,  
               @cOutField10   OUTPUT,  
               @cOutField11   OUTPUT,  
               @cOutField12   OUTPUT,  
               @cOutField13   OUTPUT,  
               @cOutField14   OUTPUT,  
               @cOutField15   OUTPUT,  
               @nErrNo        OUTPUT,  
               @cErrMsg       OUTPUT  
            IF @nErrNo <> 0  
               GOTO Step_4_Fail  
         END  
      END  
  
      ---- Prepare next screen var  
      --SET @cOutField01 = @cResult01  
      --SET @cOutField02 = @cResult02  
      --SET @cOutField03 = @cResult03  
      --SET @cOutField04 = @cResult04  
      --SET @cOutField05 = @cResult05  
      --SET @cOutField06 = @cResult06  
      --SET @cOutField07 = @cResult07  
      --SET @cOutField08 = @cResult08  
      --SET @cOutField09 = @cResult09  
      --SET @cOutField10 = @cResult10  
      --SET @cOutField11 = @cResult11  
      --SET @cOutField12 = @cResult12  
      --SET @cOutField12 = @cResult13  
        
   END  
  
   IF @nInputKey = 0  
   BEGIN  
       --Off all lights  
      IF @cLight = '1'  
      BEGIN  
         --Clear light  
         EXEC PTL.isp_PTL_TerminateModule  
             @cStorerKey  
            ,@nFunc  
            ,@cStation  
            ,'STATION'  
            ,@bSuccess    OUTPUT  
            ,@nErrNo      --OUTPUT -- Prevent PTL overwrite RDT error  
            ,@cErrMsg     --OUTPUT -- Prevent PTL overwrite RDT error  
         IF @nErrNo <> 0  
            GOTO Quit  
      END  
      
      SET @nCurrentPage = 0  
      SET @nScn = @nFromScn  
      SET @nStep = @nFromStep    
   END  
   GOTO Quit  
  
   Step_4_Fail:  
   BEGIN  
      -- Blank the matrix   
      SET @cOutField01 = ''  
      SET @cOutField02 = ''  
      SET @cOutField03 = ''  
      SET @cOutField04 = ''  
      SET @cOutField05 = ''  
      SET @cOutField06 = ''  
      SET @cOutField07 = ''  
      SET @cOutField08 = ''  
      SET @cOutField09 = ''  
      SET @cOutField10 = ''  
      SET @cOutField11 = ''  
      SET @cOutField12 = ''  
      SET @cOutField13 = ''  
  
      -- Off all lights  
      IF @cLight = '1'  
      BEGIN  
         -- Clear light  
         EXEC PTL.isp_PTL_TerminateModule  
             @cStorerKey  
            ,@nFunc  
            ,@cStation  
            ,'STATION'  
            ,@bSuccess    OUTPUT  
            ,@nErrNo      --OUTPUT -- Prevent PTL overwrite RDT error  
            ,@cErrMsg     --OUTPUT -- Prevent PTL overwrite RDT error  
         IF @nErrNo <> 0  
            GOTO Quit  
      END  
   END  
END  
GOTO QUIT  
  
/********************************************************************************  
Quit. Update back to I/O table, ready to be pick up by JBOSS  
********************************************************************************/  
Quit:  
  
BEGIN  
   UPDATE RDTMOBREC WITH (ROWLOCK) SET  
      EditDate = GETDATE(),   
      ErrMsg = @cErrMsg,  
      Func   = @nFunc,  
      Step   = @nStep,  
      Scn    = @nScn,  
  
      StorerKey = @cStorerKey,  
      Facility  = @cFacility,  
      Printer   = @cPrinter,  
      InputKey  = @nInputKey,  
  
      V_SKU      = @cSKU,  
        
      V_Integer1 = @nFromScn,  
      V_Integer2 = @nFromStep,  
  
      V_String1  = @cStation,  
      V_String2  = @cMethod,  
      V_String3  = @cIPAddress,  
      V_String4  = @cPosition,  
      V_String5  = @cLoc,  
      V_String6  = @cWaveKey,  
      V_String7  = @cBatchKey,  
      V_String8  = @cDecodeSP,  
      V_String9  = @cLight,  
      V_String10 = @cGetStatSP,  
        
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

GRANT EXECUTE ON [RDT].[rdtfnc_PTLPieceAudit] to nSQL
GO
