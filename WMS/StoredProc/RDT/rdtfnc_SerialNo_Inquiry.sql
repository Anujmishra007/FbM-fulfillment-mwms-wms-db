if exists (select 1 from sys.objects where object_id = object_id(N'[RDT].[rdtfnc_SerialNo_Inquiry]') and OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdtfnc_SerialNo_Inquiry]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Copyright: IDS                                                       */
/* Purpose: inquiry the serialno information                            */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author        Purposes                               */
/* 2017/12/04     Yee Kung       3548-Initial document create           */
/* 2018/10/05     TungGH         Performance                            */
/************************************************************************/

CREATE PROC [RDT].[rdtfnc_SerialNo_Inquiry] (
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT -- screen limitation, 20 char max
)
AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF  


-- RDT.RDTMobRec variable
DECLARE 
   @nFunc      INT,
   @nScn       INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @nInputKey  INT,
   @nMenu      INT,

   @cStorerKey NVARCHAR( 15),
   @cFacility  NVARCHAR( 5), 
   @cPrinter   NVARCHAR( 10),

   @b_success  INT,
   @n_err      INT,     
   @c_errmsg   NVARCHAR( 250), 

   @cSerialNo  NVARCHAR (60),
   @cSKU       NVARCHAR (20),
   @cSKUDescr  NVARCHAR (40),
   @cID        NVARCHAR (20),

   @cExtendedInfoSP NVARCHAR(20),
   @cExtendedInfo1 NVARCHAR(20),
   @cExtendedInfo2 NVARCHAR(20),
   @cExtendedInfo3 NVARCHAR(20),
   @cExtendedInfo4 NVARCHAR(20),
   @cExtendedInfo5 NVARCHAR(20),
   @cExtendedInfo6 NVARCHAR(20),

   @cSQL          NVARCHAR(MAX),
   @cSQLParam     NVARCHAR(MAX),

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
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60)

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

   @cSKU       = V_SKU,
   @cSKUDescr  = V_SKUDescr,
   @cID        = V_ID,
   @cExtendedInfo1 = V_String1,
   @cExtendedInfo2 = V_String2,
   @cExtendedInfo3 = V_String3,
   @cExtendedInfo4 = V_String4,
   @cExtendedInfo5 = V_String5,
   @cExtendedInfo6 = V_String6,
   @cExtendedInfoSP = V_String7,
   @cSerialNo      = V_String41,
   
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

FROM RDTMOBREC (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 627 -- Serial No inquiry 
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Inquiry by serialno
   IF @nStep = 1 GOTO Step_1   -- Scn = 5090. SERIALNO
   IF @nStep = 2 GOTO Step_2   -- Scn = 5091. SERIALNO,SKU,SKUDECR,ID,STATUS
END

--RETURN -- Do nothing if incorrect step

/********************************************************************************
Step 0. func = 627. Menu
********************************************************************************/
Step_0:
BEGIN

   -- Set the entry point
   SET @nScn  = 5090
   SET @nStep = 1

   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)
   IF @cExtendedInfoSP = ' '
      SET @cExtendedInfoSP = ''

   -- Initiate var
   SET @cSerialNo = ''
   -- Init screen
   SET @cOutField01 = '' -- LOC
END
GOTO Quit

/********************************************************************************
Step 1. Scn = 5090. SERIALNO
   SERIALNO:     (field01, input)
********************************************************************************/

Step_1:
BEGIN
   IF @nInputKey = 1 --ENTER
   BEGIN
	
      --Screen Mapping
      SET @cSerialNo = @cInField01;

      --Validate Blank
      IF @cSerialNo ='' OR @cSerialNo IS NULL
      BEGIN
         SET @nErrNo  = 117601
         SET @cErrMsg = rdt.rdtgetmessage(@nErrNo,@cLangCode,'DSP') --SerialNoReq
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step1_fail
      END

      SELECT @cSKU=SKU,  @cID=ID FROM serialno WITH (NOLOCK) WHERE serialno=@cSerialNo;

      -- Validate Serial No
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo  = 117602
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'SRNoNotExist'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step1_Fail
      END
		
      SELECT @cSKUDescr=DESCR FROM SKU WITH (NOLOCK) WHERE sku=@cSKU;

      SET @cOutField01 = @cSerialNo --SerialNo  
      SET @cOutField02 = @cSKU --SKU
      SET @cOutField03 = rdt.rdtFormatString(@cSKUDescr, 1, 20) --sku decription
      SET @cOutField04 = rdt.rdtFormatString(@cSKUDescr, 21, 20)  --sku decription
      SET @cOutField05 = @cID

      SET @cExtendedInfo1 = ''
      SET @cExtendedInfo2 = ''
      SET @cExtendedInfo3 = ''
      SET @cExtendedInfo4 = ''
      SET @cExtendedInfo5 = ''
      SET @cExtendedInfo6 = ''

      IF @cExtendedInfoSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')
         BEGIN
            SET @cSQL = 
            'EXEC rdt.' + RTRIM(@cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cSKU, @cID, @cSerialNo,'+
            ' @cExtendedInfo1 OUTPUT, @cExtendedInfo2 OUTPUT, @cExtendedInfo3 OUTPUT, @cExtendedInfo4 OUTPUT, @cExtendedInfo5 OUTPUT, @cExtendedInfo6 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'

            SET @cSQLParam =
            '@nMobile        INT,'+
            '@nFunc          INT,'+ 
            '@cLangCode      NVARCHAR( 3),'+ 
            '@nStep          INT,'+ 
            '@nInputKey      INT,'+ 
            '@cStorerkey     NVARCHAR( 15),'+ 
            '@cSKU           NVARCHAR( 20),'+
            '@cID            NVARCHAR( 20),'+
            '@cSerialNo      NVARCHAR( 20),'+
            '@cExtendedInfo1 NVARCHAR( 20) OUTPUT,'+
            '@cExtendedInfo2 NVARCHAR( 20) OUTPUT,'+
            '@cExtendedInfo3 NVARCHAR( 20) OUTPUT,'+
            '@cExtendedInfo4 NVARCHAR( 20) OUTPUT,'+
            '@cExtendedInfo5 NVARCHAR( 20) OUTPUT,'+
            '@cExtendedInfo6 NVARCHAR( 20) OUTPUT,'+
            '@nErrNo         INT            OUTPUT,'+ 
            '@cErrMsg        NVARCHAR( 20)  OUTPUT' 

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                 @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cSKU, @cID,@cSerialNo
                 ,@cExtendedInfo1 OUTPUT ,@cExtendedInfo2 OUTPUT ,@cExtendedInfo3 OUTPUT
                 ,@cExtendedInfo4 OUTPUT ,@cExtendedInfo5 OUTPUT, @cExtendedInfo6 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
            
            SET @cOutField06 = @cExtendedInfo1
            SET @cOutField07 = @cExtendedInfo2
            SET @cOutField08 = @cExtendedInfo3
            SET @cOutField09 = @cExtendedInfo4
            SET @cOutField10 = @cExtendedInfo5
            SET @cOutField11 = @cExtendedInfo6
         END
      END

      -- Go to next screen
      SET @nScn  = @nScn + 1
      SET @nStep = @nStep + 1

	END

   IF @nInputKey = 0 --ESC
   BEGIN
      --go to main menu
      SET @nFunc       = @nMenu
      SET @nScn        = @nMenu
      SET @nStep       = 0
      SET @cOutField01 = '' --SerialNo
   END
   GOTO Quit

   Step1_fail:
   BEGIN
      SET @cOutField01= ''
      SET @cSerialNo  = ''
   END
END
GOTO Quit

/********************************************************************************
Step 2. Scn = 5091.
SerialNo (field1)
SKU      (field2)
SKUDescription (Field3 and Field4)
ID       (field5)
Status   (field6)
ExtendedInfo1 (field7)
ExtendedInfo2 (field8)
ExtendedInfo3 (field9)
ExtendedInfo4 (field10)
ExtendedInfo5 (field11)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare prev screen var
      SET @cSerialNo    = ' '
      SET @cOutField01  = ' ' --SerialNo
      SET @cOutField02  = ' ' --SKU
      SET @cOutField03  = ' ' --sku decription
      SET @cOutField04  = ' ' --sku decription
      SET @cOutField05  = ' ' --ID
      SET @cOutField06  = ' ' --ExtendedInfo1
      SET @cOutField07  = ' ' --ExtendedInfo2
      SET @cOutField08  = ' ' --ExtendedInfo3
      SET @cOutField09  = ' ' --ExtendedInfo4
      SET @cOutField10  = ' ' --ExtendedInfo5
      SET @cOutField11  = ' ' --ExtendedInfo6

      -- Go to prev screen
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
   END
   GOTO Quit
END
GOTO Quit

/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE RDTMOBREC WITH (ROWLOCK) SET 
      EditDate   = GETDATE(), 
      ErrMsg     = @cErrMsg, 
      Func       = @nFunc,
      Step       = @nStep,
      Scn        = @nScn,

      StorerKey  = @cStorerKey,
      Facility   = @cFacility, 
      Printer    = @cPrinter,    

      V_SKU      = @cSKU       ,
      V_SKUDescr = @cSKUDescr  ,
      V_ID       = @cID        ,
      V_String1  = @cExtendedInfo1,
      V_String2  = @cExtendedInfo2,
      V_String3  = @cExtendedInfo3,
      V_String4  = @cExtendedInfo4,
      V_String5  = @cExtendedInfo5,
      V_String6  = @cExtendedInfo6,
      V_String7  = @cExtendedInfoSP,
      V_String41 = @cSerialNo  ,
      
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdtfnc_SerialNo_Inquiry TO NSQL
GO