import { api, LightningElement, wire,track } from 'lwc';
import getProductList from '@salesforce/apex/ProductDetailingLwcController.getProductList';
import Name from '@salesforce/schema/Product2.Name';
import Days_of_Subscription__c from '@salesforce/schema/Product2.Days_of_Subscription__c';
import ProductCode from '@salesforce/schema/Product2.ProductCode';
import StockKeepingUnit from '@salesforce/schema/Product2.StockKeepingUnit';
import Description from '@salesforce/schema/Product2.Description';
import Family from '@salesforce/schema/Product2.Family';
import QuantityUnitOfMeasure from '@salesforce/schema/Product2.QuantityUnitOfMeasure';
import Duration_In_Days__c from '@salesforce/schema/Product2.Duration_In_Days__c';
import IsActive from '@salesforce/schema/Product2.IsActive';
import DisplayUrl from '@salesforce/schema/Product2.DisplayUrl';
import ExternalId from '@salesforce/schema/Product2.ExternalId';
import ExternalDataSourceId from '@salesforce/schema/Product2.ExternalDataSourceId';

export default class ProductDetailingLwc extends LightningElement {
    @api recordId='01t0w000002hhcBAAQ';
    @api objectApiName='Product2';
    @api nameField=Name;
    @api prodDeatilsField=Days_of_Subscription__c;
    @api ProductCode=ProductCode;
    @api ProductSKU=StockKeepingUnit;
    @api DurationInDays=Duration_In_Days__c;
    @api ProductDescription=Description
    @api Family=Family
    @api QuantityUnitOfMeasure=QuantityUnitOfMeasure
    @api Active=IsActive
    @api DisplayUrl=DisplayUrl
    @api ExternalId=ExternalId
    @api ExternalDataSourceId=ExternalDataSourceId
    @track priceBookList=[]
    @track columns=[
        { label: 'PriceBook', fieldName: 'Pricebook2Id',type: 'currency' },
        { label: 'List Price', fieldName: 'UnitPrice', type: 'text' },
        { label: 'Use Standard Price', fieldName: 'UseStandardPrice', type: 'text' },
        { label: 'Active', fieldName: 'IsActive', type: 'checkbox' },
       
    ]


    @wire(getProductList,{prodid:'$recordId'})
    wireResponse({data,error}){
        debugger;
        if(data){
            this.priceBookList=data;
        }
        if(error){

        }
    }

    


}