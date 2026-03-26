SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_600ExtScn01_PH                                  */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Purpose:       NLRT2 customers                                       */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-03-05 1.0  MBI165   PHARMA                                      */
/* 2026-03-23 1.1  SSR259   FCR-11294 Update Pallet Type                */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_600ExtScn01_PH] (
    @nMobile      INT,           
    @nFunc        INT,           
    @cLangCode    NVARCHAR( 3),  
    @nStep        INT,           
    @nScn         INT,           
    @nInputKey    INT,           
    @cFacility    NVARCHAR( 5),  
    @cStorerKey   NVARCHAR( 15), 

    @cSuggLOC     NVARCHAR( 10) OUTPUT, 
    @cLOC         NVARCHAR( 20) OUTPUT, 
    @cID          NVARCHAR( 20) OUTPUT, 
    @cSKU         NVARCHAR( 20) OUTPUT, 
    @cReceiptKey  NVARCHAR( 10), 
    @cPOKey       NVARCHAR( 10),
    @cReasonCode  NVARCHAR( 10),
    @cReceiptLineNumber  NVARCHAR( 5),
    @cPalletType  NVARCHAR( 10),  

    @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
    @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
    @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
    @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
    @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
    @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT, 
    @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT, 
    @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT, 
    @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT, 
    @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT, 
    @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
    @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
    @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
    @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
    @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
    @nAction      INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
    @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT, 
    @nErrNo             INT            OUTPUT, 
    @cErrMsg            NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @nShelfLife   FLOAT
    DECLARE @cResultCode NVARCHAR( 60)

    DECLARE
    @nRowCount            INT,
    @cexternReceiptKey    NVARCHAR( 30), 
    @cexternLineNo        NVARCHAR( 30),    
    @nLotNum              INT,
    @cListName            NVARCHAR( 30),
    @cLotValue            NVARCHAR( 30),     
    @cStorerConfig        NVARCHAR( 50),  
    @SQL                  NVARCHAR( MAX),
    @cUserDefine08        NVARCHAR( 30),  
    @nSQLResult           INT,
    @nCheckDigit          INT,
    @cActLoc              NVARCHAR( 20),
    @cPalletTypeInUse     NVARCHAR( 5),
    @cPalletTypeSave      NVARCHAR( 10),
    @cLott10              NVARCHAR( 30),
    @cSKUReceived         NVARCHAR( 20),
    @cDamagedCode         NVARCHAR(30),
    @cExpiredCode         NVARCHAR(30),
    @cIDFromMobRec        NVARCHAR(20) --FCR-11294

    SELECT
    @cLott10           = C_String1,
    @cPalletTypeSave   = C_String2,
    @cSKUReceived      = C_String3
    FROM RDT.RDTMOBREC WITH (NOLOCK)
    WHERE Mobile = @nMobile


    IF( @nStep IN (4,5) )
    BEGIN
        SELECT TOP 1 @cOutField10 = ISNULL(RD.ConditionCode,'')
        FROM dbo.Receipt R WITH (NOLOCK)
            INNER JOIN dbo.ReceiptDetail RD WITH (NOLOCK) ON R.ReceiptKey  = RD.ReceiptKey
        WHERE R.Facility = @cFacility AND R.StorerKey = @cStorerKey
            AND R.ReceiptKey = @cReceiptKey
            AND RD.Sku = @cSKU
            AND toID = @cID
        ORDER BY RD.ReceiptLineNumber
    END

    IF @nAction = 1 --Validation
    BEGIN
        IF @nFunc = 600 
        BEGIN
            IF @nInputKey = 1
            BEGIN
                IF( @nStep = 99 )
                BEGIN
                    IF (ISNULL( rdt.RDTGetConfig( @nFunc, 'ValidatePalletType', @cStorerKey),'0') <> '0')
                    BEGIN
                        SELECT 
                        @cPalletTypeInUse = PalletTypeInUse
                        FROM dbo.PalletTypeMaster WITH (NOLOCK)
                            WHERE StorerKey = @cStorerKey
                            AND Facility = @cFacility
                            AND PalletType = @cPalletType

                        IF @@ROWCOUNT = 0
                        BEGIN
                            SET @nErrNo = 261351
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --261351 Pallet Type Not Configured
                            GOTO Quit
                        END

                        IF @cPalletTypeInUse <> 'Y'
                        BEGIN
                            SET @nErrNo = 261352
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --261352 Pallet Type Not In Use
                            GOTO Quit
                        END

                        SET @cPalletTypeSave = @cPalletType

                        -- FCR-11671: Update ID.PalletType when pallet type is entered
                        IF (ISNULL(rdt.RDTGetConfig(@nFunc, 'UpdPltType', @cStorerKey), '0') = '1')
                        BEGIN
                            IF ISNULL(@cID, '') <> '' AND ISNULL(@cPalletType, '') <> ''
                            BEGIN
                                UPDATE dbo.ID WITH (ROWLOCK)
                                SET PalletType = @cPalletType,
                                    EditDate = GETDATE()
                                WHERE ID = @cID
                            END
                        END
                    END
                END
            
                IF( @nStep = 2 )
                    BEGIN
                    IF ISNULL(rdt.RDTGetConfig( @nFunc, 'ReceiveDefaultToLoc', @cStorerKey),'') = @cLOC
                        GOTO QUIT

                    SELECT
                        @nCheckDigit = CheckDigitLengthForLocation
                    FROM dbo.FACILITY WITH (NOLOCK)
                    WHERE facility = @cFacility

                    IF @nCheckDigit > 0
                    BEGIN
                        SELECT @cActLoc = loc 
                        FROM dbo.LOC WITH (NOLOCK)
                        WHERE Facility = @cFacility AND CONCAT(LOC,LOCCHECKDIGIT) = @cLOC
                        SET @nRowCount = @@ROWCOUNT
                        IF @nRowCount > 1
                        BEGIN
                            SET @nErrNo = 261353
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --261353 Unique location not identified
                            GOTO Quit
                        END
                        ELSE IF @nRowCount = 0
                        BEGIN
                            SET @nErrNo = 261354
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --261354 Loc Not Found
                            GOTO Quit
                        END
                        SET @cLOC = @cActLoc
                        GOTO QUIT
                    END
                END
        
                IF( @nStep = 5 )
                BEGIN
                    SET @cStorerConfig = ISNULL(rdt.RDTGetConfig( @nFunc, 'ValidateLottable', @cStorerKey),'')
                    IF @cStorerConfig <> ''
                    BEGIN
                        SELECT TOP 1 @nLotNum = TRY_CAST(value AS INT) FROM STRING_SPLIT(@cStorerConfig, ',')
                        SELECT @cListName = value FROM STRING_SPLIT(@cStorerConfig, ',')
                        SET @cLotValue = CASE
                                            WHEN @nLotNum = 1  THEN @cLottable01 WHEN @nLotNum = 2  THEN @cLottable02 
                                            WHEN @nLotNum = 3  THEN @cLottable03 WHEN @nLotNum = 6  THEN @cLottable06 
                                            WHEN @nLotNum = 7  THEN @cLottable07 WHEN @nLotNum = 8  THEN @cLottable08 
                                            WHEN @nLotNum = 9  THEN @cLottable09 WHEN @nLotNum = 10 THEN @cLottable10 
                                            WHEN @nLotNum = 11 THEN @cLottable11 WHEN @nLotNum = 12 THEN @cLottable12
                                            END 
                        IF ISNULL(@cLotValue,'') = ''
                        BEGIN
                            GOTO Quit
                        END
                        SET @SQL = 'SELECT  @Result = COUNT(1)
                            FROM dbo.CodeLKUP WITH (NOLOCK)
                            WHERE ListName = '+CONCAT('''',@cListName,'''')+
                            'AND Storerkey = '+CONCAT('''',@cStorerkey,'''')
                        EXEC sp_executesql @SQL,N'@Result INT OUTPUT', @nSQLResult OUTPUT
                        IF @nSQLResult = 0
                        BEGIN
                            SET @nErrNo = 261355
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'List not maintained'
                            GOTO Quit
                        END
                        SET @SQL = 'SELECT  @Result = COUNT(1)
                            FROM dbo.CodeLKUP WITH (NOLOCK)
                            WHERE ListName = '+CONCAT('''',@cListName,'''')+
                            'AND Storerkey = '+CONCAT('''',@cStorerkey,'''')+
                            'AND Code ='+ CONCAT('''',@cLotValue,'''')
                        EXEC sp_executesql @SQL,N'@Result INT OUTPUT', @nSQLResult OUTPUT
                        IF @nSQLResult = 0
                        BEGIN
                            SET @nErrNo = 261356
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid Value'
                            GOTO Quit
                        END
                    END
                END

                IF( @nStep = 6 )
                BEGIN
                    IF (ISNULL(rdt.RDTGetConfig( @nFunc, 'ValidatePalletType', @cStorerKey),'0')) <> '0' -- Capture pallet type
                    BEGIN
                        IF ISNULL(@cPalletTypeSave,'') <> ''
                        BEGIN
                            UPDATE dbo.RECEIPTDETAIL SET PalletType = @cPalletTypeSave
                            WHERE ReceiptKey = @cReceiptKey
                            AND ReceiptLineNumber = @cReceiptLineNumber

                            -- FCR-11294: Also update ID table at Step 6
                            IF (ISNULL(rdt.RDTGetConfig(@nFunc, 'UpdPltType', @cStorerKey), '0') = '1')
                            BEGIN
                                SELECT @cIDFromMobRec = V_ID
                                FROM RDT.RDTMOBREC WITH (NOLOCK)
                                WHERE Mobile = @nMobile
                                
                                IF ISNULL(@cIDFromMobRec, '') <> ''
                                BEGIN
                                    UPDATE dbo.ID WITH (ROWLOCK)
                                    SET PalletType = @cPalletTypeSave,
                                        EditDate = GETDATE()
                                    WHERE ID = @cIDFromMobRec
                                END
                                
                                UPDATE dbo.ITRN WITH (ROWLOCK)
                                SET PalletType = @cPalletTypeSave,
                                    EditDate = GETDATE()
                                WHERE SourceKey = RTRIM(@cReceiptKey) + RTRIM(@cReceiptLineNumber)
                                AND TranType = 'DP'
                                AND SourceType IN ('ntrReceiptDetailAdd', 'ntrReceiptDetailUpdate')
                            END
                        END
                    END
                END
            END -- closes IF @nInputKey = 1
        END -- closes IF @nFunc = 600
    END -- closes IF @nAction = 1

Quit:
    UPDATE RDT.RDTMOBREC SET
       C_String1 = @cLott10,
       C_String2 = @cPalletTypeSave,
       C_String3 = CASE WHEN ISNULL(@cSKU,'')='' THEN @cSKUReceived ELSE @cSKU END 
    WHERE Mobile = @nMobile
END
GO


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_600ExtScn01_PH TO nSQL
GO
