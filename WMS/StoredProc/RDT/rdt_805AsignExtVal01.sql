
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_805AsignExtVal01                                      */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */
/* 03-04-2024 1.0  YeeKung  UWP-16963 Created                                 */
/* 23-09-2024 1.1  YeeKung  UWP-24769 Add new currentSP (yeekung02)           */
/******************************************************************************/
CREATE OR ALTER PROC rdt.rdt_805AsignExtVal01 (
   @nMobile     INT,           
   @nFunc       INT,           
   @cLangCode   NVARCHAR( 3),  
   @nStep       INT,           
   @nInputKey   INT,           
   @cFacility   NVARCHAR( 5) , 
   @cStorerKey  NVARCHAR( 10), 
   @cStation    NVARCHAR( 1),  
   @cMethod     NVARCHAR( 15), 
   @cCurrentSP  NVARCHAR( 60), 
   @tVar        VariableTable READONLY, 
   @nErrNo      INT           OUTPUT,  
   @cErrMsg     NVARCHAR(250) OUTPUT,
   @cType       NVARCHAR(15)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cCartonID NVARCHAR(20),
           @cWavekey  NVARCHAR(20)


   IF @cCurrentSP = 'rdt_PTLStation_Assign_WaveCarton02'
   BEGIN
      -- Parameter mapping
      SELECT @cCartonID = Value FROM @tVar WHERE Variable = '@cCartonID'
      SELECT @cWavekey = Value FROM @tVar WHERE Variable = '@cwavekey'

      IF @cType='CHECK'
      BEGIN

         IF @cCartonID <> ''
         BEGIN            
            -- Check carton ID on hold
            IF EXISTS(  SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                        WHERE caseid=@cCartonID
                           AND Storerkey=@cStorerKey
                           AND status < '9' )
            BEGIN
               SET @nErrNo = 213351 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonAdyUsed
               GOTO Quit
            END
         END
      END
   END

   IF @cCurrentSP = 'rdt_PTLStation_Assign_WaveCarton04'
   BEGIN
      -- Parameter mapping
      SELECT @cCartonID = Value FROM @tVar WHERE Variable = '@cCartonID'
      SELECT @cWavekey = Value FROM @tVar WHERE Variable = '@cwavekey'

      IF @cType='CHECK'
      BEGIN

         IF @cCartonID <> ''
         BEGIN   
            IF EXISTS ( SELECT 1 FROM rdt.rdtPTLStationLog  (NOLOCK)
                        WHERE StorerKey = @cStorerKey  
                           AND CartonID = @cCartonID )  
            BEGIN
               SET @nErrNo = 213352 
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonAdyUsed
               GOTO Quit
            END         
            -- Check carton ID on hold
            IF EXISTS(  SELECT 1 FROM PICKDETAIL PD (NOLOCK)
                        WHERE caseid=@cCartonID
                           AND Storerkey=@cStorerKey
                           AND status < '9' )
            BEGIN
               SET @nErrNo = 213353
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonAdyUsed
               GOTO Quit
            END

         END
      END
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_805AsignExtVal01 TO NSQL
GO
