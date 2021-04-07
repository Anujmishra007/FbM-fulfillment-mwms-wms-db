IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_RFID_GetLAAttrib01]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_RFID_GetLAAttrib01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_RFID_GetLAAttrib01                                  */
/* Creation Date: 2021-03-19                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  WMS-16505 - [CN]NIKE_Phoenix_RFID_Receiving_Overall_CR     */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2021-03-19  Wan      1.0   Created                                   */
/************************************************************************/
CREATE PROC isp_RFID_GetLAAttrib01
      @c_StorerKey               NVARCHAR(15)   
   ,  @c_SKU                     NVARCHAR(20) = ''  
   ,  @c_Lottable01Value         NVARCHAR(60) = '' 
   ,  @c_Lottable02Value         NVARCHAR(60) = '' 
   ,  @c_Lottable03Value         NVARCHAR(60) = '' 
   ,  @dt_Lottable04Value        DATETIME     = NULL
   ,  @dt_Lottable05Value        DATETIME     = NULL
   ,  @c_Lottable06Value         NVARCHAR(60) = ''  
   ,  @c_Lottable07Value         NVARCHAR(60) = ''  
   ,  @c_Lottable08Value         NVARCHAR(60) = ''  
   ,  @c_Lottable09Value         NVARCHAR(60) = ''  
   ,  @c_Lottable10Value         NVARCHAR(60) = ''  
   ,  @c_Lottable11Value         NVARCHAR(60) = ''  
   ,  @c_Lottable12Value         NVARCHAR(60) = ''  
   ,  @dt_Lottable13Value        DATETIME     = NULL  
   ,  @dt_Lottable14Value        DATETIME     = NULL  
   ,  @dt_Lottable15Value        DATETIME     = NULL    
   ,  @c_Lottable01              NVARCHAR(18) = ''    OUTPUT  
   ,  @c_Lottable02              NVARCHAR(18) = ''    OUTPUT  
   ,  @c_Lottable03              NVARCHAR(18) = ''    OUTPUT  
   ,  @dt_Lottable04             DATETIME             OUTPUT  
   ,  @dt_Lottable05             DATETIME             OUTPUT  
   ,  @c_Lottable06              NVARCHAR(30) = ''    OUTPUT  
   ,  @c_Lottable07              NVARCHAR(30) = ''    OUTPUT  
   ,  @c_Lottable08              NVARCHAR(30) = ''    OUTPUT  
   ,  @c_Lottable09              NVARCHAR(30) = ''    OUTPUT  
   ,  @c_Lottable10              NVARCHAR(30) = ''    OUTPUT  
   ,  @c_Lottable11              NVARCHAR(30) = ''    OUTPUT  
   ,  @c_Lottable12              NVARCHAR(30) = ''    OUTPUT  
   ,  @dt_Lottable13             DATETIME     = NULL  OUTPUT  
   ,  @dt_Lottable14             DATETIME     = NULL  OUTPUT  
   ,  @dt_Lottable15             DATETIME     = NULL  OUTPUT 
   ,  @b_ResetLottablesattrib    INT          = 0     OUTPUT     
   ,  @c_Lottable01attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable02attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable03attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable04attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable05attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable06attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable07attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable08attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable09attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable10attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable11attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable12attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable13attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable14attrib        NVARCHAR(1)  = '0'   OUTPUT   
   ,  @c_Lottable15attrib        NVARCHAR(1)  = '0'   OUTPUT   
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @b_ResetLottablesattrib = 0
   
   DECLARE @n_StartTCnt INT = @@TRANCOUNT
  
   IF (@c_Lottable01Value = 'A' AND @c_Lottable01 = '') OR @c_Lottable01 = 'A'
   BEGIN
      SET @b_ResetLottablesattrib = 1
      SET @c_Lottable02attrib = '0'
   END
   ELSE
   BEGIN
      SET @b_ResetLottablesattrib = 1
      SET @c_Lottable02attrib = '1'
   END 
   
QUIT_SP:

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RFID_GetLAAttrib01] TO nSQL 
GO
