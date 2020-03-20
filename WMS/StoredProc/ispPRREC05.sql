IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPRREC05]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPRREC05]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispPRREC05                                                  */
/* Creation Date: 28-Feb-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-1213 - HK UA Pre-Finalize copy lottable value for       */ 
/*          duplicate line by RDT Receipt                               */     
/*                                                                      */
/* Called By: ispPreFinalizeReceiptWrapper                              */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/
CREATE PROC ispPRREC05 
            @c_ReceiptKey        NVARCHAR(10)
         ,  @c_ReceiptLineNumber NVARCHAR(10)  = ''
         ,  @b_Success           INT = 1  OUTPUT 
         ,  @n_err               INT = 0  OUTPUT 
         ,  @c_errmsg            NVARCHAR(215) = '' OUTPUT
AS
BEGIN
   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT 
         , @c_DuplicateFrom   NVARCHAR(5)
         , @c_Storerkey       NVARCHAR(15)
         , @c_DocType         NCHAR(1)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @n_err      = 0
   SET @c_errmsg   = ''
   
   IF NOT EXISTS (SELECT 1 
                  FROM RECEIPT R (NOLOCK)
                  JOIN CODELKUP CL (NOLOCK) ON R.Storerkey = CL.Storerkey AND R.DocType = CL.Code2 AND CL.Listname = 'RECDTUPD'
                  AND R.Receiptkey = @c_Receiptkey)         
   BEGIN
      GOTO QUIT_SP
   END                        
   
   BEGIN TRAN 

   DECLARE CUR_RD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
   SELECT RD.DuplicateFrom, RD.ReceiptLineNumber, R.Storerkey, R.DocType
   FROM RECEIPT R (NOLOCK)
   JOIN RECEIPTDETAIL RD (NOLOCK) ON R.Receiptkey = RD.Receiptkey
   WHERE RD.Receiptkey = @c_Receiptkey
   AND   RD.ReceiptLineNumber = CASE WHEN ISNULL(RTRIM(@c_ReceiptLineNumber),'') = '' THEN RD.ReceiptLineNumber ELSE @c_ReceiptLineNumber END
   AND   ISNULL(RD.DuplicateFrom,'') <> ''

   OPEN CUR_RD

   FETCH NEXT FROM CUR_RD INTO @c_DuplicateFrom, @c_ReceiptLineNumber, @c_Storerkey, @c_DocType
                         
   WHILE @@FETCH_STATUS <> -1  
   BEGIN   	   	
   	  UPDATE RECEIPTDETAIL WITH (ROWLOCK)  
     	SET RECEIPTDETAIL.Lottable01 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable01,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE01' AND Code2 = @c_DocType) 
     	                               THEN RDF.Lottable01 ELSE RECEIPTDETAIL.Lottable01 END
   	     ,RECEIPTDETAIL.Lottable02 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable02,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE02' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable02 ELSE RECEIPTDETAIL.Lottable02 END
   	     ,RECEIPTDETAIL.Lottable03 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable03,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE03' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable03 ELSE RECEIPTDETAIL.Lottable03 END
   	     ,RECEIPTDETAIL.Lottable04 = CASE WHEN CONVERT(VARCHAR(8) ,RECEIPTDETAIL.Lottable04 ,112)='19000101' OR RECEIPTDETAIL.Lottable04 IS NULL 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE04' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable04 ELSE RECEIPTDETAIL.Lottable04 END
   	     ,RECEIPTDETAIL.Lottable05 = CASE WHEN CONVERT(VARCHAR(8) ,RECEIPTDETAIL.Lottable05 ,112)='19000101' OR RECEIPTDETAIL.Lottable05 IS NULL 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE05' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable05 ELSE RECEIPTDETAIL.Lottable05 END
   	     ,RECEIPTDETAIL.Lottable06 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable06,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE06' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable06 ELSE RECEIPTDETAIL.Lottable06 END
   	     ,RECEIPTDETAIL.Lottable07 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable07,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE07' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable07 ELSE RECEIPTDETAIL.Lottable07 END
   	     ,RECEIPTDETAIL.Lottable08 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable08,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE08' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable08 ELSE RECEIPTDETAIL.Lottable08 END
   	     ,RECEIPTDETAIL.Lottable09 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable09,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE09' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable09 ELSE RECEIPTDETAIL.Lottable09 END
   	     ,RECEIPTDETAIL.Lottable10 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable10,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE10' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable10 ELSE RECEIPTDETAIL.Lottable10 END
   	     ,RECEIPTDETAIL.Lottable11 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable11,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE11' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable11 ELSE RECEIPTDETAIL.Lottable11 END
   	     ,RECEIPTDETAIL.Lottable12 = CASE WHEN ISNULL(RECEIPTDETAIL.Lottable12,'') = '' 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE12' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable12 ELSE RECEIPTDETAIL.Lottable12 END
   	     ,RECEIPTDETAIL.Lottable13 = CASE WHEN CONVERT(VARCHAR(8) ,RECEIPTDETAIL.Lottable13 ,112)='19000101' OR RECEIPTDETAIL.Lottable13 IS NULL 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE13' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable13 ELSE RECEIPTDETAIL.Lottable13 END
   	     ,RECEIPTDETAIL.Lottable14 = CASE WHEN CONVERT(VARCHAR(8) ,RECEIPTDETAIL.Lottable14 ,112)='19000101' OR RECEIPTDETAIL.Lottable14 IS NULL 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE14' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable14 ELSE RECEIPTDETAIL.Lottable14 END
   	     ,RECEIPTDETAIL.Lottable15 = CASE WHEN CONVERT(VARCHAR(8) ,RECEIPTDETAIL.Lottable15 ,112)='19000101' OR RECEIPTDETAIL.Lottable15 IS NULL 
     	                                    AND EXISTS (SELECT 1 FROM CODELKUP (NOLOCK) WHERE Listname = 'RECDTUPD' AND Storerkey = @c_Storerkey AND Code = 'LOTTABLE15' AND Code2 = @c_DocType) 
   	                                 THEN RDF.Lottable15 ELSE RECEIPTDETAIL.Lottable15 END
   	     , RECEIPTDETAIL.TrafficCop = NULL
   	  FROM RECEIPTDETAIL 
   	  JOIN RECEIPTDETAIL RDF (NOLOCK) ON RECEIPTDETAIL.Receiptkey = RDF.ReceiptKey
   	  WHERE RECEIPTDETAIL.Receiptkey = @c_Receiptkey
   	  AND RECEIPTDETAIL.ReceiptLineNumber = @c_ReceiptLineNumber
   	  AND RDF.ReceiptLineNumber = @c_DuplicateFrom
   	  
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue=3
         SET @n_err = 62030
         SET @c_Errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_Err)+ 'Update RECEIPTDETAIL Failed. (ispPRREC05)'
                       + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT_SP
      END   	  
   	
      FETCH NEXT FROM CUR_RD INTO @c_DuplicateFrom, @c_ReceiptLineNumber, @c_Storerkey, @c_DocType
   END
   CLOSE CUR_RD
   DEALLOCATE CUR_RD
            
QUIT_SP:

   IF CURSOR_STATUS( 'LOCAL', 'CUR_RD') in (0 , 1)  
   BEGIN
      CLOSE CUR_RD
      DEALLOCATE CUR_RD
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ispPRREC05'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[ispPRREC05] TO nSQL 
GO
