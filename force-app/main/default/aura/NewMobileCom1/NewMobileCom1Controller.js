({
	doInit: function(component, event, helper) {
        component.set("v.OpportunityID", component.get("v.recordId"));
        helper.fetchMappingValues(component);
        helper.getLabels(component, event);
        helper.timePicklist(component, event);
    },
    
    setDefault: function(component, event, helper) {
        helper.showAllBranch(component, event);
    },

    chooseBranch: function(component, event, helper) {
        helper.showTestCar(component, event);
    },
    
    chooseTestCar: function(component, event, helper) {
        helper.showCarCalendar(component, event);
    },
    changeMyDate: function(component, event, helper) {
        var myResult = event.getParam("PassTestDriveDate");
        component.set("v.chooseDay", myResult);
        helper.showDateCalendar(component, event);
    },
    createRecord : function(component, event, helper) {
        var isErrorOccur = false;
        var myMessage = "";
        
        var TestCarID = component.find("myTestCar").get("v.value");
        if(TestCarID ===undefined || TestCarID === '')
        {
            myMessage += "請輸入試駕車輛。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('myTestCar');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        
        var OPPID = component.find("myOPP").get("v.value");
        if(OPPID ===undefined || OPPID === '')
        {
            myMessage += "請輸入有望客戶。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('myOPP');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        
        var myRES = component.get('v.TestDriveReservation');
        if(myRES.CarUseType__c ===undefined || myRES.CarUseType__c === '')
        {
            myMessage += "請輸入"+component.get("v.reservationLabels.carusetype__c")+"。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('carType');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        
        if(myRES.Description__c ===undefined || myRES.Description__c === '')
        {
            myMessage += "請輸入"+component.get("v.reservationLabels.description__c")+"。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('description');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        
        var StartTIME = component.find("InputSelectDynamic1").get("v.value");
        if(StartTIME ===undefined || StartTIME === '')
        {
            myMessage += "請輸入"+component.get("v.reservationLabels.starttime__c")+"。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('InputSelectDynamic1');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        
        var EndTIME = component.find("InputSelectDynamic2").get("v.value");
        if(EndTIME ===undefined || EndTIME === '')
        {
            myMessage += "請輸入"+component.get("v.reservationLabels.endtime__c")+"。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('InputSelectDynamic2');
    		$A.util.addClass(cmpTarget, 'redLine');
        }

        if(isErrorOccur)
        {
            component.set('v.errorMessage', myMessage);
        }
        else
        {
            component.set('v.isActing', true);
            helper.upsertEvent(component, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.showDateCalendar(component, event);
                    helper.closeModal(component, event);
                    component.set('v.isLocked', false);
                    component.set('v.isActing', false);
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                                component.set('v.errorMessage', errors[0].message);
                                component.set('v.isActing', false);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
        }
    },
    cancelRecord : function(component, event, helper) {
        component.set('v.isActing', true);
        helper.cancelEvent(component, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {                
                helper.showDateCalendar(component, event);
                helper.closeModal(component, event);
                component.set('v.isLocked', false);
                component.set('v.isActing', false);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set('v.isLocked', false);
                        component.set('v.isActing', false);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
    },
    showEvent: function(component, event, helper) {
        component.set('v.isLocked', true);
        helper.showExistEvent(component, event, helper);
    },
    openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },
    closeModal : function(component, event, helper) {
    	component.set('v.isLocked', false);
        helper.closeModal(component, event);
    },
    showNewRES: function(component, event, helper){
        var Tday = new Date();
        var choseDate = component.get('v.chooseDay');
        if(moment(choseDate).isBefore(moment(Tday), 'day'))
        {
            alert('不可選擇今天以前的日期');
        }
        else
        {
            var ctarget = event.currentTarget;
            var res = ctarget.dataset.value;
            var currentHH = ((parseInt(res.substring(0,2))+102).toString()).substring(1,3) + res.substring(2,5);
            //偷偷把日期換掉。
            if(currentHH === '24:30' || currentHH === '25:00' || currentHH === '25:30')
            {
                currentHH = '24:00';
            }
            
            component.set('v.isClosed', false);
            component.set('v.idVal','');
            component.set('v.errorMessage','');
            component.find("myOPP").set("v.value",component.get('v.OpportunityID'));
            component.find("myTestCar").set("v.value",component.get('v.chooseCar'));
            component.set('v.TestDriveReservation.CarUseType__c','');
            component.set('v.TestDriveReservation.TestDriveStatus__c', '');
            component.set('v.TestDriveReservation.Description__c','');
            component.set('v.TestDriveReservation.StartTime__c',component.get('v.chooseDay'));
            component.set('v.TestDriveReservation.EndTime__c',component.get('v.chooseDay'));
            component.set('v.TestDriveReservation.TestDrivePerson__c', '');
            component.find("InputSelectDynamic1").set("v.value",res);
            component.find("InputSelectDynamic2").set("v.value",currentHH);
            
            helper.openModal(component, event);
        }
    },
    myOPPCHANGE : function(component, event, helper) {
        var changeMe = component.get('v.idVal');
        if(changeMe === undefined || changeMe === '')
        {
            helper.myOPPName(component, event, helper);
        }
        else
        {
            //不動作。
        }
	}
})