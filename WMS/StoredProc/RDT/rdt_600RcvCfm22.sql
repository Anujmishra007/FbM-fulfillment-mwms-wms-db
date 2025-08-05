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

   DECLARE  @cUserDefine01       NVARCHAR( 60),
            @TargetDate          DATETIME,
            @FirstWeekDay        DATETIME,
            @JanuaryFirst        DATETIME,
            @Week                INT,
            @Year                INT,
            @WeekYear            VARCHAR(4)




   SET DATEFIRST 1 -- Monday as first day

   DECLARE @cSKUType NVARCHAR(10) = ''
   SELECT @cSKUType = itemclass FROM SKU (NOLOCK)
   WHERE SKU = @cSKUCode
     AND StorerKey = @cStorerKey

   IF (ISNULL(@cSKUType,'') = 'POSM')
   BEGIN
      GOTO Receive
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
         GOTO Receive
      END
   END
   ELSE
   BEGIN
      GOTO Receive
   END

   SET @dLottable04 = @TargetDate

   DECLARE @CurrentDate DATETIME
   SET @CurrentDate = GETDATE()

   IF @TargetDate>@CurrentDate OR YEAR(@TargetDate) > 2000+@Year
   BEGIN
      GOTO Receive
   END


   DECLARE @cFacilityPrefix NVARCHAR(30)
   SELECT @cFacilityPrefix = UserDefine01 FROM Facility where Facility = @cFacility

   IF (MONTH(@CurrentDate) < 7 AND YEAR(@TargetDate) < (YEAR(@CurrentDate)-1))
      OR (MONTH(@CurrentDate) >= 7 AND YEAR(@TargetDate) < YEAR(@CurrentDate))
      SET @cLottable03 =  @cFacilityPrefix +'-'+'OLD'
   ELSE
      SET @cLottable03 = @cFacilityPrefix +'-'+'FRESH'

--    UPDATE dbo.ReceiptDetail WITH (ROWLOCK) SET
--                                               Lottable04 = @dLottable04,
--                                               Lottable03 = @cLottable03,
--                                               EditDate = GETDATE(),
--                                               EditWho = SUSER_SNAME()
--    WHERE ReceiptKey = @cReceiptKey
--      AND ReceiptLineNumber = @cReceiptLineNumber

   Receive:
   -- Receive    
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
  
  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_600RcvCfm22 TO NSQL
GO
