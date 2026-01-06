SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_898ExtVal12                                     */
/* Copyright      : Maersk                                              */
/* Customer:                                                            */
/*                                                                      */
/* Date        Author   Ver.     Purposes                               */
/* 2025-10-29  1.0      Dennis   FCR-8472 Created                       */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_898ExtVal12]
    @nMobile     INT
   ,@nFunc       INT
   ,@cLangCode   NVARCHAR(  3)
   ,@nStep       INT
   ,@nInputKey   INT
   ,@cReceiptKey NVARCHAR( 10)
   ,@cPOKey      NVARCHAR( 10)
   ,@cLOC        NVARCHAR( 10)
   ,@cToID       NVARCHAR( 18)
   ,@cLottable01 NVARCHAR( 18)
   ,@cLottable02 NVARCHAR( 18)
   ,@cLottable03 NVARCHAR( 18)
   ,@dLottable04 DATETIME
   ,@cUCC        NVARCHAR( 20)
   ,@cSKU        NVARCHAR( 20)
   ,@nQTY        INT
   ,@cParam1     NVARCHAR( 20) OUTPUT
   ,@cParam2     NVARCHAR( 20) OUTPUT
   ,@cParam3     NVARCHAR( 20) OUTPUT
   ,@cParam4     NVARCHAR( 20) OUTPUT
   ,@cParam5     NVARCHAR( 20) OUTPUT
   ,@cOption     NVARCHAR( 1)
   ,@nErrNo      INT       OUTPUT
   ,@cErrMsg     NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @cStorerKey           NVARCHAR( 15),
   @cFacility            NVARCHAR( 5),
   @cTempLottable01      NVARCHAR( 18), --input field lottable01 from lottable screen
   @cTempLottable02      NVARCHAR( 18), --input field lottable02 from lottable screen
   @cTempLottable03      NVARCHAR( 18), --input field lottable03 from lottable screen
   @cTempLottable04      NVARCHAR( 18), --input field lottable03 from lottable screen
   @dTempLottable04      DATETIME, 
   @cStorerConfig        NVARCHAR( 50),
   @cColumn              NVARCHAR( 30),
   @cLastSku             NVARCHAR( 20)=N'',
   @cLastLot             NVARCHAR( 20)=N'',
   @cSQLHead             NVARCHAR( MAX),
   @cSQLBody             NVARCHAR( MAX),
   @cSQLFoot             NVARCHAR( MAX),
   @cSQLParam            NVARCHAR( MAX),
   @cSQL                 NVARCHAR( MAX)

   SELECT
      @cStorerKey  = [StorerKey],
      @cFacility   = [Facility],
      @cTempLottable01 = I_Field01,
      @cTempLottable02 = I_Field02,
      @cTempLottable03 = I_Field03,
      @cTempLottable04 = I_Field04
   FROM   [RDT].[RDTMOBREC] (NOLOCK)
   WHERE  [Mobile] = @nMobile

   SET @cStorerConfig = ISNULL([rdt].[RDTGetConfig]( @nFunc, 'DisAllowMixPallet', @cStorerKey), N'')

   SET @cSQLHead='SELECT TOP 1 @cLastLot = ISNULL([RD].'
   SET @cSQLBody = ', N'''')
               FROM [dbo].[Receipt] [R] WITH (NOLOCK)
                  INNER JOIN [dbo].[ReceiptDetail] [RD] WITH (NOLOCK) ON [R].[ReceiptKey]  = [RD].[ReceiptKey]
               WHERE [R].[Facility] = @cFacility AND [R].[StorerKey] = @cStorerKey
                  AND [R].[ReceiptKey] = @cReceiptKey AND (@cPOKey=''NOPO'' OR [RD].[POKey] = @cPOKey)
                  AND [RD].[ToId] = @cID
               ORDER BY [RD].[ReceiptLineNumber]

               IF @@ROWCOUNT <> 0 AND @cLastLot <> ISNULL('
   SET @cSQLFoot = '
               , N'''')
               BEGIN
                  SET @nErrNo = 224701
                  SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, N''ENG'', N''DSP'') 
               END
               '
   SET @cSQLParam =
               '@cFacility    NVARCHAR( 5),  ' +
               '@cStorerKey   NVARCHAR( 15), ' +
               '@cReceiptKey  NVARCHAR( 10), ' +
               '@cPOKey       NVARCHAR( 10), ' +
               '@cID          NVARCHAR( 18), ' +
               '@cLottable01  NVARCHAR( 18), ' +
               '@cLottable02  NVARCHAR( 18), ' +
               '@cLottable03  NVARCHAR( 18), ' +
               '@dLottable04  DATETIME,      ' +
               '@cLastLot     NVARCHAR( 20) OUTPUT,'+
               '@nErrNo       INT         OUTPUT, 
                @cErrMsg      NVARCHAR(20)  OUTPUT'

   IF @nFunc = 898 -- UCC Receive
   BEGIN
      IF @nStep = 3
      BEGIN
         IF LEN(@cTOID) <> 10
         BEGIN
            SET @nErrNo = 250752
            SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, @cLangCode, N'DSP') 
            GOTO Quit
         END
      END
      IF @nStep = 5
      BEGIN
      	IF @nInputKey = 1
      	BEGIN
            IF @cStorerConfig <> ''
            BEGIN

               SELECT @dTempLottable04 = CASE WHEN ISNULL(@cTempLottable04,'') = '' THEN NULL ELSE rdt.rdtConvertToDate(@cTempLottable04) END

               DECLARE LIST CURSOR FOR 
               SELECT [Code2] FROM [CODELKUP] (NOLOCK) WHERE [LISTNAME] = @cStorerConfig 
                  AND [Storerkey] = @cStorerKey AND [Code] = N'898'
               OPEN LIST
               FETCH NEXT FROM LIST INTO @cColumn
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  IF @cColumn IN (N'Lottable01', N'Lottable02', N'Lottable03', N'Lottable04')
                  BEGIN
                     SET @cSQL = @cSQLHead + QUOTENAME(@cColumn) + @cSQLBody
                     IF @cColumn IN ('Lottable04')
                        SET  @cSQL = @cSQL + '@d' + @cColumn
                     ELSE 
                        SET  @cSQL = @cSQL + '@c' + @cColumn
                     SET @cSQL = @cSQL + @cSQLFoot

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @cFacility, @cStorerKey, @cReceiptKey, @cPOKey, @cToID,
                        @cTempLottable01, @cTempLottable02, @cTempLottable03, @dTempLottable04, 
                        @cLastLot OUTPUT,@nErrNo OUTPUT,@cErrMsg OUTPUT
                     IF @nErrNo <> 0
                     BEGIN
                        IF @cColumn = N'Lottable01'
                        BEGIN
                           SET @nErrNo = 224703
                           SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, @cLangCode, N'DSP') 
                        END
                        ELSE IF @cColumn = N'Lottable02'
                        BEGIN
                           SET @nErrNo = 224704
                           SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, @cLangCode, N'DSP') 
                        END
                        ELSE IF @cColumn = N'Lottable03'
                        BEGIN
                           SET @nErrNo = 224705
                           SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, @cLangCode, N'DSP') 
                        END
                        ELSE IF @cColumn = N'Lottable04'
                        BEGIN
                           SET @nErrNo = 224706
                           SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, @cLangCode, N'DSP') 
                        END
                        ELSE
                        BEGIN
                           EXEC [rdt].[rdtInsertMsgQueue] @nMobile, @nErrNo, @cErrMsg,
                           'Mix',
                           @cColumn,
                           'Not Allowed On ID'
                        END
                        GOTO CLOSELIST
                     END
                  END
                  SET @cSQL = ''
                  FETCH NEXT FROM LIST INTO @cColumn
               END
               GOTO CLOSELIST
            END
      	END
      END

      IF @nStep = 8
      BEGIN
      	IF @nInputKey = 1
      	BEGIN
            IF @cStorerConfig != N''
            BEGIN
               DECLARE LIST CURSOR FOR 
               SELECT [Code2] FROM [CODELKUP] (NOLOCK) WHERE [LISTNAME] = @cStorerConfig 
                  AND [Storerkey] = @cStorerKey AND [Code] = N'898'
               OPEN LIST
               FETCH NEXT FROM LIST INTO @cColumn
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  IF @cColumn = N'SKU'
                  BEGIN
                     SELECT TOP 1 @cLastSku = ISNULL(RD.Sku,'')
                     FROM [dbo].[Receipt] [R] WITH (NOLOCK)
                        INNER JOIN [dbo].[ReceiptDetail] [RD] WITH (NOLOCK) ON [R].[ReceiptKey]  = [RD].[ReceiptKey]
                     WHERE [R].[Facility] = @cFacility AND [R].[StorerKey] = @cStorerKey
                        AND [R].[ReceiptKey] = @cReceiptKey AND (@cPOKey=N'NOPO' OR [RD].[POKey] = @cPOKey)
                        AND [RD].[ToId] = @cToID
                     ORDER BY [RD].[ReceiptLineNumber]
                     
                     IF @cLastSku <> N'' AND @cLastSku <> @cSKU
                     BEGIN
                        SET @nErrNo = 224702
                        SET @cErrMsg = [rdt].[rdtGetMessageLong]( @nErrNo, @cLangCode, N'DSP') --Mix SKU Not Allowed
                        GOTO CLOSELIST
                     END
                     GOTO CLOSELIST
                  END
                  FETCH NEXT FROM LIST INTO @cColumn
               END
               
               GOTO CLOSELIST
            END
      	END
      END
   END         
   GOTO Quit
   CLOSELIST:
      CLOSE LIST
      DEALLOCATE LIST
      GOTO Quit

   Quit:

END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_898ExtVal12 TO NSQL
GO


