SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Store procedure: rdt_830ExtVal01_CUR                                 */  
/* Copyright      : LFLogistics                                         */  
/*                                                                      */  
/* Purpose: DropID compulsory                                           */  
/*                                                                      */  
/* Date        Rev  Author      Purposes                                */  
/* 01-09-2025  1.0  TTW017      Based on rdt_830ExtVal01, add to check  */  
/*                              if DropID is being used                 */      
/************************************************************************/         
          
CREATE OR ALTER PROC [RDT].[rdt_830ExtVal01_CUR]  (
   @nMobile       INT,             
   @nFunc         INT,             
   @cLangCode     NVARCHAR( 3),    
   @nStep         INT,             
   @nInputKey     INT,             
   @cFacility     NVARCHAR( 5),    
   @cStorerKey    NVARCHAR( 15),   
   @cPickSlipNo   NVARCHAR( 10),  
   @cPickZone     NVARCHAR( 10),  
   @cSuggLOC      NVARCHAR( 10),   
   @cLOC          NVARCHAR( 10),   
   @cDropID       NVARCHAR( 20),   
   @cSKU          NVARCHAR( 20),   
   @cLottable01   NVARCHAR( 18),   
   @cLottable02   NVARCHAR( 18),   
   @cLottable03   NVARCHAR( 18),   
   @dLottable04   DATETIME,        
   @dLottable05   DATETIME,        
   @cLottable06   NVARCHAR( 30),   
   @cLottable07   NVARCHAR( 30),   
   @cLottable08   NVARCHAR( 30),   
   @cLottable09   NVARCHAR( 30),   
   @cLottable10   NVARCHAR( 30),   
   @cLottable11   NVARCHAR( 30),   
   @cLottable12   NVARCHAR( 30),   
   @dLottable13   DATETIME,        
   @dLottable14   DATETIME,        
   @dLottable15   DATETIME,        
   @nTaskQTY      INT,             
   @nQTY          INT,             
   @cToLOC        NVARCHAR( 10),   
   @cOption       NVARCHAR( 1),    
   @nErrNo        INT           OUTPUT,  
   @cErrMsg       NVARCHAR( 20) OUTPUT   
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   IF @nFunc = 830 -- PickSKU  
   BEGIN  
      IF @nStep = 2 -- LOC  
      BEGIN  
         IF @nInputKey = 1 -- ENTER  
         BEGIN  
            IF @cDropID = ''  
            BEGIN  
               SET @nErrNo = 108401  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Need DropID  
               GOTO Quit  
            END
            ELSE IF (
               EXISTS
                  (SELECT 1
                   FROM PICKDETAIL (NOLOCK)
                   WHERE Storerkey = @cStorerKey
                     AND DropID = @cDropID
                     AND Status <> '9'
                     AND Orderkey NOT IN (SELECT Orderkey
                                          FROM PickHeader (NOLOCK)
                                          WHERE Pickheaderkey = @cPickSlipNo
                                             AND Storerkey = @cStorerKey))
                  )
               BEGIN
                  SET @nErrNo = 217933  
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --DropIDIsUsed
                  GOTO Quit 
               END
         END  
      END  
   END  
     
Quit:  
  
END  
GO
