IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Id = Object_Id(N'[RDT].[rdt_Decode_Format_DNNNNNN]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_Decode_Format_DNNNNNN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_Decode_Format_DNNNNNN                           */
/* Copyright      : LF                                                  */
/*                                                                      */
/* Purpose: format input value                                          */
/*                                                                      */
/* Date        Rev  Author    Purposes                                  */
/* 15-04-2016  1.0  Ung       SOS368437. Created                        */
/* 20-05-2016  1.1  Ung       SOS370219 Migrate to Exceed               */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_Decode_Format_DNNNNNN
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT, 
   @nInputKey           INT,
   @cStorerKey          NVARCHAR( 15),
   @cFacility           NVARCHAR( 5),
   @cDecodeCode         NVARCHAR( 30), 
   @cDecodeLineNumber   NVARCHAR( 5), 
   @cFormatSP           NVARCHAR( 50), 
   @cFieldData          NVARCHAR( 60) OUTPUT,
   @nErrNo              INT           OUTPUT,
   @cErrMsg             NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cNum NVARCHAR(7)
   DECLARE @nPos INT

   -- Backup to temp
   SET @cNum = @cFieldData

   -- Format: DNNNNNN
   --    D = Decimal point position
   --    N = Numeric
   
   -- Check length
   IF LEN( @cNum) <> 7
   BEGIN
      SET @nErrNo = 99001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad NUM length
      GOTO Quit
   END

   -- Check decimal point
   IF LEFT( @cNum, 1) NOT BETWEEN '1' AND '6'
   BEGIN
      SET @nErrNo = 99002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Bad Decimal
      GOTO Quit
   END

   -- Get decimal position
   SET @nPos = LEFT( @cNum, 1) 
   
   -- Insert decimal point
   SET @cNum = SUBSTRING( @cNum, 2, 6 - @nPos) + '.' + RIGHT( @cNum, @nPos)
   
   -- Save formatted data in NNNNNN
   SET @cFieldData = @cNum

Quit:

END -- End Procedure

GO

GRANT EXECUTE ON rdt.rdt_Decode_Format_DNNNNNN TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
