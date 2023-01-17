({
    doInit : function(component, event, helper) {
        debugger;
        //{!v.userInfo.Name}
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    copyText: function(cmp, event, helper) {
        debugger;
        var userRec = cmp.get("v.userInfo");
        var copyText = 'https://www.hirect.in/connect/?utm_source=hirect_oonl/ref_id='+userRec.Id;
        
        /*const el = document.createElement('textarea');
        el.value = str;
        el.setAttribute('readonly', '');
        el.style.position = 'absolute';
        el.style.left = '-9999px';
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
        */        
    }
})