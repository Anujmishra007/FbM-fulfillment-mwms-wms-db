
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************/
/* Store Procedure:  isp_753Routing_Granite                                            */
/* Creation Date:  08-Oct-2024                                                         */
/* Copyright: Maersk WMS                                                               */
/* Written by:  Shong                                                                  */
/*                                                                                     */
/* JIRA TICKET: FCR-921                                                                */
/* Purpose:  RCMConfig Routing Request for Orders with SCAC Code                       */
/*                                                                                     */
/*                                                                                     */
/* Version: 5.4                                                                        */
/*                                                                                     */
/* Data Modifications:                                                                 */
/*                                                                                     */
/* Updates:                                                                            */
/* Date         Author      Ver         Purposes                                       */
/* YYYY-DD-MM   {author}    {ver}       Close Cursor                                   */
/* 2024-08-10   Shong       1.0         Created                                        */
/* 2024-10-14   Shong       1.1         Adding Valication for Pickup date Userdefine02 */
/***************************************************************************************/
ALTER   PROCEDURE [dbo].[isp_753Routing_Granite]
   @c_WaveKey NVARCHAR(10),
   @b_Success INT OUTPUT,
   @n_err     INT OUTPUT,
   @c_errmsg  NVARCHAR(250) OUTPUT,
   @c_Code    NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON

   DECLARE @c_OrderKey        NVARCHAR(10)  = N''
         , @c_BillToKey       NVARCHAR(15)  = N''
         , @c_OrderInfo09     NVARCHAR(30)  = N''
         , @c_StorerKey       NVARCHAR(15)  = N''
         , @c_C_Contact1      NVARCHAR(100) = N''
         , @c_MarkforKey      NVARCHAR(15)  = N'' 
         , @c_ConsigneeKey    NVARCHAR(15)  = N''
         , @c_M_Contact1      NVARCHAR(100) = N''
         , @c_FirstString     NVARCHAR(50)  = N''
         , @c_SecondString    NVARCHAR(50)  = N''
         , @c_CurrentDate     NVARCHAR(10)  = N''
         , @c_735RoutingKey   NVARCHAR(6)   = N''
         , @n_Continue        INT = 1
         , @n_StartTranCnt    INT
         , @b_Debug           INT = 0 
         , @d_PicUpDate       DATETIME
         , @c_UserDefine02    NVARCHAR(20)
         

   SET @n_Continue = 1
   SELECT @n_StartTranCnt = @@TRANCOUNT

   SET @c_UserDefine02 = ''
   SELECT @c_UserDefine02 = ISNULL(TRIM(UserDefine02),'')
   FROM WAVE WITH (NOLOCK)
   WHERE WaveKey = @c_WaveKey

   IF @c_UserDefine02 = ''
   BEGIN 
      SELECT @n_continue = 3;
      SELECT @n_err = 562751;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Pickup Date (UserDefine02) cannot be BLANK. (isp_753Routing_Granite)';
      GOTO RETURN_SP; 
   END   

   SET DATEFORMAT mdy;
   IF ISDATE(@c_UserDefine02) <> 1
   BEGIN 
      SELECT @n_continue = 3;
      SELECT @n_err = 500253;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Wrong Date Format - ' + @d_PicUpDate + ', Correct Format is (MM/DD/YYYY). (isp_753Routing_Granite)';
      GOTO RETURN_SP; 
   END     

   -- Check if date fall under Suturday (7) or Sunday (1)
   SET @d_PicUpDate = TRY_CAST (@c_UserDefine02 AS Datetime)
   IF @d_PicUpDate IS NOT NULL 
   BEGIN
      IF DATEPART(weekday, @d_PicUpDate) IN (1,7)
      BEGIN 
         SELECT @n_continue = 3;
         SELECT @n_err = 500254;
         SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': The pick-up date cannot fall on a Saturday or Sunday. (isp_753Routing_Granite)';
         GOTO RETURN_SP; 
      END   
   END 

   DECLARE CUR_BillToKey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
   SELECT Distinct O.BillToKey, O.StorerKey 
   FROM dbo.WaveDetail WD (NOLOCK)
   JOIN dbo.ORDERS O (NOLOCK) on WD.OrderKey = O.OrderKey 
   WHERE WD.WaveKey = @c_WaveKey

   OPEN CUR_BillToKey

   FETCH NEXT FROM CUR_BillToKey INTO @c_BillToKey, @c_StorerKey 
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @c_FirstString = ''

      SELECT @c_FirstString = CLK.Notes 
      FROM dbo.CODELKUP CLK (NOLOCK)  
      WHERE CLK.code = @c_BillToKey 
      AND CLK.Storerkey = @c_StorerKey
      AND CLK.LISTNAME='LVS753754' 
      AND SHORT='SUBSCRIBID' 

      IF @c_FirstString = ''
      BEGIN 
			SELECT @n_continue = 3;
			SELECT @n_err = 562751;
			SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Codelkup Not Setup for ' + @c_BillToKey + '. (isp_753Routing_Granite)';
			GOTO RETURN_SP; 
      END 
      
      DECLARE CUR_OrderKey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT O.OrderKey
      , ISNULL(TRIM(O.MarkforKey),'')
      , ISNULL(TRIM(O.ConsigneeKey),'')
      , ISNULL(TRIM(O.M_Contact1),'')
      , ISNULL(TRIM(O.C_Contact1),'') 
      FROM dbo.WAVEDETAIL WD WITH (NOLOCK) 
      JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = WD.OrderKey
      WHERE  WD.WaveKey = @c_WaveKey 
      AND O.BillToKey = @c_BillToKey
      
      OPEN CUR_OrderKey
      
      FETCH NEXT FROM CUR_OrderKey INTO @c_OrderKey, @c_MarkforKey, @c_ConsigneeKey, @c_M_Contact1, @c_C_Contact1
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
         IF ISNULL(@c_MarkforKey,'') <> ''  
         BEGIN
           IF ISNULL(@c_MarkforKey,'') <> ISNULL(@c_ConsigneeKey,'')  
            BEGIN
           IF ISNULL(@c_M_Contact1, '') = '' 
               BEGIN
             SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
                  FROM dbo.STORER (NOLOCK) 
                  WHERE ConsigneeFor = @c_StorerKey 
                  AND [Type] = '2' 
                  AND StorerKey = @c_MarkforKey
               END 
           ELSE 
            SET @c_SecondString = @c_M_Contact1 
        END
            ELSE 
            BEGIN 
               IF ISNULL(@c_C_Contact1, '') =  '' 
               BEGIN 
                  SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
                  FROM dbo.STORER (NOLOCK)
                  WHERE ConsigneeFor = @c_StorerKey
                  AND type = '2' 
                  AND StorerKey = @c_ConsigneeKey
               END 
             ELSE 
              SET @c_SecondString = @c_C_Contact1 
            END 
         END 
         ELSE  
         BEGIN
          IF ISNULL(@c_C_Contact1, '') =  '' 
            BEGIN
               SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
               FROM dbo.STORER (NOLOCK)
               WHERE ConsigneeFor = @c_StorerKey
               AND type = '2' 
               AND StorerKey = @c_ConsigneeKey
            END 
          ELSE 
           SET @c_SecondString = @c_C_Contact1 
         END 
      
         SELECT @c_SecondString = RIGHT('00000' + @c_SecondString, 5)

         SELECT @c_CurrentDate = CONVERT(VARCHAR(10), GETDATE(), 112)

         EXEC dbo.nspg_GetKey
            @KeyName = '735Routing'
         ,  @fieldlength = 6
         ,  @keystring = @c_735RoutingKey OUTPUT
         ,  @b_Success = @b_Success       OUTPUT
         ,  @n_Err     = @n_Err           OUTPUT
         ,  @c_ErrMsg  = @c_ErrMsg        OUTPUT

         SET @c_OrderInfo09 = @c_FirstString + @c_SecondString + @c_CurrentDate + @c_735RoutingKey

         IF LEN(@c_OrderInfo09) = 25
         BEGIN 
            UPDATE dbo.OrderInfo
              SET OrderInfo09 = @c_OrderInfo09  
             WHERE OrderKey = @c_OrderKey
         END 
         ELSE
         BEGIN 
			   SELECT @n_continue = 3;
			   SELECT @n_err = 562752;
			   SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Generate 735 Routing Number Failed. (isp_753Routing_Granite)';
			   GOTO RETURN_SP;            
         END 

         FETCH NEXT FROM CUR_OrderKey INTO @c_OrderKey, @c_MarkforKey, @c_ConsigneeKey, @c_M_Contact1, @c_C_Contact1
      END
      CLOSE CUR_OrderKey
      DEALLOCATE CUR_OrderKey

      -------------------------------
      -- Part 2 Insert transmitlog 2
      -------------------------------
      /* declare variables */
      IF @c_Code='DBUG'
         SET @b_Debug = 1 

      DECLARE @c_SortOrder NVARCHAR(10),
              @c_ColumnName01 NVARCHAR(60),
              @c_ColumnName02 NVARCHAR(60),
              @c_SQLFilter  NVARCHAR(4000),
              @c_TransmitBatch      NVARCHAR(60),
              @c_SQL        NVARCHAR(4000), 
              @c_Col01Value NVARCHAR(100) = '',
              @c_Col02Value NVARCHAR(100) = '',
              @b_RecordFound BIT = 0
      
      IF @b_Debug =1
      BEGIN
         PRINT 'Bill To Key: ' + @c_BillToKey 
      END 

      DECLARE CUR_CODELKUP_QUERY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
      SELECT SortOrder= CASE WHEN CLK.Code2 = '' THEN '999' ELSE CLK.Code2 END,
            CLK.UDF01, CLK.UDF02, ISNULL(TRIM(CLK.Notes), '') AS SQLCondition, 
            CLK.UDF03
      FROM dbo.CODELKUP CLK WITH (NOLOCK) 
      WHERE CLK.LISTNAME = 'DYNROUTE'
      AND CLK.Code=@c_BillToKey
      ORDER BY SortOrder
      
      OPEN CUR_CODELKUP_QUERY
      
      FETCH NEXT FROM CUR_CODELKUP_QUERY INTO @c_SortOrder, @c_ColumnName01, @c_ColumnName02, @c_SQLFilter, @c_TransmitBatch
      
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SELECT @c_Col01Value='', @c_Col02Value=''
         SET @b_RecordFound = 0

         SELECT @c_SQL =  'DECLARE CUR_TRANSMITLOG_REC CURSOR FAST_FORWARD READ_ONLY FOR ' + CHAR(13) +
                          'SELECT ' + @c_ColumnName01 + ',  ' + @c_ColumnName02 + CHAR(13) +
                          'FROM dbo.ORDERS ORDERS (NOLOCK) ' + CHAR(13) +
                          'JOIN dbo.WAVEDETAIL WAVEDETAIL (NOLOCK) ON ORDERS.OrderKey = WAVEDETAIL.OrderKey '  + CHAR(13) +
                          'JOIN dbo.WAVE WAVE (NOLOCK) ON WAVE.WaveKey = WAVEDETAIL.WaveKey ' + CHAR(13) +
                          'WHERE WAVE.WaveKey = ''' + @c_WaveKey + ''' '  + CHAR(13) +
                          '  AND ORDERS.BillToKey = ''' + @c_BillToKey + ''' '  + CHAR(13)  
         
         IF TRIM(@c_SQLFilter) <> ''
         BEGIN
            IF CHARINDEX('AND ', LTRIM(@c_SQLFilter), 1) = 1 
               SET @c_SQL = @c_SQL + @c_SQLFilter
            ELSE 
               SET @c_SQL = @c_SQL + ' AND ' + @c_SQLFilter
         END 

         IF @b_Debug = 1
         BEGIN
            PRINT @c_SQL
         END 

         EXEC sp_executesql @c_SQL 

         IF CURSOR_STATUS('global','CUR_TRANSMITLOG_REC') = -3
         BEGIN
			   SELECT @n_continue = 3;
			   SELECT @n_err = 562753;
			   SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Declare Cursor Failed. (isp_753Routing_Granite)';
			   GOTO RETURN_SP; 
         END

         OPEN CUR_TRANSMITLOG_REC

         FETCH NEXT FROM CUR_TRANSMITLOG_REC INTO @c_Col01Value, @c_Col02Value

         WHILE @@FETCH_STATUS = 0 
         BEGIN
            IF @c_Col01Value <> '' AND @c_Col02Value <> ''
            BEGIN
               SET @b_RecordFound = 1
               EXEC dbo.ispGenTransmitLog2 @c_TableName = N'WSSOROUTLOG ',   
                                           @c_Key1 = @c_Col01Value,     
                                           @c_Key2 = @c_Col02Value,      
                                           @c_Key3 = @c_StorerKey,   
                                           @c_TransmitBatch = @c_TransmitBatch,         
                                           @b_Success = @b_Success OUTPUT,  
                                           @n_err = @n_err OUTPUT,         
                                           @c_errmsg = @c_errmsg OUTPUT                  
            END
   

            FETCH NEXT FROM CUR_TRANSMITLOG_REC INTO @c_Col01Value, @c_Col02Value     
         END
         CLOSE CUR_TRANSMITLOG_REC
         DEALLOCATE CUR_TRANSMITLOG_REC

         IF @b_RecordFound = 1 
            BREAK
      
          FETCH NEXT FROM CUR_CODELKUP_QUERY INTO @c_SortOrder, @c_ColumnName01, @c_ColumnName02, @c_SQLFilter, @c_TransmitBatch
      END
      
      CLOSE CUR_CODELKUP_QUERY
      DEALLOCATE CUR_CODELKUP_QUERY


      FETCH NEXT FROM CUR_BillToKey INTO @c_BillToKey, @c_StorerKey
   END 
   CLOSE CUR_BillToKey

   RETURN_SP:
	IF @n_continue = 3  -- Error Occurred - Process And Return
	BEGIN
		SELECT @b_Success = 0;
		IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTranCnt
		BEGIN
			ROLLBACK TRAN;
		END
		ELSE
		BEGIN
			WHILE @@TRANCOUNT > @n_StartTranCnt
			BEGIN
				COMMIT TRAN
			END
		END
		EXECUTE dbo.nsp_LogError @n_err, @c_errmsg, 'isp_753Routing_Granite'
		RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
		RETURN -1
	END
	ELSE
	BEGIN
		SELECT @b_Success = 1;
		IF @@TRANCOUNT > @n_StartTranCnt
		BEGIN
			COMMIT TRAN;
		END;
		RETURN 0;
	END;
END -- Procedure
