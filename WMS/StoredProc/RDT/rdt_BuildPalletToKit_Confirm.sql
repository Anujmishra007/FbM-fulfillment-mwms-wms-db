SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_BuildPalletToKit_Confirm                                    */  
/* Copyright      : Maersk                                                    */  
/*                                                                            */  
/* Purpose: Generte to kitdetail                                              */  
/*                                                                            */  
/* PVCS Version: 2.1                                                          */  
/*                                                                            */  
/* Modifications log:                                                         */  
/*                                                                            */  
/* Date       Rev    Author   Purposes                                        */  
/* 2025-03-13 1.0.0  JCH507   FCR-2728 Created                                */  
/******************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_BuildPalletToKit_Confirm] (  
   @nFunc          INT,  
   @nMobile        INT,  
   @cLangCode      NVARCHAR( 3),  
   @nErrNo         INT          OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT, -- screen limitation, 20 char max  
   @cStorerKey     NVARCHAR( 15),  
   @cFacility      NVARCHAR( 5),  
   @cKitKey        NVARCHAR( 10),  
   @cExtKitKey     NVARCHAR( 20),
   @cToLOC         NVARCHAR( 10),  
   @cToID          NVARCHAR( 18), -- Blank = receive to blank ToID 
   @cPalletType    NVARCHAR( 10) = '', -- Pallet type 
   @cSKUCode       NVARCHAR( 20), -- SKU code. Not SKU barcode  
   @cSKUUOM        NVARCHAR( 10),  
   @nSKUQTY        INT,       -- In master unit  
   @cLottable01    NVARCHAR( 18),  
   @cLottable02    NVARCHAR( 18),  
   @cLottable03    NVARCHAR( 18),  
   @dLottable04    DATETIME,  
   @dLottable05    DATETIME,  
   @cLottable06    NVARCHAR( 30),  
   @cLottable07    NVARCHAR( 30),  
   @cLottable08    NVARCHAR( 30),  
   @cLottable09    NVARCHAR( 30),  
   @cLottable10    NVARCHAR( 30),  
   @cLottable11    NVARCHAR( 30),  
   @cLottable12    NVARCHAR( 30),  
   @dLottable13    DATETIME,  
   @dLottable14    DATETIME,  
   @dLottable15    DATETIME,   
   @cKitDtlLineNumberOutput NVARCHAR( 5) = '' OUTPUT,  
   @bDebugFlag     BINARY = 0  --1 print info, 2 traceinfo
) AS  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
DECLARE @b_success      INT  
DECLARE @nTranCount     INT  
DECLARE @cDocType       NVARCHAR( 1)  
DECLARE @cSKU           NVARCHAR( 20)  
DECLARE @nQTY           INT  
DECLARE @cUOM           NVARCHAR( 10)  
DECLARE @cSQL           NVARCHAR(MAX)  
DECLARE @cSQLParam      NVARCHAR(MAX)  
DECLARE @cCustomSQL     NVARCHAR(MAX)
DECLARE @cCheckIDInUse  NVARCHAR( 20)
DECLARE @cPackKey       NVARCHAR( 10)
  
/*-------------------------------------------------------------------------------  
  
                 Convert parameters  
  
-------------------------------------------------------------------------------*/  
IF @cStorerKey  IS NULL SET @cStorerKey  = ''  
IF @cFacility   IS NULL SET @cFacility   = ''  
IF @cKitKey     IS NULL SET @cKitKey = ''  
IF @cExtKitKey  IS NULL SET @cExtKitKey = ''  
IF @cToLOC      IS NULL SET @cToLOC      = ''  
IF @cToID       IS NULL SET @cToID       = ''  
IF @cSKUCode    IS NULL SET @cSKUCode    = ''  
IF @cSKUUOM     IS NULL SET @cSKUUOM     = ''  
IF @nSKUQTY     IS NULL SET @nSKUQTY     = 0   
IF @cLottable01 IS NULL SET @cLottable01 = ''  
IF @cLottable02 IS NULL SET @cLottable02 = ''  
IF @cLottable03 IS NULL SET @cLottable03 = ''  
IF @dLottable04 = 0 OR @dLottable04 = '1/1/1900 12:00:00 AM'   SET @dLottable04 = NULL -- 1/1/1900 12:00:00 AM is default value for datetime
IF @dLottable05 = 0 OR @dLottable05 = '1/1/1900 12:00:00 AM'   SET @dLottable05 = NULL -- 1/1/1900 12:00:00 AM is default value for datetime
IF @cLottable06 IS NULL SET @cLottable06 = ''  
IF @cLottable07 IS NULL SET @cLottable07 = ''  
IF @cLottable08 IS NULL SET @cLottable08 = ''  
IF @cLottable09 IS NULL SET @cLottable09 = ''  
IF @cLottable10 IS NULL SET @cLottable10 = ''  
IF @cLottable11 IS NULL SET @cLottable11 = ''  
IF @cLottable12 IS NULL SET @cLottable12 = ''  
IF @dLottable13 = 0 OR @dLottable13 = '1/1/1900 12:00:00 AM'   SET @dLottable13 = NULL -- 1/1/1900 12:00:00 AM is default value for datetime  
IF @dLottable14 = 0 OR @dLottable14 = '1/1/1900 12:00:00 AM'   SET @dLottable14 = NULL -- 1/1/1900 12:00:00 AM is default value for datetime 
IF @dLottable15 = 0 OR @dLottable15 = '1/1/1900 12:00:00 AM'   SET @dLottable15 = NULL -- 1/1/1900 12:00:00 AM is default value for datetime  
  
-- Truncate the time portion  
IF @dLottable04 IS NOT NULL  
   SET @dLottable04 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable04, 120), 120)  
IF @dLottable05 IS NOT NULL  
   SET @dLottable05 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable05, 120), 120)  
IF @dLottable13 IS NOT NULL  
   SET @dLottable13 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable13, 120), 120)  
IF @dLottable14 IS NOT NULL  
   SET @dLottable14 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable14, 120), 120)  
IF @dLottable15 IS NOT NULL  
   SET @dLottable15 = CONVERT( DATETIME, CONVERT( NVARCHAR( 10), @dLottable15, 120), 120)  
  
  
/*-------------------------------------------------------------------------------  
  
                                 Validate data  
  
-------------------------------------------------------------------------------*/  
DECLARE @cChkFacility  NVARCHAR( 5)  
DECLARE @cChkStorerKey NVARCHAR( 15)  
DECLARE @cChkStatus    NVARCHAR( 10)   
DECLARE @cChkLOC       NVARCHAR( 10)  

  
-- Validate StorerKey  
IF @cStorerKey = ''  
BEGIN  
   SET @nErrNo = 234901  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Need StorerKey'  
   GOTO Fail  
END  
  
-- Validate Facility  
IF @cFacility = ''  
BEGIN  
   SET @nErrNo = 234902  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Need Facility'  
   GOTO Fail  
END  
  
-- Validate Kit  
IF @cKitKey = ''  
BEGIN  
   SET @nErrNo = 234903  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Need KitKey'  
   GOTO Fail  
END

-- Validate SKUCode
IF @cSKUCode = ''
BEGIN
   SET @nErrNo = 234909  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Need SKU'  
   GOTO Fail 
END
  
-- Get the ASN  
SELECT  
   @cChkFacility = Facility,  
   @cChkStorerKey = StorerKey,  
   @cChkStatus = Status 
FROM dbo.KIT (NOLOCK)  
WHERE KITKey = @cKitKey  
  
-- Validate Kit exists  
IF @@ROWCOUNT <> 1  
BEGIN  
   SET @nErrNo = 234904
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Kit not found'  
   GOTO Fail  
END  
  
-- Validate Kit in different facility  
IF @cFacility <> @cChkFacility  
BEGIN  
   SET @nErrNo = 234905  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Kit not in FAC'  
   GOTO Fail  
END  
  
-- Validate Kit belong to diff storer  
IF @cStorerKey <> @cChkStorerKey  
BEGIN  
   SET @nErrNo = 234906
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Diff storer'  
   GOTO Fail  
END 
  
-- Get the LOC  
SELECT  
   @cChkLOC = LOC,  
   @cChkFacility = Facility  
FROM dbo.LOC (NOLOCK)  
WHERE LOC = @cToLOC  
  
-- Validate ToLOC  
IF @cChkLOC IS NULL OR @cChkLOC = ''  
BEGIN  
   SET @nErrNo = 234907  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid LOC'  
   GOTO Fail  
END  
  
-- Validate ToLOC not in facility  
IF @cChkFacility <> @cFacility  
BEGIN  
   SET @nErrNo = 234908  
   SET @cErrMsg = rdt.rdtgetmessage( 60315, @cLangCode, 'DSP') --'LOC not in FAC'  
   GOTO Fail  
END  
  
-- Validate pallet id in stock. If config turn on then not allow reuse  
SET @cCheckIDInUse = rdt.RDTGetConfig( @nFunc, 'CheckIDInUse', @cStorerKey)  
  
IF @cCheckIDInUse = '1' AND @cToID <> ''  
BEGIN  
   IF EXISTS( SELECT 1  
      FROM dbo.LOTxLOCxID LLI (NOLOCK)  
         INNER JOIN dbo.LOC LOC (NOLOCK) ON (LLI.LOC = LOC.LOC)  
      WHERE LLI.ID = @cToID  
         AND LLI.QTY > 0  
         AND LLI.StorerKey = @cStorerKey  
         AND LOC.Facility = @cFacility) -- Check duplicate ID within same facility only  
   BEGIN  
      SET @nErrNo = 234910 
      SET @cErrMsg = rdt.rdtgetmessage( 60316, @cLangCode, 'DSP') --'ID in used'  
      GOTO Fail  
   END  
END

SELECT @cPackKey = PackKey
FROM dbo.SKU SKU (NOLOCK)  
   WHERE SKU.StorerKey = @cStorerKey  
      AND SKU.SKU = @cSKUCode

-- Validate SKU  
IF @@ROWCOUNT = 0 
BEGIN  
   SET @nErrNo = 234911  
   SET @cErrMsg = rdt.rdtgetmessage( 60319, @cLangCode, 'DSP') --'Invalid SKU'  
   GOTO Fail  
END

-- Validate QTY  
IF RDT.rdtIsValidQTY( @nSKUQTY, 1) = 0 -- 1=Check for zero  
BEGIN  
   SET @nErrNo = 234912  
   SET @cErrMsg = rdt.rdtgetmessage( 60323, @cLangCode, 'DSP') --'Invalid QTY'  
   GOTO Fail  
END

-- Validate UOM field  
IF @cSKUUOM = ''  
BEGIN  
   SET @nErrNo = 234913  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UOM is needed'  
   GOTO Fail  
END  

-- Validate UOM exists  
IF NOT EXISTS( SELECT 1  
   FROM dbo.Pack P (NOLOCK)  
      INNER JOIN dbo.SKU S (NOLOCK) ON P.PackKey = S.PackKey  
   WHERE S.StorerKey = @cStorerKey  
      AND S.SKU = @cSKUCode  
      AND @cSKUUOM IN (  
         P.PackUOM1, P.PackUOM2, P.PackUOM3, P.PackUOM4,  
         P.PackUOM5, P.PackUOM6, P.PackUOM7, P.PackUOM8, P.PackUOM9))  
BEGIN  
   SET @nErrNo = 234914  
   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid UOM'  
   GOTO Fail  
END

-- Validate pallet type
DECLARE @cCapturePalletType NVARCHAR( 20)
SET @cCapturePalletType = rdt.RDTGetConfig( @nFunc, 'CapturePalletType', @cStorerKey)
IF @cCapturePalletType = '0'
   SET @cCapturePalletType = ''

IF @cCapturePalletType = '1'
BEGIN
   IF @cPalletType = ''
   BEGIN
      SET @nErrNo = 234916  
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PalletType  
      GOTO Fail 
   END
   ELSE
   BEGIN
      IF NOT EXISTS (SELECT 1
                     FROM dbo.PalletTypeMaster WITH (NOLOCK)
                     WHERE PalletType = @cPalletType
                        AND StorerKey = @cStorerKey
                        AND FACILITY  = @cFacility)
      BEGIN
         SET @nErrNo = 234917
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need PalletType  
         GOTO Fail
      END
   END
END
 
-- Copy to common variable  
SET @cSKU =  @cSKUCode 
SET @cUOM =  @cSKUUOM    
SET @nQTY =  @nSKUQTY  
  
-- Get SKU's setting  
DECLARE @cLottable01Required NVARCHAR( 1)  
DECLARE @cLottable02Required NVARCHAR( 1)  
DECLARE @cLottable03Required NVARCHAR( 1)  
DECLARE @cLottable04Required NVARCHAR( 1)  
DECLARE @cLottable05Required NVARCHAR( 1)  
DECLARE @cLottable06Required NVARCHAR( 1)  
DECLARE @cLottable07Required NVARCHAR( 1)  
DECLARE @cLottable08Required NVARCHAR( 1)  
DECLARE @cLottable09Required NVARCHAR( 1)  
DECLARE @cLottable10Required NVARCHAR( 1)  
DECLARE @cLottable11Required NVARCHAR( 1)  
DECLARE @cLottable12Required NVARCHAR( 1)  
DECLARE @cLottable13Required NVARCHAR( 1)  
DECLARE @cLottable14Required NVARCHAR( 1)  
DECLARE @cLottable15Required NVARCHAR( 1)  
DECLARE @cLottableCode       NVARCHAR( 30)  
DECLARE @nLCFunc             INT  
  
-- Get SKU info  
SELECT
   @cLottableCode = LottableCode
FROM dbo.SKU SKU (NOLOCK)  
WHERE StorerKey = @cStorerKey  
   AND SKU = @cSKU   
  
-- If function specific lottablecode not setup, use generic one  
SET @nLCFunc = @nFunc  
IF @nLCFunc > 0  
   IF NOT EXISTS( SELECT TOP 1 1  
      FROM rdt.rdtLottableCode WITH (NOLOCK)  
      WHERE LottableCode = @cLottableCode  
         AND Function_ID = @nFunc  
         AND StorerKey = @cStorerKey)  
      SET @nLCFunc = 0  
  
SELECT  
   @cLottable01Required = '0', @cLottable02Required = '0', @cLottable03Required = '0', @cLottable04Required = '0', @cLottable05Required = '0',  
   @cLottable06Required = '0', @cLottable07Required = '0', @cLottable08Required = '0', @cLottable09Required = '0', @cLottable10Required = '0',  
   @cLottable11Required = '0', @cLottable12Required = '0', @cLottable13Required = '0', @cLottable14Required = '0', @cLottable15Required = '0'  
  
-- Get LottableCode info  
SELECT  
   @cLottable01Required = CASE WHEN LottableNo =  1 THEN Required ELSE @cLottable01Required END,  
   @cLottable02Required = CASE WHEN LottableNo =  2 THEN Required ELSE @cLottable02Required END,  
   @cLottable03Required = CASE WHEN LottableNo =  3 THEN Required ELSE @cLottable03Required END,  
   @cLottable04Required = CASE WHEN LottableNo =  4 THEN Required ELSE @cLottable04Required END,  
   @cLottable05Required = CASE WHEN LottableNo =  5 THEN Required ELSE @cLottable05Required END,  
   @cLottable06Required = CASE WHEN LottableNo =  6 THEN Required ELSE @cLottable06Required END,  
   @cLottable07Required = CASE WHEN LottableNo =  7 THEN Required ELSE @cLottable07Required END,  
   @cLottable08Required = CASE WHEN LottableNo =  8 THEN Required ELSE @cLottable08Required END,  
   @cLottable09Required = CASE WHEN LottableNo =  9 THEN Required ELSE @cLottable09Required END,  
   @cLottable10Required = CASE WHEN LottableNo = 10 THEN Required ELSE @cLottable10Required END,  
   @cLottable11Required = CASE WHEN LottableNo = 11 THEN Required ELSE @cLottable11Required END,  
   @cLottable12Required = CASE WHEN LottableNo = 12 THEN Required ELSE @cLottable12Required END,  
   @cLottable13Required = CASE WHEN LottableNo = 13 THEN Required ELSE @cLottable13Required END,  
   @cLottable14Required = CASE WHEN LottableNo = 14 THEN Required ELSE @cLottable14Required END,  
   @cLottable15Required = CASE WHEN LottableNo = 15 THEN Required ELSE @cLottable15Required END  
FROM rdt.rdtLottableCode WITH (NOLOCK)  
WHERE LottableCode = @cLottableCode  
   AND Function_ID = @nLCFunc  
   AND StorerKey = @cStorerKey  
  
DECLARE @nLottableNo INT  
SET @nLottableNo = 0  
  
-- Check all lottables  
IF @nLottableNo = 0 AND @cLottable01Required = '1' AND @cLottable01 = ''    SET @nLottableNo =  1 ELSE  
IF @nLottableNo = 0 AND @cLottable02Required = '1' AND @cLottable02 = ''    SET @nLottableNo =  2 ELSE  
IF @nLottableNo = 0 AND @cLottable03Required = '1' AND @cLottable03 = ''    SET @nLottableNo =  3 ELSE  
IF @nLottableNo = 0 AND @cLottable04Required = '1' AND @dLottable04 IS NULL SET @nLottableNo =  4 ELSE  
IF @nLottableNo = 0 AND @cLottable05Required = '1' AND @dLottable05 IS NULL SET @nLottableNo =  5 ELSE  
IF @nLottableNo = 0 AND @cLottable06Required = '1' AND @cLottable06 = ''    SET @nLottableNo =  6 ELSE  
IF @nLottableNo = 0 AND @cLottable07Required = '1' AND @cLottable07 = ''    SET @nLottableNo =  7 ELSE  
IF @nLottableNo = 0 AND @cLottable08Required = '1' AND @cLottable08 = ''    SET @nLottableNo =  8 ELSE  
IF @nLottableNo = 0 AND @cLottable09Required = '1' AND @cLottable09 = ''    SET @nLottableNo =  9 ELSE  
IF @nLottableNo = 0 AND @cLottable10Required = '1' AND @cLottable10 = ''    SET @nLottableNo = 10 ELSE  
IF @nLottableNo = 0 AND @cLottable11Required = '1' AND @cLottable11 = ''    SET @nLottableNo = 11 ELSE  
IF @nLottableNo = 0 AND @cLottable12Required = '1' AND @cLottable12 = ''    SET @nLottableNo = 12 ELSE  
IF @nLottableNo = 0 AND @cLottable13Required = '1' AND @dLottable13 IS NULL SET @nLottableNo = 13 ELSE  
IF @nLottableNo = 0 AND @cLottable14Required = '1' AND @dLottable14 IS NULL SET @nLottableNo = 14 ELSE  
IF @nLottableNo = 0 AND @cLottable15Required = '1' AND @dLottable15 IS NULL SET @nLottableNo = 15  
  
-- Validate lottable  
IF @nLottableNo > 0  
BEGIN  
   SET @nErrNo = 234915  
   SET @cErrMsg = RTRIM( rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')) + RIGHT( '0' + CAST( @nLottableNo AS NVARCHAR(2)), 2) --NeedLottable99  
   GOTO Fail  
END  
  
-- Not required but pass-in value, need in matching logic below  
IF @cLottable01Required = '0' AND @cLottable01 <> ''       SET @cLottable01Required = '1'  
IF @cLottable02Required = '0' AND @cLottable02 <> ''       SET @cLottable02Required = '1'  
IF @cLottable03Required = '0' AND @cLottable03 <> ''       SET @cLottable03Required = '1'  
IF @cLottable04Required = '0' AND @dLottable04 IS NOT NULL SET @cLottable04Required = '1'  
IF @cLottable05Required = '0' AND @dLottable05 IS NOT NULL SET @cLottable05Required = '1'  
IF @cLottable06Required = '0' AND @cLottable06 <> ''       SET @cLottable06Required = '1'  
IF @cLottable07Required = '0' AND @cLottable07 <> ''       SET @cLottable07Required = '1'  
IF @cLottable08Required = '0' AND @cLottable08 <> ''       SET @cLottable08Required = '1'  
IF @cLottable09Required = '0' AND @cLottable09 <> ''       SET @cLottable09Required = '1'  
IF @cLottable10Required = '0' AND @cLottable10 <> ''       SET @cLottable10Required = '1'  
IF @cLottable11Required = '0' AND @cLottable11 <> ''       SET @cLottable11Required = '1'  
IF @cLottable12Required = '0' AND @cLottable12 <> ''       SET @cLottable12Required = '1'  
IF @cLottable13Required = '0' AND @dLottable13 IS NOT NULL SET @cLottable13Required = '1'  
IF @cLottable14Required = '0' AND @dLottable14 IS NOT NULL SET @cLottable14Required = '1'  
IF @cLottable15Required = '0' AND @dLottable15 IS NOT NULL SET @cLottable15Required = '1'  
  
/*-------------------------------------------------------------------------------  
  
                            KitDetail lookup logic  
  
-------------------------------------------------------------------------------*/  
  

DECLARE @cKitDtlLineNumber               NVARCHAR( 5)  
DECLARE @cNewKitDtlLineNumber            NVARCHAR( 5) -- (ChewKP01)  
  
  
IF @bDebugFlag = 1 
BEGIN  
   SELECT @cToID '@cToID', @cToLOC '@cToLOC',  
      @cLottable01 '@cLottable01', @cLottable02 '@cLottable02', @cLottable03 '@cLottable03', @dLottable04 '@dLottable04', @dLottable05 '@dLottable05',  
      @cLottable06 '@cLottable06', @cLottable07 '@cLottable07', @cLottable08 '@cLottable08', @cLottable09 '@cLottable09', @cLottable10 '@cLottable10',  
      @cLottable11 '@cLottable11', @cLottable12 '@cLottable12', @dLottable13 '@dLottable13', @dLottable14 '@dLottable14', @dLottable15 '@dLottable15'  
   SELECT  
      @cLottable01Required '@cLottable01Required', @cLottable02Required '@cLottable02Required', @cLottable03Required '@cLottable03Required', @cLottable04Required '@cLottable04Required', @cLottable05Required '@cLottable05Required',  
      @cLottable06Required '@cLottable06Required', @cLottable07Required '@cLottable07Required', @cLottable08Required '@cLottable08Required', @cLottable09Required '@cLottable09Required', @cLottable10Required '@cLottable10Required',  
      @cLottable11Required '@cLottable11Required', @cLottable12Required '@cLottable12Required', @cLottable13Required '@cLottable13Required', @cLottable14Required '@cLottable14Required', @cLottable15Required '@cLottable15Required'  
END

DECLARE @cChkPalletType NVARCHAR( 20)

SELECT TOP 1  
   @cKitDtlLineNumber = KITLineNumber,
   @cChkPalletType = PalletType 
FROM dbo.KITDETAIL WITH (NOLOCK)  
WHERE  Storerkey = @cStorerKey
   AND KITKey = @cKitKey
   AND Type = 'T'
   AND Loc = @cToLOC 
   AND Id = @cToID
   AND Sku = @cSKU 
   AND UOM = @cUOM 
   AND (@cLottable01Required = '0' OR Lottable01 = @cLottable01)  
   AND (@cLottable02Required = '0' OR Lottable02 = @cLottable02)  
   AND (@cLottable03Required = '0' OR Lottable03 = @cLottable03)  
   AND (@cLottable04Required = '0' OR ISNULL( Lottable04, 0) = ISNULL( @dLottable04, 0))  
   AND (@cLottable05Required = '0' OR ISNULL( Lottable05, 0) = ISNULL( @dLottable05, 0))  
   AND (@cLottable06Required = '0' OR Lottable06 = @cLottable06)  
   AND (@cLottable07Required = '0' OR Lottable07 = @cLottable07)  
   AND (@cLottable08Required = '0' OR Lottable08 = @cLottable08)  
   AND (@cLottable09Required = '0' OR Lottable09 = @cLottable09)  
   AND (@cLottable10Required = '0' OR Lottable10 = @cLottable10)  
   AND (@cLottable11Required = '0' OR Lottable11 = @cLottable11)  
   AND (@cLottable12Required = '0' OR Lottable12 = @cLottable12)  
   AND (@cLottable13Required = '0' OR IsNULL( Lottable13, 0) = IsNULL( @dLottable13, 0))  
   AND (@cLottable14Required = '0' OR IsNULL( Lottable14, 0) = IsNULL( @dLottable14, 0))  
   AND (@cLottable15Required = '0' OR IsNULL( Lottable15, 0) = IsNULL( @dLottable15, 0))

IF @bDebugFlag = 1
BEGIN
   SELECT 'Select existing Kit Detail', @cKitDtlLineNumber AS KitDtlLineNumber
END

-- Handling transaction  
SET @nTranCount = @@TRANCOUNT  
BEGIN TRAN  -- Begin our own transaction  
SAVE TRAN rdt_BuildPalletToKit_Confirm -- For rollback or commit only our own transaction  

IF ISNULL (@cKitDtlLineNumber, '') <> '' -- Existing kitdetail found
BEGIN
   BEGIN TRY
      UPDATE dbo.KITDETAIL WITH (ROWLOCK)
      SET 
         Qty = Qty + @nQTY,
         ExpectedQty = ExpectedQty + @nQTY 
      WHERE KITKey = @cKitKey
         AND KITLineNumber = @cKitDtlLineNumber
   END TRY
   BEGIN CATCH
      SET @nErrNo = 234919
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Update KitDetail failed'
      GOTO RollBackTran
   END CATCH
END
ELSE --No existing kitline found
BEGIN
   SET @cNewKITDtlLineNumber = ''  
   SELECT @cNewKITDtlLineNumber =  
   RIGHT( '00000' + CAST( CAST( IsNULL( MAX(KITLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)  
   FROM dbo.KITDetail WITH (NOLOCK)  
   WHERE KITKey = @cKitKey
      AND Type = 'T'

   IF @bDebugFlag = 1
   BEGIN
      SELECT 'New Kit Detail Line Number', @cNewKITDtlLineNumber AS NewKitDtlLineNumber
   END

   BEGIN TRY
      INSERT INTO dbo.KITDETAIL  
      ( KITKey, KITLineNumber, Type, StorerKey, SKU, lot, Loc, Id,  
      ExpectedQty, Qty, PackKey, UOM, ExternKitKey,
      Lottable01, Lottable02, Lottable03, Lottable04, Lottable05,  
      Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,  
      Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,  
      PalletType)
      VALUES
      ( @cKitKey, @cNewKITDtlLineNumber, 'T', @cStorerKey, @cSKU, '', @cToLOC, @cToID,  
         @nQTY, @nQTY, @cPackKey, @cUOM, @cExtKitKey,  
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,  
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,  
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,  
         @cPalletType
      )
   END TRY
   BEGIN CATCH
      SET @nErrNo = 234920
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Insert KitDetail failed'
      GOTO RollBackTran
   END CATCH
END
  
IF @bDebugFlag = 1
BEGIN  
   SELECT * FROM dbo.KITDETAIL (NOLOCK) WHERE KITKey = @cKitKey  
END  
ELSE  
BEGIN  
   COMMIT TRAN rdt_BuildPalletToKit_Confirm -- Only commit change made in here  
   GOTO Quit  
END  
  
RollBackTran:  
   ROLLBACK TRAN rdt_BuildPalletToKit_Confirm  
Fail:  
Quit:
   IF @bDebugFlag = 1
   BEGIN
      SELECT 'Quit', @nErrNo AS ErrNo, @cErrMsg AS ErrorMessage
   END
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN  
GO
GRANT EXECUTE ON  [RDT].[rdt_BuildPalletToKit_Confirm] TO [NSQL]
GO