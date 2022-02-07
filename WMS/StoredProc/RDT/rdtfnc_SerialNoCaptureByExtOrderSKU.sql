if exists (select * from sys.objects where object_id = object_id(N'[rdt].[rdtfnc_SerialNoCaptureByExtOrderSKU]') and OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdtfnc_SerialNoCaptureByExtOrderSKU]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdtfnc_SerialNoCaptureByExtOrderSKU                 */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Serial no capture by ext orderkey + sku                     */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 16-Mar-2016 1.0  James      SOS365632 Created                        */
/* 12-May-2016 1.1  James      Check serialno for valid format (james01)*/
/* 30-Sep-2016 1.2  Ung        Performance tuning                       */   
/* 17-Oct-2018 1.3  Gan        Performance tuning                       */
/************************************************************************/

CREATE PROC RDT.rdtfnc_SerialNoCaptureByExtOrderSKU (
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR(1024) OUTPUT
)
AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF  

DECLARE @b_Success   INT,
        @n_Err       INT,
        @c_ErrMsg    NVARCHAR( 20)
        
-- RDT.RDTMobRec variable
DECLARE
   @nFunc               INT,
   @nScn                INT,
   @nStep               INT,
   @cLangCode           NVARCHAR( 3),
   @nInputKey           INT,
   @nMenu               INT,

   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),

   @cOrderKey           NVARCHAR( 10),
	@cSKU                NVARCHAR( 20),
	@cActSKU             NVARCHAR( 20),
	@cExtOrderKey        NVARCHAR( 30),
	@cUserName           NVARCHAR( 18),
	@cSKUDescr           NVARCHAR( 60),
	@cSerialNo           NVARCHAR( 20),
	@cSerialNoKey        NVARCHAR( 10),
	@cOrderLineNumber    NVARCHAR( 5),
   @nOriQty             INT,
   @nExpQty             INT,
   @nActQty             INT,
   @nSKUCnt             INT,
   @bSuccess            INT,

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
   @cUserName  = UserName,
   
   @cStorerKey = StorerKey,
   @cFacility  = Facility,
   @cOrderKey  = V_OrderKey,
   @cSKU       = V_SKU,   
   @cSKUDescr  = V_SKUDescr,      

   @cExtOrderKey = V_String1, 
  -- @nOriQty      = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String2, 5), 0) = 1 THEN LEFT( V_String2, 5) ELSE 0 END, 
  -- @nExpQty      = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String3, 5), 0) = 1 THEN LEFT( V_String3, 5) ELSE 0 END, 
  -- @nActQty      = CASE WHEN rdt.rdtIsValidQTY( LEFT( V_String4, 5), 0) = 1 THEN LEFT( V_String4, 5) ELSE 0 END, 
   @cSerialNo    = V_String5, 
   
   @nOriQty      = V_Integer1,
   @nExpQty      = V_Integer2,
   @nActQty      = V_Integer3,

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
FROM rdt.RDTMOBREC (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 878 -- Serial no capture
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Func = Serial no capture
   IF @nStep = 1 GOTO Step_1   -- 4530 COUNT #
   IF @nStep = 2 GOTO Step_2   -- 4531 COUNT #, LOC
END

RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 878. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   SET @nScn = 4530
   SET @nStep = 1

   -- Initiate var
   SET @cExtOrderKey = ''
   SET @cSKU = ''

   -- EventLog - Sign In Function
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1', -- Sign in function
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerkey,
      @nStep       = @nStep
END
GOTO Quit


/********************************************************************************
Step 1. Screen = 4530
   EXT ORDER KEY  (Field01, input)
   SKU            (Field02, input)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cExtOrderKey = @cInField01
      SET @cActSKU = @cInField02

      IF ISNULL( @cExtOrderKey, '')  = ''
      BEGIN
         SET @nErrNo = 97551
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'EXT ORDKEY REQ'
         GOTO Step_1a_Fail
      END

      SET @cOrderKey = ''
      SELECT @cOrderKey = OrderKey
      FROM dbo.Orders WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   ExternOrderKey = @cExtOrderKey

      IF ISNULL( @cOrderKey, '') = ''
      BEGIN
         SET @nErrNo = 97552
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'INV EXT ORDKEY'
         GOTO Step_1a_Fail
      END

      IF ISNULL(@cActSKU, '') = ''
      BEGIN
         SET @nErrNo = 97553
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SKU req
         GOTO Step_1b_Fail
      END

      EXEC [RDT].[rdt_GETSKUCNT]
         @cStorerKey  = @cStorerKey,
         @cSKU        = @cActSKU,
         @nSKUCnt     = @nSKUCnt       OUTPUT,
         @bSuccess    = @bSuccess      OUTPUT,
         @nErr        = @nErrNo        OUTPUT,
         @cErrMsg     = @cErrMsg       OUTPUT

      IF @nSKUCnt = 0
      BEGIN
         SET @nErrNo = 97554
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid SKU
         GOTO Step_1b_Fail
      END

      -- Validate barcode return multiple SKU
      IF @nSKUCnt > 1
      BEGIN
         SET @nErrNo = 97555
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --MultiBarcodeSKU
         GOTO Step_1b_Fail
      END

      EXEC [RDT].[rdt_GETSKU]
         @cStorerKey  = @cStorerkey,
         @cSKU        = @cActSKU       OUTPUT,
         @bSuccess    = @bSuccess      OUTPUT,
         @nErr        = @nErrNo        OUTPUT,
         @cErrMsg     = @cErrMsg       OUTPUT

      SET @cSKU = @cActSKU

      IF NOT EXISTS ( SELECT 1 
                      FROM dbo.Orders O WITH (NOLOCK)
                      JOIN dbo.OrderDetail OD WITH (NOLOCK) 
                         ON ( O.OrderKey = OD.OrderKey AND O.StorerKey = OD.StorerKey)
                      WHERE O.StorerKey = @cStorerKey
                      AND   O.ExternOrderKey = @cExtOrderKey
                      AND   OD.SKU = @cSKU)
      BEGIN
         SET @nErrNo = 97556
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NO RECORD
         GOTO Step_1_Fail
      END

      SELECT @cSKUDescr = DESCR
      FROM dbo.SKU WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey
      AND   SKU = @cSKU

      SET @nOriQty = 0
      SET @nExpQty = 0
      SET @nActQty = 0

      SELECT @nOriQty = OriginalQty
      FROM dbo.OrderDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   OrderKey = @cOrderKey
      AND   SKU = @cSKU

      SELECT @nExpQty = ISNULL( Sum( CAST( OD.Userdefine01 AS INT)), 0)
      FROM dbo.Orders O WITH (NOLOCK)
      JOIN dbo.OrderDetail OD WITH (NOLOCK) ON ( O.OrderKey = OD.OrderKey AND O.StorerKey = OD.StorerKey)
      WHERE O.StorerKey = @cStorerKey
      AND   O.ExternOrderKey = @cExtOrderKey
      AND   OD.SKU = @cSKU
      GROUP BY OD.ExternOrderKey, OD.SKU

      SELECT @nActQty = ISNULL( SUM( Qty), 0)
      FROM dbo.SerialNo WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey
      AND   OrderKey = @cOrderKey
      AND   SKU = @cSKU
      GROUP BY OrderKey, SKU

      IF @nExpQty > @nActQty
      BEGIN
         SET @cOutField01 = @cExtOrderKey
         SET @cOutField02 = @cSKU
         SET @cOutField03 = SUBSTRING( @cSKUDescr, 1, 20)
         SET @cOutField04 = SUBSTRING( @cSKUDescr, 21, 20)
         SET @cOutField05 = ''
         SET @cOutField06 = @nOriQty
         SET @cOutField07 = @nExpQty
         SET @cOutField08 = @nActQty
         SET @nScn = @nScn + 1                
         SET @nStep = @nStep + 1                
      END
      ELSE
      BEGIN
         SET @nErrNo = 97557
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'EXP > ACT QTY'
         GOTO Step_2_Fail
      END
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
     -- EventLog - Sign Out Function
     EXEC RDT.rdt_STD_EventLog
       @cActionType = '9', -- Sign Out function
       @cUserID     = @cUserName,
       @nMobileNo   = @nMobile,
       @nFunctionID = @nFunc,
       @cFacility   = @cFacility,
       @cStorerKey  = @cStorerkey,
       @nStep       = @nStep

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = '' -- Clean up for menu option
   END
   GOTO Quit

   Step_1_Fail:
   BEGIN
      SET @cOutField01 = ''
      SET @cOutField02 = ''
      
      SET @cExtOrderKey = ''
      SET @cSKU = ''
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO Quit
   END

   Step_1a_Fail:
   BEGIN
      SET @cOutField01 = ''
      SET @cOutField02 = @cSKU
      
      SET @cExtOrderKey = ''
      EXEC rdt.rdtSetFocusField @nMobile, 1
      GOTO Quit
   END

   Step_1b_Fail:
   BEGIN
      SET @cOutField01 = @cExtOrderKey
      SET @cOutField02 = ''
      
      SET @cSKU = ''
      EXEC rdt.rdtSetFocusField @nMobile, 2
      GOTO Quit
   END
END
GOTO Quit

/********************************************************************************
Step 2. Screen = 4461
   SERIAL NO      (Field05, input)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Screen mapping
      SET @cSerialNo = @cInField05

       -- Validate location
      IF ISNULL( @cSerialNo, '') = '' 
      BEGIN
         SET @nErrNo = 97558
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Serial # req'
         GOTO Step_2_Fail
      END

      -- Check barcode format (james01)
      IF rdt.rdtIsValidFormat( @nFunc, @cStorerKey, 'SERIAL', @cSerialNo) = 0
      BEGIN
         SET @nErrNo = 97562
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Inv serial no
         GOTO Step_2_Fail
      END

      IF EXISTS ( SELECT 1 FROM dbo.SerialNo WITH (NOLOCK) 
                  WHERE StorerKey = @cStorerKey
                  AND   OrderKey = @cOrderKey
                  AND   SerialNo = @cSerialNo)
      BEGIN
         SET @nErrNo = 97559
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Duplicate rec'
         GOTO Step_2_Fail
      END

      SELECT TOP 1 @cOrderLineNumber = OrderLineNumber
      FROM dbo.Orders O WITH (NOLOCK) 
      JOIN dbo.OrderDetail OD WITH (NOLOCK) ON ( O.OrderKey = OD.OrderKey AND O.StorerKey = OD.StorerKey)
      WHERE O.StorerKey = @cStorerKey
      AND   O.ExternOrderKey = @cExtOrderKey
      AND   OD.SKU = @cSKU
      
      -- Get SerialNoKey
      EXECUTE dbo.nspg_GetKey
         'SerialNo',
         10 ,
         @cSerialNoKey OUTPUT,
         @b_success    OUTPUT,
         @n_err        OUTPUT,
         @c_errmsg     OUTPUT

      IF @b_success <> 1
      BEGIN
         SET @nErrNo = 97560
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Get key fail
         GOTO Quit
      END
   
      INSERT INTO dbo.SerialNo (SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, QTY)
      VALUES (@cSerialNoKey, @cOrderKey, @cOrderLineNumber, @cStorerKey, @cSKU, @cSerialNo, 1)

      IF @@ERROR <> 0
      BEGIN
         SET @nErrNo = 97561
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins rec fail
         GOTO Quit
      END

      SET @nExpQty = 0
      SET @nActQty = 0

      SELECT @nExpQty = ISNULL( Sum( CAST( OD.Userdefine01 AS INT)), 0)
      FROM dbo.Orders O WITH (NOLOCK)
      JOIN dbo.OrderDetail OD WITH (NOLOCK) ON ( O.OrderKey = OD.OrderKey AND O.StorerKey = OD.StorerKey)
      WHERE O.StorerKey = @cStorerKey
      AND   O.ExternOrderKey = @cExtOrderKey
      AND   OD.SKU = @cSKU
      GROUP BY OD.ExternOrderKey, OD.SKU

      SELECT @nActQty = ISNULL( SUM( Qty), 0)
      FROM dbo.SerialNo WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey
      AND   OrderKey = @cOrderKey
      AND   SKU = @cSKU
      GROUP BY OrderKey, SKU

      IF @nExpQty > @nActQty
      BEGIN
         SET @cOutField01 = @cExtOrderKey
         SET @cOutField02 = @cSKU
         SET @cOutField03 = SUBSTRING( @cSKUDescr, 1, 20)
         SET @cOutField04 = SUBSTRING( @cSKUDescr, 21, 20)
         SET @cOutField05 = ''
         SET @cOutField06 = @nOriQty
         SET @cOutField07 = @nExpQty
         SET @cOutField08 = @nActQty
      END
      ELSE
      BEGIN
         SET @cOutField01 = ''
         SET @cOutField02 = ''

         SET @nScn = @nScn - 1                
         SET @nStep = @nStep - 1                
      END         
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      SET @cOutField01 = ''
      SET @cOutField02 = ''

      EXEC rdt.rdtSetFocusField @nMobile, 1

      -- Go back screen 1
      SET @nScn  = @nScn - 1
      SET @nStep = @nStep - 1
   END
   GOTO Quit

   Step_2_Fail:
   BEGIN
      SET @cSerialNo = ''
      SET @cOutField05 = ''
   END
END
GOTO Quit

/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK) SET
      EditDate = GETDATE(), 
      ErrMsg = @cErrMsg,
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      StorerKey = @cStorerKey,
      Facility  = @cFacility,
      -- UserName  = @cUserName,
      
      V_OrderKey = @cOrderKey,
      V_SKU = @cSKU, 
      V_SKUDescr = @cSKUDescr, 

      V_String1 = @cExtOrderKey, 
      --V_String2 = @nOriQty, 
      --V_String3 = @nExpQty, 
      --V_String4 = @nActQty, 
      V_String5 = @cSerialNo, 
      
      V_Integer1 = @nOriQty,
      V_Integer2 = @nExpQty,
      V_Integer3 = @nActQty,

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

GRANT EXECUTE ON RDT.rdtfnc_SerialNoCaptureByExtOrderSKU TO NSQL
GO
