
/************************************************************************/
/* Store procedure: rdt_512ExtInfo99                                    */
/* Purpose: Move By LOC Extended Info                                   */
/*                                                                      */
/* Called from: rdtfnc_Move_LOC                                         */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-09-12  1.0  ELB012     Project - FCR-8646 - Created             */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_512ExtInfo99] (
  @nMobile          INT,
  @nFunc            INT, 
  @cLangCode        NVARCHAR( 3), 
  @nStep            INT, 
  @nInputKey        INT, 
  @cStorerKey       NVARCHAR( 15), 
  @cFromLOC         NVARCHAR( 10),
  @cToLOC           NVARCHAR( 10),
  @cToID            NVARCHAR( 18),
  @cSKU             NVARCHAR( 20),
  @cOption          NVARCHAR( 1), 
  @cExtendedInfo    NVARCHAR( 20) OUTPUT
)
AS
BEGIN

  SET NOCOUNT ON
  SET QUOTED_IDENTIFIER OFF
  SET ANSI_NULLS OFF
  SET CONCAT_NULL_YIELDS_NULL OFF  

  DECLARE @cSuggLOC    NVARCHAR( 10)
  DECLARE @cBuffM1     NVARCHAR( 10)
  DECLARE @cBuffM2     NVARCHAR( 10)
  DECLARE @cBuffM3     NVARCHAR( 10)
  DECLARE @cBuffM4     NVARCHAR( 10)
  DECLARE @cBuffRk     NVARCHAR( 10)
  DECLARE @cPndM1      NVARCHAR( 10)
  DECLARE @cPndM2      NVARCHAR( 10)
  DECLARE @cPndM3      NVARCHAR( 10)
  DECLARE @cPndM4      NVARCHAR( 10)
  DECLARE @cPndRk      NVARCHAR( 10) 
   
  -- Get Buffers Loc 
  SELECT  @cBuffM1    = ISNULL(UDF01,''), --ONBR BUFFER M1
    @cBuffM2    = ISNULL(UDF02,''), --ONBR BUFFER M2
    @cBuffM3    = ISNULL(UDF03,''), --ONBR BUFFER M3
    @cBuffM4    = ISNULL(UDF04,''), --ONBR BUFFER M4
    @cBuffRk    = ISNULL(UDF05,'')  --ONBR BUFFER RK
  FROM dbo.CodeLKUP WITH (NOLOCK)  
  WHERE ListName = 'ONBRBFFPND'
    AND StorerKey = @cStorerKey  
    AND Code = 'BUFFER'

  -- Get Pnds Loc 
  SELECT  @cPndM1    = ISNULL(UDF01,''), --ONBR PND M1
    @cPndM2    = ISNULL(UDF02,''), --ONBR PND M2
    @cPndM3    = ISNULL(UDF03,''), --ONBR PND M3
    @cPndM4    = ISNULL(UDF04,''), --ONBR PND M4
    @cPndRk    = ISNULL(UDF05,'')  --ONBR PND RK
  FROM dbo.CodeLKUP WITH (NOLOCK)  
  WHERE ListName = 'ONBRBFFPND'
    AND StorerKey = @cStorerKey  
    AND Code = 'PND'
	-- End get configs


  IF @nStep = 1 
  BEGIN
    IF @nInputKey = 1
    BEGIN -- Suggest LOC  
      IF @cFromLOC = @cBuffM1
      SET @cSuggLOC = @cPndM1
      ELSE IF @cFromLOC = @cBuffM2
      SET @cSuggLOC = @cPndM2
      ELSE IF @cFromLOC = @cBuffM3
      SET @cSuggLOC = @cPndM3
      ELSE IF @cFromLOC = @cBuffM4
      SET @cSuggLOC = @cPndM4
      ELSE IF @cFromLOC = @cBuffRk
      SET @cSuggLOC = @cPndRk
      ELSE
        SET @cSuggLOC = ''

      IF @cSuggLOC = ''
		    SET @cExtendedInfo = ''
      ELSE
		    SET @cExtendedInfo = 'LOC MOVE: ' + @cSuggLOC       
    END
  END
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_512ExtInfo99 TO NSQL
GO
