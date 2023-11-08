SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_513SuggestLOC21                                       */
/* Copyright      : LFLogistics                                               */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 02-10-2023  1.0  yeekung  WMS-23814 Created                                */
/******************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_513SuggestLOC21] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @cStorerKey      NVARCHAR( 15),
   @cFacility       NVARCHAR(  5),
   @cFromLOC        NVARCHAR( 10),
   @cFromID         NVARCHAR( 18),
   @cSKU            NVARCHAR( 20),
   @nQTY            INT,
   @cToID           NVARCHAR( 18),
   @cToLOC          NVARCHAR( 10),
   @cType           NVARCHAR( 10),
   @nPABookingKey   INT           OUTPUT,
   @cOutField01     NVARCHAR( 20) OUTPUT,
   @cOutField02     NVARCHAR( 20) OUTPUT,
   @cOutField03     NVARCHAR( 20) OUTPUT,
   @cOutField04     NVARCHAR( 20) OUTPUT,
   @cOutField05     NVARCHAR( 20) OUTPUT,
   @cOutField06     NVARCHAR( 20) OUTPUT,
   @cOutField07     NVARCHAR( 20) OUTPUT,
   @cOutField08     NVARCHAR( 20) OUTPUT,
   @cOutField09     NVARCHAR( 20) OUTPUT,
   @cOutField10     NVARCHAR( 20) OUTPUT,
   @cOutField11     NVARCHAR( 20) OUTPUT,
   @cOutField12     NVARCHAR( 20) OUTPUT,
   @cOutField13     NVARCHAR( 20) OUTPUT,
   @cOutField14     NVARCHAR( 20) OUTPUT,
   @cOutField15     NVARCHAR( 20) OUTPUT,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @i              INT
   DECLARE @nLOCQTY        INT

   DECLARE @cLOCCat1    NVARCHAR(10)
   DECLARE @cLOCCat2    NVARCHAR(10)
   DECLARE @cLOCCat3    NVARCHAR(10)
   DECLARE @cUDF04      NVARCHAR(20)
   DECLARE @cUDF05      NVARCHAR(20)
   DECLARE @cLong       NVARCHAR(30)
   DECLARE @cShort      NVARCHAR(30)
   DECLARE @cSKUGroup   NVARCHAR(20)
   DECLARE @cSuggLOC    NVARCHAR(20)
   DECLARE @cSQL        NVARCHAR(MAX)
   DECLARE @cSQLParams  NVARCHAR(MAX)
   DECLARE @cOutput     NVARCHAR(20)
   DECLARE @cStyle      NVARCHAR(20)
   DECLARE @curLOC CURSOR
   DECLARE @nROWCOUNT   INT

   SET @i = 1
   SET @cLOCCat1 = ''
   SET @cLOCCat2 = ''
   SET @cLOCCat3 = ''
   SET @cOutField01= '' 
   SET @cOutField02= ''
   SET @cOutField03= ''
   SET @cOutField04= ''
   SET @cOutField05= ''
   SET @cOutField06= ''
   SET @cOutField07= ''
   SET @cOutField08= ''
   SET @cOutField09= ''

   SELECT @cSKUGroup = SKUGROUP,
          @cStyle = Style
   FROM SKU (NOLOCK)
   WHERE SKU = @cSKU
      AND STorerkey = @cStorerKey

      -- Get location category
   SELECT 
      @cLOCCat1 = LEFT( UDF01, 10), 
      @cLOCCat2 = LEFT( UDF02, 10), 
      @cLOCCat3 = LEFT( UDF03, 10), 
      @cUDF04   = UDF04, 
      @cUDF05   = UDF05,
      @cLong    = Long,
      @cShort   = Short
   FROM CodeLKUP WITH (NOLOCK) 
   WHERE ListName = 'RDTMVFF' 
      AND Code = @cSKUGroup
      AND StorerKey = @cStorerKey 

   SET @cSQL = ''
   SET @cSQLParams = ''

   SET @cSQL = 
   'SET @curLOC = CURSOR FOR '+
   '  Select TOP 10 LOC.LOC, sum(SL.QTY)
      FROM SKUXLoc SL INNER JOIN Loc LOC ON SL.loc =LOC.loc
      Inner join SKU SKU on SKU.storerkey=SL.storerkey and SKU.sku=SL.sku
      WHERE LOC.facility = @cFacility
         AND SL.Storerkey = @cStorerkey
         AND SKU.skugroup = @cSKUGroup
         AND LOC.LocationCategory IN (@cLOCCat1,@cLOCCat2,@cLOCCat3)
         AND SL.QTY < @cUDF04
         AND SKU.' + @cLong + ' = ' + CASE WHEN ISNULL(@cLong,'')='SKU' THEN '@cSKU'
                                           WHEN ISNULL(@cLong,'')='Style' THEN '@cStyle' END +           
         ' GROUP BY LOC.LOC,LOC.LocationCategory,SKU.' + @cLong + 
         ' Having Count(distinct SL.SKU)  < @cShort' +
         ' ORDER BY CASE WHEN @cUDF05 =''1'' THEN SUM(QTY) END DESC,
                     CASE WHEN @cUDF05 =''0'' THEN SUM(QTY) END'

      SET @cSQLParams =
      ' @cLOCCat1    NVARCHAR(10),
         @cLOCCat2    NVARCHAR(10),
         @cLOCCat3    NVARCHAR(10),
         @cUDF04      NVARCHAR(20),
         @cUDF05      NVARCHAR(20),
         @cLong       NVARCHAR(30),
         @cShort      NVARCHAR(30),
         @cSKUGroup   NVARCHAR(20),
         @cFacility   NVARCHAR(20),
         @cStorerkey  NVARCHAR(20),
         @cSKU        NVARCHAR(20),
         @cStyle      NVARCHAR(20),
         @curLOC      CURSOR OUTPUT'


   SET @cSQL = @cSQL + ' OPEN @curLOC'


   EXEC sp_ExecuteSQL @cSQL, @cSQLParams,@cLOCCat1,@cLOCCat2,@cLOCCat3,@cUDF04,@cUDF05
   ,@cLong,@cShort,@cSKUGroup,@cFacility,@cStorerkey,@cSKU,@cStyle,@curLOC OUTPUT

   FETCH NEXT FROM @curLOC INTO @cSuggLOC, @nLOCQTY
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @cOutput = @cSuggLOC + ' '+ CAST( @nLOCQTY AS NVARCHAR(10))


      IF @i = 1 SET @cOutField01 = @cOutput
      IF @i = 2 SET @cOutField02 = @cOutput
      IF @i = 3 SET @cOutField03 = @cOutput
      IF @i = 4 SET @cOutField04 = @cOutput
      IF @i = 5 SET @cOutField05 = @cOutput
      IF @i = 6 SET @cOutField06 = @cOutput
      IF @i = 7 SET @cOutField07 = @cOutput
      IF @i = 8 SET @cOutField08 = @cOutput

      SET @i = @i + 1
      IF @i > 8
         BREAK

      FETCH NEXT FROM @curLOC INTO @cSuggLOC, @nLOCQTY
   END


Quit:

END

GO
GRANT EXECUTE ON  [RDT].[rdt_513SuggestLOC21] TO [NSQL]
GO
