SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO    


/************************************************************************/    
/* Store procedure: rdt_838ExtVal43                                     */
/* Copyright      : MAERSK                                              */    
/*                                                                      */    
/* Date       Rev  Author      Purposes                                 */    
/* 2026-08-12 1.0  DSA314      FCR-15951 Order Pick Validation          */    
/************************************************************************/    
    
CREATE OR ALTER PROC [RDT].[rdt_838ExtVal43]
(  
   @nMobile          INT,  
   @nFunc            INT,  
   @cLangCode        NVARCHAR(3),  
   @nStep            INT,  
   @nInputKey        INT,  
   @cFacility        NVARCHAR(5),  
   @cStorerKey       NVARCHAR(15),  
   @cPickSlipNo      NVARCHAR(10),  
   @cFromDropID      NVARCHAR(20),  
   @nCartonNo        INT,  
   @cLabelNo         NVARCHAR(20),  
   @cSKU             NVARCHAR(20),  
   @nQTY             INT,  
   @cUCCNo           NVARCHAR(20),  
   @cCartonType      NVARCHAR(10),  
   @cCube            NVARCHAR(10),  
   @cWeight          NVARCHAR(10),  
   @cRefNo           NVARCHAR(20),  
   @cSerialNo        NVARCHAR(30),  
   @nSerialQTY       INT,  
   @cOption          NVARCHAR(1),  
   @cPackDtlRefNo    NVARCHAR(20),  
   @cPackDtlRefNo2   NVARCHAR(20),  
   @cPackDtlUPC      NVARCHAR(30),  
   @cPackDtlDropID   NVARCHAR(20),  
   @cPackData1       NVARCHAR(30),  
   @cPackData2       NVARCHAR(30),  
   @cPackData3       NVARCHAR(30),  
   @nErrNo           INT OUTPUT,  
   @cErrMsg          NVARCHAR(20) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON;  
   SET QUOTED_IDENTIFIER OFF;  
   SET ANSI_NULLS OFF;  
   SET CONCAT_NULL_YIELDS_NULL OFF;  
  
   IF @nFunc = 838 -- Pack  
   BEGIN  
      IF @nStep = 1 -- PSNO screen
      BEGIN
         IF @nInputKey = 1 --Enter
         BEGIN  
            IF EXISTS  
            (  
               SELECT 1  
               FROM dbo.PICKDETAIL PD WITH (NOLOCK)  
               WHERE PD.PickSlipNo = @cPickSlipNo  
               AND PD.StorerKey =@cStorerKey  
            )  
            BEGIN  
               SET @nErrNo = 279451;  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP'); -- invalid PSNO
               GOTO Quit;  
            END
         END -- Enter  
      END  
   END  
  
   Quit:  
      RETURN;  
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtVal43 TO NSQL
GO