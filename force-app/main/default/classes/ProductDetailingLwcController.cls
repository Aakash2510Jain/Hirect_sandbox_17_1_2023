public class ProductDetailingLwcController {
    @AuraEnabled(cacheable=true)
    Public Static list<PricebookEntry> getProductList(String prodid){
        list<PricebookEntry> prcbkList = new list<PricebookEntry>();
        prcbkList=[SELECT Id,IsActive,Name,Pricebook2Id,Product2Id,ProductCode,UnitPrice,UseStandardPrice FROM PricebookEntry where Product2Id =:prodid];
        system.debug('prcbkList'+prcbkList);
        return prcbkList;
    }
}