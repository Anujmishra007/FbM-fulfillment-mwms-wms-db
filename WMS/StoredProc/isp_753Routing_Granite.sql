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
/* 2024-08-10   Shong       1.0         Created                                        */
/* 2024-10-14   Shong       1.1         Adding Valication for Pickup date Userdefine02 */
/* 2024-10-15   Shong       1.2         Changing Update By Dynamic group setup         */
/* 2024-11-18   Shong       1.3         New validation logic before actual SP begins   */
/* 26-May-2026  WLChooi     1.4         FCR-13104 Added Validation for early submission*/
/*                                      for 753 (WL01)                                 */
/***************************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_753Routing_Granite]
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
         , @c_Col01Value      NVARCHAR(15)  = N'' 
         , @c_Col02Value      NVARCHAR(15)  = N''
         , @c_M_Contact1      NVARCHAR(100) = N''
         , @c_FirstString     NVARCHAR(50)  = N''
         , @c_SecondString    NVARCHAR(50)  = N''
         , @c_CurrentDate     NVARCHAR(10)  = N''
         , @c_735RoutingKey   NVARCHAR(6)   = N''
         , @n_Continue        INT = 1
         , @n_StartTranCnt    INT
         , @b_Debug           INT = 0 
         , @d_PickupDate      DATETIME
         , @c_UserDefine02    NVARCHAR(20)

   DECLARE @c_SortOrder     NVARCHAR(10)
         , @c_ColumnName01  NVARCHAR(60)
         , @c_ColumnName02  NVARCHAR(60)
         , @c_SQLFilter     NVARCHAR(4000)
         , @c_TransmitBatch NVARCHAR(60)
         , @c_SQL           NVARCHAR(4000)
         , @c_SQL2          NVARCHAR(4000)
         , @b_RecordFound   BIT           = 0
         , @c_TMReleaseFlag NVARCHAR(20) = 'N'
         , @cTransmitLogSubmitDate NVARCHAR(10) = ''; --(Ver 1.3)

   --WL01 S
   DECLARE @c_TableName       NVARCHAR(30) = N'WSWAVELOG'

   IF OBJECT_ID('tempdb..#TMP_WaveOrders') IS NOT NULL
      DROP TABLE #TMP_WaveOrders

   CREATE TABLE #TMP_WaveOrders
   (
         OrderKey   NVARCHAR(10) PRIMARY KEY
       , StorerKey  NVARCHAR(15) NOT NULL
       , [Status]   NVARCHAR(10) NOT NULL
       , BillToKey  NVARCHAR(15) NOT NULL
   );
   --WL01 E

   SET @n_Continue = 1
   SELECT @n_StartTranCnt = @@TRANCOUNT

   SET @c_UserDefine02 = ''
   SET @cTransmitLogSubmitDate = ''

   SELECT @c_UserDefine02 = ISNULL(TRIM(UserDefine02),'')
        , @c_TMReleaseFlag=ISNULL(Wave.TMReleaseFlag,'N')
        , @cTransmitLogSubmitDate = ISNULL(Wave.UserDefine10, '')
   FROM dbo.WAVE WITH (NOLOCK)
   WHERE WaveKey = @c_WaveKey

   IF @c_UserDefine02 = ''
   BEGIN 
      SELECT @n_continue = 3;
      SELECT @n_err = 562751;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Pickup Date (UserDefine02) cannot be BLANK. (isp_753Routing_Granite)';
      GOTO RETURN_SP; 
   END  

   SET DATEFORMAT mdy;
   IF ISDATE(@c_UserDefine02) <> 1 OR @c_UserDefine02 NOT LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
   BEGIN 
      SELECT @n_continue = 3;
      SELECT @n_err = 500253;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Wrong Date Format - ' + @d_PickupDate + ', Correct Format is (MM/DD/YYYY). (isp_753Routing_Granite)';
      GOTO RETURN_SP; 
   END     

   IF @cTransmitLogSubmitDate <> '' AND ISDATE(@cTransmitLogSubmitDate) = 1
   BEGIN 
      SELECT @n_continue = 3;
      SELECT @n_err = 500256;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Retrigger of 753 is not allow. Trigger had submitted on ' + @cTransmitLogSubmitDate + '. (isp_753Routing_Granite)';
      GOTO RETURN_SP; 
   END   

   -- Check if date fall under Suturday (7) or Sunday (1)
   SET @d_PickupDate = TRY_CAST (@c_UserDefine02 AS Datetime)
   IF @d_PickupDate IS NOT NULL 
   BEGIN
      IF DATEPART(weekday, @d_PickupDate) IN (1,7)
      BEGIN 
         SELECT @n_continue = 3;
         SELECT @n_err = 500254;
         SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': The pick-up date cannot fall on a Saturday or Sunday. (isp_753Routing_Granite)';
         GOTO RETURN_SP; 
      END   
   END 

   --(Ver 1.3) Begin
   IF @c_TMReleaseFlag <> 'Y' 
   BEGIN 
      SELECT @n_continue = 3;
      SELECT @n_err = 500255;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Wave not release yet. (isp_753Routing_Granite)';
      GOTO RETURN_SP; 
   END   
   
   DECLARE @c_MBOLKey NVARCHAR(10) = N'';
   SELECT TOP 1 @c_MBOLKey = MD.MbolKey
   FROM dbo.WAVEDETAIL WD WITH (NOLOCK) 
   JOIN dbo.MBOLDETAIL MD WITH (NOLOCK) ON WD.OrderKey = MD.OrderKey
   WHERE WD.WaveKey = @c_WaveKey
   ORDER BY MD.MbolKey DESC 

   IF @c_MBOLKey <> ''
   BEGIN
      SELECT @n_continue = 3;
      SELECT @n_err = 500256;
      SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Order already exist in Ship Ref ' + @c_MBOLKey + '. (isp_753Routing_Granite)';
      GOTO RETURN_SP;        
   END

   -- (Ver 1.3) End

   --WL01 S
   -- 753 Early Submission
   IF @n_Continue IN (1, 2)
   BEGIN
      INSERT #TMP_WaveOrders (OrderKey, StorerKey, [Status], BillToKey)
      SELECT DISTINCT
             O.OrderKey
           , O.StorerKey
           , ISNULL(O.[Status], '')
           , ISNULL(O.BillToKey, '')
      FROM dbo.WAVEDETAIL WD WITH (NOLOCK)
      JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = WD.OrderKey
      WHERE WD.WaveKey = @c_WaveKey
      
      SELECT TOP 1 @c_StorerKey = O.StorerKey
      FROM #TMP_WaveOrders O

      IF NOT EXISTS ( SELECT 1
                      FROM dbo.TRANSMITLOG2 TL2 WITH (NOLOCK)
                      WHERE TL2.Tablename = @c_TableName
                      AND TL2.Key1 = @c_WaveKey
                      AND TL2.Key2 = ''
                      AND TL2.Key3 = @c_StorerKey )
      BEGIN
         SELECT @n_continue = 3;
         SELECT @n_err = 500257;
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(6), @n_err) + ': Wave#: ' + @c_WaveKey
                          + ' not released to WCS. (isp_753Routing_Granite)';
         GOTO RETURN_SP;
      END

      SET @c_OrderKey = N''
      SELECT TOP 1 @c_OrderKey = O.OrderKey
      FROM #TMP_WaveOrders O
      WHERE O.[Status] IN ('CANC')

      IF @c_OrderKey > ''
      BEGIN
         SELECT @n_continue = 3;
         SELECT @n_err = 500258;
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(6), @n_err) + ': Cancelled Order Exists in Wave#: ' + @c_WaveKey
                          + '. ' + 'Order#: ' + @c_OrderKey + '. (isp_753Routing_Granite)';
         GOTO RETURN_SP;
      END

      IF EXISTS ( SELECT 1
                  FROM #TMP_WaveOrders O
                  HAVING COUNT(DISTINCT O.[Status]) > 1 )
      BEGIN
         SELECT @n_continue = 3;
         SELECT @n_err = 500259;
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(6), @n_err) + ': Wave#: ' + @c_WaveKey
                          + ' Orders in different Status. (isp_753Routing_Granite)';
         GOTO RETURN_SP;
      END
   END
   --WL01 E

   DECLARE CUR_BillToKey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
   SELECT DISTINCT O.BillToKey, O.StorerKey
   FROM #TMP_WaveOrders O                                     --WL01
   --FROM dbo.WaveDetail WD (NOLOCK)                          --WL01
   --JOIN dbo.ORDERS O (NOLOCK) on WD.OrderKey = O.OrderKey   --WL01
   --WHERE WD.WaveKey = @c_WaveKey                            --WL01

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
      
      --DECLARE CUR_OrderKey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      --SELECT O.OrderKey
      --, ISNULL(TRIM(O.MarkforKey),'')
      --, ISNULL(TRIM(O.ConsigneeKey),'')
      --, ISNULL(TRIM(O.M_Contact1),'')
      --, ISNULL(TRIM(O.C_Contact1),'') 
      --FROM dbo.WAVEDETAIL WD WITH (NOLOCK) 
      --JOIN dbo.ORDERS O WITH (NOLOCK) ON O.OrderKey = WD.OrderKey
      --WHERE  WD.WaveKey = @c_WaveKey 
      --AND O.BillToKey = @c_BillToKey
      
      --OPEN CUR_OrderKey
      
      --FETCH NEXT FROM CUR_OrderKey INTO @c_OrderKey, @c_Col01Value, @c_Col02Value, @c_M_Contact1, @c_C_Contact1
      
      --WHILE @@FETCH_STATUS = 0
      --BEGIN
      --   IF ISNULL(@c_Col01Value,'') <> ''  
      --   BEGIN
      --     IF ISNULL(@c_Col01Value,'') <> ISNULL(@c_Col02Value,'')  
      --      BEGIN
      --     IF ISNULL(@c_M_Contact1, '') = '' 
      --         BEGIN
      --       SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
      --            FROM dbo.STORER (NOLOCK) 
      --            WHERE ConsigneeFor = @c_StorerKey 
      --            AND [Type] = '2' 
      --            AND StorerKey = @c_Col01Value
      --         END 
      --     ELSE 
      --      SET @c_SecondString = @c_M_Contact1 
      --  END
      --      ELSE 
      --      BEGIN 
      --         IF ISNULL(@c_C_Contact1, '') =  '' 
      --         BEGIN 
      --            SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
      --            FROM dbo.STORER (NOLOCK)
      --            WHERE ConsigneeFor = @c_StorerKey
      --            AND type = '2' 
      --            AND StorerKey = @c_Col02Value
      --         END 
      --       ELSE 
      --        SET @c_SecondString = @c_C_Contact1 
      --      END 
      --   END 
      --   ELSE  
      --   BEGIN
      --    IF ISNULL(@c_C_Contact1, '') =  '' 
      --      BEGIN
      --         SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
      --         FROM dbo.STORER (NOLOCK)
      --         WHERE ConsigneeFor = @c_StorerKey
      --         AND type = '2' 
      --         AND StorerKey = @c_Col02Value
      --      END 
      --    ELSE 
      --     SET @c_SecondString = @c_C_Contact1 
      --   END 
      
      --   SELECT @c_SecondString = RIGHT('00000' + @c_SecondString, 5)

      --   SELECT @c_CurrentDate = CONVERT(VARCHAR(10), GETDATE(), 112)

      --   EXEC dbo.nspg_GetKey
      --      @KeyName = '735Routing'
      --   ,  @fieldlength = 6
      --   ,  @keystring = @c_735RoutingKey OUTPUT
      --   ,  @b_Success = @b_Success       OUTPUT
      --   ,  @n_Err     = @n_Err           OUTPUT
      --   ,  @c_ErrMsg  = @c_ErrMsg        OUTPUT

      --   SET @c_OrderInfo09 = @c_FirstString + @c_SecondString + @c_CurrentDate + @c_735RoutingKey

      --   IF LEN(@c_OrderInfo09) = 25
      --   BEGIN 
      --      UPDATE dbo.OrderInfo
      --        SET OrderInfo09 = @c_OrderInfo09  
      --       WHERE OrderKey = @c_OrderKey
      --   END 
      --   ELSE
      --   BEGIN 
            --SELECT @n_continue = 3;
            --SELECT @n_err = 562752;
            --SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Generate 735 Routing Number Failed. (isp_753Routing_Granite)';
            --GOTO RETURN_SP;            
      --   END 

      --   FETCH NEXT FROM CUR_OrderKey INTO @c_OrderKey, @c_Col01Value, @c_Col02Value, @c_M_Contact1, @c_C_Contact1
      --END
      --CLOSE CUR_OrderKey
      --DEALLOCATE CUR_OrderKey

      -------------------------------
      -- Part 2 Insert transmitlog 2
      -------------------------------
      /* declare variables */
      IF @c_Code='DBUG'
         SET @b_Debug = 1 

      
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
                                + ', ISNULL(TRIM(MAX(ORDERS.M_Contact1)),''''), ISNULL(TRIM(MAX(ORDERS.C_Contact1)),'''') ' + CHAR(13) +
                          'FROM dbo.ORDERS ORDERS (NOLOCK) ' + CHAR(13) + 
                          'JOIN dbo.WAVEDETAIL WAVEDETAIL (NOLOCK) ON ORDERS.OrderKey = WAVEDETAIL.OrderKey '  + CHAR(13) +
                          'JOIN dbo.WAVE WAVE (NOLOCK) ON WAVE.WaveKey = WAVEDETAIL.WaveKey ' + CHAR(13) +
                          'WHERE WAVE.WaveKey = ''' + @c_WaveKey + ''' '  + CHAR(13) +
                          'AND ORDERS.BillToKey = ''' + @c_BillToKey + ''' '  + CHAR(13)  
         
         IF TRIM(@c_SQLFilter) <> ''
         BEGIN
            IF CHARINDEX('AND ', LTRIM(@c_SQLFilter), 1) = 1 
               SET @c_SQL = @c_SQL + @c_SQLFilter + CHAR(13)
            ELSE 
               SET @c_SQL = @c_SQL + 'AND ' + @c_SQLFilter + ' ' + CHAR(13)
         END 

         SET @c_SQL = @c_SQL + 'GROUP BY ' +  @c_ColumnName01 + ',  ' + @c_ColumnName02 + ' ' + CHAR(13)

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

         FETCH NEXT FROM CUR_TRANSMITLOG_REC INTO @c_Col01Value, @c_Col02Value, @c_M_Contact1, @c_C_Contact1

         WHILE @@FETCH_STATUS = 0 
         BEGIN
            IF @c_Col01Value <> '' AND @c_Col02Value <> ''
            BEGIN
              IF ISNULL(@c_Col01Value,'') <> ''  
              BEGIN
                 IF ISNULL(@c_Col01Value,'') <> ISNULL(@c_Col02Value,'')  
                 BEGIN
                    IF ISNULL(@c_M_Contact1, '') = '' 
                    BEGIN
                      SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
                           FROM dbo.STORER (NOLOCK) 
                           WHERE ConsigneeFor = @c_StorerKey 
                           AND [Type] = '2' 
                           AND StorerKey = @c_Col01Value
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
                        AND StorerKey = @c_Col02Value
                     END 
                     ELSE 
                        SET @c_SecondString = @c_C_Contact1 
                  END 
               END -- IF ISNULL(@c_Col01Value,'') <> '' 
               ELSE  
               BEGIN
                  IF ISNULL(@c_C_Contact1, '') =  '' 
                  BEGIN
                     SELECT @c_SecondString = ISNULL(TRIM(SUSR4), '')
                     FROM dbo.STORER (NOLOCK)
                     WHERE ConsigneeFor = @c_StorerKey
                     AND type = '2' 
                     AND StorerKey = @c_Col02Value
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

               IF @b_Debug=1
               BEGIN
                   PRINT 'OrderInfo09: ' + @c_OrderInfo09
               END

               IF LEN(@c_OrderInfo09) = 25
               BEGIN 
                  SELECT @c_SQL2 = 'DECLARE CUR_ORDERKEY CURSOR FAST_FORWARD READ_ONLY FOR ' + CHAR(13) +
                                   'SELECT ORDERS.OrderKey ' + CHAR(13) +
                                   'FROM dbo.ORDERS ORDERS (NOLOCK) ' + CHAR(13) + 
                                   'JOIN dbo.WAVEDETAIL WAVEDETAIL (NOLOCK) ON ORDERS.OrderKey = WAVEDETAIL.OrderKey '  + CHAR(13) +
                                   'JOIN dbo.WAVE WAVE (NOLOCK) ON WAVE.WaveKey = WAVEDETAIL.WaveKey ' + CHAR(13) +
                                   'WHERE WAVE.WaveKey = ''' + @c_WaveKey + ''' '  + CHAR(13) +
                                   'AND ORDERS.BillToKey = ''' + @c_BillToKey + ''' '  + CHAR(13) +
                                   'AND ' + @c_ColumnName01 + ' = ''' + @c_Col01Value + ''' ' + CHAR(13) +
                                   'AND ' + @c_ColumnName02 + ' = ''' + @c_Col02Value + ''' ' + CHAR(13)  
         
                  IF TRIM(@c_SQLFilter) <> ''
                  BEGIN
                     IF CHARINDEX('AND ', LTRIM(@c_SQLFilter), 1) = 1 
                        SET @c_SQL2 = @c_SQL2 + @c_SQLFilter + CHAR(13)
                     ELSE 
                        SET @c_SQL2 = @c_SQL2 + 'AND ' + @c_SQLFilter + CHAR(13)
                  END 

                  IF @b_Debug = 1
                  BEGIN
                     PRINT @c_SQL2
                  END 

                  EXEC sp_executesql @c_SQL2 

                  IF CURSOR_STATUS('global','CUR_ORDERKEY') = -3
                  BEGIN
                     SELECT @n_continue = 3;
                     SELECT @n_err = 562753;
                     SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Declare CUR_ORDERKEY Cursor Failed. (isp_753Routing_Granite)';
                     GOTO RETURN_SP; 
                  END

                  OPEN CUR_ORDERKEY

                  FETCH NEXT FROM CUR_ORDERKEY INTO @c_OrderKey

                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     UPDATE dbo.OrderInfo
                        SET OrderInfo09 = @c_OrderInfo09  
                        WHERE OrderKey = @c_OrderKey

                     FETCH NEXT FROM CUR_ORDERKEY INTO @c_OrderKey
                  END 
                  CLOSE CUR_ORDERKEY
                  DEALLOCATE CUR_ORDERKEY

               END 
               ELSE
               BEGIN 
                  SELECT @n_continue = 3;
                  SELECT @n_err = 562752;
                  SELECT @c_errmsg='NSQL' + CONVERT(char(6), @n_err) + ': Generate 735 Routing Number Failed. (isp_753Routing_Granite)';
                  GOTO RETURN_SP;            
               END 

               SET @b_RecordFound = 1
               EXEC dbo.ispGenTransmitLog2 @c_TableName = N'WSSOROUTLOG ',   
                                           @c_Key1 = @c_Col01Value,     
                                           @c_Key2 = @c_Col02Value,      
                                           @c_Key3 = @c_StorerKey,   
                                           @c_TransmitBatch = @c_TransmitBatch,         
                                           @b_Success = @b_Success OUTPUT,  
                                           @n_err = @n_err OUTPUT,         
                                           @c_errmsg = @c_errmsg OUTPUT                  
            END -- IF @c_Col01Value <> '' AND @c_Col02Value <> ''
   

            FETCH NEXT FROM CUR_TRANSMITLOG_REC INTO @c_Col01Value, @c_Col02Value, @c_M_Contact1, @c_C_Contact1     
         END
         CLOSE CUR_TRANSMITLOG_REC
         DEALLOCATE CUR_TRANSMITLOG_REC

         IF @b_RecordFound = 1 
            BREAK
      
          FETCH NEXT FROM CUR_CODELKUP_QUERY INTO @c_SortOrder, @c_ColumnName01, @c_ColumnName02, @c_SQLFilter, @c_TransmitBatch
      END -- IF @c_Col01Value <> '' AND @c_Col02Value <> ''
      
      CLOSE CUR_CODELKUP_QUERY
      DEALLOCATE CUR_CODELKUP_QUERY


      FETCH NEXT FROM CUR_BillToKey INTO @c_BillToKey, @c_StorerKey
   END 
   CLOSE CUR_BillToKey
   DEALLOCATE CUR_BillToKey   --WL01

   IF @n_Continue IN (1,2)
   BEGIN
       SET @cTransmitLogSubmitDate= CONVERT(NVARCHAR(10), GETDATE(), 110)
       UPDATE dbo.WAVE WITH (ROWLOCK)
         SET UserDefine10 = @cTransmitLogSubmitDate, 
             EditDate=GETDATE()
       WHERE WaveKey = @c_WaveKey
       
   END

   RETURN_SP:
   --WL01 S
   IF OBJECT_ID('tempdb..#TMP_WaveOrders') IS NOT NULL
      DROP TABLE #TMP_WaveOrders

   IF CURSOR_STATUS('LOCAL', 'CUR_BillToKey') IN (0 , 1)
   BEGIN
      CLOSE CUR_BillToKey
      DEALLOCATE CUR_BillToKey   
   END
   
   IF CURSOR_STATUS('LOCAL', 'CUR_CODELKUP_QUERY') IN (0 , 1)
   BEGIN
      CLOSE CUR_CODELKUP_QUERY
      DEALLOCATE CUR_CODELKUP_QUERY   
   END

   IF CURSOR_STATUS('GLOBAL', 'CUR_TRANSMITLOG_REC') IN (0 , 1)
   BEGIN
      CLOSE CUR_TRANSMITLOG_REC
      DEALLOCATE CUR_TRANSMITLOG_REC   
   END
   
   IF CURSOR_STATUS('GLOBAL', 'CUR_ORDERKEY') IN (0 , 1)
   BEGIN
      CLOSE CUR_ORDERKEY
      DEALLOCATE CUR_ORDERKEY   
   END
   --WL01 E

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