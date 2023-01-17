import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class OpportunityQuickAction extends LightningElement {

    @api recordId;
    @api objectApiName;
    handleSuccess(e){
     this.dispatchEvent(new CloseActionScreenEvent());
     this.dispatchEvent(
         new ShowToastEvent({
             title: 'SUCCESS',
             message: 'Record Updated Successfully',
             variant: 'success',
         })
     );
    }
}