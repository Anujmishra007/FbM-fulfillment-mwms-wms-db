IF OBJECT_ID('dbo.V_OTM_Table_Mapping') IS NOT NULL
   DROP VIEW dbo.V_OTM_Table_Mapping
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store Procedure:  V_OTM_Table_Mapping                                */
/* Creation Date: 05-Apr-2019                                           */
/* Copyright: IDS                                                       */
/* Written by: Shong                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/*                              SG Request to change DEL_ORDERS (MC01)  */
/*                              TW Request to add ASNRCMOTM (MC02)      */
/*                              Add OTM-MBLUPD (MC03)                   */
/*                              Add New Config (MC04)                   */
/************************************************************************/


CREATE VIEW V_OTM_Table_Mapping AS
SELECT 'ASNADDOTM ' AS TableName, 
       'RECEIPT'    AS PhysicalTableName, 
       'ReceiptKey' AS Key1, 
       'DocType'    AS Key2,
       'StorerKey'  AS Key3, 
       'OTM-ASN'    AS ParmType   
UNION SELECT 'CANCASNOTM', 'RECEIPT',        'ReceiptKey',  'DocType',  'StorerKey', 'OTM-ASN'
UNION SELECT 'RCPTOTM',    'RECEIPT',        'ReceiptKey',  'DocType',  'StorerKey', 'OTM-ASN'
UNION SELECT 'ASNRCMOTM',  'RECEIPT',        'ReceiptKey',  'DocType',  'StorerKey', 'OTM-ASN'           --(MC02)
UNION SELECT 'CANCSOOTM',  'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
--UNION SELECT 'DELSOOTM', 'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'           --(MC01)
UNION SELECT 'DELSOOTM',   'DEL_ORDERS',     'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'           --(MC01)
UNION SELECT 'SOADDOTM',   'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'SOCARGOOTM', 'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'SOCFMOTM',   'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'SOPNPOTM',   'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'SORCMOTM',   'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'SOSHPOTM',   'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'SOALLOCOTM', 'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'           --(MC04)
UNION SELECT 'RLWAVSOOTM', 'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'           --(MC04)
UNION SELECT 'DSTADDOTM',  'DOCStatusTrack', 'RowRef',      'Status',   'StorerKey', 'OTM-DST'
UNION SELECT 'LOADFNZOTM', 'LOADPLAN',       'LoadKey',     'Status',   'StorerKey', 'OTM-LP'
UNION SELECT 'LPCARGOOTM', 'LOADPLAN',       'LoadKey',     'Status',   'StorerKey', 'OTM-LP'
UNION SELECT 'MBCARGOOTM', 'MBOL',           'MbolKey',     '',         'StorerKey', 'OTM-MBL'
UNION SELECT 'MBOLSHPOTM', 'MBOL',           'MbolKey',     '',         'StorerKey', 'OTM-MBL'
UNION SELECT 'SOALLOCOTM', 'ORDERS',         'OrderKey',    'Status',   'StorerKey', 'OTM-ORD'
UNION SELECT 'PKHADDOTM',  'LOADPLAN',       'LoadKey',     '',         'StorerKey', 'OTM-CLP'
UNION SELECT 'PKHCFMOTM',  'LOADPLAN',       'LoadKey',     '',         'StorerKey', 'OTM-CLP'
UNION SELECT 'MBLUPDOTM',  'MBOL',           'MbolKey',     '',         'StorerKey', 'OTM-MBLUPD'        --(MC03)
UNION SELECT 'MBCGUPDOTM', 'MBOL',           'MbolKey',     '',         'StorerKey', 'OTM-MBLUPD'        --(MC03)

GO

