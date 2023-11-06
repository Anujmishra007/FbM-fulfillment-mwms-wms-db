IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_950ExtVal03]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_950ExtVal03]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_950ExtVal03                                           */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date        Rev  Author    Purposes                                        */
/* 26-10-2023  1.0  Michael   WMS-23980 Created                               */
/******************************************************************************/

CREATE PROC [RDT].[rdt_950ExtVal03] (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@nInputKey       INT
   ,@cFacility       NVARCHAR( 5)
   ,@cStorerKey      NVARCHAR( 15)
   ,@cWaveKey        NVARCHAR( 10)
   ,@cLoadKey        NVARCHAR( 10)
   ,@cPickZone       NVARCHAR( 10)
   ,@cPKSLIP_Cnt     NVARCHAR( 5)
   ,@cCountry        NVARCHAR( 20)
   ,@cFromLOC        NVARCHAR( 10)
   ,@cToLOC          NVARCHAR( 10)
   ,@cT_PickSlipNo1  NVARCHAR( 10)
   ,@cT_PickSlipNo2  NVARCHAR( 10)
   ,@cT_PickSlipNo3  NVARCHAR( 10)
   ,@cT_PickSlipNo4  NVARCHAR( 10)
   ,@cT_PickSlipNo5  NVARCHAR( 10)
   ,@cT_PickSlipNo6  NVARCHAR( 10)
   ,@cT_PickSlipNo7  NVARCHAR( 10)
   ,@cT_PickSlipNo8  NVARCHAR( 10)
   ,@cT_PickSlipNo9  NVARCHAR( 10)
   ,@cPickSlipNo     NVARCHAR( 10)
   ,@cS_LOC          NVARCHAR( 10)
   ,@cSKU            NVARCHAR( 20)
   ,@cLottable01     NVARCHAR( 18)
   ,@cLottable02     NVARCHAR( 18)
   ,@cLottable03     NVARCHAR( 18)
   ,@dLottable04     DATETIME
   ,@nQtyToPick      INT
   ,@nActQty         INT
   ,@nCartonNo       INT
   ,@cLabelNo        NVARCHAR( 20)
   ,@cOption         NVARCHAR( 1)
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cListName         NVARCHAR(10)  = 'RDTEXTVLD'
         , @cFuncStep         NVARCHAR(30)  = ''
         , @cFuncStepInputkey NVARCHAR(30)  = ''
         , @cRDTExtVldCode    NVARCHAR(30)  = ''
         , @cUsername         NVARCHAR(128) = ''
         , @cFocusField1      NVARCHAR(20)  = ''
         , @cFocusField       NVARCHAR(20)  = ''
         , @cMsgText          NVARCHAR(250) = ''
         , @cWarningMsg       NVARCHAR(250) = ''
         , @cValidateExp      NVARCHAR(MAX) = ''
         , @cCode2            NVARCHAR(30)  = ''
         , @cValidateAction   NVARCHAR(60)  = ''
         , @c_StorerKey       NVARCHAR(15)  = @cStorerKey
         , @c_Facility        NVARCHAR(5)   = @cFacility
         , @c_Sku             NVARCHAR(20)  = @cSKU
         , @bSuccess          INT
         , @nTemp             INT
         , @cTemp             NVARCHAR(250)
         , @cSQL              NVARCHAR(MAX)
         , @cSQLParam         NVARCHAR(MAX)
         , @cTemp01           NVARCHAR(MAX) = ''
         , @cTemp02           NVARCHAR(MAX) = ''
         , @cTemp03           NVARCHAR(MAX) = ''
         , @cTemp04           NVARCHAR(MAX) = ''
         , @cTemp05           NVARCHAR(MAX) = ''
         , @cTemp06           NVARCHAR(MAX) = ''
         , @cTemp07           NVARCHAR(MAX) = ''
         , @cTemp08           NVARCHAR(MAX) = ''
         , @cTemp09           NVARCHAR(MAX) = ''
         , @cTemp10           NVARCHAR(MAX) = ''

   SET @cFuncStep         = ISNULL(CONVERT(NVARCHAR(10),@nFunc),'') +'-'+ ISNULL(CONVERT(NVARCHAR(10),@nStep),'')
   SET @cFuncStepInputkey = @cFuncStep +'-'+ ISNULL(CONVERT(NVARCHAR(10),@nInputKey),'')

   SELECT TOP 1
          @cRDTExtVldCode = Code
     FROM dbo.CODELKUP WITH (NOLOCK)
    WHERE LISTNAME = @cListName
      AND Storerkey = @cStorerKey
      AND Code IN (@cFuncStep, @cFuncStepInputkey)
    ORDER BY CASE WHEN Code = @cFuncStepInputkey THEN 1 ELSE 2 END

   IF ISNULL(@cRDTExtVldCode,'')=''
      GOTO QUIT

   SELECT @cUsername = userName
    FROM rdt.rdtmobrec WITH (NOLOCK)
   WHERE mobile = @nMobile

   DECLARE C_VALIDATION CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT FocusField     = Short
         , MsgText        = ISNULL(RTRIM(Long), '')
         , ValidateExp    = Notes
         , Code2          = Code2
         , ValidateAction = UDF01
      FROM dbo.CodeLkup WITH (NOLOCK)
     WHERE Listname = @cListName
       AND Storerkey = @c_StorerKey
       AND Code = @cRDTExtVldCode
       AND ISNULL(Notes,'')<>''
     ORDER BY Code2

   OPEN C_VALIDATION

   SET @cSQLParam = '@bSuccess        INT           OUTPUT'
                  +',@cFocusField     NVARCHAR(20)  OUTPUT'
                  +',@cMsgText        NVARCHAR(250) OUTPUT'
                  +',@cWarningMsg     NVARCHAR(250) OUTPUT'
                  +',@cCode2          NVARCHAR(30)  OUTPUT'
                  +',@cValidateAction NVARCHAR(60)  OUTPUT'
                  +',@cUsername       NVARCHAR(128) OUTPUT'
                  +',@cRDTExtVldCode  NVARCHAR(30)  OUTPUT'
                  +',@cTemp01         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp02         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp03         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp04         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp05         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp06         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp07         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp08         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp09         NVARCHAR(MAX) OUTPUT'
                  +',@cTemp10         NVARCHAR(MAX) OUTPUT'
                  +',@nMobile         INT'
                  +',@nFunc           INT'
                  +',@cLangCode       NVARCHAR(3)'
                  +',@nStep           INT'
                  +',@nInputKey       INT'
                  +',@cFacility       NVARCHAR(5)   OUTPUT'
                  +',@cStorerKey      NVARCHAR(15)  OUTPUT'
                  +',@cWaveKey        NVARCHAR(10)  OUTPUT'
                  +',@cLoadKey        NVARCHAR(10)  OUTPUT'
                  +',@cPickZone       NVARCHAR(10)  OUTPUT'
                  +',@cPKSLIP_Cnt     NVARCHAR(5)   OUTPUT'
                  +',@cCountry        NVARCHAR(20)  OUTPUT'
                  +',@cFromLOC        NVARCHAR(10)  OUTPUT'
                  +',@cToLOC          NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo1  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo2  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo3  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo4  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo5  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo6  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo7  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo8  NVARCHAR(10)  OUTPUT'
                  +',@cT_PickSlipNo9  NVARCHAR(10)  OUTPUT'
                  +',@cPickSlipNo     NVARCHAR(10)  OUTPUT'
                  +',@cS_LOC          NVARCHAR(10)  OUTPUT'
                  +',@cSku            NVARCHAR(20)  OUTPUT'
                  +',@cLottable01     NVARCHAR(18)  OUTPUT'
                  +',@cLottable02     NVARCHAR(18)  OUTPUT'
                  +',@cLottable03     NVARCHAR(18)  OUTPUT'
                  +',@dLottable04     DATETIME      OUTPUT'
                  +',@nQtyToPick      INT           OUTPUT'
                  +',@nActQty         INT           OUTPUT'
                  +',@nCartonNo       INT           OUTPUT'
                  +',@cLabelNo        NVARCHAR(20)  OUTPUT'
                  +',@cOption         NVARCHAR(1)   OUTPUT'


   WHILE 1=1
   BEGIN
      FETCH NEXT FROM C_VALIDATION
       INTO @cFocusField1, @cMsgText, @cValidateExp, @cCode2, @cValidateAction

      IF @@FETCH_STATUS<>0
         BREAK

      SELECT @bSuccess = 0
           , @cFocusField = ''
           , @cWarningMsg = ''

      IF @cValidateAction='DECODE'
         SET @cSQL = 'SET @bSuccess=1 BEGIN ' +CHAR(10)+ @cValidateExp +CHAR(10)+ 'END'
      ELSE
         SET @cSQL = 'IF (' + @cValidateExp + ') SET @bSuccess=1'

      BEGIN TRY
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam
            , @bSuccess         OUTPUT
            , @cFocusField      OUTPUT
            , @cMsgText         OUTPUT
            , @cWarningMsg      OUTPUT
            , @cCode2           OUTPUT
            , @cValidateAction  OUTPUT
            , @cUsername        OUTPUT
            , @cRDTExtVldCode   OUTPUT
            , @cTemp01          OUTPUT
            , @cTemp02          OUTPUT
            , @cTemp03          OUTPUT
            , @cTemp04          OUTPUT
            , @cTemp05          OUTPUT
            , @cTemp06          OUTPUT
            , @cTemp07          OUTPUT
            , @cTemp08          OUTPUT
            , @cTemp09          OUTPUT
            , @cTemp10          OUTPUT
            , @nMobile
            , @nFunc
            , @cLangCode
            , @nStep
            , @nInputKey
            , @c_Facility       OUTPUT
            , @c_StorerKey      OUTPUT
            , @cWaveKey         OUTPUT
            , @cLoadKey         OUTPUT
            , @cPickZone        OUTPUT
            , @cPKSLIP_Cnt      OUTPUT
            , @cCountry         OUTPUT
            , @cFromLOC         OUTPUT
            , @cToLOC           OUTPUT
            , @cT_PickSlipNo1   OUTPUT
            , @cT_PickSlipNo2   OUTPUT
            , @cT_PickSlipNo3   OUTPUT
            , @cT_PickSlipNo4   OUTPUT
            , @cT_PickSlipNo5   OUTPUT
            , @cT_PickSlipNo6   OUTPUT
            , @cT_PickSlipNo7   OUTPUT
            , @cT_PickSlipNo8   OUTPUT
            , @cT_PickSlipNo9   OUTPUT
            , @cPickSlipNo      OUTPUT
            , @cS_LOC           OUTPUT
            , @c_SKU            OUTPUT
            , @cLottable01      OUTPUT
            , @cLottable02      OUTPUT
            , @cLottable03      OUTPUT
            , @dLottable04      OUTPUT
            , @nQtyToPick       OUTPUT
            , @nActQty          OUTPUT
            , @nCartonNo        OUTPUT
            , @cLabelNo         OUTPUT
            , @cOption          OUTPUT
      END TRY
      BEGIN CATCH
         SELECT @nTemp = ISNULL(ERROR_NUMBER(),0)
              , @cTemp = ISNULL(ERROR_MESSAGE(),'')
         EXEC nsp_logerror @nTemp, @cTemp, 'rdt_950ExtVal03 (Validation Loop)'

         SET @nErrNo = 208051
         SET @cErrMsg = 'VALIDATION ERR^' + ISNULL(@cCode2,'') --VALIDATION ERR
         BREAK
      END CATCH

      IF ISNULL(@cFocusField,'')<>''
        SET @cFocusField1 = @cFocusField
      ELSE IF ISNULL(@bSuccess,0)=1
        SET @cFocusField1 = ''

      IF ISNUMERIC(@cFocusField1) = 1
      BEGIN
         SET @nTemp = CONVERT(INT, CONVERT(FLOAT, @cFocusField1))
         IF @nTemp >= 1 AND @nTemp <=10
            EXEC rdt.rdtSetFocusField @nMobile, @nTemp
      END

      IF ISNULL(@bSuccess,0)<>1
      BEGIN
         IF ISNULL(@cValidateAction,'')='WARNING'
         BEGIN
            SET @cWarningMsg = ISNULL(@cMsgText,'')
         END
         ELSE
         BEGIN
            SET @nErrNo = 208052
            SET @cErrMsg = CASE WHEN @cMsgText='_' THEN '' ELSE ISNULL(@cMsgText,'') END
            BREAK
         END
      END
   END

   CLOSE C_VALIDATION
   DEALLOCATE C_VALIDATION

   IF @nErrNo<>0
      GOTO Quit

   -- Show Warning Message
   IF ISNULL(@cWarningMsg,'')<>''
      SET @cErrMsg = @cWarningMsg
QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE on [RDT].[rdt_950ExtVal03] to nSQL
GO
