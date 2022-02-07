IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_1580ExtInfo01]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [rdt].[rdt_1580ExtInfo01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_1580ExtInfo01                                   */  
/* Copyright      : LFLogistics                                         */  
/*                                                                      */  
/* Purpose: Display Count                                               */  
/*                                                                      */  
/* Date       Rev  Author   Purposes                                    */  
/* 2018-04-19 1.0  ChewKP   WMS-4126 Created                            */  
/************************************************************************/  
  
CREATE PROCEDURE [rdt].[rdt_1580ExtInfo01] (  
  @cReceiptKey   NVARCHAR( 10),   
  @cPOKey        NVARCHAR( 10),   
  @cLOC          NVARCHAR( 10),   
  @cToID         NVARCHAR( 18),   
  @cLottable01   NVARCHAR( 18),   
  @cLottable02   NVARCHAR( 18),   
  @cLottable03   NVARCHAR( 18),   
  @dLottable04   DATETIME,    
  @cStorer       NVARCHAR( 15),   
  @cSKU          NVARCHAR( 20),   
  @cExtendedInfo NVARCHAR( 20) OUTPUT  
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @nBeforeReceivedQty     INT  
          ,@nQtyExpected           INT  
          ,@nStep                  INT  
     
   SELECT TOP 1 @nStep = Step   
   FROM rdt.rdtMobrec WITH (NOLOCK)   
   WHERE StorerKey = @cStorer  
   AND Func = 1580   
   AND V_ReceiptKey = @cReceiptKey  
   AND V_Loc = @cLoc  
   AND V_ID  = @cToID  
  
            
   IF @nStep = 4   
   BEGIN  
      SET @nBeforeReceivedQty = 0   
      SET @nQtyExpected = 0   
  
      SET @cExtendedInfo = 'SKU CNT: ' + RIGHT(Replicate(' ',4) + CAST(@nBeforeReceivedQty As VARCHAR(4)), 4)  + ' / ' + RIGHT(Replicate(' ',4) + CAST(@nQtyExpected As VARCHAR(4)), 4)    
   END  
  
  
   IF @nStep = 5   
   BEGIN  
     
           
      SELECT  
      @nBeforeReceivedQty = ISNULL( SUM( BeforeReceivedQty), 0) +  1 ,  
      @nQtyExpected = ISNULL( SUM( QtyExpected), 0)  
      FROM dbo.ReceiptDetail WITH (NOLOCK)  
      WHERE Receiptkey = @cReceiptKey  
      --AND   POKey      = @cPOKey  
      AND   SKU        = @cSKU  
      --AND   ToID       = @cToID  
      AND   ToLoc      = @cLoc  
      AND   Storerkey  = @cStorer  
      AND   FinalizeFlag = 'N'  
           
            
  
      SET @cExtendedInfo = 'SKU CNT: ' + RIGHT(Replicate(' ',4) + CAST(@nBeforeReceivedQty As VARCHAR(4)), 4)  + ' / ' + RIGHT(Replicate(' ',4) + CAST(@nQtyExpected As VARCHAR(4)), 4)    
      --SELECT @nScanCount '@nScanCount' , @nCaseCnt '@nCaseCnt' , @cOutPutText '@cOutPutText'   
   END  
  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1580ExtInfo01 TO NSQL
GO