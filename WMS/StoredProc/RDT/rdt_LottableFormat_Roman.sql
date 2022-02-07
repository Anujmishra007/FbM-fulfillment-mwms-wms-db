IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Id = Object_Id(N'[RDT].[rdt_LottableFormat_Roman]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE rdt.rdt_LottableFormat_Roman
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_LottableFormat_Roman                                  */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: Generate expiry date base on code                                 */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 09-09-2017  Ung       1.0   WMS-2963 Created                               */
/******************************************************************************/

CREATE PROCEDURE rdt.rdt_LottableFormat_Roman
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nInputKey        INT,
   @cStorerKey       NVARCHAR( 15),
   @cSKU             NVARCHAR( 20),
   @cLottableCode    NVARCHAR( 30), 
   @nLottableNo      INT,
   @cFormatSP        NVARCHAR( 50), 
   @cLottableValue   NVARCHAR( 60), 
   @cLottable        NVARCHAR( 60) OUTPUT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cYear  NVARCHAR(4)
   DECLARE @cMonth NVARCHAR(2)
   DECLARE @cDay   NVARCHAR(2)

   SET @cDay = LEFT( @cLottableValue, 2)
   SET @cMonth = SUBSTRING( @cLottableValue, 3, 2)
   SET @cYear = SUBSTRING( @cLottableValue, 5, 2)

   -- Generate date
   SET @cLottable = @cDay + '/' + @cMonth +  '/' + '20' + @cYear
   
   -- Check date valid
   IF rdt.rdtIsValidDate( @cLottable) = 0
      SET @cLottable = ''

Quit:

END
GO

GRANT EXECUTE ON rdt.rdt_LottableFormat_Roman TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
