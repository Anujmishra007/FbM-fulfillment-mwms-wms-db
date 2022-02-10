IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_1837ExtInfo02]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_1837ExtInfo02]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1837ExtInfo02                                   */
/*                                                                      */
/* Purpose: Prompt screen when PPA carton scanned                       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2021-07-13  1.0  Chermaine   WMS-17386. Created                      */
/************************************************************************/

CREATE PROC [RDT].[rdt_1837ExtInfo02] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCartonID      NVARCHAR( 20), 
   @cPalletID      NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cLoc           NVARCHAR( 10), 
   @cOption        NVARCHAR( 1), 
   @tExtValidate   VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cPickDetailCartonID NVARCHAR( 20),
           @cPickConfirmStatus  NVARCHAR( 1),
           @cSQL        NVARCHAR(MAX), 
           @cSQLParam   NVARCHAR(MAX),
           @nRowCount   INT
           
   DECLARE @cErrMsg01   NVARCHAR( 20), @cErrMsg06   NVARCHAR( 20),
           @cErrMsg02   NVARCHAR( 20), @cErrMsg07   NVARCHAR( 20),
           @cErrMsg03   NVARCHAR( 20), @cErrMsg08   NVARCHAR( 20),
           @cErrMsg04   NVARCHAR( 20), @cErrMsg09   NVARCHAR( 20),
           @cErrMsg05   NVARCHAR( 20), @cErrMsg10   NVARCHAR( 20)
           

   IF @nStep = 1 -- CartonID
   BEGIN
      IF @nInputKey = 1
      BEGIN
      	IF @cCartonID <> ''
      	BEGIN
      		
         SET @cPickDetailCartonID = rdt.RDTGetConfig( @nFunc, 'PickDetailCartonID', @cStorerKey)
         IF @cPickDetailCartonID NOT IN ('DropID', 'CaseID')
            SET @cPickDetailCartonID = 'DropID'

         SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)  
         IF @cPickConfirmStatus = '0'  
            SET @cPickConfirmStatus = '5'  
            
         SELECT @cErrMsg01 = '', @cErrMsg06 = '',
                @cErrMsg02 = '', @cErrMsg07 = '',
                @cErrMsg03 = '', @cErrMsg08 = '',
                @cErrMsg04 = '', @cErrMsg09 = '',
                @cErrMsg05 = '', @cErrMsg10 = ''
      
      		--check CartonId hav PPA flag
      		SET @cSQL = 
               ' SELECT 1 ' + 
               ' FROM dbo.PickDetail pickDT WITH (NOLOCK) ' + 
               ' JOIN dbo.PackDetail packDt WITH (NOLOCK) on packDt.labelNo = pickDt.' + RTRIM( @cPickDetailCartonID) +
               ' JOIN dbo.PackInfo pkInfo WITH (NOLOCK) on (packDt.pickslipNo = pkInfo.pickSlipNo AND packDt.CartonNo = pkInfo.cartonno) ' +
               ' WHERE pickDT.StorerKey = @cStorerKey ' + 
                  ' AND pickDT.Status = ''' + @cPickConfirmStatus + '''' +  
                  ' AND pickDT.QTY > 0 ' + 
                  ' AND pickDT.' + RTRIM( @cPickDetailCartonID) + ' = @cCartonID ' +
                  ' AND pkInfo.RefNo = ''PPA'' ' +
                  ' ORDER BY 1 ' +
                  ' SET @nRowCount = @@ROWCOUNT '

            SET @cSQLParam = 
               ' @cStorerKey  NVARCHAR( 15), ' + 
               ' @cCartonID   NVARCHAR( 20), ' + 
               ' @nRowCount   INT  OUTPUT    '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam
               ,@cStorerKey
               ,@cCartonID 
               ,@nRowCount OUTPUT
               
            IF @nRowCount > 0
            BEGIN
            	SET @nErrNo = -1
            	--SELECT @cErrMsg01 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '1'
            	--SELECT @cErrMsg02 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '2'
            	--SELECT @cErrMsg03 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '3'
            	--SELECT @cErrMsg04 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '4'
            	--SELECT @cErrMsg05 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '5'
            	--SELECT @cErrMsg06 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '6'
            	--SELECT @cErrMsg07 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '7'
            	--SELECT @cErrMsg08 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '8'
            	--SELECT @cErrMsg09 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '9'
            	--SELECT @cErrMsg10 = [Description] FROM codelkup (NOLOCK) WHERE listName = 'RDTMsgQ' AND storerKey = @cStorerKey AND code2 = @nFunc AND code = '10'
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

GRANT EXECUTE ON rdt.rdt_1837ExtInfo02 to nSQL
GO
