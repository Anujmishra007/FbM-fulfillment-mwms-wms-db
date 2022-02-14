IF EXISTS ( SELECT * FROM sys.objects WHERE  object_id = OBJECT_ID(N'[RDT].[rdt_LottableFormat_PARIS]') 
AND OBJECTPROPERTY(object_id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [RDT].[rdt_LottableFormat_PARIS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
         
/************************************************************************/
/* Store procedure: rdt_LottableFormat_PARIS                            */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2020-06-20 1.0  YeeKung    WMS-13456 Created                         */
/* 2022-02-14 1.1  YeeKung    Fix quit After END								*/
/************************************************************************/

           
CREATE PROCEDURE rdt.rdt_LottableFormat_PARIS(           
    @nMobile          INT              
   ,@nFunc            INT              
   ,@cLangCode        NVARCHAR( 3)              
   ,@nInputKey        INT              
   ,@cStorerKey       NVARCHAR( 15)              
   ,@cSKU             NVARCHAR( 20)
   ,@cLottableCode    NVARCHAR( 30)
   , @nLottableNo     INT          
   , @cFormatSP       NVARCHAR( 20)
   , @cLottableValue  NVARCHAR( 20)
   , @cLottable       NVARCHAR( 30)  OUTPUT  
   , @nErrNo           INT           OUTPUT              
   , @cErrMsg          NVARCHAR( 20) OUTPUT
)              
AS              
BEGIN              
   SET NOCOUNT ON              
   SET QUOTED_IDENTIFIER OFF              
   SET ANSI_NULLS OFF              
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE @cYearCode NVARCHAR(20),
           @cJulianDate NVARCHAR(20)

   SET @cLottable= REPLACE(@cLottable,' ','')

   IF (LEN(@cLottable)NOT BETWEEN 5 AND 8)    
   BEGIN    
      SET @nErrNo = 154101            
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Batch                                
      GOTO Quit      
   END  

   SET @cYearCode ='20'+(SUBSTRING(@cLottable,1,2)) 
   SET @cJulianDate=@cYearCode+(SUBSTRING(@cLottable,3,3))
   SET @cLottable = convert(varchar,(dateadd(dd, (@cJulianDate - ((@cJulianDate/1000) * 1000)) - 1, dateadd(yy, @cJulianDate/1000 - 1900, 0)) ),103)    
   GOTO QUIT

QUIT:

END
GO    

SET QUOTED_IDENTIFIER OFF  
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  rdt.rdt_LottableFormat_PARIS TO NSQL
GO
