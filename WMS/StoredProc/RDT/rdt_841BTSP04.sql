IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[rdt].[rdt_841BTSP04]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [rdt].[rdt_841BTSP04]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_841BTSP04                                       */
/* Copyright      : LFL                                                 */
/*                                                                      */
/* Purpose: ANF Ecomm Bartender Printing SP                             */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From INTerface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 13-MAR-2019  1.0  James    WMS8276. Created                          */
/* 24-Feb-2020  1.1  Leong    INC1049672 - Revise BT Cmd parameters.    */
/************************************************************************/

CREATE PROC [RDT].[rdt_841BTSP04] (
   @nMobile     INT
  ,@nFunc       INT
  ,@cLangCode   NVARCHAR(3)
  ,@cFacility   NVARCHAR(5)
  ,@cStorerKey  NVARCHAR(15)
  ,@cPrinterID  NVARCHAR(10)
  ,@cDropID     NVARCHAR(20)
  ,@cLoadKey    NVARCHAR(10)
  ,@cLabelNo    NVARCHAR(20)
  ,@cUserName   NVARCHAR(18)
  ,@nErrNo      INT            OUTPUT
  ,@cErrMsg     NVARCHAR(1024) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cLabelType  AS NVARCHAR(30)
          ,@cOrderType  AS NVARCHAR(10)
          ,@cLabelFlag  AS NVARCHAR(1)
          ,@cPickSlipNo AS NVARCHAR(10)
          ,@cExternORderKey AS NVARCHAR(30)
          ,@cOrderKey   AS NVARCHAR(10)
          ,@cShipperKey AS NVARCHAR(10)

   SET @nErrNo     = 0
   SET @cERRMSG    = ''

   SET @cPickSlipNo = ''
   SET @cOrderType = ''
   SET @cLabelFlag = ''

   IF ISNULL(@cLabelNo ,'' )  <> '' AND ISNULL(@cDropID ,'' )  = ''
   BEGIN
      SELECT TOP 1 @cPickSlipNo = PickSlipNo
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND LabelNo = @cLabelNo
   END
   ELSE IF ISNULL(@cLabelNo ,'' )  = '' AND ISNULL(@cDropID ,'' )  <> ''
   BEGIN
      SELECT TOP 1  @cPickSlipNo = PickSlipNo
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND DropID = @cDropID
   END
   ELSE
   BEGIN
      SELECT TOP 1  @cPickSlipNo = PickSlipNo
      FROM dbo.PackDetail WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND DropID = @cDropID
      AND LabelNo = @cLabelNo
   END

   IF ISNULL(RTRIM(@cPickSlipNo),'') = ''
   BEGIN
      SELECT @cOrderKey   = PH.OrderKey
      FROM dbo.Pickheader PH WITH (NOLOCK)
      INNER JOIN dbo.PickDetail PD WITH (NOLOCK)  ON PD.OrderKey = PH.OrderKey
      WHERE PD.StorerKey = @cStorerKey
      AND PD.CaseID = @cLabelNo
   END
   ELSE
   BEGIN
      SELECT @cOrderKey = OrderKey
      FROM dbo.PackHeader WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND PickSlipNo = @cPickSlipNo
   END

   SELECT  @cExternOrderKey = ExternOrderKey
          ,@cShipperKey     = ShipperKey
          ,@cLoadKey        = LoadKey
   FROM dbo.Orders WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND OrderKey = @cOrderKey

   IF @cShipperKey IN ( 'LFL01', 'DHL' )
   BEGIN
      SET @cLabelType = 'SHIPPLABELDTC'
      EXEC dbo.isp_BT_GenBartenderCommand
            @cPrinterID     = @cPrinterID
          , @c_LabelType    = @cLabelType
          , @c_userid       = @cUserName
          , @c_Parm01       = @cLoadKey
          , @c_Parm02       = @cOrderKey -- OrderKey
          , @c_Parm03       = @cExternOrderKey
          , @c_Parm04       = @cLabelNo
          , @c_Parm05       = @cShipperKey
          , @c_Parm06       = ''
          , @c_Parm07       = ''
          , @c_Parm08       = ''
          , @c_Parm09       = ''
          , @c_Parm10       = ''
          , @c_StorerKey    = @cStorerKey
          , @c_NoCopy       = '1'
          , @b_Debug        = '0'
          , @c_Returnresult = 'N'
          , @n_err          = @nErrNo  OUTPUT
          , @c_errmsg       = @cERRMSG OUTPUT
   END
   ELSE
   BEGIN
      SET @cLabelType = 'SHIPPLBLSP' -- 'SHIPPLABEL'
      EXEC dbo.isp_BT_GenBartenderCommand
            @cPrinterID     = @cPrinterID
          , @c_LabelType    = @cLabelType
          , @c_userid       = @cUserName
          , @c_Parm01       = @cLoadKey
          , @c_Parm02       = @cOrderKey -- OrderKey
          , @c_Parm03       = @cShipperKey
          , @c_Parm04       = 0
          , @c_Parm05       = ''
          , @c_Parm06       = ''
          , @c_Parm07       = ''
          , @c_Parm08       = ''
          , @c_Parm09       = ''
          , @c_Parm10       = ''
          , @c_StorerKey    = @cStorerKey
          , @c_NoCopy       = '1'
          , @b_Debug        = '0'
          , @c_Returnresult = 'N'
          , @n_err          = @nErrNo  OUTPUT
          , @c_errmsg       = @cERRMSG OUTPUT
   END

   -- To Proceed Ecomm Despatch while Printing having error --
   SET @nErrNo     = 0
   SET @cERRMSG    = ''
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_841BTSP04 TO NSQL
GO