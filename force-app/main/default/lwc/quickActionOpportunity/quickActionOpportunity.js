import { LightningElement,api,wire} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import Opportunity_Object from '@salesforce/schema/Opportunity';
export default class QuickActionOpportunity extends LightningElement {

    @api recordId;
   

   fieldList = {
       Name:  '',
      StageName : '',
       CloseDate: '',
   }

   statusOptions = [
    { 
        value: 'Qualification', label: 'Qualification'
    },
    {
        value: 'Needs Analysis', label: 'Needs Analysis'
    },
    {
        value: 'Proposal', label: 'Proposal'
    },
    {
        value: 'Negotiation', label: 'Negotiation'
    },
    {
        value: 'Closed Won', label: 'Closed Won'
    },
    {
        value: 'Closed Lost', label: 'Closed Lost'
    },
];
value = 'new';

   hanldeChange(event){
       let name = event.target.name
       let value  = event.target.value;
       if(name=='name'){
           this.fieldList.Name = value;
       }else if(name == 'date'){
           this.fieldList.CloseDate = value;
      }
      else if(name =='Stage'){
          this.fieldList.StageName = value;
     }
   }

   handleSave(){
       debugger;
    const fields = {...this.fieldList};
    fields.Parent_opportunity__c = this.recordId;
    
    console.log('FILEDS',this.fieldList);
    let recordInput = { apiName: Opportunity_Object.objectApiName, fields}
    createRecord(recordInput).then(result=>{
        this.fieldList = {}
        console.log('Opportunity Id--->', JSON.stringify(result.id))
    })
    .catch(error =>{
        console.log(error);
    })
    this.dispatchEvent(new CloseActionScreenEvent());
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'SUCCESS',
            message: 'Record Created Success Successfully',
            variant: 'success',
        })
    );
   }
}