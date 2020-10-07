({
    doInit: function(component, event, helper) {
        component.set("v.LineKeyWordID", component.get("v.recordId"));
        component.set("v.TheUserID", $A.get("$SObjectType.CurrentUser.Id"));
        helper.initial(component, event);
        helper.lineAccountList(component, event);
        helper.initialD2(component, event);
        helper.defaultIMOJI(component, event);
        helper.defaultSticker(component, event);
    },
    onSingleSelectChange: function(component, event, helper) {
        var selectCmp = component.find("InputSelectSingle");
        var resultCmp = component.find("singleResult");
        resultCmp.set("v.value", selectCmp.get("v.value"));
    },
    onSingleSelectChangeType: function(component, event, helper) {
        var selectCmp = component.find("InputSelectSingleType");
        var resultCmp = component.find("singleResultType");
        resultCmp.set("v.value", selectCmp.get("v.value"));
    },
    addNewMessage: function(component, event, helper) {
        helper.newMessage(component, event);
    },
    saveAllMessage: function(component, event, helper) {
        helper.checkMyMessage(component, event);
        var errMMM = component.get("v.errMSG");
        if(errMMM === "")
        {
            helper.saveMessage(component, event, helper);
        }
    },
    previewMe: function(component, event, helper) {
        helper.generateReview(component, event);
    },
    removeMe : function(component, event, helper) {
        var returnList = component.get('v.TheMessageList2');
        var myCount=0;
        for(var i=0; i<returnList.length;i++)
        {
            if(returnList[i].theMessage.isDeleted__c===false)
            {
                myCount++;
            }
        }
        component.set('v.messageCount', myCount);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "已刪除訊息。"
        });
        toastEvent.fire();
    },
})