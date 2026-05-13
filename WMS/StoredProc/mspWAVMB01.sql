SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Store Procedure: mspWAVMB01                                           */
/* Creation Date: 11-May-2026                                            */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-12847 Mattel Chile WaveGenMBOL_SP                        */
/*                                                                       */
/* Input Parameters: Wavekey                                             */
/*                                                                       */
/* Called By:  Generate Ship Ref Unit                                    */
/*                                                                       */
/* Version: 1.0                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 11-May-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/  

CREATE OR ALTER PROC [dbo].[mspWAVMB01]
   @c_WaveKey NVARCHAR(10),
   @b_Success INT          OUTPUT,
   @n_err     INT          OUTPUT,
   @c_errmsg  NVARCHAR(250) OUTPUT
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_OrderKey        NVARCHAR(10)
         , @c_Loadkey         NVARCHAR(10)
         , @c_Facility        NVARCHAR(5)
         , @c_ExternOrderKey  NVARCHAR(50)
         , @c_StorerKey       NVARCHAR(15)
         , @c_Route           NVARCHAR(10)
         , @c_MBOLKey         NVARCHAR(10)
         , @n_Continue        INT
         , @n_StartTranCnt    INT
         , @d_OrderDate       DATETIME
         , @d_Delivery_Date   DATETIME
         , @n_mbolcount       INT
         , @n_TotWeight       FLOAT = 0.00
         , @n_TotCube         FLOAT = 0.00

   DECLARE @c_ListName                 NVARCHAR(10)
         , @c_Code                     NVARCHAR(30) -- e.g. ORDERS01
         , @c_Description              NVARCHAR(250)
         , @c_TableColumnName          NVARCHAR(250)  -- e.g. ORDERS.Orderkey
         , @c_TableName                NVARCHAR(30)
         , @c_ColumnName               NVARCHAR(30)
         , @c_ColumnType               NVARCHAR(10)
         , @c_SQLField                 NVARCHAR(2000)
         , @c_SQLWhere                 NVARCHAR(2000)
         , @c_SQLGroup                 NVARCHAR(2000)
         , @c_SQLDYN01                 NVARCHAR(2000)
         , @c_SQLDYN02                 NVARCHAR(2000)
         , @c_SQLDYN03                 NVARCHAR(2000)
         , @c_Field01                  NVARCHAR(60)
         , @c_Field02                  NVARCHAR(60)
         , @c_Field03                  NVARCHAR(60)
         , @c_Field04                  NVARCHAR(60)
         , @c_Field05                  NVARCHAR(60)
         , @c_Field06                  NVARCHAR(60)
         , @c_Field07                  NVARCHAR(60)
         , @c_Field08                  NVARCHAR(60)
         , @c_Field09                  NVARCHAR(60)
         , @c_Field10                  NVARCHAR(60)
         , @n_cnt                      INT
         , @c_FoundMBOLKey             NVARCHAR(10)
         , @c_Configkey                NVARCHAR(30) = 'WAVEGENMBOL_SP'
         , @c_Authority                NVARCHAR(30)
         , @c_Userdefine01             NVARCHAR(20) = ''
         , @c_Userdefine02             NVARCHAR(20) = ''
         , @c_Userdefine03             NVARCHAR(20) = ''
         , @c_Userdefine04             NVARCHAR(20) = ''
         , @c_Userdefine09             NVARCHAR(10) = ''
         , @c_Option5                  NVARCHAR(4000)
         , @c_SkipUpdateMBOLUserdefine NVARCHAR(10) = 'N'
         , @c_Condition                NVARCHAR(MAX) = ''

   CREATE TABLE #TMP_MBOL ( MbolKey    NVARCHAR(10)
                          , Orderkey   NVARCHAR(10)
                          , OrderCube  FLOAT )
   CREATE NONCLUSTERED INDEX IDX_TMP_ORDER ON #TMP_MBOL (MbolKey, Orderkey)

   SELECT @n_StartTranCnt = @@TRANCOUNT, @n_Continue = 1, @n_mbolcount = 0

   -------------------------- Wave Validation ------------------------------
   IF NOT EXISTS ( SELECT 1 
                   FROM WaveDetail WITH (NOLOCK)
                   WHERE WaveKey = @c_WaveKey )
   BEGIN
      SELECT @n_Continue = 3
      SELECT @n_err = 63501
      SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': No Orders being populated INTO WaveDetail. (mspWAVMB01)'
      GOTO RETURN_SP
   END

   SET @c_Userdefine02 = 'Y'
   SET @c_Userdefine04 = 'Y'
   SET @c_Userdefine09 = @c_WaveKey

   SELECT @c_StorerKey = MIN(OH.Storerkey)
        , @c_Facility  = MIN(OH.Facility)
   FROM WAVEDETAIL WD (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = WD.OrderKey
   WHERE WD.WaveKey = @c_WaveKey

   EXECUTE nspGetRight                                
      @c_Facility  = @c_Facility,                     
      @c_StorerKey = @c_StorerKey,                    
      @c_sku       = '',
      @c_ConfigKey = @c_Configkey,
      @b_Success   = @b_Success   OUTPUT,             
      @c_authority = @c_Authority OUTPUT,             
      @n_err       = @n_err       OUTPUT,             
      @c_errmsg    = @c_errmsg    OUTPUT,                           
      @c_Option5   = @c_Option5   OUTPUT
     
   IF ISNULL(@c_authority,'') = 'mspWAVMB01'
   BEGIN
      SELECT @c_SkipUpdateMBOLUserdefine = dbo.fnc_GetParamValueFromString('@c_SkipUpdateMBOLUserdefine', @c_Option5, 'N')  

      IF @c_SkipUpdateMBOLUserdefine = 'Y'
      BEGIN
         SET @c_Userdefine02 = ''
         SET @c_Userdefine04 = ''
         SET @c_Userdefine09 = ''
      END
   END

   -------------------------- Construct Wave Dynamic Grouping ------------------------------
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      SELECT @c_listname = CODELIST.Listname
      FROM WAVE WITH (NOLOCK)
      JOIN CODELIST WITH (NOLOCK) ON WAVE.MBOLGroupMethod = CODELIST.Listname AND CODELIST.ListGroup = 'WAVEMBOLGROUP'
      WHERE WAVE.Wavekey = @c_Wavekey

      IF ISNULL(@c_ListName,'') = ''
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_err = 63503
         SELECT @c_errmsg='NSQL'+CONVERT(Char(5),@n_err)+': Empty/Invalid MBOL Group Is Not Allowed. (LIST GROUP: WAVEMBOLGROUP) (mspWAVMB01)'
         GOTO RETURN_SP
      END

      SELECT TOP 1 @c_Condition = CL.UDF05
      FROM CODELKUP CL (NOLOCK)
      WHERE CL.Listname = @c_ListName
      AND CL.Code = 'CONDITION'        
      
      IF ISNULL(@c_Condition,'') <> '' AND LEFT(LTRIM(@c_Condition), 4) <> 'AND '
         SET @c_Condition = 'AND ' + @c_Condition

      DECLARE CUR_CODELKUP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT TOP 10 Code, Description, Long
         FROM   CODELKUP WITH (NOLOCK)
         WHERE  ListName = @c_ListName
         AND Code NOT IN('CONDITION')      
         ORDER BY Code

      OPEN CUR_CODELKUP
      FETCH NEXT FROM CUR_CODELKUP INTO @c_Code, @c_Description, @c_TableColumnName

      SELECT @c_SQLField = '', @c_SQLWhere = '', @c_SQLGroup = '', @n_cnt = 0

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @n_cnt = @n_cnt + 1
         SET @c_TableName = LEFT(@c_TableColumnName, CHARINDEX('.', @c_TableColumnName) - 1)
         SET @c_ColumnName = SUBSTRING(@c_TableColumnName,
               CHARINDEX('.', @c_TableColumnName) + 1, LEN(@c_TableColumnName) - CHARINDEX('.', @c_TableColumnName))

         IF ISNULL(TRIM(@c_TableName), '') <> 'ORDERS'
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_err = 63504
            SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Grouping Only Allow Refer To Orders Table''s Fields. Invalid Table: '+TRIM(@c_TableColumnName)+' (mspWAVMB01)'
            GOTO RETURN_SP
         END

         SET @c_ColumnType = ''

         SELECT @c_ColumnType = DATA_TYPE
         FROM   INFORMATION_SCHEMA.COLUMNS
         WHERE  TABLE_NAME = @c_TableName
         AND    COLUMN_NAME = @c_ColumnName

         IF ISNULL(TRIM(@c_ColumnType), '') = ''
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_err = 63505
            SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Invalid Column Name: ' + TRIM(@c_TableColumnName)+ '. (mspWAVMB01)'
            GOTO RETURN_SP
         END

         IF @c_ColumnType IN ('FLOAT', 'money', 'INT', 'decimal', 'numeric', 'tinyInt', 'real', 'bigInt','text')
         BEGIN
            SELECT @n_Continue = 3
            SELECT @n_err = 63506
            SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Numeric/Text Column Type Is Not Allowed For MBOL Grouping: ' + TRIM(@c_TableColumnName)+ '. (mspWAVMB01)'
            GOTO RETURN_SP
         END

         IF @c_ColumnType IN ('CHAR', 'NVARCHAR', 'VARCHAR','NCHAR') 
         BEGIN
            SELECT @c_SQLField = @c_SQLField + ',' + TRIM(@c_TableColumnName)
            SELECT @c_SQLWhere = @c_SQLWhere + ' AND ' + TRIM(@c_TableColumnName) + '=' +
                                 CASE WHEN @n_cnt = 1 THEN '@c_Field01'
                                 WHEN @n_cnt = 2 THEN '@c_Field02'
                                 WHEN @n_cnt = 3 THEN '@c_Field03'
                                 WHEN @n_cnt = 4 THEN '@c_Field04'
                                 WHEN @n_cnt = 5 THEN '@c_Field05'
                                 WHEN @n_cnt = 6 THEN '@c_Field06'
                                 WHEN @n_cnt = 7 THEN '@c_Field07'
                                 WHEN @n_cnt = 8 THEN '@c_Field08'
                                 WHEN @n_cnt = 9 THEN '@c_Field09'
                                 WHEN @n_cnt = 10 THEN '@c_Field10' END
         END

         IF @c_ColumnType IN ('DATETIME')
         BEGIN
            SELECT @c_SQLField = @c_SQLField + ', CONVERT(VarChar(10),' + TRIM(@c_TableColumnName) + ',112)'
            SELECT @c_SQLWhere = @c_SQLWhere + ' AND CONVERT(VarChar(10),' + TRIM(@c_TableColumnName) + ',112)=' +
                                 CASE WHEN @n_cnt = 1 THEN '@c_Field01'
                                 WHEN @n_cnt = 2 THEN '@c_Field02'
                                 WHEN @n_cnt = 3 THEN '@c_Field03'
                                 WHEN @n_cnt = 4 THEN '@c_Field04'
                                 WHEN @n_cnt = 5 THEN '@c_Field05'
                                 WHEN @n_cnt = 6 THEN '@c_Field06'
                                 WHEN @n_cnt = 7 THEN '@c_Field07'
                                 WHEN @n_cnt = 8 THEN '@c_Field08'
                                 WHEN @n_cnt = 9 THEN '@c_Field09'
                                 WHEN @n_cnt = 10 THEN '@c_Field10' END
         END

         FETCH NEXT FROM CUR_CODELKUP INTO @c_Code, @c_Description, @c_TableColumnName
      END
      CLOSE CUR_CODELKUP
      DEALLOCATE CUR_CODELKUP

      SELECT @c_SQLGroup = @c_SQLField
      WHILE @n_cnt < 10
      BEGIN
         SET @n_cnt = @n_cnt + 1
         SELECT @c_SQLField = @c_SQLField + ','''''

         SELECT @c_SQLWhere = @c_SQLWhere + ' AND ''''=' +
                              CASE WHEN @n_cnt = 1 THEN 'ISNULL(@c_Field01,'''')'
                              WHEN @n_cnt = 2 THEN 'ISNULL(@c_Field02,'''')'
                              WHEN @n_cnt = 3 THEN 'ISNULL(@c_Field03,'''')'
                              WHEN @n_cnt = 4 THEN 'ISNULL(@c_Field04,'''')'
                              WHEN @n_cnt = 5 THEN 'ISNULL(@c_Field05,'''')'
                              WHEN @n_cnt = 6 THEN 'ISNULL(@c_Field06,'''')'
                              WHEN @n_cnt = 7 THEN 'ISNULL(@c_Field07,'''')'
                              WHEN @n_cnt = 8 THEN 'ISNULL(@c_Field08,'''')'
                              WHEN @n_cnt = 9 THEN 'ISNULL(@c_Field09,'''')'
                              WHEN @n_cnt = 10 THEN 'ISNULL(@c_Field10,'''')' END
      END
   END

   BEGIN TRAN
   -------------------------- CREATE MBOL ------------------------------
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      SELECT @c_SQLDYN01 = 'DECLARE cur_MBGroup CURSOR FAST_FORWARD READ_ONLY FOR '
                         + ' SELECT ORDERS.Storerkey ' + @c_SQLField
                         + ' FROM ORDERS WITH (NOLOCK) '
                         + ' JOIN WAVEDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = WAVEDETAIL.OrderKey) '
                         +'  WHERE WAVEDETAIL.WaveKey = ''' +  TRIM(@c_WaveKey) +''''
                         + ' AND (ORDERS.MBOLKey IS NULL OR ORDERS.MBOLKey = '''') '
                         + ' AND ORDERS.Status NOT IN (''9'',''CANC'') '
                         + TRIM(ISNULL(@c_Condition,''))                      
                         + ' GROUP BY ORDERS.Storerkey ' + @c_SQLGroup
                         + ' ORDER BY ORDERS.Storerkey ' + @c_SQLGroup

      EXEC (@c_SQLDYN01)

      OPEN cur_MBGroup
      FETCH NEXT FROM cur_MBGroup INTO @c_Storerkey, @c_Field01, @c_Field02, @c_Field03, @c_Field04, @c_Field05,
                                       @c_Field06, @c_Field07, @c_Field08, @c_Field09, @c_Field10
      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1, 2)
      BEGIN
         SELECT @c_SQLDYN02 = ' SELECT @c_FoundMBOLKey = MAX(ORDERS.MBOLKey) '
                            + ' FROM ORDERS WITH (NOLOCK) '
                            + ' JOIN WAVEDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = WAVEDETAIL.OrderKey) '
                            + ' WHERE  ORDERS.StorerKey = @c_StorerKey '
                            + ' AND WAVEDETAIL.WaveKey = @c_WaveKey '
                            + ' AND ORDERS.Status NOT IN (''9'',''CANC'') '
                            + ' AND (ORDERS.MBOLKey IS NOT NULL AND ORDERS.MBOLKey <> '''') '
                            + TRIM(ISNULL(@c_Condition,'')) + ' '                      
                            + @c_SQLWhere

         EXEC sp_executesql @c_SQLDYN02,
                           N'@c_Storerkey NVARCHAR(15), @c_Wavekey NVARCHAR(10), @c_Field01 NVARCHAR(60), @c_Field02 NVARCHAR(60),@c_Field03 NVARCHAR(60),@c_Field04 NVARCHAR(60),
                           @c_Field05 NVARCHAR(60), @c_Field06 NVARCHAR(60), @c_Field07 NVARCHAR(60), @c_Field08 NVARCHAR(60), @c_Field09 NVARCHAR(60), @c_Field10 NVARCHAR(60), @c_FoundMBOLKey NVARCHAR(10) OUTPUT',
                           @c_Storerkey,
                           @c_Wavekey,
                           @c_Field01,
                           @c_Field02,
                           @c_Field03,
                           @c_Field04,
                           @c_Field05,
                           @c_Field06,
                           @c_Field07,
                           @c_Field08,
                           @c_Field09,
                           @c_Field10,
                           @c_FoundMBOLKey OUTPUT

         IF ISNULL(@c_FoundMBOLKey,'') <> ''
         BEGIN
            SET @c_MBOLKey = @c_FoundMBOLKey
         END
         ELSE
         BEGIN
            SELECT @b_success = 0
            EXECUTE nspg_GetKey
                   'MBOL',
                   10,
                   @c_MBOLKey OUTPUT,
                   @b_success OUTPUT,
                   @n_err     OUTPUT,
                   @c_errmsg  OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               GOTO RETURN_SP
            END

            SELECT TOP 1 @c_Facility = Orders.Facility
                       , @c_Userdefine01 = LEFT(ISNULL(TRIM(Orders.C_Address4), ''), 20)
                       , @c_Userdefine03 = LEFT(ISNULL(TRIM(Orders.OrderGroup), ''), 20)
            FROM Orders WITH (NOLOCK)
            JOIN WAVEDETAIL WITH (NOLOCK) ON Orders.OrderKey = WAVEDETAIL.Orderkey
            WHERE WAVEDETAIL.Wavekey = @c_WaveKey
            AND Orders.Storerkey = @c_StorerKey
            AND Orders.[Status] NOT IN ('9','CANC')
            AND (Orders.MBOLKey IS NULL OR Orders.MBOLKey = '')

            IF @c_SkipUpdateMBOLUserdefine = 'Y'
            BEGIN
               SET @c_Userdefine01 = ''
               SET @c_Userdefine03 = ''
            END

            -- Create MBOL
            INSERT INTO MBOL ( MBOLKey, Facility, PlaceOfdeliveryQualifier, TransMethod, Userdefine09, UserDefine01, Userdefine02
                             , UserDefine03, Userdefine04) 
            VALUES ( @c_MBOLKey, @c_Facility, 'D','O', @c_Userdefine09, @c_Userdefine01, @c_Userdefine02
                   , @c_Userdefine03, @c_Userdefine04)

            SELECT @n_err = @@ERROR
            IF @n_err <> 0
            BEGIN
               SELECT @n_Continue = 3
               SELECT @n_err = 63507
               SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Insert INTO MBOL Failed. (mspWAVMB01)'
               GOTO RETURN_SP
            END
         END

         SELECT @n_mbolcount = @n_mbolcount + 1

         -- Create mbol detail
         SELECT @c_SQLDYN03 = 'DECLARE cur_mboldet CURSOR FAST_FORWARD READ_ONLY FOR '
                            + ' SELECT ORDERS.OrderKey '
                            + ' FROM ORDERS WITH (NOLOCK) '
                            + ' JOIN WAVEDETAIL WITH (NOLOCK) ON (ORDERS.OrderKey = WAVEDETAIL.OrderKey) '
                            + ' WHERE ORDERS.StorerKey = @c_StorerKey ' +
                            + ' AND WAVEDETAIL.WaveKey = @c_WaveKey '
                            + ' AND ORDERS.Status NOT IN (''9'',''CANC'') '
                            + ' AND (ORDERS.MBOLKey IS NULL OR ORDERS.MBOLKey = '''') '
                            + TRIM(ISNULL(@c_Condition,'')) + ' '                                                 
                            + @c_SQLWhere
                            + ' ORDER BY ORDERS.OrderKey '

         EXEC sp_executesql @c_SQLDYN03,
                           N'@c_Storerkey NVARCHAR(15), @c_Wavekey NVARCHAR(10), @c_Field01 NVARCHAR(60), @c_Field02 NVARCHAR(60),@c_Field03 NVARCHAR(60),@c_Field04 NVARCHAR(60),
                           @c_Field05 NVARCHAR(60), @c_Field06 NVARCHAR(60), @c_Field07 NVARCHAR(60), @c_Field08 NVARCHAR(60), @c_Field09 NVARCHAR(60), @c_Field10 NVARCHAR(60)',
                           @c_Storerkey,
                           @c_Wavekey,
                           @c_Field01,
                           @c_Field02,
                           @c_Field03,
                           @c_Field04,
                           @c_Field05,
                           @c_Field06,
                           @c_Field07,
                           @c_Field08,
                           @c_Field09,
                           @c_Field10

         OPEN cur_mboldet
         FETCH NEXT FROM cur_mboldet INTO @c_OrderKey
         WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1, 2)
         BEGIN
            IF (SELECT COUNT(1) FROM MbolDetail WITH (NOLOCK) WHERE OrderKey = @c_OrderKey) = 0
            BEGIN
               SELECT @d_OrderDate = O.OrderDate,
                      @d_Delivery_Date = O.DeliveryDate,
                      @c_Route = O.[Route],
                      @n_totweight = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdGrossWgt),
                      @n_totcube = SUM((OD.Qtyallocated + OD.QtyPicked + OD.ShippedQty) * SKU.StdCube),
                      @c_ExternOrderkey = O.ExternOrderkey,
                      @c_Loadkey = ISNULL(O.Loadkey,'')
               FROM Orders O WITH (NOLOCK)
               JOIN Orderdetail OD WITH (NOLOCK) ON (O.Orderkey = OD.Orderkey)
               JOIN SKU WITH (NOLOCK) ON (OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku)
               WHERE O.OrderKey = @c_OrderKey
               GROUP BY O.OrderDate,
                        O.DeliveryDate,
                        O.Route,
                        O.ExternOrderkey,
                        ISNULL(O.Loadkey,'')

               EXEC isp_InsertMBOLDetail
                     @cMBOLKey        = @c_MBOLKey,
                     @cFacility       = @c_Facility,
                     @cOrderKey       = @c_OrderKey,
                     @cLoadKey        = @c_Loadkey,
                     @nStdGrossWgt    = @n_totweight,
                     @nStdCube        = @n_totcube,
                     @cExternOrderKey = @c_ExternOrderkey,
                     @dOrderDate      = @d_OrderDate,
                     @dDelivery_Date  = @d_Delivery_Date,
                     @cRoute          = @c_Route,
                     @b_Success       = @b_Success OUTPUT,
                     @n_err           = @n_err     OUTPUT,
                     @c_errmsg        = @c_errmsg  OUTPUT

               SELECT @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_err = 63508
                  SELECT @c_errmsg='NSQL'+CONVERT(Char(5),@n_err)+': Insert INTO MBOLDETAIL Failed. (mspWAVMB01)'
                  GOTO RETURN_SP
               END

               MERGE INTO #TMP_MBOL AS TGT
               USING ( SELECT @c_MBOLKey, @c_OrderKey, @n_totcube 
               ) AS SRC (MbolKey, Orderkey, OrderCube) ON TGT.MbolKey = SRC.MbolKey 
                                                      AND TGT.Orderkey = SRC.Orderkey
               WHEN MATCHED 
               THEN 
                  UPDATE SET TGT.OrderCube = TGT.OrderCube + SRC.OrderCube
               WHEN NOT MATCHED BY TARGET 
               THEN 
                  INSERT (MbolKey, Orderkey, OrderCube)
                  VALUES (SRC.MbolKey, SRC.Orderkey, SRC.OrderCube);
            END

            FETCH NEXT FROM cur_mboldet INTO @c_OrderKey
         END
         CLOSE cur_mboldet
         DEALLOCATE cur_mboldet

         FETCH NEXT FROM cur_MBGroup INTO @c_Storerkey, @c_Field01, @c_Field02, @c_Field03, @c_Field04, @c_Field05,
                                          @c_Field06, @c_Field07, @c_Field08, @c_Field09, @c_Field10
      END
      CLOSE cur_MBGroup
      DEALLOCATE cur_MBGroup
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      BEGIN TRY
         ;WITH UPD_MBOL AS ( SELECT MbolKey
                                  , OrderCube = SUM(OrderCube)
                             FROM #TMP_MBOL
                             GROUP BY MbolKey )
         UPDATE MB
         SET MB.[Cube] = UPD_MBOL.OrderCube
           , MB.TrafficCop = NULL
           , MB.EditDate = GETDATE()
           , MB.EditWho = SUSER_SNAME()
         FROM dbo.MBOL MB
         JOIN UPD_MBOL ON UPD_MBOL.MbolKey = MB.MbolKey
      END TRY
      BEGIN CATCH
         SET @n_Continue = 3
         SET @c_errmsg = ERROR_MESSAGE()
         SET @n_err = ERROR_NUMBER()
      END CATCH
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF @n_mbolcount > 0
         SELECT @c_errmsg = TRIM(CAST(@n_mbolcount AS NVARCHAR)) + ' MBOL Generated. Refer to MBOL Userdefine09 for Wave#'
      ELSE
         SELECT @c_errmsg = 'No MBOL Generated'
   END

   RETURN_SP:
   IF CURSOR_STATUS('GLOBAL','cur_MBGroup') IN (0,1) 
   BEGIN
      CLOSE cur_MBGroup
      DEALLOCATE cur_MBGroup
   END

   IF CURSOR_STATUS('GLOBAL','cur_mboldet') IN (0,1) 
   BEGIN
      CLOSE cur_mboldet
      DEALLOCATE cur_mboldet
   END

   IF CURSOR_STATUS('LOCAL','CUR_CODELKUP') IN (0,1) 
   BEGIN
      CLOSE CUR_CODELKUP
      DEALLOCATE CUR_CODELKUP
   END

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTranCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspWAVMB01'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[mspWAVMB01] TO [NSQL]
GO