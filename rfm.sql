---------from 'ONLINERETAIL_2010' to RFM table---------

--Empty table
TRUNCATE TABLE RFM

--Add 'CustomerId' 
INSERT INTO RFM (CUSTOMERID)
SELECT DISTINCT [Customer ID] FROM ONLINERETAIL_2010

--Add/update 'LastInvoiceDate' from 'ONLINERETAIL_2010' to RFM table
UPDATE RFM SET LastInvoiceDate=(SELECT MAX(InvoiceDate) 
FROM ONLINERETAIL_2010 where [Customer ID]=RFM.CustomerID)

--Add/update 'Recency' 
UPDATE RFM SET Recency=DATEDIFF(DAY,LastInvoiceDate,'20111211')

--Add/update 'Frequency' 
UPDATE RFM SET Frequency=(SELECT COUNT(Distinct Invoice) 
FROM ONLINERETAIL_2010 where CustomerID=RFM.CustomerID)

--Add/update 'Monetary' 
UPDATE RFM SET Monatery=(SELECT sum(Price*Quantity)  
FROM ONLINERETAIL_2010 where CustomerID=RFM.CustomerID)




--Add/update 'Recency_Score' 
UPDATE RFM SET Recency_Score= 
(
 select RANK from
 (
SELECT  *,
       NTILE(5) OVER(
       ORDER BY Recency desc) Rank
FROM RFM
) t where  CUSTOMERID=RFM. CUSTOMERID)

--Add/update 'Frequency_Score' 
update RFM SET Frequency_Score= 
(
 select RANK from
 (
SELECT  *,
       NTILE(5) OVER(
       ORDER BY Frequency) Rank
FROM rfm 
) T where  CUSTOMERID=RFM. CUSTOMERID)

--Add/update 'Monetary_Score' 
update RFM SET Monetary_Score= 
(
 select RANK from
 (
SELECT  *,
       NTILE(5) OVER(
       ORDER BY Monatery) Rank
FROM rfm 
) t where  CustomerID=RFM.CustomerID)



---Segmentation
UPDATE RFM SET Segment ='Hibernating' 
WHERE Recency_Score LIKE  '[1-2]%' AND Frequency_Score LIKE '[1-2]%'  
UPDATE RFM SET Segment ='At_Risk' 
WHERE Recency_Score LIKE  '[1-2]%' AND Frequency_Score LIKE '[3-4]%'  
UPDATE RFM SET Segment ='Cant_Loose' 
WHERE Recency_Score LIKE  '[1-2]%' AND Frequency_Score LIKE '[5]%'  
UPDATE RFM SET Segment ='About_to_Sleep' 
WHERE Recency_Score LIKE  '[3]%' AND Frequency_Score LIKE '[1-2]%'  
UPDATE RFM SET Segment ='Need_Attention' 
WHERE Recency_Score LIKE  '[3]%' AND Frequency_Score LIKE '[3]%' 
UPDATE RFM SET Segment ='Loyal_Customers' 
WHERE Recency_Score LIKE  '[3-4]%' AND Frequency_Score LIKE '[4-5]%' 

UPDATE RFM SET Segment ='Promising' 
WHERE Recency_Score LIKE  '[4]%' AND Frequency_Score LIKE '[1]%' 
UPDATE RFM SET Segment ='New_Customers' 
WHERE Recency_Score LIKE  '[5]%' AND Frequency_Score LIKE '[1]%' 
UPDATE RFM SET Segment ='Potential_Loyalists' 
WHERE Recency_Score LIKE  '[4-5]%' AND Frequency_Score LIKE '[2-3]%' 
UPDATE RFM SET Segment ='Champions' 
WHERE Recency_Score LIKE  '[5]%' AND Frequency_Score LIKE '[4-5]%'