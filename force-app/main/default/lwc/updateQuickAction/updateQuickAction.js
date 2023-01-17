import { LightningElement,track,wire } from 'lwc';
import getOppRecord from '@salesforce/apex/OpportunityHelper.getOppRecord';
import Opp_Name from '@salesforce/schema/Opportunity.Name';
import Opp_CloseDate from '@salesforce/schema/Opportunity.CloseDate';
import Opp_StageName from '@salesforce/schema/Opportunity.StageName';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class UpdateQuickAction extends LightningElement {
    
    @track oppId;
    @track oppRecord = {
        Name: Opp_Name,
        CloseDate: Opp_CloseDate,
        StageName: Opp_StageName
    };

    handleChange(event){
        this.oppRecord.Name = event.target.value;
    }
    handleChange(event){
        this.oppRecord.CloseDate = event.target.value;
    }
    handleChange(event){
        this.oppRecord.StageName = event.target.value;
    }

    handleSaveOpp(){
        getOppRecord({opportunityRecObj: this.oppRecord})
        .then(result=>{
            this.oppRecord = {};
            this.oppId = result.Id;
            window.console.log('Id---->'+this.oppId);

            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Record Created Successfully',
                variant: 'success'
            });
           this.dispatchEvent(toastEvent);
        })
        .catch(error=>{
            this.error= error.message;
        });
    }
}