import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import sendPaymentLink from '@salesforce/apex/RazorpayPaymentHandler.sendPaymentLink';
import createInvoiceRec from '@salesforce/apex/RazorpayPaymentHandler.createInvoiceRec';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class PaymentIntegration extends LightningElement {
    @api recordId;

    @wire(sendPaymentLink, { recordId: "$recordId" })
    paymentResp(result) {
        debugger;
        if (result.data && result.data.accept_partial) {
            console.log(result);
            //alert('Paymet Sent Successfully');
            this.createInvoice();
            this.closeAction();
        } else if (!this.recordId && !result.data) {
            console.log('Payment Initated ----------------------')
        } else if (this.recordId && !result.data) {
            alert('Payment Failed');
            this.closeAction();
        }
    }

    createInvoice() {
        createInvoiceRec({ recordId: this.recordId }).then(result => {
            console.log("RESULT----", result);
        }).catch(error => {
            console.log("Errorr----", error);
        })
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}