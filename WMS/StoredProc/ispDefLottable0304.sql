SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/    
/* Trigger:  ispDefLottable0304                                         */    
/* Creation Date: 03-Dec-2023                                           */    
/* Copyright: Maersk                                                    */    
/* Written by: yeekung                                                   */    
/*                                                                      */    
/* Purpose:  Generate Receiptdetail Lottable01 to Lottable04            */
/*           BY nonsku                                                  */    
/*                                                                      */    
/*                                                                      */    
/* PVCS Version: 1.1                                                    */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver.  Purposes                                */    
/* 03-Dec-2023  yeekung   1.0  WMS-24285 Use Codelkup to control        */    
/************************************************************************/    

CREATE OR ALTER PROCEDURE ispDefLottable0304    
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
   , @n_Err                int            = 0      OUTPUT  
   , @c_Errmsg             NVARCHAR(250)  = ''     OUTPUT  
   , @c_Sourcekey          NVARCHAR(15)   = ''    
   , @c_Sourcetype         NVARCHAR(20)   = ''     
   , @c_LottableLabel      NVARCHAR(20)   = ''   
   , @c_type               NVARCHAR(10) = ''     --(CS01)  
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE    
      @c_Lottable01Label   NVARCHAR( 20),    
      @c_ReceiptKey        NVARCHAR( 10),    
      @c_ReceiptLineNo     NVARCHAR( 5),    
      @c_CodeLkupStorerKey NVARCHAR( 15),    
      @c_ListName          NVARCHAR( 10),    
      @c_CheckType         NVARCHAR( 10),    
      @n_RowCount          INT    
    
   DECLARE @n_continue     INT,    
           @b_debug        INT, 
           @n_Func         INT, 
           @c_LOT          NVARCHAR( 10), -- (james01)
           @c_DropID       NVARCHAR( 20)  -- (james01)
           
               
    
   SELECT @n_continue = 1, @b_success = 1, @n_Err = 0, @b_debug = 0    
   SELECT @c_Lottable01 = '',    
          @c_Lottable02 = '',    
          @c_Lottable03 = '',    
          @c_Lottable06 = '',  
          @c_Lottable07 = '',  
          @c_Lottable08 = '',  
          @c_Lottable09 = '',  
          @c_Lottable10 = '',  
          @c_Lottable11 = '',  
          @c_Lottable12 = '',  
          --@dt_Lottable04 = NULL,    
          --@dt_Lottable05 = NULL,    
          @n_Rowcount = 0    

   SELECT @n_Func = Func FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE UserName = sUser_sName()

   SET @c_ReceiptKey    = LEFT(@c_SourceKey,10)     
   SET @c_ReceiptLineNo = RIGHT(@c_SourceKey,5)     
   
   IF @n_Func =1581
   BEGIN
     
      SELECT @c_Lottable03 = UDF01
      FROM CODELKUP (NOLOCK)
      WHERE LISTNAME ='DEFLOTVal'
         AND Storerkey= @c_Storerkey
         AND code ='Lottable03'

      SELECT @dt_Lottable04 = UDF01
      FROM CODELKUP (NOLOCK)
      WHERE LISTNAME ='DEFLOTVal'
         AND Storerkey= @c_Storerkey
         AND code ='Lottable04'
   END
   ELSE  
   BEGIN  
      SET @dt_Lottable04=''  
      SET @c_Lottable03 =''  
  
   END  
       
QUIT:    
    
END -- End Procedure    
GO
GRANT EXECUTE ON  [dbo].[ispDefLottable0304] TO [NSQL]
GO

