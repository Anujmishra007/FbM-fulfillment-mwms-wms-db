IF EXISTS (SELECT name FROM sysobjects WHERE name = 'ispMoveByLblNoChk20d' AND type = 'P')
   DROP PROC ispMoveByLblNoChk20d
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: ispMoveByLblNoChk20d                                */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Decode Label No Scanned                                     */
/*          Copied from ispMoveByLabelNoChk but validate 20 digits label*/
/* Called from:                                                         */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2014-04-03 1.0  James    SOS307345 Created                           */
/************************************************************************/

CREATE PROCEDURE [dbo].[ispMoveByLblNoChk20d]
   @nMobile       INT, 
   @nFunc         INT, 
   @cLangCode     NVARCHAR(3),
   @cFromLabelNo  NVARCHAR(20),
   @cToLabelNo    NVARCHAR(20),
   @nErrNo        INT      OUTPUT, 
   @cErrMsg       NVARCHAR(20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- IDX label format
   -- Label format: Fixed value ('3') + Distribution center (6 digits) + 
   -- Shop number (6 digits) + Section (1 digit) + Separate (1 digit) + Bult Number/Box (5 digits)
   -- Check left 15 because the last 5 chars is running no.
   -- Check if same type
   IF LEN( RTRIM( @cFromLabelNo)) <> LEN( RTRIM( @cToLabelNo)) OR 
      LEFT( @cFromLabelNo, 15) <> LEFT( @cToLabelNo, 15)          
   BEGIN
      SET @nErrNo = 77751
      SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Diff LabelType
   END
QUIT:
END -- End Procedure
GO

GRANT EXECUTE ON  ispMoveByLblNoChk20d TO NSQL 
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
