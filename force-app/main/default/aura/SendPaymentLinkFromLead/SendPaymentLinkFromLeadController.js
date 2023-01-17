({
    doInit: function(component, event) {
        debugger;
        
        var opts = [
            { value: "Percentage", label: "Percentage" },
            { value: "Amount", label: "Amount" }
        ];
        
        component.set("v.DiscountOptions", opts);
        var recID = component.get("v.recordId");
        //var param = window.location.href;
        var action = component.get("c.queryDataOnDoInit");
        debugger;
        action.setParams({
            RecID: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() === "SUCCESS") {
                var serverresponse = response.getReturnValue();
                debugger;
                component.set("v.ProductList", response.getReturnValue().PBERecords);
                component.set("v.LeadRecord", response.getReturnValue().LeadRecord);
                if (response.getReturnValue().LeadRecord.RegistrationProgress__c != 'Audit Verified') {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        message: 'Payment link cannot be forwarded untill lead has been Onboarded',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            } else {
                debugger;
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSelectedProducts: function(component, event, helper) {
        debugger;
        var selectedproductsId;
        var checkvalue = component.find("checkProduct");
        var allproducts = component.get("v.ProductList");
        
        if (!Array.isArray(checkvalue)) {
            if (checkvalue.get("v.value") == true) {
                selectedproductsId = checkvalue.get("v.text");
            }
        } else {
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedproductsId = checkvalue[i].get("v.text");
                }
            }
        }
        console.log('selected products Id-' + selectedproductsId);
        var Selectedproducts = {};
        //component.set("v.LeadList",selectedproducts);
        
        if (selectedproductsId != null) {
            for (var j = 0; j < allproducts.length; j++) {
                if (allproducts[j].Id == selectedproductsId) {
                    Selectedproducts = allproducts[j];
                }
            }
        }
        if (Selectedproducts != null) {
            component.set("v.LeadRec", Selectedproducts);
            component.set("v.showAllproductList", false);
            component.set("v.showSelectedproductList", true);
        } else {
            console.log('selected Atleast a single product');
        }
    },
    
    updateToLead: function(component, event, helper) {
        debugger;
        
        var LeadRecordForJs = component.get("v.LeadRecord");
        if(LeadRecordForJs.Email == null || LeadRecordForJs.Phone == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Warning',
                message: 'Either Phone Or Email is Blank, Please Provide the same!!!!!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'sticky'
            });
            toastEvent.fire();
        }
        else if(LeadRecordForJs.Email != null && LeadRecordForJs.Phone != null){
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            var recID = component.get("v.recordId");
            var updatedLeadrecord = {};
            var Leadrecord = component.get("v.LeadRec");
            updatedLeadrecord = Leadrecord;
            if (Leadrecord.Discount__c > 0) {
                var discount = Leadrecord.Discount__c;
                delete updatedLeadrecord.Discount__c;
                if(Leadrecord.SelectedDiscountOption == 'Percentage'){
                    /*if(discount > 100){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        message: 'Discount Percentage cannot be greater than 100!!!!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'Warning',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else if(discount <= 100){*/
                var ActualAmount = Leadrecord.UnitPrice - ((Leadrecord.UnitPrice * discount) / 100);
                updatedLeadrecord.Amount__c = ActualAmount;
                updatedLeadrecord.Discount__c = discount;
                updatedLeadrecord.Discount_Type__c = 'Percentage';
                updatedLeadrecord.Discount_Threshold__c = discount;
                //}
            }
            else if(Leadrecord.SelectedDiscountOption == 'Amount'){
                /*if(discount > Leadrecord.UnitPrice){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        message: 'Discount Amount cannot be greater than Price of product!!!!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'Warning',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else if(discount <= Leadrecord.UnitPrice){*/
                var ActualAmount = Leadrecord.UnitPrice - discount;
                updatedLeadrecord.Amount__c = ActualAmount;
                updatedLeadrecord.Discount_in_Amount__c = discount;
                updatedLeadrecord.Discount_Type__c = 'Amount';
                updatedLeadrecord.Discount_Threshold__c = ((discount/Leadrecord.UnitPrice )*100);
                //}
            }
            
        } else {
            updatedLeadrecord.Amount__c = Leadrecord.UnitPrice;
        }
            //
            updatedLeadrecord.Product__c = Leadrecord.Product2Id;
            updatedLeadrecord.Id = recID;
            delete updatedLeadrecord.UnitPrice;
            delete updatedLeadrecord.ProductCode;
            delete updatedLeadrecord.Product2Id;
            delete updatedLeadrecord.Product2; //
            delete updatedLeadrecord.Pricebook2Id;
            delete updatedLeadrecord.Name;
            //delete updatedLeadrecord.SelectedDiscountOption;
            var action = component.get("c.updateLead");
            debugger;
            action.setParams({
                LeadRecords: updatedLeadrecord
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (response.getState() === "SUCCESS") {
                    //var serverresponse = response.getReturnValue();
                    var spinner = component.find("mySpinner");
                    $A.util.addClass(spinner, "slds-hide");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Payment link has been forwarded.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var a = component.get('c.sendPaymentLinkToLead');
                    $A.enqueueAction(a);
                    
                    //component.set("v.oppTeamMaster",response.getReturnValue());
                } else {
                    debugger;
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                debugger;
                
            });
            $A.enqueueAction(action);
            
        }
        
        
        
    },
    
    sendPaymentLinkToLead: function(component, event, helper) {
        debugger;
        var action = component.get("c.sendPaymentLinkFromLead");
        debugger;
        var a = component.get('c.createInvoiceRecForLead');
        $A.enqueueAction(a);
        action.setParams({
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
            } else {
                debugger;
            }
            
        });
        $A.enqueueAction(action);
    },
    createInvoiceRecForLead: function(component, event, helper) {
        debugger;
        var action = component.get("c.createInvoiceRec");
        debugger;
        action.setParams({
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {} else {
                debugger;
            }
            
        });
        $A.enqueueAction(action);
    },
})