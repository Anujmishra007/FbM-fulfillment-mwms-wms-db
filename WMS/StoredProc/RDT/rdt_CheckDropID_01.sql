if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_CheckDropID_01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [RDT].[rdt_CheckDropID_01]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt_CheckDropID_01                                  */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Check validity of Drop ID scanned (SOS145455)               */
/*                                                                      */
/* Called from: rdtfnc_Cluster_Pick                                     */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 24-Aug-2009 1.0  James       Created                                 */
/************************************************************************/

CREATE PROC [RDT].[rdt_CheckDropID_01] (
   @cFacility                 NVARCHAR( 5),
   @cStorerKey                NVARCHAR( 15),
   @cOrderKey                 NVARCHAR( 10),
   @cDropID                   NVARCHAR( 18),
   @nValid                    INT          OUTPUT, 
   @nErrNo                    INT          OUTPUT, 
   @cErrMsg     				 NVARCHAR( 20) OUTPUT  -- screen limitation, 20 char max 
)
AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_success INT
   DECLARE @n_err		 INT
   DECLARE @c_errmsg  NVARCHAR( 250)

   IF SUBSTRING(@cDropID, 1, 2) + SUBSTRING(@cDropID, 3, 10) <> 
      'ID' + @cOrderKey
      SET @nValid = 0
   ELSE
      SET @nValid = 1
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_CheckDropID_01 TO NSQL
GO
