IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdtMaskValue]') AND xtype in (N'FN', N'IF', N'TF'))
   DROP FUNCTION [RDT].[rdtMaskValue]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: rdtMaskValue    					                     */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Purpose: Mask Value Displayed                                         */
/*                                                                      */
/* Date        Author    Ver     Purposes                               */
/* Aug-13-2025 Cuize       1.0   FCR-6731 Created                       */
/************************************************************************/
CREATE FUNCTION rdt.rdtMaskValue (
   @nFunc      INT,
   @cStorerKey NVARCHAR( 15),
   @cFieldName NVARCHAR( 25),
   @cInput     NVARCHAR( 60)
) RETURNS NVARCHAR( MAX) AS
BEGIN

   DECLARE @nDisplayLength INT
   DECLARE @nFrontbackflag INT
   DECLARE @cCode          NVARCHAR(30)
   DECLARE @maskedStr      NVARCHAR( 60)

   SET @maskedStr = @cInput

   SET @cCode = RTRIM( CAST( @nFunc AS NVARCHAR(5))) + '-' + @cFieldName

   SELECT TOP 1
      @nDisplayLength = Short,
      @nFrontbackflag = ISNULL( Long, '')
   FROM CodeLkup WITH (NOLOCK)
   WHERE ListName = 'RDTMaskVal'
     AND Code = @cCode
     AND StorerKey = @cStorerKey

   IF @@rowcount < 1
      GOTO Fail

   IF @nFrontbackflag = 0
   BEGIN

      IF @nDisplayLength >= LEN(@cInput)
      BEGIN
         SET @maskedStr = REPLICATE('*', 5) + @cInput;
      END
      ELSE
      BEGIN
         SET @maskedStr = REPLICATE('*', LEN(@cInput) - @nDisplayLength)
            + RIGHT(@cInput, @nDisplayLength);
      END

   END
   ELSE IF @nFrontbackflag = 1
   BEGIN
      IF @nDisplayLength >= LEN(@cInput)
      BEGIN
         SET @maskedStr = @cInput + REPLICATE('*', 5);
      END
      ELSE
      BEGIN
         SET @maskedStr = LEFT(@cInput, @nDisplayLength)
            + REPLICATE('*', LEN(@cInput) - @nDisplayLength);
      END
   END
   ELSE
   BEGIN
      SET @maskedStr = @cInput;
   END

   GOTO Quit

Fail:
   RETURN @cInput
Quit:
   -- Note: RIGHT() is not working with NVARCHAR( MAX)
   RETURN @maskedStr
END
GO

GRANT EXECUTE ON rdt.rdtMaskValue TO NSQL
GO
