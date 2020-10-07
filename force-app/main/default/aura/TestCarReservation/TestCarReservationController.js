({
    gotoCalendar : function(component, event, helper) {
        helper.getInitialD(component, event);
        helper.getLabels(component, event);
        helper.getTestCarLabels(component, event);
        helper.getTestCarInfo(component, event);
        helper.timePicklist(component, event, helper);
	},
	getResult : function(component, event, helper) {
        helper.getReservations(component, event);
        
        helper.getLabels(component, event);
        
        helper.getTestCarLabels(component, event);
        
        helper.getTestCarInfo(component, event);
        
        //傳入event id。
		var myResult = event.getParam("PassCar");
        component.set("v.Get_Result9", myResult);
        //給預設值。
        component.set('v.idVal', '');
       
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
            var evObj = {
                "title" : component.get('v.TestDriveReservation.Title__c'),
                "startDateTime" : moment(component.get('v.TestDriveReservation.StartTime__c')).format('YYYY-MM-DD')+'T'+component.find("InputSelectDynamic1").get("v.value")+':00+08:00',
                "endDateTime" : moment(component.get('v.TestDriveReservation.EndTime__c')).format('YYYY-MM-DD')+'T'+component.find("InputSelectDynamic2").get("v.value")+':00+08:00',
                "description" : component.get('v.TestDriveReservation.Description__c'),
                //"testCardId" : component.get('v.TestDriveReservation.TestCar__c'),
                //"OptId" : component.get('v.TestDriveReservation.Opportunity__c'),
                "testCardId" : component.find("myTestCar").get("v.value"),
                "OptId" : component.find("myOPP").get("v.value"),
                "testDrivePerson" : component.get('v.TestDriveReservation.TestDrivePerson__c'),
                "carUseType" : component.get('v.TestDriveReservation.CarUseType__c')
            };
            if (component.get('v.idVal')) {
                evObj.id = component.get('v.idVal');
            }
            helper.upsertEvent(component, evObj, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    //在這裡才清除掉。
                    $('#calendar').fullCalendar( 'removeEvents', response.getReturnValue().Id );
                    
                    var newEvent = {
                        id : response.getReturnValue().Id,
                        title : response.getReturnValue().title,
                        start : moment(response.getReturnValue().startDateTime),
                        end : moment(response.getReturnValue().endDateTime),
                        description : response.getReturnValue().description,
                        owner : response.getReturnValue().owner,
                        testcar : response.getReturnValue().testCardId, 
                        optid : response.getReturnValue().OptId,
                        carusetype: response.getReturnValue().carUseType,
                        driveStatus : response.getReturnValue().driveStatus,
                        testDrivePerson : response.getReturnValue().testDrivePerson,
                        isReadable : true
                    }
                    $('#calendar').fullCalendar( 'renderEvent', newEvent );
                    component.set('v.isActing', false);
                    helper.closeModal(component, event);
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                                alert(errors[0].message);
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
        var evObj = {
            "title" : component.get('v.TestDriveReservation.Title__c'),
            "startDateTime" : moment(component.get('v.TestDriveReservation.StartTime__c')).format(),
            "endDateTime" : moment(component.get('v.TestDriveReservation.EndTime__c')).format(),
            "description" : component.get('v.TestDriveReservation.Description__c'),
            //"testCardId" : component.get('v.TestDriveReservation.TestCar__c'),
            //"OptId" : component.get('v.TestDriveReservation.Opportunity__c'),
            "testCardId" : component.find("myTestCar").get("v.value"),
            "OptId" : component.find("myOPP").get("v.value"),
            "testDrivePerson" : component.get('v.TestDriveReservation.TestDrivePerson__c'),
            "carUseType" : component.get('v.TestDriveReservation.CarUseType__c')
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            $('#calendar').fullCalendar( 'removeEvents', component.get('v.idVal') );
        }
        helper.cancelEvent(component, evObj, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isActing', false);
                helper.closeModal(component, event);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
    },
    openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },
    //先回復
    closeModal : function(component, event, helper) {
        component.set('v.isLocked', false);
        component.set('v.idVal','');
        component.set('v.TestDriveReservation.Description__c','');
        component.set('v.TestDriveReservation.StartTime__c','');
        component.set('v.TestDriveReservation.EndTime__c','');
        component.set('v.TestDriveReservation.CarUseType__c','');
        component.set('v.TestDriveReservation.TestDriveStatus__c', '');
        component.set('v.TestDriveReservation.TestDrivePerson__c', '');
        component.find("myOPP").set("v.value",'');
        component.find("myTestCar").set("v.value",'');	
    	helper.closeModal(component, event);
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
	},
    openActionWindow : function(component, event, helper) {
        var testDriveId = component.get('v.idVal');
        
		window.open("https://pangerman--c.ap5.visual.force.com/apex/takesurvey?id=a077F000002jpAQQAY&oppid="+testDriveId);
	}
})