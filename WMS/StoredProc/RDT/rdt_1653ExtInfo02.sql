SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/        
/* Store procedure: rdt_1653ExtInfo02                                   */        
/* Copyright      : IDS                                                 */        
/*                                                                      */        
/* Called from: rdtfnc_TrackNo_SortToPallet                             */        
/*                                                                      */        
/* Purpose: Display pallet min and max height                           */        
/*                                                                      */        
/* Modifications log:                                                   */        
/* Date        Rev  Author   Purposes                                   */        
/* 2022-10-05  1.0  James    WMS-20667. Created                         */      
/************************************************************************/        
        
CREATE OR ALTER PROC [RDT].[rdt_1653ExtInfo02] (        
   @nMobile        INT,    
   @nFunc          INT,    
   @cLangCode      NVARCHAR( 3),    
   @nStep          INT,    
   @nAfterStep     INT,    
   @nInputKey      INT,    
   @cFacility      NVARCHAR( 5),    
   @cStorerKey     NVARCHAR( 15),    
   @cTrackNo       NVARCHAR( 40),    
   @cOrderKey      NVARCHAR( 20),    
   @cPalletKey     NVARCHAR( 20),    
   @cMBOLKey       NVARCHAR( 10),    
   @cLane          NVARCHAR( 20),    
   @tExtInfoVar    VariableTable READONLY,    
   @cExtendedInfo  NVARCHAR( 20) OUTPUT    
) AS        
BEGIN        
   SET NOCOUNT ON        
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF        
       
   DECLARE @cStatus           NVARCHAR( 10)    
   DECLARE @cUDF03            NVARCHAR( 60)    
   DECLARE @fMinHeight        FLOAT = 0    
   DECLARE @fMaxHeight        FLOAT = 0    
       
   IF @nAfterStep = 2    
   BEGIN    
      IF @nInputKey = 1    
      BEGIN    
         SELECT @cStatus = STATUS    
         FROM dbo.ORDERS WITH (NOLOCK)    
         WHERE OrderKey = @cOrderKey    
             
         IF @cStatus < '5'    
            SET @cExtendedInfo = 'ORDERS NOT PACKED'    
         ELSE    
          SET @cExtendedInfo = 'ORDERS PACKED'    
      END     
   END    
       
   IF @nAfterStep = 6   -- Only go back step 1 need show ctn count    
   BEGIN    
      IF @nInputKey = 1 -- Enter    
      BEGIN    
       --UDF03 = empty pallet height    
       SELECT     
          @cUDF03 = UDF03    
       FROM dbo.CODELKUP WITH (NOLOCK)     
       WHERE LISTNAME = 'ADIPLTDM'    
       AND   Storerkey = @cStorerkey    
       AND   CHARINDEX( Code, @cPalletKey) > 0    
                  
         SELECT     
            @fMinHeight =  CAST( @cUDF03 AS FLOAT) + CAST(MIN(Height) AS FLOAT) * (CASE WHEN CEILING(COUNT(1) / 4.0) > 0 THEN CEILING(COUNT(1) / 4.0) ELSE 1 END), --'Estimated Min Height (CM)'    
            @fMaxHeight =  CAST( @cUDF03 AS FLOAT) + CAST(MAX(Height) AS FLOAT) * (CASE WHEN CEILING(COUNT(1) / 4.0) > 0 THEN CEILING(COUNT(1) / 4.0) ELSE 1 END)  --'Estimated Max Height (CM)'       
         FROM dbo.PALLETDETAIL PLD WITH (NOLOCK)    
         CROSS APPLY (    
         SELECT DISTINCT LABELNO, LENGTH, WIDTH, HEIGHT FROM dbo.PACKDETAIL PD WITH (NOLOCK)     
         JOIN dbo.PACKINFO PI WITH (NOLOCK) ON PI.PICKSLIPNO = PD.PICKSLIPNO AND PI.CartonNo = PD.CartonNo    
         WHERE PD.LABELNO = PLD.CASEID     
         AND PLD.STORERKEY = PD.STORERKEY     
         ) PD    
         WHERE PLD.STORERKEY = @cStorerKey    
         AND PalletKey = @cPalletKey    
         GROUP BY PALLETKEY    
             
         SET @cExtendedInfo = '(MIN|MAX): ' + CAST( @fMinHeight AS NVARCHAR( 3)) + '|' + CAST( @fMaxHeight AS NVARCHAR( 3))
   END    
   END    
   GOTO Quit    
       
   Quit:      
        
END 
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1653ExtInfo02 TO NSQL
GO