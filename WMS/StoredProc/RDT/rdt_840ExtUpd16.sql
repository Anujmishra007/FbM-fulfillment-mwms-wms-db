IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_840ExtUpd16]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_840ExtUpd16]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    

/************************************************************************/    
/* Store procedure: rdt_840ExtUpd16                                     */    
/* Purpose: Turn Off light for ptl station                              */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date        Rev  Author     Purposes                                 */    
/* 2021-07-23  1.0  James      WMS-17435. Created                       */  
/************************************************************************/    
    
CREATE PROC [RDT].[rdt_840ExtUpd16] (    
   @nMobile     INT,    
   @nFunc       INT,    
   @cLangCode   NVARCHAR( 3),    
   @nStep       INT,    
   @nInputKey   INT,    
   @cStorerkey  NVARCHAR( 15),    
   @cOrderKey   NVARCHAR( 10),    
   @cPickSlipNo NVARCHAR( 10),    
   @cTrackNo    NVARCHAR( 20),    
   @cSKU        NVARCHAR( 20),    
   @nCartonNo   INT,    
   @cSerialNo   NVARCHAR( 30),   
   @nSerialQTY  INT,    
   @nErrNo      INT           OUTPUT,    
   @cErrMsg     NVARCHAR( 20) OUTPUT    
)    
AS    
    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
    
   DECLARE @cStation       NVARCHAR( 10)  
   DECLARE @bSuccess       INT  
     
   IF @nStep = 5    
   BEGIN    
      IF @nInputKey = 1   
      BEGIN    
         IF EXISTS ( SELECT 1 FROM dbo.PackHeader WITH (NOLOCK)   
                     WHERE PickSlipNo = @cPickSlipNo   
                     AND  [Status] = '9')  
         BEGIN  
            SELECT TOP 1 @cStation = Station  
            FROM rdt.rdtPTLPieceLog WITH (NOLOCK)  
            WHERE OrderKey = @cOrderKey  
            ORDER BY 1  
           
            -- Clear light  
            EXEC PTL.isp_PTL_TerminateModule  
                @cStorerKey  
               ,@nFunc  
               ,@cStation  
               ,'STATION'  
               ,@bSuccess    OUTPUT  
               ,@nErrNo      --OUTPUT -- Prevent PTL overwrite RDT error  
               ,@cErrMsg     --OUTPUT -- Prevent PTL overwrite RDT error  
            IF @nErrNo <> 0  
               GOTO Quit  
         END  
      END  
   END    
    
   Quit:    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_840ExtUpd16 to nSQL
GO