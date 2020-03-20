if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_838GenLabelNo01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure dbo.isp_838GenLabelNo01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: isp_838GenLabelNo01                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 13-10-2017 1.0 Ung         WMS-3197 Created                          */
/************************************************************************/

CREATE PROC dbo.isp_838GenLabelNo01 (
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

   IF @cLabelNo <> ''
      SET @cLabelNo = RIGHT( @cLabelNo, 14)

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.isp_838GenLabelNo01 TO NSQL
GO
