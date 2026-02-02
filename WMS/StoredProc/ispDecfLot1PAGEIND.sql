SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: ispDecfLot1PAGEIND                                 */
/* Copyright: IDS                                                       */
/* Purpose: Default lottable01 from ReceiptDetail                       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-07-24   Cuize     1.0   Created                                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ispDecfLot1PAGEIND
     @c_Storerkey          NVARCHAR(15)
   , @c_Sku                NVARCHAR(20)
   , @c_Lottable01Value    NVARCHAR(18)
   , @c_Lottable02Value    NVARCHAR(18)
   , @c_Lottable03Value    NVARCHAR(18)
   , @dt_Lottable04Value   DATETIME
   , @dt_Lottable05Value   DATETIME
   , @c_Lottable06Value    NVARCHAR(30)   = ''
   , @c_Lottable07Value    NVARCHAR(30)   = ''
   , @c_Lottable08Value    NVARCHAR(30)   = ''
   , @c_Lottable09Value    NVARCHAR(30)   = ''
   , @c_Lottable10Value    NVARCHAR(30)   = ''
   , @c_Lottable11Value    NVARCHAR(30)   = ''
   , @c_Lottable12Value    NVARCHAR(30)   = ''
   , @dt_Lottable13Value   DATETIME       = NULL
   , @dt_Lottable14Value   DATETIME       = NULL
   , @dt_Lottable15Value   DATETIME       = NULL
   , @c_Lottable01         NVARCHAR(18)            OUTPUT
   , @c_Lottable02         NVARCHAR(18)            OUTPUT
   , @c_Lottable03         NVARCHAR(18)            OUTPUT
   , @dt_Lottable04        DATETIME                OUTPUT
   , @dt_Lottable05        DATETIME                OUTPUT
   , @c_Lottable06         NVARCHAR(30)   = ''     OUTPUT
   , @c_Lottable07         NVARCHAR(30)   = ''     OUTPUT
   , @c_Lottable08         NVARCHAR(30)   = ''     OUTPUT
   , @c_Lottable09         NVARCHAR(30)   = ''     OUTPUT
   , @c_Lottable10         NVARCHAR(30)   = ''     OUTPUT
   , @c_Lottable11         NVARCHAR(30)   = ''     OUTPUT
   , @c_Lottable12         NVARCHAR(30)   = ''     OUTPUT
   , @dt_Lottable13        DATETIME       = NULL   OUTPUT
   , @dt_Lottable14        DATETIME       = NULL   OUTPUT
   , @dt_Lottable15        DATETIME       = NULL   OUTPUT
   , @b_Success            int            = 1      OUTPUT
   , @n_ErrNo              int            = 0      OUTPUT
   , @c_Errmsg             NVARCHAR(250)  = ''     OUTPUT
   , @c_Sourcekey          NVARCHAR(15)   = ''  
   , @c_Sourcetype         NVARCHAR(20)   = ''   
   , @c_LottableLabel      NVARCHAR(20)   = '' 
   , @c_type               NVARCHAR(10)   = ''

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   IF @c_Lottable01Value <> ''
   BEGIN
      IF LEN( @c_Lottable01Value) - LEN(REPLACE( @c_Lottable01Value, ':', '')) > 1
         BEGIN
            SET @n_ErrNo = 237651
            SET @c_Errmsg = rdt.rdtgetmessage( @n_ErrNo, 'ENG', 'DSP') --Invalid Value
            GOTO Quit
         END

      IF CHARINDEX( ':', @c_Lottable01Value) = 0
         BEGIN
            SET @c_Lottable01 = ''
         END
      ELSE
         BEGIN
            SET @c_Lottable01 = SUBSTRING( @c_Lottable01Value,  CHARINDEX( ':', @c_Lottable01Value) + 1, LEN( @c_Lottable01Value))
         END
   END   -- @c_Lottable01Value

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.ispDecfLot1PAGEIND TO NSQL
GO
