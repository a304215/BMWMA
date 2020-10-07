({
	getResult : function(component, event, helper) {
        helper.getOpportunity(component, event);        
    },
    clearAll : function(component, event, helper) {
        component.set('v.SelectedAccount.Id', '');
        
        component.set('v.SelectedAccount.LastName', '');
        component.find("LastName").set("v.value", "");
        component.set('v.SelectedAccount.FirstName', '');
        component.find("FirstName").set("v.value", "");
        component.set('v.SelectedAccount.PersonalID__c', '');
        component.find("PersonalID").set("v.value", "");
        component.set('v.SelectedAccount.Gender__pc', '');
        component.find("Gender").set("v.value", "");
        component.set('v.SelectedAccount.ContactMethod__c', '');
        component.find("MainContact").set("v.value", "");
        component.set('v.SelectedAccount.MainContactNumber__c', '');
        component.find("MainPhone").set("v.value", "");
        component.set('v.SelectedAccount.Phone', '');
        component.find("Phone").set("v.value", "");
        component.set('v.SelectedAccount.CompanyPhone__c', '');
        component.find("CompanyPhone").set("v.value", "");
        component.set('v.SelectedAccount.PersonMobilePhone', '');
        component.find("PersonMobilePhone").set("v.value", "");
        component.set('v.SelectedAccount.PersonBirthdate', '');
        component.find("PersonBirthdate").set("v.value", "");
        component.set('v.SelectedAccount.PersonEmail', '');
        component.find("PersonEmail").set("v.value", "");
        component.set('v.SelectedAccount.MainAddress__c', '');
        component.find("MainAddress").set("v.value", "");
        component.set('v.SelectedAccount.HomeStreet__c', '');
        component.find("HomeStreet").set("v.value", "");
        component.set('v.SelectedAccount.CompanyStreet__c', '');
        component.find("CompanyStreet").set("v.value", "");
        /*Opp資訊不該被清掉
        component.set('v.selectedOpportunity.Estimateddateofnew__c', '');
        component.find("ChageCarDate").set("v.value", "");
        component.set('v.selectedOpportunity.DeliveryDate__c', '');
        component.find("DeliveryDate").set("v.value", "");*/
        
        component.set('v.isHomeCityNull', false);
        component.set('v.isHomeDistrictNull', false);
        component.set('v.isCompanyCityNull', false);
        component.set('v.isCompanyDistrictNull', false);
    },
    save : function(component, event, helper) {
        //給預設值。
        helper.clearRedLine(component, event);
        helper.saveTheWorld(component, event);
        window && window.scroll(0,0);
    },
    myActionHandler : function(component, event, helper) {
        helper.getAccount(component, event);
    }
})