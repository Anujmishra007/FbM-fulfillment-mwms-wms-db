IF EXISTS ( SELECT * FROM sys.objects WHERE  object_id = OBJECT_ID(N'[RDT].[rdt_LottableFormat_MORRIS]') 
AND OBJECTPROPERTY(object_id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [RDT].[rdt_LottableFormat_MORRIS]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
         
/************************************************************************/
/* Store procedure: rdt_LottableFormat_MORRIS                            */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2020-06-20 1.0  YeeKung    WMS-13456 Created                         */
/************************************************************************/

           
CREATE PROCEDURE rdt.rdt_LottableFormat_MORRIS(           
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

   DECLARE @cYearCode NVARCHAR(5),
           @cDayCode  NVARCHAR(5),
           @cMonthCode NVARCHAR(5),
           @cJulianDate NVARCHAR(20),
           @nYear       INT


   IF (LEN(@cLottable)NOT IN (4,8))    
   BEGIN    
      SET @nErrNo = 154351            
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Batch                                
      GOTO Quit      
   END  

   IF (LEN(@cLottable)=4)    
   BEGIN    
      SELECT @cmonthcode=short
      FROM codelkup (NOLOCK)
      WHERE  LISTNAME='RDTDECODE'
         AND code = 'MORRISPROFUMIM'
         AND code2= SUBSTRING(@cLottable,1,1)

      IF (ISNULL(@cmonthcode,'')='')    
      BEGIN    
         SET @nErrNo = 154352            
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Batch                                
         GOTO Quit      
      END  

      SELECT @cYearcode=short
      FROM codelkup (NOLOCK)
      WHERE  LISTNAME='RDTDECODE'
         AND code = 'MORRISPROFUMIY'
         AND code2= SUBSTRING(@cLottable,2,1)

      IF (ISNULL(@cYearcode,'')='')    
      BEGIN    
         SET @nErrNo = 154353            
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Batch                                
         GOTO Quit      
      END  

      SET @cLottable='01'+'/'+@cmonthcode+'/'+@cYearcode
   END  

   ELSE IF (LEN(@cLottable)=8)    
   BEGIN    
      SELECT @cmonthcode=short
      FROM codelkup (NOLOCK)
      WHERE  LISTNAME='RDTDECODE'
         AND code = 'MORRISPROFUMIM'
         AND code2= SUBSTRING(@cLottable,5,1)

      IF (ISNULL(@cmonthcode,'')='')    
      BEGIN    
         SET @nErrNo = 154354            
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Batch                                
         GOTO Quit      
      END  

      SELECT @cYearcode=short
      FROM codelkup (NOLOCK)
      WHERE  LISTNAME='RDTDECODE'
         AND code = 'MORRISPROFUMIY'
         AND code2= SUBSTRING(@cLottable,6,1)

      IF (ISNULL(@cYearcode,'')='')    
      BEGIN    
         SET @nErrNo = 154355            
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid Batch                                
         GOTO Quit      
      END  

      SET @cLottable=SUBSTRING(@cLottable,3,2)+'/'+@cmonthcode+'/'+@cYearcode
                              
      GOTO Quit    
   END  


   GOTO QUIT

END
QUIT:
GO    

SET QUOTED_IDENTIFIER OFF  
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  rdt.rdt_LottableFormat_MORRIS TO NSQL
GO
