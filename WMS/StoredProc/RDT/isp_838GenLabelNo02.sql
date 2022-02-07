if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_838GenLabelNo02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure dbo.isp_838GenLabelNo02
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: isp_838GenLabelNo02                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 28-05-2018 1.0 Ung         WMS-4932 Created                          */
/************************************************************************/

CREATE PROC dbo.isp_838GenLabelNo02 (
   @cPickslipNo NVARCHAR(10),        
   @nCartonNo   INT,                 
   @cLabelNo    NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess INT
   DECLARE @nErrNo INT
   DECLARE @cErrMsg NVARCHAR( 250)

   EXEC isp_GenUCCLabelNo_STD
       @cPickslipNo      
      ,@nCartonNo              
      ,@cLabelNo  OUTPUT
      ,@bSuccess  OUTPUT
      ,@nErrNo    OUTPUT
      ,@cErrMsg   OUTPUT

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.isp_838GenLabelNo02 TO NSQL
GO
