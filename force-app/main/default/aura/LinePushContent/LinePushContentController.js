({
    doInit: function(component, event, helper) {
        component.set("v.LineContentID", component.get("v.recordId"));
        component.set("v.TheUserID", $A.get("$SObjectType.CurrentUser.Id"));
        helper.initial(component, event);
        helper.lineAccountList(component, event);
        helper.initialD2(component, event);
        helper.defaultIMOJI(component, event);
        helper.defaultSticker(component, event);
        //helper.showReportList(component, event);
    },
    onSingleSelectChange: function(component, event, helper) {
        var selectCmp = component.find("InputSelectSingle");
        var resultCmp = component.find("singleResult");
        resultCmp.set("v.value", selectCmp.get("v.value"));
        helper.showReportList(component, event);
    },
    onSingleSelectChange2: function(component, event, helper) {
        var selectCmp = component.find("InputSelectSingle2");
        var resultCmp = component.find("singleResult2");
        resultCmp.set("v.value", selectCmp.get("v.value"));
    },
    addNewMessage: function(component, event, helper) {
        helper.newMessage(component, event);
    },
    saveAllContent: function(component, event, helper) {
        helper.checkMyContent(component, event);
        var errMMM = component.get("v.errMSG");
        if(errMMM === "")
        {
            helper.saveContent(component, event, helper);
        }
    },
    completeAllContent: function(component, event, helper) {
        helper.checkMyCompleteContent(component, event);
        var errMMM = component.get("v.errMSG");
        if(errMMM === "")
        {
            helper.completeContent(component, event);
        }
    },
    previewMe: function(component, event, helper) {
        helper.generateReview(component, event);
    },
    BackToTheFuture : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Line_Content__c/list"
        });
        urlEvent.fire();
    },
    removeMe : function(component, event, helper) {
        var returnList = component.get('v.TheMessageList2');
        var myCount=0;
        for(var i=0; i<returnList.length;i++)
        {
            if(returnList[i].isDeleted__c===false)
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