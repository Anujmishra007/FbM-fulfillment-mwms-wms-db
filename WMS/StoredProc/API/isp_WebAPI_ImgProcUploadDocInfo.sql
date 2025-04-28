SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: isp_WebAPI_ImgProcUploadDocInfo                     */
/* Creation Date: 02-Jul-2021                                           */
/* Copyright: IDS                                                       */
/* Written by: GuanHaoChan                                              */
/*                                                                      */
/* Purpose: ImageProcessor OR PhotoRepo Insert/Update DocInfo.          */
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
/* Called By: ImageProcessor OR PhotoRepo - isp_Generic_WebAPI_Request  */
/*                                                                      */
/* PVCS Version: -                                                      */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Purposes														*/
/* 2021-Jul-02 GHChan   Initial                                         */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_WebAPI_ImgProcUploadDocInfo]
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
            @c_StorerKey NVARCHAR(15),
            @c_SKU NVARCHAR(20),
            @c_DESCR NVARCHAR(60),
            @c_PONumber NVARCHAR(18),
            @c_ContainerNumber NVARCHAR(30),
            @c_OrderNumber NVARCHAR(10),
            @c_CustomerName NVARCHAR(45),
            @c_Brand NVARCHAR(10),
            @c_SKUType NVARCHAR(10),
            @c_Lottable NVARCHAR(20),
            @c_DefectCode NVARCHAR(50),
            @c_DefectQty NVARCHAR(10),
            @c_TransferKey NVARCHAR(50),
            @c_UploadDate NVARCHAR(50),
            @c_Remarks NVARCHAR(2000),
            @b_ViewAction BIT,
            @c_ImgName NVARCHAR(100),
            @n_ActionFlag INT,
            @n_RecordID INT,
            @c_TableName NVARCHAR(20),
            @c_Key1 NVARCHAR(20),
            @c_Key2 NVARCHAR(20),
            @c_Key3 NVARCHAR(20),
            @n_LineSeq INT,
            @c_Data NVARCHAR(2000),
            @c_ListImageName NVARCHAR(2000);

    DECLARE @tempJson TABLE
    (
        --RowRef            INT IDENTITY(1,1) NOT NULL
        ContainerNumber NVARCHAR(30) NULL,
        DefectCode NVARCHAR(50) NULL,
        DefectQty NVARCHAR(10) NULL,
        Remarks NVARCHAR(2000) NULL,
        ImageName NVARCHAR(100) NULL
    );

    --DECLARE @tempImageJson TABLE
    --(
    --    ImgName NVARCHAR(2000) NULL
    --);

    SET @n_Continue = 1;
    SET @n_StartCnt = @@TRANCOUNT;
    SET @b_Success = 1;
    SET @n_ErrNo = 0;
    SET @c_ErrMsg = '';
    SET @c_ResponseString = '';
    SET @c_XMLRequestString = N'';

    SET @c_SearchType = N'';
    SET @c_StorerKey = N'';
    SET @c_SKU = N'';
    SET @c_DESCR = N'';
    SET @c_PONumber = N'';
    SET @c_ContainerNumber = N'';
    SET @c_OrderNumber = N'';
    SET @c_CustomerName = N'';
    SET @c_Brand = N'';
    SET @c_SKUType = N'';
    SET @c_Lottable = N'';
    SET @c_DefectCode = N'';
    SET @c_DefectQty = N'';
    SET @c_TransferKey = N'';
    SET @c_UploadDate = N'';
    SET @c_Remarks = N'';
    SET @b_ViewAction = 1;
    SET @c_ImgName = N'';

    SET @n_ActionFlag = 0; -- 1 == INSERT ; 2 == UPDATE

    SET @n_RecordID = 0;
    SET @c_TableName = N'IMGMGR_PHOTOREPO';
    SET @c_Key1 = N'';
    SET @c_Key2 = N'';
    SET @c_Key3 = N'';
    SET @n_LineSeq = 0;
    SET @c_Data = N'';
    SET @c_ListImageName = N'';

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
    IF @n_Continue = 1
    BEGIN
        EXEC sp_xml_preparedocument @n_doc OUTPUT, @x_xml;

        --Read data from XML
        SELECT @c_SearchType = ISNULL(RTRIM(SearchType), ''),
               @c_StorerKey = ISNULL(RTRIM(StorerKey), ''),
               @c_SKU = ISNULL(RTRIM(SKU), ''),
               @c_DESCR = ISNULL(RTRIM([DESCR]), ''),
               @c_PONumber = ISNULL(RTRIM(POKey), ''),
               @c_ContainerNumber = ISNULL(RTRIM(ContainerNumber), ''),
               @c_OrderNumber = ISNULL(RTRIM(OrderKey), ''),
               @c_CustomerName = ISNULL(RTRIM(CustomerName), ''),
               @c_Brand = ISNULL(RTRIM(Brand), ''),
               @c_SKUType = ISNULL(RTRIM(SKUType), ''),
               @c_Lottable = ISNULL(RTRIM(Lottable), ''),
               @c_DefectCode = ISNULL(RTRIM(DefectCode), ''),
               @c_DefectQty = ISNULL(RTRIM(DefectQty), ''),
               @c_TransferKey = ISNULL(RTRIM(TransferKey), ''),
               @c_UploadDate = ISNULL(RTRIM(UploadDate), ''),
               @c_Remarks = ISNULL(RTRIM(Remarks), ''),
               @b_ViewAction = ViewAction,
               @c_ImgName = ISNULL(RTRIM(ImgName), '')
        FROM
            OPENXML(@n_doc, 'Request/Data', 1)
            WITH
            (
                SearchType NVARCHAR(50) 'SearchType',
                StorerKey NVARCHAR(15) 'StorerKey',
                SKU NVARCHAR(20) 'SKU',
                [DESCR] NVARCHAR(60) 'Description',
                POKey NVARCHAR(18) 'POKey',
                ContainerNumber NVARCHAR(30) 'ContainerNumber',
                OrderKey NVARCHAR(10) 'OrderKey',
                CustomerName NVARCHAR(45) 'CustomerName',
                Brand NVARCHAR(10) 'Brand',
                SKUType NVARCHAR(10) 'SKUType',
                Lottable NVARCHAR(20) 'Lottable',
                DefectCode NVARCHAR(50) 'DefectCode',
                DefectQty NVARCHAR(10) 'DefectQty',
                TransferKey NVARCHAR(50) 'TransferKey',
                UploadDate NVARCHAR(50) 'UploadDate',
                Remarks NVARCHAR(2000) 'Remarks',
                ViewAction BIT 'ViewAction',
                ImgName NVARCHAR(100) 'ImgName'
            );

        EXEC sp_xml_removedocument @n_doc;

        IF @c_SearchType NOT IN ( 'SKU', 'INBOUND', 'OUTBOUND', 'INBOUND_DAMAGE', 'DAMAGE_BY_WAREHOUSE', 'RETURN',
                                  'COPACK(KITTING)'
                                )
        BEGIN
            SET @n_Continue = 3;
            SET @n_ErrNo = 97002;
            SET @c_ErrMsg = 'Invalid SearchType[' + @c_SearchType + ']..';
            GOTO QUIT;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.STORER WITH (NOLOCK)
            WHERE StorerKey = @c_StorerKey
        )
        BEGIN
            SET @n_Continue = 3;
            SET @n_ErrNo = 97003;
            SET @c_ErrMsg = 'Invalid StorerKey[' + @c_StorerKey + ']';
            GOTO QUIT;
        END;
        --IF @c_SearchType = 'SKU'
        --BEGIN
        --    IF @c_SKU = ''
        --       AND @c_SKUType = ''
        --       AND @c_Brand = ''
        --    BEGIN
        --        SET @n_Continue = 3;
        --        SET @n_ErrNo = 97004;
        --        SET @c_ErrMsg = 'SKU, SKUType and Brand cannot be blank.';
        --        GOTO QUIT;
        --    END;

        --    SELECT @n_RecordID = RecordID,
        --           @c_TableName = TableName,
        --           @c_Key1 = Key1,
        --           @c_Key2 = Key2,
        --           @c_Key3 = Key3,
        --           @n_LineSeq = LineSeq,
        --           @c_Data = ISNULL(RTRIM([Data]), '')
        --    FROM dbo.DocInfo WITH (NOLOCK)
        --    WHERE StorerKey = @c_StorerKey
        --          AND Key1 = @c_SKU
        --          AND Key2 = @c_SKUType
        --          AND Key3 = @c_Brand;

        --    IF @n_RecordID != 0
        --    BEGIN
        --        IF @c_Data != @c_Remarks
        --        BEGIN
        --            SET @c_Data = @c_Remarks;
        --            SET @n_ActionFlag = 2;
        --        END;
        --        ELSE
        --            GOTO QUIT;
        --    END;
        --    ELSE
        --    BEGIN
        --        SET @c_Key1 = @c_SKU;
        --        SET @c_Key2 = @c_SKUType;
        --        SET @c_Key3 = @c_Brand;
        --        SET @c_Data = @c_Remarks;
        --        SET @n_ActionFlag = 1;
        --    END;
        --END;
        --ELSE IF @c_SearchType = 'INBOUND'
        --        OR @c_SearchType = 'RETURN'
        --        OR @c_SearchType = 'INBOUND_DAMAGE'
        --BEGIN
        --    IF @c_PONumber = ''
        --       AND @c_ContainerNumber = ''
        --    BEGIN
        --        SET @n_Continue = 3;
        --        SET @n_ErrNo = 97005;
        --        SET @c_ErrMsg = 'PONumber and ContainerNumber cannot be blank.';
        --        GOTO QUIT;
        --    END;

        --    IF @c_PONumber <> ''
        --       AND @c_ContainerNumber <> ''
        --       AND @c_SKU <> ''
        --       AND @c_Lottable <> ''
        --    BEGIN

        --        --INSERT INTO @tempImageJson
        --        --(
        --        --    ImgName
        --        --)
        --        --VALUES
        --        --(@c_ImgName);
        --        --SET @c_ListImageName =
        --        --(
        --        --    SELECT * FROM @tempImageJson FOR JSON PATH
        --        --);

        --        SELECT @n_RecordID = RecordID,
        --               @c_TableName = TableName,
        --               @c_Key1 = Key1,
        --               @c_Key2 = Key2,
        --               @c_Key3 = Key3,
        --               @n_LineSeq = LineSeq,
        --               @c_Data = ISNULL(RTRIM([Data]), '')
        --        FROM dbo.DocInfo WITH (NOLOCK)
        --        WHERE StorerKey = @c_StorerKey
        --              AND Key1 = @c_PONumber
        --              AND Key2 = @c_SKU
        --              AND Key3 = @c_Lottable;

        --        --IF @n_RecordID != 0
        --        --BEGIN
        --        --    SET @n_ActionFlag = 2;
        --        --    IF @c_Data <> ''
        --        --       AND ISJSON(@c_Data) > 0
        --        --    BEGIN

        --        --        INSERT INTO @tempJson
        --        --        (
        --        --            ContainerNumber,
        --        --            DefectCode,
        --        --            DefectQty,
        --        --            Remarks,
        --        --            ImageName
        --        --        )
        --        --        SELECT ContainerNumber,
        --        --               DefectCode,
        --        --               DefectQty,
        --        --               Remarks,
        --        --               [Value] AS ImageName
        --        --        FROM
        --        --            OPENJSON(@c_Data)
        --        --            WITH
        --        --            (
        --        --                ContainerNumber NVARCHAR(30) '$.ContainerNumber',
        --        --                DefectCode NVARCHAR(50) '$.DefectCode',
        --        --                DefectQty NVARCHAR(10) '$.DefectQty',
        --        --                Remarks NVARCHAR(2000) '$.Remarks',
        --        --                ListImageName NVARCHAR(MAX) '$.ListImageName' AS JSON
        --        --            ) AS Main
        --        --            CROSS APPLY OPENJSON(Main.ListImageName);
        --        --        IF EXISTS
        --        --        (
        --        --            SELECT 1
        --        --            FROM @tempJson
        --        --            WHERE ContainerNumber = @c_ContainerNumber
        --        --                  AND DefectCode = @c_DefectCode
        --        --        )
        --        --        BEGIN
        --        --            IF @c_ImgName <> ''
        --        --            BEGIN
        --        --                INSERT @tempJson
        --        --                (
        --        --                    ContainerNumber,
        --        --                    DefectCode,
        --        --                    DefectQty,
        --        --                    Remarks,
        --        --                    ImageName
        --        --                )
        --        --                VALUES
        --        --                (@c_ContainerNumber, @c_DefectCode, @c_DefectQty, @c_Remarks, @c_ImgName);
        --        --            END;
        --        --            UPDATE @tempJson
        --        --            SET DefectQty = @c_DefectQty,
        --        --                Remarks = @c_Remarks
        --        --            WHERE ContainerNumber = @c_ContainerNumber
        --        --                  AND DefectCode = @c_DefectCode;
        --        --        END;
        --        --        ELSE
        --        --        BEGIN
        --        --            INSERT INTO @tempJson
        --        --            (
        --        --                ContainerNumber,
        --        --                DefectCode,
        --        --                DefectQty,
        --        --                Remarks,
        --        --                ImageName
        --        --            )
        --        --            VALUES
        --        --            (@c_ContainerNumber, @c_DefectCode, @c_DefectQty, @c_Remarks, @c_ImgName);
        --        --        END;
        --        --    END;
        --        --    ELSE IF @c_Data <> ''
        --        --            AND ISJSON(@c_Data) <= 0
        --        --    BEGIN
        --        --        SET @n_Continue = 3;
        --        --        SET @n_ErrNo = 97007;
        --        --        SET @c_ErrMsg
        --        --            = 'Unable to perform insert or update. Unable to extract the data from "DATA" column. ';
        --        --        GOTO QUIT;
        --        --    END;
        --        --    ELSE
        --        --    BEGIN
        --        --        INSERT INTO @tempJson
        --        --        (
        --        --            ContainerNumber,
        --        --            DefectCode,
        --        --            DefectQty,
        --        --            Remarks,
        --        --            ImageName
        --        --        )
        --        --        VALUES
        --        --        (@c_ContainerNumber, @c_DefectCode, @c_DefectQty, @c_Remarks, @c_ImgName);
        --        --    END;
        --        --END;
        --        --ELSE
        --        --BEGIN
        --        --    SET @c_Key1 = @c_PONumber;
        --        --    SET @c_Key2 = @c_SKU;
        --        --    SET @c_Key3 = @c_Lottable;
        --        --    --SET @c_Data = @c_Remarks

        --        --    INSERT INTO @tempJson
        --        --    (
        --        --        ContainerNumber,
        --        --        DefectCode,
        --        --        DefectQty,
        --        --        Remarks,
        --        --        ImageName
        --        --    )
        --        --    VALUES
        --        --    (@c_ContainerNumber, @c_DefectCode, @c_DefectQty, @c_Remarks, @c_ImgName);

        --        --    SET @n_ActionFlag = 1;
        --        --END;

        --        --SET @c_Data =
        --        --(
        --        --    SELECT ContainerNumber,
        --        --           DefectCode,
        --        --           DefectQty,
        --        --           Remarks,
        --        --           JSON_QUERY('[' + STUFF(
        --        --                            (
        --        --                                SELECT ',' + '"' + ImageName + '"'
        --        --                                FROM @tempJson t1
        --        --                                WHERE t1.ContainerNumber = t2.ContainerNumber
        --        --                                      AND t1.DefectCode = t2.DefectCode
        --        --                                FOR XML PATH('')
        --        --                            ),
        --        --                            1,
        --        --                            1,
        --        --                            ''
        --        --                                 ) + ']'
        --        --                     ) AS [ListImageName]
        --        --    FROM @tempJson t2
        --        --    GROUP BY ContainerNumber,
        --        --             DefectCode,
        --        --             DefectQty,
        --        --             Remarks
        --        --    FOR JSON PATH
        --        --);
        --    END;
        --    ELSE IF @c_PONumber <> ''
        --            AND @c_ContainerNumber <> ''
        --    BEGIN
        --        SELECT @n_RecordID = RecordID,
        --               @c_TableName = TableName,
        --               @c_Key1 = Key1,
        --               @c_Key2 = Key2,
        --               @c_Key3 = Key3,
        --               @n_LineSeq = LineSeq,
        --               @c_Data = ISNULL(RTRIM([Data]), '')
        --        FROM dbo.DocInfo WITH (NOLOCK)
        --        WHERE StorerKey = @c_StorerKey
        --              AND Key1 = @c_PONumber
        --              AND Key2 = @c_ContainerNumber;

        --        --IF @n_RecordID != 0
        --        --BEGIN
        --        --    SET @n_ActionFlag = 2;
        --        --    IF @c_Data <> ''
        --        --       AND ISJSON(@c_Data) > 0
        --        --    BEGIN

        --        --        INSERT INTO @tempJson
        --        --        (
        --        --            Remarks,
        --        --            ImageName
        --        --        )
        --        --        SELECT Remarks,
        --        --               [Value] AS ImageName
        --        --        FROM
        --        --            OPENJSON(@c_Data)
        --        --            WITH
        --        --            (
        --        --                Remarks NVARCHAR(2000) '$.Remarks',
        --        --                ListImageName NVARCHAR(MAX) '$.ListImageName' AS JSON
        --        --            ) AS Main
        --        --            CROSS APPLY OPENJSON(Main.ListImageName);

        --        --        IF @c_ImgName <> ''
        --        --        BEGIN
        --        --            INSERT @tempJson
        --        --            (
        --        --                Remarks,
        --        --                ImageName
        --        --            )
        --        --            VALUES
        --        --            (@c_Remarks, @c_ImgName);
        --        --        END;

        --        --        UPDATE @tempJson
        --        --        SET Remarks = @c_Remarks;
        --        --    END;
        --        --    ELSE IF @c_Data <> ''
        --        --            AND ISJSON(@c_Data) <= 0
        --        --    BEGIN
        --        --        SET @n_Continue = 3;
        --        --        SET @n_ErrNo = 97007;
        --        --        SET @c_ErrMsg
        --        --            = 'Unable to perform insert or update. Unable to extract the data from "DATA" column. ';
        --        --        GOTO QUIT;
        --        --    END;
        --        --    ELSE
        --        --    BEGIN
        --        --        INSERT INTO @tempJson
        --        --        (
        --        --            Remarks,
        --        --            ImageName
        --        --        )
        --        --        VALUES
        --        --        (@c_Remarks, @c_ImgName);
        --        --    END;
        --        --END;
        --        --ELSE
        --        --BEGIN
        --        --    SET @c_Key1 = @c_PONumber;
        --        --    SET @c_Key2 = @c_ContainerNumber;
        --        --    SET @c_Data = @c_Remarks;

        --        --     INSERT INTO @tempJson
        --        --    (
        --        --        Remarks,
        --        --        ImageName
        --        --    )
        --        --    VALUES
        --        --    ( @c_Remarks, @c_ImgName);

        --        --    SET @n_ActionFlag = 1;
        --        --END;

        --        --SET @c_Data =
        --        --(
        --        --    SELECT Remarks,
        --        --           JSON_QUERY('['
        --        --                      + STUFF(
        --        --                        (
        --        --                            SELECT ',' + '"' + ImageName + '"' FROM @tempJson FOR XML PATH('')
        --        --                        ),
        --        --                        1,
        --        --                        1,
        --        --                        ''
        --        --                             ) + ']'
        --        --                     ) AS [ListImageName]
        --        --    FROM @tempJson
        --        --    GROUP BY Remarks
        --        --    FOR JSON PATH
        --        --);

        --    END;
        --END;
        --ELSE IF @c_SearchType = 'OUTBOUND'
        --BEGIN
        --    IF @c_OrderNumber = ''
        --       AND @c_ContainerNumber = ''
        --    BEGIN
        --        SET @n_Continue = 3;
        --        SET @n_ErrNo = 97008;
        --        SET @c_ErrMsg = 'OrderNumber and ContainerNumber cannot be blank.';
        --        GOTO QUIT;
        --    END;

        --    SELECT @n_RecordID = RecordID,
        --           @c_TableName = TableName,
        --           @c_Key1 = Key1,
        --           @c_Key2 = Key2,
        --           @c_Key3 = Key3,
        --           @n_LineSeq = LineSeq,
        --           @c_Data = ISNULL(RTRIM([Data]), '')
        --    FROM dbo.DocInfo WITH (NOLOCK)
        --    WHERE StorerKey = @c_StorerKey
        --          AND Key1 = @c_OrderNumber
        --          AND Key2 = @c_ContainerNumber;

        --    IF @n_RecordID != 0
        --    BEGIN
        --        IF @c_Data != @c_Remarks
        --        BEGIN
        --            SET @c_Data = @c_Remarks;
        --            SET @n_ActionFlag = 2;
        --        END;
        --        ELSE
        --            GOTO QUIT;
        --    END;
        --    ELSE
        --    BEGIN
        --        SET @c_Key1 = @c_OrderNumber;
        --        SET @c_Key2 = @c_ContainerNumber;
        --        SET @c_Data = @c_Remarks;
        --        SET @n_ActionFlag = 1;
        --    END;
        --END;
        --ELSE IF @c_SearchType = 'DAMAGE_BY_WAREHOUSE'
        --BEGIN
        --    IF @c_TransferKey = ''
        --       AND @c_UploadDate = ''
        --    BEGIN
        --        SET @n_Continue = 3;
        --        SET @n_ErrNo = 97009;
        --        SET @c_ErrMsg = 'TransferKey and UploadDate cannot be blank.';
        --        GOTO QUIT;
        --    END;

        --    SELECT @n_RecordID = RecordID,
        --           @c_TableName = TableName,
        --           @c_Key1 = Key1,
        --           @c_Key2 = Key2,
        --           @c_Key3 = Key3,
        --           @n_LineSeq = LineSeq,
        --           @c_Data = ISNULL(RTRIM([Data]), '')
        --    FROM dbo.DocInfo WITH (NOLOCK)
        --    WHERE StorerKey = @c_StorerKey
        --          AND Key1 = @c_TransferKey
        --          AND Key2 = @c_UploadDate;

        --    IF @n_RecordID != 0
        --    BEGIN
        --        IF @c_Data != @c_Remarks
        --        BEGIN
        --            SET @c_Data = @c_Remarks;
        --            SET @n_ActionFlag = 2;
        --        END;
        --        ELSE
        --            GOTO QUIT;
        --    END;
        --    ELSE
        --    BEGIN
        --        SET @c_Key1 = @c_TransferKey;
        --        SET @c_Key2 = @c_UploadDate;
        --        SET @c_Data = @c_Remarks;
        --        SET @n_ActionFlag = 1;
        --    END;
        --END;
        --ELSE IF @c_SearchType = 'COPACK(KITTING)'
        --BEGIN
        --    IF @c_OrderNumber = ''
        --       AND @c_UploadDate = ''
        --    BEGIN
        --        SET @n_Continue = 3;
        --        SET @n_ErrNo = 97010;
        --        SET @c_ErrMsg = 'OrderNumber and UploadDate cannot be blank.';
        --        GOTO QUIT;
        --    END;

        --    SELECT @n_RecordID = RecordID,
        --           @c_TableName = TableName,
        --           @c_Key1 = Key1,
        --           @c_Key2 = Key2,
        --           @c_Key3 = Key3,
        --           @n_LineSeq = LineSeq,
        --           @c_Data = ISNULL(RTRIM([Data]), '')
        --    FROM dbo.DocInfo WITH (NOLOCK)
        --    WHERE StorerKey = @c_StorerKey
        --          AND Key1 = @c_OrderNumber
        --          AND Key2 = @c_UploadDate;

        --    IF @n_RecordID != 0
        --    BEGIN
        --        IF @c_Data != @c_Remarks
        --        BEGIN
        --            SET @c_Data = @c_Remarks;
        --            SET @n_ActionFlag = 2;
        --        END;
        --        ELSE
        --            GOTO QUIT;
        --    END;
        --    ELSE
        --    BEGIN
        --        SET @c_Key1 = @c_OrderNumber;
        --        SET @c_Key2 = @c_UploadDate;
        --        SET @c_Data = @c_Remarks;
        --        SET @n_ActionFlag = 1;
        --    END;
        --END;

        --IF @b_ViewAction != 1
        --BEGIN
        --    IF @n_ActionFlag = 1
        --    BEGIN
        --        INSERT INTO dbo.DocInfo
        --        (
        --            TableName,
        --            Key1,
        --            Key2,
        --            Key3,
        --            StorerKey,
        --            LineSeq,
        --            [Data],
        --            DataType
        --        )
        --        VALUES
        --        (@c_TableName, @c_Key1, @c_Key2, @c_Key3, @c_StorerKey, @n_LineSeq, @c_Data, 'STRING');

        --        SELECT @n_RecordID = SCOPE_IDENTITY();
        --    END;
        --    ELSE IF @n_ActionFlag = 2
        --    BEGIN
        --        UPDATE dbo.DocInfo WITH (ROWLOCK)
        --        SET TableName = @c_TableName,
        --            Key1 = @c_Key1,
        --            Key2 = @c_Key2,
        --            Key3 = @c_Key3,
        --            StorerKey = @c_StorerKey,
        --            LineSeq = @n_LineSeq,
        --            [Data] = @c_Data
        --        WHERE RecordID = @n_RecordID;
        --    END;
        --    ELSE
        --    BEGIN
        --        SET @n_Continue = 3;
        --        SET @n_ErrNo = 97011;
        --        SET @c_ErrMsg = 'Invalid Action Flag! Unable to perform insert or update..';
        --        GOTO QUIT;
        --    END;
        --END;
    END;

    --IF @n_RecordID = 0
    --BEGIN
    --    --SET @n_Continue = 3
    --    SET @n_ErrNo = 97012;
    --    SET @c_ErrMsg = 'No records found!';
    --    GOTO QUIT;
    --END;

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
        SELECT @b_Success = 1;
        WHILE @@TRANCOUNT > @n_StartCnt
        BEGIN
            COMMIT TRAN;
        END;

        --IF @n_RecordID <> 0
        --BEGIN
        --    SET @c_ResponseString =
        --    (
        --        SELECT RecordID,
        --          [Data] AS Remarks
        --        FROM dbo.DocInfo WITH (NOLOCK)
        --        WHERE RecordID = @n_RecordID
        --        FOR XML PATH('')
        --    );
        --END;

        RETURN;
    END;
END; -- Procedure
GO
