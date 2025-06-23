/************************************************************************/
/* Store procedure: [isp_UK_HUSQ_BQ_AsnVal]                             */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: update the ASN value for B&Q SO                             */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2024-09-04 1.0  AGA399       HUSQ custom ASN value for B&Q SO        */
/* 2024-09-20 1.1  WSE016       Correcting of ASN_ID generation         */
/* 2024-12-10 1.1  AGA399       Correcting of new date value            */
/************************************************************************/
CREATE OR ALTER       PROC [dbo].[isp_UK_HUSQ_BQ_AsnVal]  (
            @cMBOLKey              NVARCHAR(10),
            @cStorerKey            NVARCHAR(15),
            @nSuccess              int = 1 OUTPUT,    -- @nSuccess = 0 (Fail), @nSuccess = 1 (Success), @nSuccess = 2 (Warning)
            @nErrNo                int  OUTPUT,
            @cErrMsg               NVARCHAR(1024) OUTPUT
) AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
DECLARE @tempCounter        int = 0,
        @myCont1            int = 1,
        @myCont2            int = 1,
        @myCont3            int = 1,
        @nrepeat            int = 1,
        @code_date          Date,
        @myUserDdefine05    NVARCHAR(9),
        @stringDate         NVARCHAR(10),
        @newCountVal        NVARCHAR(2),
        @codeValue          NVARCHAR(16),
        @shortCodeVal       NVARCHAR(14)
        --@cStorerKey         NVARCHAR(15) = 'HUSQ'
--SET @cMBOLKey = '0000004355' --TESTING IF THE ISSUE IS DUE TO THE PARAMETERS RECEIVED
--Create temp table for store all orderKey with the same MBOL value
 IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
   DROP TABLE #temp
CREATE TABLE #temp
(
  [ID] [int] IDENTITY(1,1) NOT NULL,
  [OrderKey] NVARCHAR(10),
  [SUB0RDU05] NVARCHAR(9),--Customer PO
  [NSUB0RDU05] INT,--Number of times same Customer PO is repeated in the same wave
  [ASNPO] NVARCHAR(20), --ASN PO ID, this value is stored also in ORDERS.BUYERPO
  [MBOL] NVARCHAR(20) --ASN PO ID, this value is stored also in ORDERS.BUYERPO
)
INSERT INTO #temp (OrderKey, MBOL)
  --select OrderKey FROM dbo.MBOLDETAIL WITH(NOLOCK) WHERE MbolKey = @cMBOLKey
  --change to just fill #temp table with only the BQ SO with the same MBOL
  SELECT MBO.OrderKey, MBO.MbolKey
        FROM dbo.MBOLDETAIL AS MBO WITH(NOLOCK)
        INNER JOIN ORDERS AS ORD ON MBO.OrderKey = ORD.OrderKey
        WHERE MBO.MbolKey = @cMBOLKey
        AND ORD.ConsigneeKey = 'H604'
        ORDER BY ORD.OrderKey
--check 1 WS.
--SELECT * FROM #temp
---Get number of rows in #temp table
SET @tempCounter = (SELECT COUNT(ID) FROM #temp WITH (NOLOCK))
---Get value of the date store in BQAsn codelukp
SET @code_date = (SELECT CAST((SELECT UDF01 FROM dbo.CODELKUP WITH(NOLOCK) WHERE listname = 'BQAsn' AND storerkey = @cStorerKey) AS DATE))
-- check 2 WS:
--SELECT  @tempCounter
-- check 3 WS:
--SELECT  @code_date
-- Update table #temp with the substring of ORD.UserDefine05 (customer PO) in column SUB0RDU05
WHILE @myCont1 <= @tempCounter
   BEGIN
      UPDATE #temp WITH(ROWLOCK)
      SET SUB0RDU05 = (SELECT SUBSTRING((SELECT ORD.UserDefine05
                                                      FROM dbo.ORDERS ORD WITH(NOLOCK)
                                                      WHERE  ORD.OrderKey = (SELECT OrderKey FROM #temp WITH (NOLOCK) WHERE ID = @myCont1)
                                                      AND ORD.StorerKey = 'HUSQ'),1,9))
      WHERE ID = @myCont1
      SET @myCont1 = @myCont1 + 1
   END
--check 4 WS.
--select * FROM #temp
-- Update table #temp with the number of repeated UserDefine05 (customer PO) in column NSUB0RDU05
WHILE @myCont2 <= @tempCounter
   BEGIN
      SET @nrepeat = 0
      --Get customer PO value for the current SO
      SET @myUserDdefine05 = (SELECT SUBSTRING((SELECT UserDefine05 FROM dbo.ORDERS WITH (NOLOCK) WHERE OrderKey = (SELECT ORDERKEY  FROM #temp WITH (NOLOCK) WHERE ID = @myCont2 )),1,9))
       --check 5 WS.
       SELECT @myUserDdefine05
        IF (SELECT LEN (@myUserDdefine05)) = 9
          BEGIN
            --Get value nrepeat with the number of SO in the system with the same customer PO (UserDefine05)
            SET @nrepeat = (SELECT COUNT(*) FROM dbo.ORDERS WITH (NOLOCK) WHERE UserDefine05 LIKE '%'+@myUserDdefine05+'%' AND sTORERKEY = 'HUSQ'
                -- WS Start 17092924
                AND MBOLKey = @cMBOLKey
                -- WS End 17092924
                )
          END
      ELSE
          BEGIN
            SET @nrepeat = 1
          END
    --check 6 WS.
--SELECT * FROM #temp
      --Update value nrepeat with the number of SO in the system with the same customer PO
      UPDATE #temp WITH(ROWLOCK)
      SET NSUB0RDU05 = @nrepeat
      WHERE id = @myCont2
    --check 7 WS.
--SELECT * FROM #temp
-- WS 19/09/2024 START ->  removed to pervent checks for exisiting ASNID linked to Customer PO
      --If the current SO  has same customer PO as other SO, update the value of #temp ASNPO with the same value as BUYERPO for the other SO with the same customer PO (UserDefine05)
      -- IF @nrepeat > 1
      -- 	BEGIN
      -- --Update the value of ASNPO in #temp
      -- UPDATE #temp WITH(ROWLOCK)SET ASNPO = (SELECT TOP 1 BUYERPO FROM dbo.ORDERS WITH (NOLOCK) WHERE UserDefine05 LIKE '%'+@myUserDdefine05+'%' AND STORERKEY = 'HUSQ' AND (BUYERPO is not null AND BUYERPO <> '')
      -- 		             -- WS Start 17092924
        --                     AND MBOL = @cMBOLKey
        --                     -- WS End 17092924
      -- 		)
      -- 		WHERE id = @myCont2
      -- 	END
-- WS 19/09/2024 END
      SET @myCont2 = @myCont2 + 1
    END
--check 8 WS.
--SELECT * FROM #temp
--for testing
--UPDATE CODELKUP WITH(ROWLOCK) SET CODE2 = '' WHERE listname = 'BQAsn' AND storerkey = @cStorerKey
WHILE @myCont3 <= @tempCounter
    BEGIN
      --Check if current SO has not a value in field ASNPO
      IF ((SELECT ASNPO FROM #temp WITH (NOLOCK) WHERE ID = @myCont3) IS NULL) OR ((SELECT ASNPO FROM #temp WITH (NOLOCK) WHERE ID = @myCont3 ) = '')
          BEGIN
            --Chek current Date is equal the date store in BQAsn CODELKUP
                IF @code_date <> (SELECT FORMAT (GETDATE(), 'yyy-MM-dd'))
                        BEGIN
                            --If is a new date update variable @code_date and value UDF01 in the BQAsn CODELKUP
                            --SET @code_date = (SELECT CAST((DATEADD(day, 1, @code_date)) AS DATE))-> AGA6399 24/12/10
                            SET @code_date = (SELECT FORMAT (GETDATE(), 'yyy-MM-dd'))
                            SET @stringDate = (SELECT CONVERT(Nvarchar,@code_date ))
                            UPDATE CODELKUP WITH(ROWLOCK) SET UDF01 = @stringDate WHERE listname = 'BQAsn' AND storerkey = @cStorerKey
                            --Update the value of code with the new date and set counter to 00
                            SET @codeValue = '200180'+(SELECT FORMAT (@code_date, 'yyMMdd'))+'02'+'00'
                            UPDATE CODELKUP WITH(ROWLOCK) SET CODE = @codeValue WHERE listname = 'BQAsn' AND storerkey = @cStorerKey
                            -- Update the value of SO BUYERPO
                            UPDATE ORDERS WITH(ROWLOCK) SET BUYERPO = @codeValue WHERE OrderKey = (SELECT OrderKey FROM #temp WITH (NOLOCK) WHERE ID = @myCont3) AND storerkey = @cStorerKey
                            -- Update the value of #temp ASNPO for all the rows with same customer PO
                            UPDATE #temp WITH(ROWLOCK) SET ASNPO = @codeValue WHERE SUB0RDU05 = (SELECT SUB0RDU05 FROM #temp WITH (NOLOCK) WHERE ID = @myCont3
                            -- WS Start 17092924
                            AND MBOL = @cMBOLKey
                            -- WS End 17092924
                            )
                        END
                    ELSE
                        BEGIN
                            --In case date are correct increase one digit the counter
                            SET @newCountVal = (SELECT REPLACE(STR(CAST((SELECT SUBSTRING((SELECT code FROM dbo.CODELKUP WITH (NOLOCK) WHERE listname = 'BQAsn' AND storerkey = @cStorerKey),15,2)) AS INT) + 1,2),' ','0'))
                            SET @shortCodeVal = (SELECT SUBSTRING((SELECT code FROM dbo.CODELKUP WITH (NOLOCK) WHERE listname = 'BQAsn' AND storerkey = @cStorerKey),1,14))
                            -- Update the value of code with the counter val
                            UPDATE CODELKUP WITH(ROWLOCK) SET CODE = @shortCodeVal+@newCountVal WHERE listname = 'BQAsn' AND storerkey = @cStorerKey
                            -- Update the value of SO BUYERPO
                            --UPDATE ORDERS WITH(ROWLOCK) SET BUYERPO = @shortCodeVal+@newCountVal WHERE OrderKey = (SELECT OrderKey FROM #temp WITH (NOLOCK) WHERE ID = @myCont3) --AND storerkey = @cStorerKey
                            --UPDATE ORDERS SET BUYERPO = '***399'+(SELECT CONVERT(Nvarchar,@myCont3 )) WHERE OrderKey = (SELECT OrderKey FROM #temp WITH (NOLOCK) WHERE ID = @myCont3) AND storerkey = @cStorerKey
                            UPDATE ORDERS WITH(ROWLOCK) SET BUYERPO = @shortCodeVal+@newCountVal WHERE OrderKey = (SELECT OrderKey FROM #temp WITH (NOLOCK) WHERE ID = @myCont3
                             -- WS Start 17092924
                            AND MBOL = @cMBOLKey
                            -- WS End 17092924
                            ) AND storerkey = @cStorerKey
                            -- Update the value of #temp ASNPO for all the rows with same customer PO
                            UPDATE #temp WITH(ROWLOCK) SET ASNPO = @shortCodeVal+@newCountVal WHERE SUB0RDU05 = (SELECT SUB0RDU05 FROM #temp WITH (NOLOCK) WHERE ID = @myCont3
                             -- WS Start 17092924
                            AND MBOL = @cMBOLKey
                            -- WS End 17092924
                            )
                        END
            END
            --current #temp SO has aready a value in ASNPO, in that case update SO BUYERPO with the same value
        ELSE
            BEGIN
               --- Update the value of SO BUYERPO
               UPDATE ORDERS WITH(ROWLOCK) SET BUYERPO = (SELECT ASNPO FROM #temp WITH (NOLOCK) WHERE ID = @myCont3) WHERE OrderKey = (SELECT OrderKey FROM #temp WITH (NOLOCK) WHERE ID = @myCont3) AND storerkey = @cStorerKey
            END
        SET @myCont3 = @myCont3 + 1
    END
--check 9 WS.
--SELECT * FROM #temp
GRANT EXECUTE ON [RDT].[isp_UK_HUSQ_BQ_AsnVal] TO [NSQL]
GO