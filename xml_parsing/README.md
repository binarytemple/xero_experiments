# XmlParsing


Outline of BankTransaction data structure:

```
xmlstarlet el ~/Google\ Drive/xero-api/transactions/april-2016.xml | sort -u
Response
Response/BankTransactions
Response/BankTransactions/BankTransaction
Response/BankTransactions/BankTransaction/BankAccount
Response/BankTransactions/BankTransaction/BankAccount/AccountID
Response/BankTransactions/BankTransaction/BankAccount/Name
Response/BankTransactions/BankTransaction/BankTransactionID
Response/BankTransactions/BankTransaction/Contact
Response/BankTransactions/BankTransaction/Contact/ContactID
Response/BankTransactions/BankTransaction/Contact/Name
Response/BankTransactions/BankTransaction/CurrencyCode
Response/BankTransactions/BankTransaction/Date
Response/BankTransactions/BankTransaction/HasAttachments
Response/BankTransactions/BankTransaction/IsReconciled
Response/BankTransactions/BankTransaction/LineAmountTypes
Response/BankTransactions/BankTransaction/Reference
Response/BankTransactions/BankTransaction/Status
Response/BankTransactions/BankTransaction/SubTotal
Response/BankTransactions/BankTransaction/Total
Response/BankTransactions/BankTransaction/TotalTax
Response/BankTransactions/BankTransaction/Type
Response/BankTransactions/BankTransaction/UpdatedDateUTC
Response/DateTimeUTC
Response/Id
Response/ProviderName
Response/Status
```

So for the first itteration we will:


* Match on startElement - `BankTransaction`;
* Create a placeholder data structure to hold the attributes (inner elements) of the `BankTransaction`;
* Match on startElement for each of the inner elements
* Match on endElement - `BankTransaction`
  * 


BankAccount
BankAccount/AccountID
BankAccount/Name
BankTransactionID
Contact
Contact/ContactID
Contact/Name
CurrencyCode
Date
HasAttachments
IsReconciled
LineAmountTypes
Reference
Status
SubTotal
Total
TotalTax
Type
UpdatedDateUTC
