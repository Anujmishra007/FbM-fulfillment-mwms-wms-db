
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/******************************************************************************/  
/* Store procedure: rdt_600ExtSNVal02                                         */  
/* Copyright      : Maersk                                                    */  
/*                                                                            */  
/* Date        Rev  Author       Purposes                                     */  
/* 10-03-2025  1.0  yeekung      UWP-31293 Created                            */  
/******************************************************************************/  
  
CREATE OR ALTER  PROCEDURE rdt.rdt_600ExtSNVal02  
   @nMobile          INT,  
   @nFunc            INT,  
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,  
   @nInputKey        INT,  
   @cFacility        NVARCHAR( 3),  
   @cStorerKey       NVARCHAR( 15),  
   @cSKU             NVARCHAR( 20),  
   @nQTY             INT,   
   @cSerialNo        NVARCHAR( 30),  
   @cType            NVARCHAR( 15), --CHECK/INSERT  
   @cDocType         NVARCHAR( 10),   
   @cDocNo           NVARCHAR( 20),   
   @nErrNo           INT           OUTPUT,  
   @cErrMsg          NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cReceiptKey NVARCHAR( 10)  
   DECLARE @cChkStatus  NVARCHAR( 10)  
   DECLARE @cASNType    NVARCHAR( 1)  
   DECLARE @nRowCount   INT  
   DECLARE @b_success   INT = 1  
   DECLARE @cAllow_OverReceipt NVARCHAR(1)  
   DECLARE @cByPassTolerance NVARCHAR(1)  
   DECLARE @nTolerancePercentage  INT    
   DECLARE @cSUSR4                NVARCHAR( 18)  
   DECLARE @nQTYExpected_Total INT  
   DECLARE @nQTY_Bal   INT  
  
   IF @nFunc = 600 -- Normal receiving  
   BEGIN  
      -- Get Receipt info  
      SET @cReceiptKey = @cDocNo  
      SELECT @cASNType = DocType FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey  
  
      SELECT    
          @cSUSR4 = ISNULL( SUSR4, '')    
      FROM dbo.SKU SKU (NOLOCK)    
      WHERE StorerKey = @cStorerKey    
         AND SKU = @cSKU    
        
      -- Normal ASN/ Cross Dock  
      IF @cASNType IN ('A','X')  
      BEGIN  
         -- Check SNO received  
         IF EXISTS( SELECT TOP 1 1  
            FROM ReceiptSerialNo WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
               AND SerialNo = @cSerialNo)  
         BEGIN  
            SET @nErrNo = 234651  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO received  
            GOTO Quit  
         END  
           
         -- Check SNO received  
         IF EXISTS( SELECT TOP 1 1  
            FROM SerialNo WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
               AND SKU = @cSKU  
               AND SerialNo = @cSerialNo)  
         BEGIN  
            SET @nErrNo = 234652  
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SNO received  
            GOTO Quit  
         END  
  
         -- Storer config 'Allow_OverReceipt'    
         EXECUTE dbo.nspGetRight    
            @cFacility, -- (cc01)    
            @cStorerKey,    
            @cSKU,    
            'Allow_OverReceipt',    
            @b_success             OUTPUT,    
            @cAllow_OverReceipt    OUTPUT,    
            @nErrNo                OUTPUT,    
            @cErrMsg               OUTPUT    
         IF @b_success <> 1    
         BEGIN    
            SET @nErrNo = 234653    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'nspGetRight'    
            GOTO Quit    
         END    
  
         -- Storer config 'ByPassTolerance'    
         EXECUTE dbo.nspGetRight    
            NULL, -- Facility    
            @cStorerKey,    
            NULL,    
            'ByPassTolerance',    
            @b_success           OUTPUT,    
            @cByPassTolerance    OUTPUT,    
            @nErrNo              OUTPUT,    
            @cErrMsg             OUTPUT    
         IF @b_success <> 1    
         BEGIN    
            SET @nErrNo = 234654    
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'nspGetRight'    
            GOTO Quit    
         END    
  
         SELECT   
            @nQTYExpected_Total = IsNULL( SUM( QTYExpected), 0),  
            @nQTY_Bal = IsNULL( SUM( BeforeReceivedQTY), 0)    
         FROM ReceiptDetail (NOLOCK)  
         WHERE Receiptkey = @cReceiptKey  
            AND Storerkey = @cStorerkey  
            AND SKU = @cSKU  
         GROUP BY SKU  
           
  
         -- Not allow over receive, by DocType (follow Exceed way in ntrReceiptDetailUpdate)      
         IF @cAllow_OverReceipt IN ('0', '') OR                   -- Not allow for all doc type      
            (@cAllow_OverReceipt = '2' AND @cDocType <> 'R') OR   -- Not allow, except return (means only return is allow)      
            (@cAllow_OverReceipt = '3' AND @cDocType <> 'A') OR   -- Not allow, except normal (means only normal is allow)      
            (@cAllow_OverReceipt = '4' AND @cDocType <> 'X')      -- Not allow, except xdock  (means only xdoc   is allow)      
         BEGIN      
            -- Over received      
            IF (@nQTY_Bal + 1) > @nQTYExpected_Total      
            BEGIN      
               SET @nErrNo = 234655      
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Over Receive'      
               GOTO Quit      
            END      
         END      
         ELSE -- Allow over receive      
         BEGIN      
              
            --(yeekung01)    
            -- Not allow over receive, by DocType (follow Exceed way in ntrReceiptDetailUpdate)      
            IF @cByPassTolerance IN ('0', '') OR                   -- Not allow for all doc type      
               (@cByPassTolerance = '2' AND @cDocType <> 'R') OR   -- Not allow, except return (means only return is allow)      
               (@cByPassTolerance = '3' AND @cDocType <> 'A') OR   -- Not allow, except normal (means only normal is allow)      
               (@cByPassTolerance = '4' AND @cDocType <> 'X')      -- Not allow, except xdock  (means only xdoc   is allow)       
            BEGIN      
               SET @nTolerancePercentage = 0      
               SET @cSUSR4 = LEFT( @cSUSR4, 9) -- integer max = 2,147,483,647 (10 chars). Take 9 chars to prevent overlow      
               IF rdt.rdtIsInteger( @cSUSR4) = 1      
                  SET @nTolerancePercentage = CAST( @cSUSR4 AS INT)      
              
               -- Check if over tolerance %      
               IF (@nQTY_Bal + 1) > (@nQTYExpected_Total * (1 + (@nTolerancePercentage * 0.01)))      
               BEGIN      
                  SET @nErrNo = 234656      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'OverTolerance%'      
                  GOTO Quit      
               END      
            END      
         END    
    
      END  
   END  
  
Quit:  
  
END  

GO

GRANT EXECUTE ON rdt.rdt_600ExtSNVal02 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
