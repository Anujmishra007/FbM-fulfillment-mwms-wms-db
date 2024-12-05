SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
  
/******************************************************************************/        
/* Store procedure: rdtfnc_Inbound_PalletTempCapture                          */        
/* Copyright      : Maersk                                                    */        
/*                                                                            */        
/* Purpose:  Inbound Pallet Temprature Capture                                */        
/*                                                                            */        
/* Modifications log:                                                         */        
/*                                                                            */        
/* Date         Rev  Author   Purposes                                        */        
/* 2024-12-05   1.0  JHU151   FCR-1398 Created                                */ 
/******************************************************************************/        
        
CREATE OR ALTER PROC [RDT].[rdtfnc_Inbound_PalletTempCapture](        
   @nMobile    int,        
   @nErrNo     int  OUTPUT,        
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max        
)        
AS        
        
SET NOCOUNT ON        
SET QUOTED_IDENTIFIER OFF        
SET ANSI_NULLS OFF        
SET CONCAT_NULL_YIELDS_NULL OFF  

-- RDT.RDTMobRec variables        
DECLARE        
   @nFunc          INT,        
   @nScn           INT,        
   @nStep          INT,        
   @cLangCode      NVARCHAR( 3),        
   @nInputKey      INT,        
   @nMenu          INT,        
   @bSuccess       INT,
   @cID            NVARCHAR(18),
   @cReceiptKey    NVARCHAR(10),
   @cStorerKey     NVARCHAR( 15),        
   @cUserName      NVARCHAR( 18),        
   @cFacility      NVARCHAR( 5), 
   @fTemprature    FLOAT,
   
   @nStep_ASN      INT,        
   @nStep_ID       INT,         
   @nStep_Temprature INT,          
   @nStep_Confrim    INT,  
   @nScn_ASN         INT,  
   @nScn_ID          INT, 
   @nScn_Temprature  INT,
   @nScn_Confrim     INT,

   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),  @cFieldAttr01 NVARCHAR( 1),  @cLottable01  NVARCHAR( 18),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),  @cFieldAttr02 NVARCHAR( 1),  @cLottable02  NVARCHAR( 18),     
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),  @cFieldAttr03 NVARCHAR( 1),  @cLottable03  NVARCHAR( 18),     
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),  @cFieldAttr04 NVARCHAR( 1),  @dLottable04  DATETIME,     
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),  @cFieldAttr05 NVARCHAR( 1),  @dLottable05  DATETIME,     
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60),  @cFieldAttr06 NVARCHAR( 1),  @cLottable06  NVARCHAR( 30),     
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60),  @cFieldAttr07 NVARCHAR( 1),  @cLottable07  NVARCHAR( 30),     
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60),  @cFieldAttr08 NVARCHAR( 1),  @cLottable08  NVARCHAR( 30),      
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60),  @cFieldAttr09 NVARCHAR( 1),  @cLottable09  NVARCHAR( 30),     
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60),  @cFieldAttr10 NVARCHAR( 1),  @cLottable10  NVARCHAR( 30),     
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60),  @cFieldAttr11 NVARCHAR( 1),  @cLottable11  NVARCHAR( 30),     
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60),  @cFieldAttr12 NVARCHAR( 1),  @cLottable12  NVARCHAR( 30),     
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60),  @cFieldAttr13 NVARCHAR( 1),  @dLottable13  DATETIME,     
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60),  @cFieldAttr14 NVARCHAR( 1),  @dLottable14  DATETIME,     
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60),  @cFieldAttr15 NVARCHAR( 1),  @dLottable15  DATETIME,  

   @cExtScnUDF01  NVARCHAR( 250), @cExtScnUDF02 NVARCHAR( 250), @cExtScnUDF03 NVARCHAR( 250),
   @cExtScnUDF04  NVARCHAR( 250), @cExtScnUDF05 NVARCHAR( 250), @cExtScnUDF06 NVARCHAR( 250),
   @cExtScnUDF07  NVARCHAR( 250), @cExtScnUDF08 NVARCHAR( 250), @cExtScnUDF09 NVARCHAR( 250),
   @cExtScnUDF10  NVARCHAR( 250), @cExtScnUDF11 NVARCHAR( 250), @cExtScnUDF12 NVARCHAR( 250),
   @cExtScnUDF13  NVARCHAR( 250), @cExtScnUDF14 NVARCHAR( 250), @cExtScnUDF15 NVARCHAR( 250),
   @cExtScnUDF16  NVARCHAR( 250), @cExtScnUDF17 NVARCHAR( 250), @cExtScnUDF18 NVARCHAR( 250),
   @cExtScnUDF19  NVARCHAR( 250), @cExtScnUDF20 NVARCHAR( 250), @cExtScnUDF21 NVARCHAR( 250),
   @cExtScnUDF22  NVARCHAR( 250), @cExtScnUDF23 NVARCHAR( 250), @cExtScnUDF24 NVARCHAR( 250),
   @cExtScnUDF25  NVARCHAR( 250), @cExtScnUDF26 NVARCHAR( 250), @cExtScnUDF27 NVARCHAR( 250),
   @cExtScnUDF28  NVARCHAR( 250), @cExtScnUDF29 NVARCHAR( 250), @cExtScnUDF30 NVARCHAR( 250)

-- Getting Mobile information        
SELECT        
   @nFunc            = Func,        
   @nScn             = Scn,        
   @nStep            = Step,        
   @nInputKey        = InputKey,        
   @nMenu            = Menu,        
   @cLangCode        = Lang_code,                
   @cStorerKey       = StorerKey,        
   @cFacility        = Facility,        
   @cUserName        = UserName,
   @cReceiptKey      = V_ReceiptKey,
   @cID              = V_ID,
   @fTemprature      = V_String1,

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,  @cFieldAttr01 = FieldAttr01,        
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,  @cFieldAttr02 = FieldAttr02,        
   @cInField03 = I_Field03,   @cOutField03 = O_Field03,  @cFieldAttr03 = FieldAttr03,        
   @cInField04 = I_Field04,   @cOutField04 = O_Field04,  @cFieldAttr04 = FieldAttr04,        
   @cInField05 = I_Field05,   @cOutField05 = O_Field05,  @cFieldAttr05 = FieldAttr05,        
   @cInField06 = I_Field06,   @cOutField06 = O_Field06,  @cFieldAttr06 = FieldAttr06,        
   @cInField07 = I_Field07,   @cOutField07 = O_Field07,  @cFieldAttr07 = FieldAttr07,        
   @cInField08 = I_Field08,   @cOutField08 = O_Field08,  @cFieldAttr08 = FieldAttr08,         
   @cInField09 = I_Field09,   @cOutField09 = O_Field09,  @cFieldAttr09 = FieldAttr09,        
   @cInField10 = I_Field10,   @cOutField10 = O_Field10,  @cFieldAttr10 = FieldAttr10,        
   @cInField11 = I_Field11,   @cOutField11 = O_Field11,  @cFieldAttr11 = FieldAttr11,        
   @cInField12 = I_Field12,   @cOutField12 = O_Field12,  @cFieldAttr12 = FieldAttr12,        
   @cInField13 = I_Field13,   @cOutField13 = O_Field13,  @cFieldAttr13 = FieldAttr13,        
   @cInField14 = I_Field14,   @cOutField14 = O_Field14,  @cFieldAttr14 = FieldAttr14,        
   @cInField15 = I_Field15,   @cOutField15 = O_Field15,  @cFieldAttr15 = FieldAttr15        
           
FROM rdt.rdtMobRec WITH (NOLOCK)        
WHERE Mobile = @nMobile

SELECT        
   @nStep_ASN              = 1,  @nScn_ASN            = 6530,        
   @nStep_ID               = 2,  @nScn_ID             = 6531,        
   @nStep_Temprature       = 3,  @nScn_Temprature     = 6532,        
   @nStep_Confrim          = 4,  @nScn_Confrim        = 6533


IF @nFunc = 1869        
BEGIN        
   -- Redirect to respective screen        
   IF @nStep = 0  GOTO Step_Start            -- Menu. Func = 1869
   IF @nStep = 1  GOTO Step_ASN              -- Scn = 6530. Scan ASN
   IF @nStep = 2  GOTO Step_ID               -- Scn = 6531. Scan ID
   IF @nStep = 3  GOTO Step_Temp             -- Scn = 6532. Capture Temprature        
   IF @nStep = 4  GOTO Step_Confrim          -- Scn = 6533. Confrim option
END        
        
RETURN -- Do nothing if incorrect step   

Step_Start:
BEGIN
   -- Prepare next screen var        
   SET @cOutField01 = ''     
      
   EXEC rdt.rdtSetFocusField @nMobile, 1          
           
   -- Logging        
   EXEC RDT.rdt_STD_EventLog        
      @cActionType     = '1', -- Sign-in        
      @cUserID         = @cUserName,        
      @nMobileNo       = @nMobile,        
      @nFunctionID     = @nFunc,        
      @cFacility       = @cFacility,        
      @cStorerKey      = @cStorerKey,        
      @nStep           = @nStep        
        
   -- Go to next screen        
   SET @nScn = @nScn_ASN        
   SET @nStep = @nStep_ASN

END  
GOTO Quit  


/************************************************************************************        
Scn = 6530. Scan Cart Id        
   ASN         (field01, input)               
************************************************************************************/  
Step_ASN:
BEGIN
   SET @cReceiptKey = @cInField01

   IF @cReceiptKey = ''
   BEGIN
      SET @nErrNo = 227551          
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ASN is needed          
      EXEC rdt.rdtSetFocusField @nMobile, 1          
      GOTO Quit   
   END

END
GOTO Quit

END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON RDT.rdtfnc_Inbound_PalletTempCapture TO NSQL
GO