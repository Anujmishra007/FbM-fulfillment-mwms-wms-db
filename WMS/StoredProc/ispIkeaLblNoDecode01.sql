IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ispIkeaLblNoDecode01]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[ispIkeaLblNoDecode01]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: ispIkeaLblNoDecode01                                */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Decode Label No Scanned. Not using rdt_Decode because in    */
/*          rdtscndetail some storer setup ColStringExp which conflict  */
/*          with existing setup (decode 2 times)                        */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 24-08-2018  1.0  James       WMS5311. Created                        */
/************************************************************************/

CREATE PROCEDURE [dbo].[ispIkeaLblNoDecode01]
   @c_LabelNo          NVARCHAR(40),
   @c_Storerkey        NVARCHAR(15),
   @c_ReceiptKey       NVARCHAR(10),
   @c_POKey            NVARCHAR(10),
	@c_LangCode	        NVARCHAR(3),
	@c_oFieled01        NVARCHAR(20) OUTPUT,
	@c_oFieled02        NVARCHAR(20) OUTPUT,
   @c_oFieled03        NVARCHAR(20) OUTPUT,
   @c_oFieled04        NVARCHAR(20) OUTPUT,
   @c_oFieled05        NVARCHAR(20) OUTPUT,
   @c_oFieled06        NVARCHAR(20) OUTPUT,
   @c_oFieled07        NVARCHAR(20) OUTPUT,
   @c_oFieled08        NVARCHAR(20) OUTPUT,
   @c_oFieled09        NVARCHAR(20) OUTPUT,
   @c_oFieled10        NVARCHAR(20) OUTPUT,
   @b_Success          INT = 1  OUTPUT,
   @n_ErrNo            INT      OUTPUT, 
   @c_ErrMsg           NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Func      INT,
           @n_Step      INT,
           @n_InputKey  INT

   IF ISNULL( @c_LabelNo, '') = ''
      GOTO Quit

   SELECT @n_Func = Func, 
          @n_Step = Step,
          @n_InputKey = InputKey
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE UserName = sUser_sName()

   IF @n_InputKey = 1
   BEGIN
      IF @n_Func = 523
      BEGIN
         IF @n_Step = 1 --ID
         BEGIN
            SET @c_oFieled01 = @c_LabelNo
            GOTO Quit
         END
         ELSE IF @n_Step = 2  -- SKU
         BEGIN
            SET @c_oFieled01 = SUBSTRING( RTRIM( @c_LabelNo), 1, 13)
            GOTO Quit
         END
         ELSE
            GOTO Quit
      END
   END
QUIT:
END -- End Procedure

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON [dbo].[ispIkeaLblNoDecode01] TO NSQL 
GO   
