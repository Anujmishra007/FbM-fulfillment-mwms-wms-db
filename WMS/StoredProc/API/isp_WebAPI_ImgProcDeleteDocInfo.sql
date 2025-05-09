SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: isp_WebAPI_ImgProcDeleteDocInfo                     */
/* Creation Date: 22-Jul-2021                                           */
/* Copyright: IDS                                                       */
/* Written by: GuanHaoChan                                              */
/*                                                                      */
/* Purpose: PhotoRepo Delete DocInfo records.                           */
/*                                                                      */
/* Input Parameters:  @b_Debug            - 0                           */
/*                    @c_Format           - 'XML/JSON'                  */
/*                    @c_UserID           - 'UserName'                  */
/*                    @c_OperationType    - 'Operation'                 */
/*                    @c_RequestString    - ''                          */
/*                    @b_Debug            - 0                           */
/*                                                                      */
/* Output Parameters: @b_Success          - Success Flag    = 0         */
/*                    @c_ErrNo            - Error No        = 0         */
/*                    @c_ErrMsg           - Error Message   = ''        */
/*                    @c_ResponseString   - ResponseString  = ''        */
/*                                                                      */
/* Called By: PhotoRepo - isp_Generic_WebAPI_Request                    */
/*                                                                      */
/* PVCS Version: -                                                      */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Purposes						    		            	*/
/* 2021-Jul-22 GHChan   Initial                                         */
/* 2024-Aug-23 GCH002   Added new Type VAS & VAP                        */
/* 2024-Nov-25 GCH003   Enhance for delete multi line for same records  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_WebAPI_ImgProcDeleteDocInfo]
   (
   @b_Debug INT = 0,
   @c_Format VARCHAR(10) = '',
   @c_UserID NVARCHAR(256) = '',
   @c_OperationType NVARCHAR(60) = '',
   @c_RequestString NVARCHAR(MAX) = '',
   @b_Success INT = 0 OUTPUT,
   @n_ErrNo INT = 0 OUTPUT,
   @c_ErrMsg NVARCHAR(250) = '' OUTPUT,
   @c_ResponseString NVARCHAR(MAX) = '' OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON;
   SET ANSI_DEFAULTS OFF;
   SET QUOTED_IDENTIFIER OFF;
   SET CONCAT_NULL_YIELDS_NULL OFF;

   DECLARE @n_Continue INT,
            @n_StartCnt INT,
            @c_ExecStatements NVARCHAR(MAX),
            @c_ExecArguments NVARCHAR(2000),
            @x_xml XML,
            @n_doc INT,
            @c_XMLRequestString NVARCHAR(MAX),
            @c_SearchType NVARCHAR(50),
            @c_RecordID NVARCHAR(10),
            @c_ImgName NVARCHAR(100),
            @n_RecordID INT,
            @c_TableName NVARCHAR(20),
            @c_Data NVARCHAR(MAX),
            @c_col3 NVARCHAR(100),
            @c_col4 NVARCHAR(100),
            @c_col5 NVARCHAR(100),
            @c_col6 NVARCHAR(100),
            @c_col7 NVARCHAR(100),
            -- @nTotal_StorerKey INT,
            @c_StorerKey NVARCHAR(15),
            @ChunkSize INT, -- Max chunk siz,
            @Start INT,
            @DataLength INT,
            @n_LineSeq INT;

   --DECLARE @tempJson TABLE
   --(
   --    --RowRef            INT IDENTITY(1,1) NOT NULL
   --    ContainerNumber NVARCHAR(30) NULL,
   --    DefectCode NVARCHAR(50) NULL,
   --    DefectQty NVARCHAR(10) NULL,
   --    Remarks NVARCHAR(2000) NULL,
   --    ImageName NVARCHAR(100) NULL
   --);

   DECLARE @tempJson TABLE
    (
      --RowRef            INT IDENTITY(1,1) NOT NULL
      col1 NVARCHAR(100) NULL,
      col2 NVARCHAR(100) NULL,
      col3 NVARCHAR(100) NULL,
      col4 NVARCHAR(100) NULL,
      col5 NVARCHAR(100) NULL,
      col6 NVARCHAR(100) NULL,
      col7 NVARCHAR(100) NULL,
      col8 NVARCHAR(100) NULL,
      col9 NVARCHAR(100) NULL,
      col10 NVARCHAR(100) NULL,
      col11 NVARCHAR(100) NULL,
      col12 NVARCHAR(100) NULL,
      col13 NVARCHAR(100) NULL,
      col14 NVARCHAR(100) NULL,
      col15 NVARCHAR(2000) NULL,
      ImageName NVARCHAR(100) NULL
    );

   SET @n_Continue = 1;
   SET @n_StartCnt = @@TRANCOUNT;
   SET @b_Success = 1;
   SET @n_ErrNo = 0;
   SET @c_ErrMsg = '';
   SET @c_ResponseString = '';
   SET @c_XMLRequestString = N'';

   SET @c_RecordID = N'0';
   SET @c_ImgName = N'';

   SET @c_SearchType = N'';
   SET @c_TableName = N'IMPR_';

   SET @c_col3 = N'';
   SET @c_col4 = N'';
   SET @c_col5 = N'';
   SET @c_col6 = N'';
   SET @c_col7 = N'';

   -- SET @nTotal_StorerKey = 0;
   SET @c_StorerKey = '';
   SET @n_LineSeq = 0;
   SET @c_Data = N'';
   SET @ChunkSize = 2000;

   IF ISNULL(RTRIM(@c_RequestString), '') = ''
    BEGIN
      SET @n_Continue = 3;
      SET @n_ErrNo = 97001;
      SET @c_ErrMsg = 'Content Body cannot be blank.';
      GOTO QUIT;
   END;

   SET @x_xml = CONVERT(XML, @c_RequestString);

   BEGIN TRAN;

   STEP_1:
   IF @n_Continue <> 1
   BEGIN
      GOTO QUIT;
   END;

   EXEC sp_xml_preparedocument @n_doc OUTPUT, @x_xml;

   --Read data from XML
   SELECT
      @c_StorerKey = ISNULL(RTRIM(StorerKey),''),
      @c_SearchType = ISNULL(RTRIM(SearchType), ''),
      @c_col3 = ISNULL(RTRIM(col3), ''),
      @c_col4 = ISNULL(RTRIM(col4), ''),
      @c_col5 = ISNULL(RTRIM(col5), ''),
      @c_col6 = ISNULL(RTRIM(col6), ''),
      @c_col7 = ISNULL(RTRIM(col7), ''),
      @c_RecordID = ISNULL(RTRIM(RecordID), ''),
      @c_ImgName = ISNULL(RTRIM(ImgName), '')
   FROM
      OPENXML(@n_doc, 'Request/Data', 1)
            WITH
            (
                StorerKey NVARCHAR(15) 'StorerKey',
                SearchType NVARCHAR(50) 'SearchType',
                col3 NVARCHAR(100) 'col3',
                col4 NVARCHAR(100) 'col4',
                col5 NVARCHAR(100) 'col5',
                col6 NVARCHAR(100) 'col6',
                col7 NVARCHAR(100) 'col7',
                RecordID NVARCHAR(10) 'RecordID',
                ImgName NVARCHAR(100) 'ImgName'
            );
   EXEC sp_xml_removedocument @n_doc;

   IF @c_SearchType NOT IN ( 'SKU', 'INBOUND', 'OUTBOUND', 'INBOUND_DAMAGE', 'DAMAGE_BY_WAREHOUSE', 'RETURN',  
                            'COPACK(KITTING)', 'KIT_DAMAGE' , 'VAS',  'VAP'  --GCH002
                          )
   BEGIN
      SET @n_Continue = 3;
      SET @n_ErrNo = 97002;
      SET @c_ErrMsg = 'Invalid SearchType[' + @c_SearchType + ']..';
      GOTO QUIT;
   END;

   IF @c_SearchType = 'SKU'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'SKU');
   END;
   ELSE IF @c_SearchType = 'INBOUND'
      OR @c_SearchType = 'RETURN'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'CONT_PO');
   END;
   ELSE IF @c_SearchType = 'INBOUND_DAMAGE'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'CONT_PO_SKU');
   END;
   ELSE IF @c_SearchType = 'OUTBOUND'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'CONT_ORD');
   END;
   ELSE IF @c_SearchType = 'DAMAGE_BY_WAREHOUSE'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'TSFRKey');
   END;
   ELSE IF @c_SearchType = 'COPACK(KITTING)'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'ORDKey');
   END;
   ELSE IF @c_SearchType = 'KIT_DAMAGE'
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'KIT_SKU_LOT');
   END;
   --GCH002 Begin
   ELSE IF @c_SearchType = 'VAS'  
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'VAS_ORD_SKU');
   END;
   ELSE IF @c_SearchType = 'VAP'  
   BEGIN
      SET @c_TableName = CONCAT(@c_TableName, 'VAP_ORD_SKU');
   END;
   ELSE
   BEGIN
      --SET @n_Continue = 3
      SET @n_ErrNo = 97003;
      SET @c_ErrMsg = 'Invalid Search Type Found.';
      GOTO QUIT;
   END
   --GCH002 End

   --SELECT
   --   @nTotal_StorerKey = COUNT(DISTINCT StorerKey)
   --FROM
   --   dbo.DocInfo (NOLOCK)
   --WHERE TableName = @c_TableName
   --   AND Key1 = @c_col3
   --   AND Key2 = @c_col4
   --   AND Key3 = @c_col5

   --IF @nTotal_StorerKey > 1
   --BEGIN
   --   --SET @n_Continue = 3
   --   SET @n_ErrNo = 97004;
   --   SET @c_ErrMsg = 'Multiple StorerKey Found. Unable to delete the record.';
   --   GOTO QUIT;
   --END
   --ELSE IF @nTotal_StorerKey = 0
   --BEGIN
   --   --SET @n_Continue = 3
   --   SET @n_ErrNo = 97005;
   --   SET @c_ErrMsg = 'No records found! Unable to delete the record.';
   --   GOTO QUIT;
   --END
   --ELSE
   --BEGIN
   --   SELECT
   --      @c_StorerKey = StorerKey
   --   FROM
   --      dbo.DocInfo (NOLOCK)
   --   WHERE TableName = @c_TableName
   --      AND Key1 = @c_col3
   --      AND Key2 = @c_col4
   --      AND Key3 = @c_col5
   --END

   
   IF @c_RecordID <> '0' 
   BEGIN
      SELECT
         @c_Data = ISNULL(RTRIM([Data]), '')
      FROM
         dbo.DocInfo WITH (NOLOCK)
      WHERE RecordID = @c_RecordID
      
      IF ISJSON(@c_Data) <> 1
      BEGIN
         GOTO GETVALIDJSON
      END
   END
   ELSE
   BEGIN
      GETVALIDJSON:
      SET @c_RecordID = '0'
      SELECT
         @c_Data = STRING_AGG(ISNULL(RTRIM([Data]), ''), '') WITHIN GROUP (ORDER BY LineSeq ASC)
      FROM
         dbo.DocInfo WITH (NOLOCK)
      WHERE StorerKey = @c_StorerKey
         AND TableName = @c_TableName
         AND Key1 = @c_col3
         AND Key2 = @c_col4
         AND Key3 = @c_col5
   END

   BEGIN TRAN;

   IF @c_Data = ''
   BEGIN
      GOTO DELETE_RECORD
   END;

   IF @c_ImgName <> ''
   BEGIN
      INSERT INTO @tempJson
         (
         col1,
         col2,
         col3,
         col4,
         col5,
         col6,
         col7,
         col8,
         col9,
         col10,
         col11,
         col12,
         col13,
         col14,
         col15,
         ImageName
         )
      SELECT
         ISNULL(RTRIM(Main.col1), ''),
         ISNULL(RTRIM(Main.col2), ''),
         ISNULL(RTRIM(Main.col3), ''),
         ISNULL(RTRIM(Main.col4), ''),
         ISNULL(RTRIM(Main.col5), ''),
         ISNULL(RTRIM(Main.col6), ''),
         ISNULL(RTRIM(Main.col7), ''),
         ISNULL(RTRIM(Main.col8), ''),
         ISNULL(RTRIM(Main.col9), ''),
         ISNULL(RTRIM(Main.col10), ''),
         ISNULL(RTRIM(Main.col11), ''),
         ISNULL(RTRIM(Main.col12), ''),
         ISNULL(RTRIM(Main.col13), ''),
         ISNULL(RTRIM(Main.col14), ''),
         ISNULL(RTRIM(Main.col15), ''),
         [Value] AS ImageName
      FROM
         OPENJSON(@c_Data)
            WITH
            (
               col1 NVARCHAR(100) '$.col1',
               col2 NVARCHAR(100) '$.col2',
               col3 NVARCHAR(100) '$.col3',
               col4 NVARCHAR(100) '$.col4',
               col5 NVARCHAR(100) '$.col5',
               col6 NVARCHAR(100) '$.col6',
               col7 NVARCHAR(100) '$.col7',
               col8 NVARCHAR(100) '$.col8',
               col9 NVARCHAR(100) '$.col9',
               col10 NVARCHAR(100) '$.col10',
               col11 NVARCHAR(100) '$.col11',
               col12 NVARCHAR(100) '$.col12',
               col13 NVARCHAR(100) '$.col13',
               col14 NVARCHAR(100) '$.col14',
               col15 NVARCHAR(2000) '$.col15',
               ListImageName NVARCHAR(MAX) '$.ListImageName' AS JSON
            ) AS Main
            CROSS APPLY OPENJSON(Main.ListImageName);

      IF (SELECT COUNT(1) FROM @tempJson) = 1
      BEGIN
         GOTO DELETE_RECORD;
      END;

      DELETE FROM @tempJson
         WHERE ISNULL(RTRIM(col2), '') = ISNULL(RTRIM(@c_SearchType), '')
         AND ISNULL(RTRIM(col3), '') = ISNULL(RTRIM(@c_col3), '')
         AND ISNULL(RTRIM(col4), '') = ISNULL(RTRIM(@c_col4), '')
         AND ISNULL(RTRIM(col5), '') = ISNULL(RTRIM(@c_col5), '')
         AND ISNULL(RTRIM(col6), '') = ISNULL(RTRIM(@c_col6), '')
         AND ISNULL(RTRIM(col7), '') = ISNULL(RTRIM(@c_col7), '')
         AND ImageName = @c_ImgName;

      SET @c_Data =
         (
            SELECT
         t2.col1,
         t2.col2,
         CASE WHEN t2.col3 = '' THEN NULL
               ELSE t2.col3
               END AS col3,
         CASE WHEN t2.col4 = '' THEN NULL
               ELSE t2.col4
               END AS col4,
         CASE WHEN t2.col5 = '' THEN NULL
               ELSE t2.col5
               END AS col5,
         CASE WHEN t2.col6 = '' THEN NULL
               ELSE t2.col6
               END AS col6,
         CASE WHEN t2.col7 = '' THEN NULL
               ELSE t2.col7
               END AS col7,
         CASE WHEN t2.col8 = '' THEN NULL
               ELSE t2.col8
               END AS col8,
         CASE WHEN t2.col9 = '' THEN NULL
               ELSE t2.col9
               END AS col9,
         CASE WHEN t2.col10 = '' THEN NULL
               ELSE t2.col10
               END AS col10,
         CASE WHEN t2.col11 = '' THEN NULL
               ELSE t2.col11
               END AS col11,
         CASE WHEN t2.col12 = '' THEN NULL
               ELSE t2.col12
               END AS col12,
         CASE WHEN t2.col13 = '' THEN NULL
               ELSE t2.col13
               END AS col13,
         CASE WHEN t2.col14 = '' THEN NULL
               ELSE t2.col14
               END AS col14,
         CASE WHEN t2.col15 = '' THEN NULL
               ELSE t2.col15
               END AS col15,
         JSON_QUERY('[' + STUFF((SELECT
            ',' + '"' + ImageName + '"'
         FROM
            @tempJson t1
         WHERE ISNULL(RTRIM(t1.col1), '') = ISNULL(RTRIM(t2.col1), '')
            AND ISNULL(RTRIM(t1.col2), '') = ISNULL(RTRIM(t2.col2), '')
            AND ISNULL(RTRIM(t1.col3), '') = ISNULL(RTRIM(t2.col3), '')
            AND ISNULL(RTRIM(t1.col4), '') = ISNULL(RTRIM(t2.col4), '')
            AND ISNULL(RTRIM(t1.col5), '') = ISNULL(RTRIM(t2.col5), '')
            AND ISNULL(RTRIM(t1.col6), '') = ISNULL(RTRIM(t2.col6), '')
            AND ISNULL(RTRIM(t1.col7), '') = ISNULL(RTRIM(t2.col7), '')
            AND ISNULL(RTRIM(t1.col8), '') = ISNULL(RTRIM(t2.col8), '')
            AND ISNULL(RTRIM(t1.col9), '') = ISNULL(RTRIM(t2.col9), '')
            AND ISNULL(RTRIM(t1.col10), '') = ISNULL(RTRIM(t2.col10), '')
            AND ISNULL(RTRIM(t1.col11), '') = ISNULL(RTRIM(t2.col11), '')
            AND ISNULL(RTRIM(t1.col12), '') = ISNULL(RTRIM(t2.col12), '')
            AND ISNULL(RTRIM(t1.col13), '') = ISNULL(RTRIM(t2.col13), '')
            AND ISNULL(RTRIM(t1.col14), '') = ISNULL(RTRIM(t2.col14), '')
            AND ISNULL(RTRIM(t1.col15), '') = ISNULL(RTRIM(t2.col15), '')
         FOR XML PATH('')
                                    ),
                                    1,
                                    1,
                                    ''
                                          ) + ']'
                              ) AS [ListImageName]
      FROM
         @tempJson t2
      GROUP BY t2.col1,
                     t2.col2,
                     t2.col3,
                     t2.col4,
                     t2.col5,
                     t2.col6,
                     t2.col7,
                     t2.col8,
                     t2.col9,
                     t2.col10,
                     t2.col11,
                     t2.col12,
                     t2.col13,
                     t2.col14,
                     t2.col15
      FOR JSON AUTO
         );

      SET @DataLength = LEN(@c_Data);

      IF @DataLength > 2000
      BEGIN
         SET @Start = 1
         SET @n_LineSeq = 0

         DELETE FROM dbo.DocInfo
         WHERE StorerKey = CASE WHEN ISNULL(@c_StorerKey,'') = '' THEN StorerKey ELSE @c_StorerKey END
            AND TableName = @c_TableName
            AND Key1 = @c_col3
            AND Key2 = @c_col4
            AND Key3 = @c_col5


         WHILE @Start <= @DataLength
         BEGIN
            -- Extract a chunk of 2000 characters
            INSERT INTO dbo.DocInfo
               (
               TableName,
               Key1,
               Key2,
               Key3,
               StorerKey,
               LineSeq,
               [Data],
               DataType
               )
            VALUES
               (@c_TableName, @c_col3, @c_col4, @c_col5, @c_StorerKey, @n_LineSeq, SUBSTRING(@c_Data, @Start, @ChunkSize), 'STRING');

            SET @n_LineSeq = @n_LineSeq + 1
            SET @Start = @Start + @ChunkSize;
         -- Move to the next chunk
         END;
      END
      ELSE
      BEGIN
         IF @c_RecordID <> '0'
         BEGIN
            UPDATE dbo.DocInfo WITH (ROWLOCK)  
            SET [Data] = @c_Data  
            WHERE RecordID = @c_RecordID;
         END
         ELSE
         BEGIN
            SET @n_ErrNo = 97006;
            SET @c_ErrMsg = 'Unable to update the record. Kindly check with administrator.';
            GOTO QUIT;
         END
      END
   END;
   ELSE
   BEGIN
      DELETE_RECORD:
      IF @c_RecordID <> '0'
      BEGIN
         DELETE FROM dbo.DocInfo
         WHERE RecordID = @c_RecordID
            AND TableName = @c_TableName
            AND StorerKey = CASE WHEN ISNULL(@c_StorerKey,'') = '' THEN StorerKey ELSE @c_StorerKey END;
      END
      ELSE
      BEGIN
         DELETE FROM dbo.DocInfo
         WHERE StorerKey = CASE WHEN ISNULL(@c_StorerKey,'') = '' THEN StorerKey ELSE @c_StorerKey END
            AND TableName = @c_TableName
            AND Key1 = @c_col3
            AND Key2 = @c_col4
            AND Key3 = @c_col5
      END
   END;

   QUIT:
   IF @n_Continue = 3 -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0;
      IF @@TRANCOUNT > @n_StartCnt
         AND @@TRANCOUNT = 1
      BEGIN
         ROLLBACK TRAN;
      END;
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartCnt
         BEGIN
            COMMIT TRAN;
         END;
      END;
      RETURN;
   END;
   ELSE
   BEGIN
      SELECT
         @b_Success = 1;
      WHILE @@TRANCOUNT > @n_StartCnt
      BEGIN
         COMMIT TRAN;
      END;
      RETURN;
   END;
END; -- Procedure
GO
