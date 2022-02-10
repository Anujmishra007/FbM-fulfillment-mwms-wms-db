IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dbo.ispGenLot1AsID') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE dbo.ispGenLot1AsID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: ispGenLot1AsID                                      */
/* Copyright: IDS                                                       */
/* Purpose: Generate lottable01 as ID                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2011-08-09   Ung       1.0   SOS240680 New pallet ID format          */
/************************************************************************/

CREATE PROCEDURE dbo.ispGenLot1AsID
   @c_Storerkey        NVARCHAR(15),
   @c_Sku              NVARCHAR(20),
	@c_Lottable01Value  NVARCHAR(18),
	@c_Lottable02Value  NVARCHAR(18),
	@c_Lottable03Value  NVARCHAR(18),
	@dt_Lottable04Value datetime,
	@dt_Lottable05Value datetime,
	@c_Lottable01       NVARCHAR(18) OUTPUT,
	@c_Lottable02       NVARCHAR(18) OUTPUT,
	@c_Lottable03       NVARCHAR(18) OUTPUT,
	@dt_Lottable04      datetime OUTPUT,
   @dt_Lottable05      datetime OUTPUT,
   @b_Success          int = 1  OUTPUT,
   @n_ErrNo            int = 0  OUTPUT,
   @c_Errmsg           NVARCHAR(250) = '' OUTPUT,
   @c_Sourcekey        NVARCHAR(15) = '',  
   @c_Sourcetype       NVARCHAR(20) = '',  
   @c_LottableLabel    NVARCHAR(20) = ''   
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_ID NVARCHAR( 7)
   SET @c_ID = ''

	EXECUTE dbo.nspg_GetKey
		'DSGTHCSID', 
		7,
		@c_ID       OUTPUT,
		@b_success  OUTPUT,
		@n_ErrNo    OUTPUT,
		@c_errmsg   OUTPUT

   IF @b_success <> 1 -- FAIL
	   SET @c_Lottable01 = ''
	ELSE
	   SET @c_Lottable01 =                          -- Format: 
	      'D' +                                     -- Prefix 'D'
	      master.dbo.fnc_GetCharASCII( 65 + (YEAR( GETDATE()) - 2012)) +   -- A=2012, B=2013, C=2014...
	      @c_ID +                                   -- 7 digit case ID. Don't need serialize
	      'C00'                                     -- Surfix 'C00'
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.ispGenLot1AsID TO NSQL
GO
