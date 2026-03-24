SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_AutoFinalizeCHTRF_PUMA                            */
/* Creation Date: 18-Aug-2025                                              */
/* Copyright: MAERSK                                                       */
/* Written by: Michael Lam                                                 */
/*                                                                         */
/* Purpose: FCR-6907 - AU - PUMA - Auto Finalize Channel Transfer          */
/*                                                                         */
/* Called By: SQL Job                                                      */
/*                                                                         */
/* GitHub Version: 1.0                                                     */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author  Ver   Purposes                                      */
/* 2025-10-13  Michael 1.0   DevOps Combine Script                         */
/***************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_AutoFinalizeCHTRF_PUMA]
(
     @c_Storerkey          NVARCHAR(15)
   , @c_ChannelTransferkey NVARCHAR(10)  = ''
   , @c_AlertSubject       NVARCHAR(255) = NULL
   , @c_Recipients         VARCHAR(MAX)  = NULL
   , @c_CC                 VARCHAR(MAX)  = NULL
   , @c_BCC                VARCHAR(MAX)  = NULL
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success            INT = 1
         , @n_Err                INT = 0
         , @c_ErrMsg             NVARCHAR(255) = ''
         , @n_Continue           INT = 1
         , @n_StartTranCount     INT = @@TRANCOUNT
         , @c_ChannelTrfkey      NVARCHAR(10)
         , @c_ChannelTrfLineNo   NVARCHAR(5)
         , @c_HostWHCode         NVARCHAR(10)
         , @c_FromStorerkey      NVARCHAR(15)
         , @c_FromSku            NVARCHAR(20)
         , @c_ToStorerkey        NVARCHAR(15)
         , @c_ToSku              NVARCHAR(20)
         , @c_ToChannel          NVARCHAR(20)
         , @c_FromC_Attribute01  NVARCHAR(30)
         , @c_FromC_Attribute02  NVARCHAR(30)
         , @c_FromC_Attribute03  NVARCHAR(30)
         , @c_FromC_Attribute04  NVARCHAR(30)
         , @c_FromC_Attribute05  NVARCHAR(30)
         , @c_ToC_Attribute01    NVARCHAR(30)
         , @c_ToC_Attribute02    NVARCHAR(30)
         , @c_ToC_Attribute03    NVARCHAR(30)
         , @c_ToC_Attribute04    NVARCHAR(30)
         , @c_ToC_Attribute05    NVARCHAR(30)
         , @n_FromQty            INT
         , @n_ToQty              INT
         , @n_CurrLLI            INT
         , @n_CurrChannelInv     INT
         , @n_AvailQty           INT
         , @c_tableHTML          NVARCHAR(MAX)
         , @c_SQL                NVARCHAR(MAX)
         , @c_AttributeLabel01   NVARCHAR(50) = ''
         , @c_AttributeLabel02   NVARCHAR(50) = ''
         , @c_AttributeLabel03   NVARCHAR(50) = ''
         , @c_AttributeLabel04   NVARCHAR(50) = ''
         , @c_AttributeLabel05   NVARCHAR(50) = ''

   DECLARE @t_EmailAlert TABLE (
        RowNo                     INT IDENTITY(1,1) NOT NULL
      , ChannelTransferkey        NVARCHAR(10)      NULL
      , ChannelTransferLineNumber NVARCHAR(5)       NULL
      , Sku                       NVARCHAR(20)      NULL
      , FromQty                   INT               NULL
      , Err                       INT               NULL
      , ErrMsg                    NVARCHAR(255)     NULL
   )

   SELECT TOP 1
          @c_AttributeLabel01 = TRIM(C_AttributeLabel01)
        , @c_AttributeLabel02 = TRIM(C_AttributeLabel02)
        , @c_AttributeLabel03 = TRIM(C_AttributeLabel03)
        , @c_AttributeLabel04 = TRIM(C_AttributeLabel04)
        , @c_AttributeLabel05 = TRIM(C_AttributeLabel05)
   FROM ChannelAttributeConfig WITH(NOLOCK)
   WHERE Storerkey = @c_Storerkey
   ORDER BY ChannelConfig_ID

   IF NOT (@c_AttributeLabel01 LIKE 'LOTTABLE[0-9][0-9]' AND @c_AttributeLabel01 BETWEEN 'LOTTABLE01' AND 'LOTTABLE15')  SET @c_AttributeLabel01 = ''
   IF NOT (@c_AttributeLabel02 LIKE 'LOTTABLE[0-9][0-9]' AND @c_AttributeLabel02 BETWEEN 'LOTTABLE01' AND 'LOTTABLE15')  SET @c_AttributeLabel02 = ''
   IF NOT (@c_AttributeLabel03 LIKE 'LOTTABLE[0-9][0-9]' AND @c_AttributeLabel03 BETWEEN 'LOTTABLE01' AND 'LOTTABLE15')  SET @c_AttributeLabel03 = ''
   IF NOT (@c_AttributeLabel04 LIKE 'LOTTABLE[0-9][0-9]' AND @c_AttributeLabel04 BETWEEN 'LOTTABLE01' AND 'LOTTABLE15')  SET @c_AttributeLabel04 = ''
   IF NOT (@c_AttributeLabel05 LIKE 'LOTTABLE[0-9][0-9]' AND @c_AttributeLabel05 BETWEEN 'LOTTABLE01' AND 'LOTTABLE15')  SET @c_AttributeLabel05 = ''


   DECLARE CUR_CHTRF CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT CTH.ChannelTransferKey
     FROM ChannelTransfer       CTH WITH(NOLOCK)
     JOIN ChannelTransferDetail CTD WITH(NOLOCK) ON CTH.ChannelTransferkey = CTD.ChannelTransferkey
     JOIN CODELKUP              CL  WITH(NOLOCK) ON CL.Listname = 'AUTOCTTYPE' AND CTH.FromStorerkey = CL.Storerkey AND CL.Code = CTH.Type AND CTH.Facility = CL.Code2
    WHERE CTH.FromStorerkey = @c_Storerkey
      AND CTH.ChannelTransferkey = CASE WHEN ISNULL(@c_ChannelTransferkey,'')<>'' THEN @c_ChannelTransferkey ELSE CTH.ChannelTransferkey END
      AND CTH.Status < '9'
      AND CTD.Status < '9'
      AND CTD.Userdefine01 NOT IN ('SHORT', 'Finalize Error')
    GROUP BY CTH.ChannelTransferKey
    HAVING MAX(CTH.EditDate) < DATEADD(n, -5, GETDATE())
       AND MAX(CTD.EditDate) < DATEADD(n, -5, GETDATE())
    ORDER BY 1

   OPEN CUR_CHTRF


   WHILE @n_Continue IN (1,2)
   BEGIN
      FETCH NEXT FROM CUR_CHTRF INTO @c_ChannelTrfkey

      IF @@FETCH_STATUS <> 0
         BREAK

      DECLARE CUR_CHTRF_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT CTD.ChannelTransferLineNumber, CL.Short, CTD.FromStorerkey, CTD.FromSku, CTD.FromQty, CTD.ToQty
           , CTD.ToStorerkey, CTD.ToSku, CTD.ToChannel
           , CTD.FromC_Attribute01, CTD.FromC_Attribute02, CTD.FromC_Attribute03, CTD.FromC_Attribute04, CTD.FromC_Attribute05
           , CTD.ToC_Attribute01, CTD.ToC_Attribute02, CTD.ToC_Attribute03, CTD.ToC_Attribute04, CTD.ToC_Attribute05
        FROM ChannelTransfer       CTH WITH(NOLOCK)
        JOIN ChannelTransferDetail CTD WITH(NOLOCK) ON CTH.ChannelTransferkey = CTD.ChannelTransferkey
        LEFT JOIN CODELKUP         CL  WITH(NOLOCK) ON CL.Listname = 'AUTOCTHWC' AND CTD.FromStorerkey = CL.Storerkey AND CTD.FromChannel = CL.Code AND CTH.Facility = CL.Code2
       WHERE CTD.ChannelTransferkey = @c_ChannelTrfkey
         AND CTD.STATUS < '9'
         AND CTD.Userdefine01 NOT IN ('SHORT', 'Finalize Error')
       ORDER BY CTD.ChannelTransferLineNumber

      OPEN CUR_CHTRF_DET

      WHILE @n_Continue IN (1,2)
      BEGIN
         FETCH NEXT FROM CUR_CHTRF_DET INTO @c_ChannelTrfLineNo, @c_HostWHCode, @c_FromStorerkey, @c_FromSku, @n_FromQty, @n_ToQty
            , @c_ToStorerkey, @c_ToSku, @c_ToChannel
            , @c_FromC_Attribute01, @c_FromC_Attribute02, @c_FromC_Attribute03, @c_FromC_Attribute04, @c_FromC_Attribute05
            , @c_ToC_Attribute01, @c_ToC_Attribute02, @c_ToC_Attribute03, @c_ToC_Attribute04, @c_ToC_Attribute05

         IF @@FETCH_STATUS <> 0
            BREAK

         SELECT @n_Err = 0
              , @c_ErrMsg = ''

         IF ISNULL(@c_FromStorerkey,'')<>ISNULL(@c_ToStorerkey,'')
         BEGIN
            SET @n_Err = 100001
            SET @c_ErrMsg = 'FromStorerkey '''+ISNULL(RTRIM(@c_FromStorerkey),'')+''' <> ToStorerkey '''+ISNULL(RTRIM(@c_ToStorerkey),'')+''''
            GOTO NEXT_LINE
         END

         IF ISNULL(@c_FromSku,'')<>ISNULL(@c_ToSku,'')
         BEGIN
            SET @n_Err = 100002
            SET @c_ErrMsg = 'FromSku '''+ISNULL(RTRIM(@c_FromSku),'')+''' <> ToSku '''+ISNULL(RTRIM(@c_ToSku),'')+''''
            GOTO NEXT_LINE
         END

         IF ISNULL(@n_FromQty,'')<>ISNULL(@n_ToQty,'')
         BEGIN
            SET @n_Err = 100003
            SET @c_ErrMsg = 'FromQty '+CONVERT(VARCHAR(10),ISNULL(@n_FromQty,0))+' <> ToQty '+CONVERT(VARCHAR(10),ISNULL(@n_ToQty,0))
            GOTO NEXT_LINE
         END

         IF ISNULL(@n_FromQty,'') <= 0
         BEGIN
            SET @n_Err = 100004
            SET @c_ErrMsg = 'FromQty '+CONVERT(VARCHAR(10),ISNULL(@n_FromQty,0))+' < 0'
            GOTO NEXT_LINE
         END

         SELECT @n_CurrLLI = 0
              , @n_CurrChannelInv = 0

         SET @c_SQL = N'SELECT @n_CurrLLI = SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked)'
           + ' FROM LOTxLOCxID LLI WITH(NOLOCK)'
           + ' JOIN LOC LOC WITH(NOLOCK) ON LLI.Loc = LOC.Loc'
           + ' JOIN LOTATTRIBUTE LA WITH(NOLOCK) ON LLI.Lot = LA.Lot'
           + ' WHERE LLI.Storerkey = ''' + ISNULL(REPLACE(@c_FromStorerkey,'''',''''''),'') + ''''
           +   ' AND LLI.Sku = ''' + ISNULL(REPLACE(@c_FromSku,'''',''''''),'') + ''''

         IF ISNULL(@c_HostWHCode,'') <> ''
            SET @c_SQL = @c_SQL + ' AND LOC.HostWHCode = ''' + ISNULL(REPLACE(@c_HostWHCode,'''',''''''),'') + ''''

         IF ISNULL(@c_AttributeLabel01,'') <> ''
            SET @c_SQL = @c_SQL + ' AND ISNULL(LA.' + @c_AttributeLabel01 + ','''') = ''' + ISNULL(REPLACE(@c_FromC_Attribute01,'''',''''''),'') + ''''

         IF ISNULL(@c_AttributeLabel02,'') <> ''
            SET @c_SQL = @c_SQL + ' AND ISNULL(LA.' + @c_AttributeLabel02 + ','''') = ''' + ISNULL(REPLACE(@c_FromC_Attribute02,'''',''''''),'') + ''''

         IF ISNULL(@c_AttributeLabel03,'') <> ''
            SET @c_SQL = @c_SQL + ' AND ISNULL(LA.' + @c_AttributeLabel03 + ','''') = ''' + ISNULL(REPLACE(@c_FromC_Attribute03,'''',''''''),'') + ''''

         IF ISNULL(@c_AttributeLabel04,'') <> ''
            SET @c_SQL = @c_SQL + ' AND ISNULL(LA.' + @c_AttributeLabel04 + ','''') = ''' + ISNULL(REPLACE(@c_FromC_Attribute04,'''',''''''),'') + ''''

         IF ISNULL(@c_AttributeLabel05,'') <> ''
            SET @c_SQL = @c_SQL + ' AND ISNULL(LA.' + @c_AttributeLabel05 + ','''') = ''' + ISNULL(REPLACE(@c_FromC_Attribute05,'''',''''''),'') + ''''

         EXEC sp_executesql @c_SQL
            , N'@n_CurrLLI INT OUTPUT'
            , @n_CurrLLI OUTPUT

         IF @n_CurrLLI < 0
            SET @n_CurrLLI = 0

         SELECT @n_CurrChannelInv = SUM(Qty - QtyAllocated - QtyOnHold)
         FROM CHANNELINV WITH(NOLOCK)
         WHERE Storerkey = @c_ToStorerkey
           AND Sku = @c_ToSku
           AND Channel = @c_ToChannel
           AND C_Attribute01 = @c_ToC_Attribute01
           AND C_Attribute02 = @c_ToC_Attribute02
           AND C_Attribute03 = @c_ToC_Attribute03
           AND C_Attribute04 = @c_ToC_Attribute04
           AND C_Attribute05 = @c_ToC_Attribute05

         IF @n_CurrChannelInv < 0
            SET @n_CurrChannelInv = 0

         SET @n_AvailQty = ISNULL(@n_CurrLLI,0) - ISNULL(@n_CurrChannelInv,0)
         
         IF @n_AvailQty < 0
            SET @n_AvailQty = 0


         IF @n_FromQty > @n_AvailQty
         BEGIN
            INSERT INTO @t_EmailAlert (ChannelTransferkey, ChannelTransferLineNumber, Sku, FromQty, Err, ErrMsg)
            VALUES(@c_ChannelTrfkey, @c_ChannelTrfLineNo, @c_FromSku, @n_FromQty, 1, 'Short Qty')

            EXEC nspLogAlert
                 @c_modulename         = 'isp_AutoFinalizeCHTRF_PUMA'
               , @c_AlertMessage       = 'Short Qty'
               , @n_Severity           = 5
               , @b_success            = 0
               , @n_err                = 0
               , @c_errmsg             = ''
               , @c_Activity           = 'Auto Finalize CHTRF'
               , @c_Storerkey          = @c_FromStorerkey
               , @c_SKU                = @c_FromSku
               , @c_TaskDetailKey      = @c_ChannelTrfkey
               , @c_UCCNo              = @c_ChannelTrfLineNo

            UPDATE ChannelTransferDetail WITH(ROWLOCK)
               SET FromQty      = @n_AvailQty
                 , ToQty        = @n_AvailQty
                 , Userdefine01 = 'SHORT'
                 , Userdefine02 = FromQty
             WHERE ChannelTransferkey = @c_ChannelTrfkey
               AND ChannelTransferLineNumber = @c_ChannelTrfLineNo
               AND Status < '9'
         END

         IF EXISTS(SELECT TOP 1 1 FROM ChannelTransferDetail WITH(NOLOCK)
                   WHERE ChannelTransferkey = @c_ChannelTrfkey AND ChannelTransferLineNumber = @c_ChannelTrfLineNo AND FromQty>0)
         BEGIN
            EXEC isp_FinalizeChannelTransfer
                 @c_ChannelTrfkey
               , @c_ChannelTrfLineNo
               , @b_Success OUTPUT
               , @n_Err     OUTPUT
               , @c_ErrMsg  OUTPUT

            IF @b_Success = 0
            BEGIN
               IF ISNULL(@c_ErrMsg,'')=''
                  SET @c_ErrMsg = 'ERROR: Failed to Finalize ChannelTransferkey=' + ISNULL(@c_ChannelTrfkey,'') + ', Line#=' + ISNULL(@c_ChannelTrfLineNo,'')
               GOTO NEXT_LINE
            END
         END

NEXT_LINE:
         IF ISNULL(@c_ErrMsg,'')<>''
         BEGIN
            UPDATE ChannelTransferDetail WITH(ROWLOCK)
               SET Userdefine01 = 'Finalize Error'
             WHERE ChannelTransferkey = @c_ChannelTrfkey
               AND ChannelTransferLineNumber = @c_ChannelTrfLineNo
               AND Status < '9'

            INSERT INTO @t_EmailAlert (ChannelTransferkey, ChannelTransferLineNumber, Sku, FromQty, Err, ErrMsg)
            VALUES(@c_ChannelTrfkey, @c_ChannelTrfLineNo, @c_FromSku, @n_FromQty, @n_Err, @c_ErrMsg)

            EXEC nspLogAlert
                 @c_modulename         = 'isp_AutoFinalizeCHTRF_PUMA'
               , @c_AlertMessage       = @c_ErrMsg
               , @n_Severity           = 5
               , @b_success            = 0
               , @n_err                = 0
               , @c_errmsg             = ''
               , @c_Activity           = 'Auto Finalize CHTRF'
               , @c_Storerkey          = @c_FromStorerkey
               , @c_SKU                = @c_FromSku
               , @c_TaskDetailKey      = @c_ChannelTrfkey
               , @c_UCCNo              = @c_ChannelTrfLineNo
         END
      END
      CLOSE CUR_CHTRF_DET
      DEALLOCATE CUR_CHTRF_DET
   END
   CLOSE CUR_CHTRF
   DEALLOCATE CUR_CHTRF


   IF EXISTS(SELECT TOP 1 1 FROM @t_EmailAlert)
      AND (ISNULL(@c_Recipients,'')<>'' OR ISNULL(@c_CC,'')<>'' OR ISNULL(@c_BCC,'')<>'')
   BEGIN
      IF ISNULL(@c_AlertSubject,'') = ''
         SET @c_AlertSubject = '['+TRIM(ISNULL(@c_Storerkey,''))+'] Auto Finalize Channel Transfer Alert (' + @@servername + ')'

      SET @c_tableHTML = '<style type="text/css">.table {font-family: arial, "lucida console", sans-serif;  font-size: 100%;}</style><table class="table"  border="1" cellpadding="3" cellspacing="0"><tr><td>ChannelTransferkey<td>LineNo<td>Sku<td>Qty<td>Err<td>ErrMsg</tr>'
        + CAST( (SELECT
                    td = ISNULL(RTRIM(ChannelTransferkey),''), '',
                    td = ISNULL(RTRIM(ChannelTransferLineNumber),''), '',
                    td = ISNULL(RTRIM(Sku),''), '',
                    td = ISNULL(CONVERT(NVARCHAR(10),FromQty),''), '',
                    td = ISNULL(CONVERT(NVARCHAR(10),Err),''), '',
                    td = ISNULL(RTRIM(ErrMsg),'')
                  FROM @t_EmailAlert
                  ORDER BY RowNo
                  FOR XML PATH('tr'),TYPE
          ) AS VARCHAR(MAX) ) + '</table>'

      EXEC msdb.dbo.sp_send_dbmail
           @recipients = @c_Recipients, 
           @copy_recipients = @c_CC,
           @blind_copy_recipients = @c_BCC,
           @subject = @c_AlertSubject,
           @body = @c_tableHTML,
           @body_format = 'HTML'
   END

QUIT_SP:
   IF CURSOR_STATUS('LOCAL', 'CUR_CHTRF') IN (0 , 1)
   BEGIN
      CLOSE CUR_CHTRF
      DEALLOCATE CUR_CHTRF
   END
   IF CURSOR_STATUS('LOCAL', 'CUR_CHTRF_DET') IN (0 , 1)
   BEGIN
      CLOSE CUR_CHTRF_DET
      DEALLOCATE CUR_CHTRF_DET
   END

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_AutoFinalizeCHTRF_PUMA'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCount
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_AutoFinalizeCHTRF_PUMA] TO [nSQL]
GO