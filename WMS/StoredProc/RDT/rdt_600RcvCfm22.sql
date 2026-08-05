SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
  
/***************************************************************************/  
/* Store procedure: rdt_600RcvCfm22                                        */
/* Copyright      : Maersk                                                 */
/*                                                                         */  
/* Purpose: Client VNM Michelin                                            */
/*                                                                         */
/* Date       Rev  Author  Purposes                                        */
/* 2025-05-20 1.0  CYU027   FCR-4213 Created                               */
/* 2026-06-29 1.1  Sreeja   FCR-14112 Default QTY for PC&TB tires          */
/* 2026-07-28 1.2  Cuize    FCR-14406 Configurable cutoff, PC class only   */
/***************************************************************************/
  
CREATE OR ALTER PROC [RDT].[rdt_600RcvCfm22](
   @nFunc          INT,             
   @nMobile        INT,             
   @cLangCode      NVARCHAR( 3),    
   @cStorerKey     NVARCHAR( 15),   
   @cFacility      NVARCHAR( 5),    
   @cReceiptKey    NVARCHAR( 10),   
   @cPOKey         NVARCHAR( 10),   
   @cToLOC         NVARCHAR( 10),   
   @cToID          NVARCHAR( 18),   
   @cSKUCode       NVARCHAR( 20),   
   @cSKUUOM        NVARCHAR( 10),   
   @nSKUQTY        INT,             
   @cUCC           NVARCHAR( 20),   
   @cUCCSKU        NVARCHAR( 20),   
   @nUCCQTY        INT,             
   @cCreateUCC     NVARCHAR( 1),    
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
   @nNOPOFlag      INT,             
   @cConditionCode NVARCHAR( 10),   
   @cSubreasonCode NVARCHAR( 10),   
   @nErrNo         INT           OUTPUT,   
   @cErrMsg        NVARCHAR( 20) OUTPUT,   
   @cReceiptLineNumberOutput NVARCHAR( 5) OUTPUT,  
   @cSerialNo      NVARCHAR( 30) = '',     
   @nSerialQTY     INT = 0,     
   @nBulkSNO       INT = 0,     
   @nBulkSNOQTY    INT = 0   
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Restore pallet ID when framework cleared V_ID after prior receipt confirm
   IF ISNULL(@cToID, '') = ''
   BEGIN
       SELECT @cToID = LTRIM(RTRIM(C_String3))
       FROM rdt.RDTMOBREC WITH (NOLOCK)
       WHERE Mobile = @nMobile
   END

   DECLARE  @cUserDefine01       NVARCHAR( 60),
            @TargetDate          DATETIME,
            @FirstWeekDay        DATETIME,
            @JanuaryFirst        DATETIME,
            @Week                INT,
            @Year                INT,
            @WeekYear            VARCHAR(4)

   SET DATEFIRST 1 -- Monday as first day

   DECLARE @cSKUType NVARCHAR(10) = ''
   DECLARE @cItemClass NVARCHAR(10) = ''
   SELECT @cSKUType = Class, @cItemClass = ItemClass
   FROM dbo.SKU WITH (NOLOCK)
   WHERE SKU = @cSKUCode
     AND StorerKey = @cStorerKey

   -- Use ItemClass for POSM check (POSM is stored in ItemClass column)
   IF (ISNULL(@cItemClass,'') = 'POSM')
   BEGIN
      GOTO Receive
   END

   -- FCR-14406: Get facility prefix for sub-inventory code
   DECLARE @cFacilityPrefix NVARCHAR(30)
   SELECT @cFacilityPrefix = UserDefine01
   FROM dbo.Facility WITH (NOLOCK)
   WHERE Facility = @cFacility

   -- FCR-14406: DOT logic only applies to SKU.Class = 'PC'
   -- Other classes default to FRESH
   IF ISNULL(@cSKUType, '') <> 'PC'
   BEGIN
      SET @cLottable03 = @cFacilityPrefix + '-' + 'FRESH'
      GOTO Receive
   END

   -- Determine correct MIN DOT BEFORE date conversion
   -- First tire on pallet: MIN DOT defaults to PCS DOT
   IF ISNULL(@cLottable02, '') = '' AND ISNULL(@cLottable07, '') <> '' AND LEN(@cLottable07) = 4
   BEGIN
      SET @cLottable02 = @cLottable07
   END
   -- PCS DOT older than existing MIN DOT (same year): this row also uses PCS DOT as MIN DOT
   ELSE IF ISNULL(@cLottable07, '') <> '' AND LEN(@cLottable07) = 4
        AND ISNULL(@cLottable02, '') <> '' AND LEN(@cLottable02) = 4
   BEGIN
      DECLARE @nPCSDOT_W_Cfm INT
      DECLARE @nPCSDOT_Y_Cfm INT
      DECLARE @nMINDOT_W_Cfm INT
      DECLARE @nMINDOT_Y_Cfm INT
      SET @nPCSDOT_W_Cfm = TRY_CAST(LEFT(@cLottable07, 2) AS INT)
      SET @nPCSDOT_Y_Cfm = TRY_CAST(RIGHT(@cLottable07, 2) AS INT)
      SET @nMINDOT_W_Cfm = TRY_CAST(LEFT(@cLottable02, 2) AS INT)
      SET @nMINDOT_Y_Cfm = TRY_CAST(RIGHT(@cLottable02, 2) AS INT)
      IF @nPCSDOT_Y_Cfm IS NOT NULL AND @nMINDOT_Y_Cfm IS NOT NULL
         AND @nPCSDOT_Y_Cfm = @nMINDOT_Y_Cfm AND @nPCSDOT_W_Cfm < @nMINDOT_W_Cfm
      BEGIN
         SET @cLottable02 = @cLottable07
      END
   END

   SET @WeekYear = @cLottable02
   -- Check if the input is exactly 4 characters and is a valid week and year
   IF LEN(@WeekYear) = 4 AND ISNUMERIC(SUBSTRING(@WeekYear, 1, 2)) > 0 AND ISNUMERIC(SUBSTRING(@WeekYear, 3, 2)) > 0
   BEGIN

      SET @Week = CAST(SUBSTRING(@WeekYear, 1, 2) AS INT);
      SET @Year = CAST(SUBSTRING(@WeekYear, 3, 2) AS INT);

      -- Check if the week number is between 1 and 53
      IF @Week BETWEEN 1 AND 53
      BEGIN
         -- Determine the January 1st of the given year
         SET @JanuaryFirst = CAST(('20' + RIGHT(@Year + 2000, 2) + '-01-01') AS DATE); -- Assuming the year is within 2000-2099

         --IOS FIRST WEEK START AT SATURDAY
         IF DATEPART(WEEKDAY, @JanuaryFirst) < 5
            SET @FirstWeekDay = @JanuaryFirst;
         ELSE
            SET @FirstWeekDay = DATEADD(WEEK, 1, @JanuaryFirst);


         -- Calculate the target date based on the week number and assuming the week starts on Monday
         SET @TargetDate = DATEADD(WEEK, @Week - 1, @FirstWeekDay);

         --SET to monday
         SET @TargetDate = DATEADD(DAY,(1-DATEPART(WEEKDAY,@TargetDate)),@TargetDate)

         IF (YEAR(@TargetDate) < 2000+@Year)
            SET @TargetDate = @JanuaryFirst

      END
      ELSE
      BEGIN
         SET @cLottable03 = @cFacilityPrefix + '-' + 'FRESH'
         GOTO Receive
      END
   END
   ELSE
   BEGIN
      SET @cLottable03 = @cFacilityPrefix + '-' + 'FRESH'
      GOTO Receive
   END

   SET @dLottable04 = @TargetDate

   DECLARE @CurrentDate DATETIME
   SET @CurrentDate = GETDATE()

   IF @TargetDate > @CurrentDate OR YEAR(@TargetDate) > 2000 + @Year
   BEGIN
      SET @cLottable03 = @cFacilityPrefix + '-' + 'FRESH'
      GOTO Receive
   END

   -- FCR-14406: Get cutoff date from CODELKUP based on SKU Class
   DECLARE @cCutoffMMDD NVARCHAR(10)
   DECLARE @dCutoffDate DATE
   DECLARE @nThisYear INT = YEAR(@CurrentDate)
   DECLARE @nDotYear INT = 2000 + @Year

   SELECT TOP 1 @cCutoffMMDD = Short
   FROM dbo.CODELKUP WITH (NOLOCK)
   WHERE ListName = 'MICDOTCTOF'
     AND Code = @cSKUType
     AND Storerkey = @cStorerKey

   -- Validate cutoff date exists and has correct format (MMDD)
   IF ISNULL(@cCutoffMMDD, '') = ''
   BEGIN
      SET @nErrNo = 275901
      SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
      GOTO Quit
   END

   IF LEN(@cCutoffMMDD) <> 4 OR ISNUMERIC(@cCutoffMMDD) = 0
   BEGIN
      SET @nErrNo = 275902
      SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
      GOTO Quit
   END

   -- Build cutoff date from MMDD
   BEGIN TRY
      SET @dCutoffDate = DATEFROMPARTS(
         @nThisYear,
         CAST(LEFT(@cCutoffMMDD, 2) AS INT),
         CAST(RIGHT(@cCutoffMMDD, 2) AS INT)
      )
   END TRY
   BEGIN CATCH
      SET @nErrNo = 275903
      SET @cErrMsg = rdt.rdtGetMessage(@nErrNo, @cLangCode, N'DSP')
      GOTO Quit
   END CATCH

   -- FCR-14406: Apply FRESH/OLD logic based on cutoff date
   -- If today < cutoff: DOT year < (ThisYear - 1) → OLD, else FRESH
   -- If today >= cutoff: DOT year < ThisYear → OLD, else FRESH
   IF (@CurrentDate < @dCutoffDate AND @nDotYear < (@nThisYear - 1))
      OR (@CurrentDate >= @dCutoffDate AND @nDotYear < @nThisYear)
      SET @cLottable03 = @cFacilityPrefix + '-' + 'OLD'
   ELSE
      SET @cLottable03 = @cFacilityPrefix + '-' + 'FRESH'

--    UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET
--                                               Lottable04 = @dLottable04,
--                                               Lottable03 = @cLottable03,
--                                               EditDate = GETDATE(),
--                                               EditWho = SUSER_SNAME()
--    WHERE ReceiptKey = @cReceiptKey
--      AND ReceiptLineNumber = @cReceiptLineNumber

   Receive:
   -- FCR-14112: VND Michelin - Default QTY from CODELKUP for PC/TB tires if incoming QTY is 0
   IF ISNULL(@nSKUQTY, 0) = 0 AND @cSKUType IN ('PC', 'TB')
   BEGIN
       DECLARE @cDefaultQty NVARCHAR(10)
       DECLARE @nDefaultQty INT

       -- Lookup default QTY from CODELKUP based on SKU CLASS and master UoM
       SELECT TOP 1 @cDefaultQty = Short
       FROM dbo.CODELKUP WITH (NOLOCK)
       WHERE ListName = 'MICPCSIBDF'
         AND StorerKey = @cStorerKey
         AND Code = @cSKUType
         AND Long = @cSKUUOM  -- Validate master UoM matches

       -- Set QTY only if valid number found in CODELKUP
       IF ISNULL(@cDefaultQty, '') <> '' AND RDT.rdtIsValidQty(@cDefaultQty, 1) = 1
       BEGIN
           SET @nDefaultQty = TRY_CAST(@cDefaultQty AS INT)
           IF ISNULL(@nDefaultQty, 0) > 0
           BEGIN
               SET @nSKUQTY = @nDefaultQty
           END
       END
       -- If no CODELKUP entry found, QTY remains as-is (blank behavior per requirement)
   END

   -- Call rdt_Receive_V7 to complete receiving
   EXEC rdt.rdt_Receive_V7
      @nFunc         = @nFunc,    
      @nMobile       = @nMobile,    
      @cLangCode     = @cLangCode,    
      @nErrNo        = @nErrNo OUTPUT,    
      @cErrMsg       = @cErrMsg OUTPUT,    
      @cStorerKey    = @cStorerKey,    
      @cFacility     = @cFacility,    
      @cReceiptKey   = @cReceiptKey,    
      @cPOKey        = @cPoKey,    
      @cToLOC        = @cToLOC,    
      @cToID         = @cToID,    
      @cSKUCode      = @cSKUCode,    
      @cSKUUOM       = @cSKUUOM,    
      @nSKUQTY       = @nSKUQTY,    
      @cUCC          = '',    
      @cUCCSKU       = '',    
      @nUCCQTY       = '',    
      @cCreateUCC    = '',    
      @cLottable01   = @cLottable01,    
      @cLottable02   = @cLottable02,    
      @cLottable03   = @cLottable03,    
      @dLottable04   = @dLottable04,    
      @dLottable05   = @dLottable05,    
      @cLottable06   = @cLottable06,    
      @cLottable07   = @cLottable07,    
      @cLottable08   = @cLottable08,    
      @cLottable09   = @cLottable09,    
      @cLottable10   = @cLottable10,    
      @cLottable11   = @cLottable11,    
      @cLottable12   = @cLottable12,    
      @dLottable13   = @dLottable13,    
      @dLottable14   = @dLottable14,    
      @dLottable15   = @dLottable15,    
      @nNOPOFlag     = @nNOPOFlag,    
      @cConditionCode = @cConditionCode,
      @cSubreasonCode = '',
      @cReceiptLineNumberOutput = @cReceiptLineNumberOutput OUTPUT

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_600RcvCfm22 TO NSQL
GO
