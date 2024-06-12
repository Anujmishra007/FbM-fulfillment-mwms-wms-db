
/****** Object:  StoredProcedure [RDT].[rdt_593PrintPLWgt01]    Script Date: 6/5/2024 11:00:11 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593PrintPLWeight01                                    */
/*                                                                            */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2024-05-31 1.0  Bruce      UWP-20408 Created                               */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593PrintPLWgt01] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 1),
   @cParam1    NVARCHAR(20),  -- PalletWeight
   @cParam2    NVARCHAR(20),  -- PalletQty
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success      INT
   DECLARE @n_Err          INT
   DECLARE @c_ErrMsg       NVARCHAR( 250)
   DECLARE @cLabelPrinter  NVARCHAR( 10)
   DECLARE @cDataWindow   NVARCHAR( 50)
   DECLARE @cTargetDB     NVARCHAR( 20)

   DECLARE @cPalletWeight  NVARCHAR( 20)
   DECLARE @cPalletQty     NVARCHAR( 20)
   DECLARE @cID            NVARCHAR( 18)
   DECLARE @c_cnt          INT
   DECLARE @c_weight       FLOAT
   DECLARE @c_RemainWeight FLOAT
   DECLARE @cEmpltyPalletChar NVARCHAR(1)

   -- Parameter mapping
   SET @cPalletWeight = @cParam1
   SET @cPalletQty    = @cParam2
   SET @cDataWindow   = ''
   SET @cTargetDB     = ''

   -- Check blank
   IF @cPalletWeight = ''
   BEGIN
      SET @nErrNo = 60896
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') 
      GOTO Quit
   END

   IF @cPalletQty = '' OR TRY_CAST(@cPalletQty as INT) IS NULL
   BEGIN
      SET @nErrNo = 107701
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') 
      GOTO Quit
   END
   
   -- Get login info
   SELECT @cLabelPrinter = Printer
   FROM rdt.rdtMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Check data window blank
   IF @cLabelPrinter = ''
   BEGIN
      SET @nErrNo = 108452
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoLabelPrinter
      GOTO Quit
   END

   SELECT  
      @cDataWindow = ISNULL(RTRIM(DataWindow), ''),  
      @cTargetDB = ISNULL(RTRIM(TargetDB), '')  
   FROM RDT.RDTReport WITH (NOLOCK)  
   WHERE StorerKey = @cStorerKey  
      AND ReportType ='EMPTYLPWGT'  
  
   -- Check data window  
   IF ISNULL(@cDataWindow, '') = ''  
   BEGIN  
      SET @nErrNo = 93161  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DWNOTSetup  
      GOTO Quit  
   END  
  
   -- Check database  
   IF ISNULL(@cTargetDB, '') = ''  
   BEGIN  
      SET @nErrNo = 93162  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --TgetDB Not Set  
      GOTO Quit  
   END  

   SET @c_cnt = 0
   SET @c_RemainWeight = @cPalletWeight
   WHILE(@c_cnt < @cPalletQty)
   BEGIN
      EXECUTE dbo.nspg_GetKey
               'BTSLP',
               5 ,
               @cID               OUTPUT,
               @b_success         OUTPUT,
               @n_err             OUTPUT,
               @c_errmsg          OUTPUT
      IF @b_success <> 1
      BEGIN
         SET @nErrNo = 59418
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
         GOTO Quit
      END

      SET @cEmpltyPalletChar = rdt.RDTGetConfig( @nFunc, 'EmptyPalletChar', @cStorerKey)
      IF @cEmpltyPalletChar = '0' SET @cEmpltyPalletChar = 'A'

      IF @cID = '99999'
      BEGIN
         DELETE nCounter WHERE keyname = 'BTSLP'

         UPDATE rdt.StorerConfig 
         SET SValue = CHAR(ASCII(SValue) + 1 ) 
         WHERE ConfigKey = 'EmptyPalletChar' 
            AND StorerKey = @cStorerKey 
            AND function_id = @nFunc
      END

      IF @cPalletQty = @c_cnt + 1
      BEGIN
         SELECT @c_weight = @c_RemainWeight
      END
      ELSE
      BEGIN
         SELECT @c_weight = FLOOR(CAST(@cPalletWeight AS FLOAT) / CAST(@cPalletQty AS INT ))

         SELECT @c_RemainWeight = @c_RemainWeight - @c_weight
      END

      SELECT @cID = 'BTSLP' + @cEmpltyPalletChar + @cID

      INSERT INTO PALLET (PalletKey,StorerKey,GrossWgt) VALUES (@cID,@cStorerKey,@c_weight)

      -- Insert print job
      EXEC RDT.rdt_BuiltPrintJob
         @nMobile,
         @cStorerKey,
         'EMPTYLPWGT',       -- ReportType
         'PRINT_EMPTYLPTWGT', -- PrintJobName
         @cDataWindow,
         @cLabelPrinter,
         @cTargetDB,
         @cLangCode,
         @nErrNo  OUTPUT,
         @cErrMsg OUTPUT,
         @cID,
         @c_weight
          
      SELECT @c_cnt += 1
   END -- end while

Quit:

END -- END SP
GO

GRANT EXECUTE ON  [RDT].[rdt_593PrintPLWgt01] TO [NSQL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

