({
    
    copyTextFieldHelper : function(component,event,text) {
        //Hidden input variable
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", text);
        
        //Append Hidden Input to the body
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        
        // Executing the copy command
        document.execCommand("copy");
        document.body.removeChild(hiddenInput); 
        
        // store target button label value
        var orignalLabel = event.getSource().get("v.label");
        
        //To change Button Icon after text is copied
        event.getSource().set("v.iconName" , 'utility:check');
        
        //To change button label to 'copied' after text is copied 
        event.getSource().set("v.label" , 'copied');
        
        // set timeout to reset icon and button label value after 'n' milliseconds 
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 1000);
        
    }
})