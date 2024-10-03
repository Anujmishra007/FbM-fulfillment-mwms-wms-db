SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_593FedexLabel01                                       */
/*                                                                            */
/* Customer: Granite                                                          */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2018-02-07 1.0  NLT03      FCR-727 Create                                  */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593FedexLabel01] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @cStorerKey NVARCHAR( 15),
   @cOption    NVARCHAR( 2), 
   @cParam1    NVARCHAR(60), 
   @cParam2    NVARCHAR(60), 
   @cParam3    NVARCHAR(60), 
   @cParam4    NVARCHAR(60), 
   @cParam5    NVARCHAR(60), 
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cDropID                   NVARCHAR( 20),
      @cShipperKey               NVARCHAR( 15),
      @c_QCmdClass               NVARCHAR(10),
      @cTransmitLogKey           NVARCHAR(10),
      @tFedexLabelList           VariableTable,
      @nRowCount                 INT,
      @bSuccess                  INT,
      @b_Debug                   INT = 0

   SET @cDropID = ISNULL(@cParam1, '')
   SET @c_QCmdClass = ''

   IF TRIM(@cDropID) = ''
   BEGIN
      SET @nErrNo = 223001
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LabelNoNeeded
      GOTO Quit
   END

   IF LEN(@cDropID) = 20 AND LEFT(@cDropID, 2) = '00'
      SET @cDropID = RIGHT(@cDropID, 18)

   IF NOT EXISTS(SELECT 1 FROM PACKDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LabelNo = @cDropID)
   BEGIN
      SET @nErrNo = 223002
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidLabel
      GOTO Quit
   END

   SELECT DISTINCT @cShipperKey = ISNULL(ORM.ShipperKey, '')
   FROM PACKDETAIL PAK WITH(NOLOCK) 
   INNER JOIN PICKDETAIL PKD WITH(NOLOCK) ON PAK.StorerKey = PKD.StorerKey AND PAK.LabelNo = ISNULL(PKD.CaseID, '')
   INNER JOIN ORDERS ORM WITH(NOLOCK) ON PKD.StorerKey = ORM.StorerKey AND PKD.OrderKey = ORM.OrderKey
   WHERE PAK.StorerKey = @cStorerKey
      AND PAK.LabelNo = @cDropID

   SELECT @nRowCount = @@ROWCOUNT

   IF @nRowCount <> 1
   BEGIN
      SET @nErrNo = 223003
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DiffSCAC
      GOTO Quit
   END

   IF EXISTS(SELECT 1 FROM CODELKUP WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND LISTNAME = 'WSCourier' AND @cShipperKey = ISNULL(notes,'-1'))
   BEGIN
      DECLARE @cTrauncatedDropID    NVARCHAR(10) = @cDropID
      -- Insert transmitlog2 here
      EXECUTE ispGenTransmitLog2
         @c_TableName      = 'WSSOECL',
         @c_Key1           = @cTrauncatedDropID,
         @c_Key2           = @cDropID,
         @c_Key3           = @cStorerkey,
         @c_TransmitBatch  = '',
         @b_Success        = @bSuccess   OUTPUT,
         @n_err            = @nErrNo     OUTPUT,
         @c_errmsg         = @cErrMsg    OUTPUT

      IF @bSuccess <> 1
      BEGIN
         SET @nErrNo = 223004
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenTranLogFail
         GOTO Quit
      END

      SELECT @cTransmitLogKey = transmitlogkey
      FROM dbo.TRANSMITLOG2 WITH (NOLOCK)
      WHERE tablename = 'WSSOECL'
      AND   key1 = @cTrauncatedDropID
      AND   key2 = @cDropID
      AND   key3 = @cStorerkey
      
      EXEC dbo.isp_QCmd_WSTransmitLogInsertAlert 
         @c_QCmdClass         = @c_QCmdClass, 
         @c_FrmTransmitlogKey = @cTransmitLogKey, 
         @c_ToTransmitlogKey  = @cTransmitLogKey, 
         @b_Debug             = @b_Debug, 
         @b_Success           = @bSuccess    OUTPUT, 
         @n_Err               = @nErrNo      OUTPUT, 
         @c_ErrMsg            = @cErrMsg     OUTPUT 

      IF @bSuccess <> 1
      BEGIN
         SET @nErrNo = 223005
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --QCmdFail
         GOTO Quit
      END
   END
   ELSE 
   BEGIN
      SET @nErrNo = 223006
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --NoCODELKUP
      GOTO Quit
   END

Fail:
   RETURN
Quit:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_593FedexLabel01] TO [NSQL]
GO
