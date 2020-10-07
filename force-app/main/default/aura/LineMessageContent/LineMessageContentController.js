({
    doInit: function(component, event, helper) {
        var selectCmp1 = component.find("InputSelectSingleActionA");
        selectCmp1.set("v.value", component.get("v.TheContent.ActionTypeA__c"));

        var selectCmp2 = component.find("InputSelectSingleActionB");
        selectCmp2.set("v.value", component.get("v.TheContent.ActionTypeB__c"));

        var selectCmp3 = component.find("InputSelectSingleActionC");
        selectCmp3.set("v.value", component.get("v.TheContent.ActionTypeC__c"));

        var selectCmp4 = component.find("InputSelectSingleActionD");
        selectCmp4.set("v.value", component.get("v.TheContent.ActionTypeD__c"));

        var selectCmp5 = component.find("InputSelectSingleActionE");
        selectCmp5.set("v.value", component.get("v.TheContent.ActionTypeE__c"));

        var selectCmp6 = component.find("InputSelectSingleActionF");
        selectCmp6.set("v.value", component.get("v.TheContent.ActionTypeF__c"));
    },
    removeMe : function(component, event, helper) {
        component.set('v.TheContent.isDeleted__c', true);
        var myPassEvent = component.getEvent("passEvent1");
        myPassEvent.setParams({
            "message" : 1
        });
        myPassEvent.fire();
    },
    onSingleSelectChangeActionA: function(component) {
        var selectCmp = component.find("InputSelectSingleActionA");
        component.set("v.TheContent.ActionTypeA__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeActionB: function(component) {
        var selectCmp = component.find("InputSelectSingleActionB");
        component.set("v.TheContent.ActionTypeB__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeActionC: function(component) {
        var selectCmp = component.find("InputSelectSingleActionC");
        component.set("v.TheContent.ActionTypeC__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeActionD: function(component) {
        var selectCmp = component.find("InputSelectSingleActionD");
        component.set("v.TheContent.ActionTypeD__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeActionE: function(component) {
        var selectCmp = component.find("InputSelectSingleActionE");
        component.set("v.TheContent.ActionTypeE__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeActionF: function(component) {
        var selectCmp = component.find("InputSelectSingleActionF");
        component.set("v.TheContent.ActionTypeF__c", selectCmp.get("v.value"));
    },
    handleUploadFinished: function (component, event, helper) {
        helper.LinkStart(component, event);
    },
})