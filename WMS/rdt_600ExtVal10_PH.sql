SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_600ExtVal10_PH                                  */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Purpose: PHARMA													    */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2022-03-17 1.0  MBI165    PHARMA                                     */
/************************************************************************/

CREATE   OR ALTER    PROC [RDT].[rdt_600ExtVal10_PH] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5), 
   @cStorerKey   NVARCHAR( 15), 
   @cReceiptKey  NVARCHAR( 10), 
   @cPOKey       NVARCHAR( 10), 
   @cLOC         NVARCHAR( 10), 
   @cID          NVARCHAR( 18), 
   @cSKU         NVARCHAR( 20), 
   @cLottable01  NVARCHAR( 18), 
   @cLottable02  NVARCHAR( 18), 
   @cLottable03  NVARCHAR( 18), 
   @dLottable04  DATETIME,      
   @dLottable05  DATETIME,      
   @cLottable06  NVARCHAR( 30), 
   @cLottable07  NVARCHAR( 30), 
   @cLottable08  NVARCHAR( 30), 
   @cLottable09  NVARCHAR( 30), 
   @cLottable10  NVARCHAR( 30), 
   @cLottable11  NVARCHAR( 30), 
   @cLottable12  NVARCHAR( 30), 
   @dLottable13  DATETIME,      
   @dLottable14  DATETIME,      
   @dLottable15  DATETIME,      
   @nQTY         INT,           
   @cReasonCode  NVARCHAR( 10), 
   @cSuggToLOC   NVARCHAR( 10), 
   @cFinalLOC    NVARCHAR( 10), 
   @cReceiptLineNumber NVARCHAR( 10), 
   @nErrNo       INT            OUTPUT, 
   @cErrMsg      NVARCHAR( 20)  OUTPUT
)
AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cPackKey        NVARCHAR(10) 
          ,@nPallet         INT
          ,@cLot07          NVARCHAR(30)
          ,@cLot08          NVARCHAR(30)
          ,@cLot10          NVARCHAR(30)
          ,@cUserdefine08   NVARCHAR(30)
          ,@cUserdefine09   NVARCHAR(30)
          ,@cUserdefine10   NVARCHAR(30)
          ,@cQtyExpected     INT

          

   IF @nFunc = 600 -- Normal receiving
   BEGIN
        IF @nStep = 3 -- ToID
            IF @nInputKey = 1 -- ENTER
            BEGIN
                -- Receive to ID
                IF @cID <> ''
                BEGIN
                -- New ID
                    IF NOT EXISTS( SELECT 1 FROM ReceiptDetail WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND ToID = @cID)
                        BEGIN
                        SET @nErrNo = 218270 
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID Not In ASN  
                        GOTO QUIT 
                        END
  
                END
            END       
        IF @nStep = 4 -- SKU
            BEGIN
                IF @nInputKey = 1 -- ENTER
                BEGIN

                    SELECT TOP 1  
                    @cLot07         = ISNULL(Lottable07,'')        
                    ,@cLot08        = ISNULL(Lottable08,'')    
                    ,@cLot10        = ISNULL(Lottable10,'')  
                    ,@cUserdefine08 = ISNULL(Userdefine08,'')      
                    ,@cUserdefine09 = ISNULL(Userdefine09,'')    
                    ,@cUserdefine10 = ISNULL(Userdefine10,'')  
                    FROM RECEIPTDETAIL (NOLOCK)
                    WHERE Receiptkey=@cReceiptKey
                    AND sku =@csku
                    AND TOID= @cID
                    AND storerkey=@cStorerKey

                IF EXISTS (SELECT 1  FROM
                            RECEIPTDETAIL (NOLOCK)
                            WHERE Receiptkey=@cReceiptKey
                            AND TOID= @cID
                            AND storerkey=@cStorerKey)
                    BEGIN
                        IF EXISTS (SELECT 1  FROM
                                RECEIPTDETAIL (NOLOCK)
                                WHERE Receiptkey=@cReceiptKey
                                AND sku<>@csku
                                AND TOID= @cID
                                AND storerkey=@cStorerKey)
                            BEGIN
                            SET @nErrNo = 184351   
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- ID in USE  
                            GOTO QUIT 
                            END

                        --Customs status wrong - Should be T1-TEMP or T2-ENT                  
                        IF @cLot10 NOT IN  ('T1-TEMP','T2-ENT')     
                            BEGIN
                            SET @nErrNo = 218271   
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Customs status wrong - Should be T1-TEMP or T2-ENT
                            GOTO QUIT 
                            END   
                        --Customs document number missing
                        IF @cLot10 = 'T1-TEMP' AND @cUserdefine08 = '' 
                            BEGIN
                            SET @nErrNo = 218272   
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Customs document number missing
                            GOTO QUIT 
                            END          
                        --Container Number Missing
                        IF @cLot08 = ''    
                            BEGIN
                            SET @nErrNo = 218273   
                            SET @cErrMsg = 'Container MSNG'--rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Container Number Missing
                            GOTO QUIT 
                            END 
                        --Temperature Range Missing
                        IF @cLot07 = ''                 
                            BEGIN
                            SET @nErrNo = 218274   
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Temperature Range Missing 
                            GOTO QUIT 
                            END 
                        --COO or HS Code is missing for T1-TEMP
                        IF @cLot10 = 'T1-TEMP' AND ( @cUserdefine08 = '' OR   @cUserdefine09 = '' )   
                            BEGIN
                            SET @nErrNo = 218275   
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- COO or HS Code is missing for T1-TEMP 
                            GOTO QUIT 
                            END                 
                    
                    END
                END
            END
       IF @nStep = 6 -- QTY
                BEGIN
                IF @nInputKey = 1 -- ENTER
                    BEGIN 
                        SELECT TOP 1  
                        @cQtyExpected = QtyExpected        
                        FROM RECEIPTDETAIL (NOLOCK)
                        WHERE Receiptkey=@cReceiptKey
                        AND sku =@csku
                        AND TOID= @cID
                        AND storerkey=@cStorerKey
                        
                    -- Condition Code is Not Correct For Under Receipt
                    IF ( @cQtyExpected > ISNULL(@nQTY,0) AND @cReasonCode = 'OK' )
                    BEGIN
                    SET @nErrNo = 218276   
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Condition Code is Not Correct For Under Receipt
                    GOTO QUIT 
                    END

                    --Over Receiving Not Allowed
                    IF ( @cQtyExpected < ISNULL(@nQTY,0))
                    BEGIN
                    SET @nErrNo = 218278   
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Over Receiving Not Allowed
                    GOTO QUIT 
                    END
                END            
        END 
   END         

   Quit:

GO
