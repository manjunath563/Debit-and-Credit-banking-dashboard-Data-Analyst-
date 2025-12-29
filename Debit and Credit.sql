create database Debit_Credit_Dataset;
use Debit_credit_Dataset;
select * from `debit and credit banking_data`;

------------ Drop Column ---------------------------
ALTER TABLE `debit and credit banking_data`
DROP COLUMN Description,
DROP COLUMN Currency;

--------------- 1) Total Amount Debited--------------------
SELECT 
    CONCAT(ROUND(SUM(Amount) / 1000000, 2), ' M') AS Total_Debit_Millions
FROM `debit and credit banking_data`
WHERE `Transaction Type` = 'Debit';


----------------- 2) Total Credit Amount -------------------
SELECT 
    CONCAT(ROUND(SUM(Amount) / 1000000, 2), ' M') AS Total_Credit
FROM `debit and credit banking_data`
WHERE`Transaction Type` = 'Credit';

----------------- 3) Net Change-----------------
SELECT 
    CONCAT(
        ROUND(
            (
                SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) -
                SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END)
            ) / 1000000,
        2), 
        ' M'
    ) AS Net_Change
FROM `debit and credit banking_data`;

------------------------ 4)Branch-wise Total Transactions------------------
SELECT Branch, COUNT(*) AS Total_Transactions
FROM `debit and credit banking_data`
GROUP BY Branch;

--------------------- 5) Branch-wise Total Amount -------------
SELECT 
    Branch,
    CONCAT(ROUND(SUM(Amount) / 1000000, 2), ' M') AS Total_Amount
FROM `debit and credit banking_data`
GROUP BY Branch;

----------------------- 6) Daily Transaction Volume-------------
SELECT `Transaction Date`,
       COUNT(*) AS Transaction_Count,
       SUM(Amount) AS Total_Amount
FROM `debit and credit banking_data`
GROUP BY `Transaction Date`
ORDER BY `Transaction Date`;

------------------ 7) Customer-wise Total Transactions ----------------------
alter table `debit and credit banking_data`
rename	column `ï»¿Customer ID` to `Customer ID`;

SELECT `Customer ID`, `Customer Name`,
       COUNT(*) AS Number_of_Transactions,
       SUM(Amount) AS Total_Amount
FROM `debit and credit banking_data`
GROUP BY `Customer ID`, `Customer Name`;

---------------- 8) 8) Transaction Method Usage ----------------------
SELECT `Transaction Method`,
       COUNT(*) AS Method_Count
FROM `debit and credit banking_data`
GROUP BY `Transaction Method`;

-------------------- Advance Queries----------------------

--------------------------- 1. Customer-wise Balance Trend------------
SELECT 
    `Customer ID`,
    `Customer Name`,
    `Transaction Date`,
    `Transaction Type`,
    Amount,
    SUM(CASE 
            WHEN `Transaction Type` = 'Credit' THEN Amount 
            WHEN `Transaction Type` = 'Debit' THEN -Amount 
            ELSE 0 
        END
    ) OVER(PARTITION BY `Customer ID` ORDER BY `Transaction Date`) AS Running_Balance
FROM `debit and credit banking_data`
ORDER BY `Customer ID`, `Transaction Date`;

---------------- 2. Branch-wise Debit/Credit Comparison---------------
SELECT 
    Branch,

    CONCAT(
        ROUND(SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) / 1000000, 2),
        ' M'
    ) AS Total_Credit,

    CONCAT(
        ROUND(SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END) / 1000000, 2),
        ' M'
    ) AS Total_Debit,

    CONCAT(
        ROUND(
            (SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END)
           - SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END)) / 1000000,
        2),
        ' M'
    ) AS Net_Balance
FROM `debit and credit banking_data`
GROUP BY Branch;


------------------ 3) Monthly Summary (Amount + Count) ------------------
SELECT 
    DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Month,
    COUNT(*) AS Total_Transactions,
    SUM(Amount) AS Total_Amount,
    CONCAT(
        ROUND(SUM(Amount) / 1000000, 2),
        ' M'
    ) AS Total_Amount_Million

FROM `debit and credit banking_data`
GROUP BY DATE_FORMAT(`Transaction Date`, '%Y-%m')
ORDER BY Month;


---------------- 4) Weekly Summary -----------------
SELECT 
    YEARWEEK(`Transaction Date`, 1) AS Week_Number,
    COUNT(*) AS Total_Transactions,
 SUM(Amount)AS Total_Amount,
    CONCAT(ROUND(SUM(Amount) / 1000000, 2),"M") AS Total_Amount_Million
FROM `debit and credit banking_data`
GROUP BY YEARWEEK(`Transaction Date`, 1)
ORDER BY Week_Number;
