({
    getInitialD : function(component, event) {
		var myAction = component.get("c.getReservations");
        
        //傳入event id。
        myAction.setParams({
            TestCarID : event.getParam("PassCar")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.relatedList",response.getReturnValue());
                component.set("v.relatedList2",response.getReturnValue());
                
                var eventsMap = component.get("v.relatedList2");
                $(document).ready(function(){
                    //印之前先把calendar 燒毀。
                    $('#calendar').fullCalendar('destroy');
                    var eventArray = [];
                    $.each(eventsMap, function(index, value){
                        var tempColor = "lightBlue";
                        if(value.TestDriveStatus__c==="使用中" || value.TestDriveStatus__c==="維修中")
                        {
                            tempColor = "Red";
                        }
                        if(value.TestDriveStatus__c==="已還車" || value.TestDriveStatus__c==="已完成")
                        {
                            tempColor = "Silver ";
                        }
                        var newEvent = {
                            id : value.Id,
                            title : value.OwnerName__c ,
                            start : moment(value.StartTime__c),
                            end : moment(value.EndTime__c),
                            description : value.Description__c,
                            owner : value.OwnerName__c, 
                            testcar : value.TestCar__c, 
                            optid : value.Opportunity__c,
                            carusetype: value.CarUseType__c,
                            isReadable : value.isReadable__c,
                            driveStatus : value.TestDriveStatus__c,
                            testDrivePerson : value.TestDrivePerson__c,
                            color: tempColor
                        }
                        eventArray.push(newEvent);
                    });
                    $('#calendar').fullCalendar({
                        header: {
                            left: 'today prev,next',
                            center: 'title',
                            right: 'agendaDay,agendaWeek,month'
                        },
                        defaultDate: moment().format("YYYY-MM-DD"),
                        defaultView: 'agendaWeek',
                        firstHour: '07:00:00',
                        minTime: '07:00:00',
                        maxTime: '23:59:59',
                        navLinks: true, // can click day/week names to navigate views
                        editable: false,
                        displayEventTime: false,
                        eventLimit: true, // allow "more" link when too many events
                        weekends: true,
                        eventBackgroundColor: '#CFEBFE',
                        eventBorderColor: '#ffffff',
                        eventTextColor: '#00396b',
                        events: eventArray,
                        
                        eventClick: function(calEvent, jsEvent, view) {
                            if(calEvent.isReadable)
                            {
                                if(calEvent.driveStatus != '已預約')
                                {
                                	component.set('v.isClosed', true);    
                                }
                                else
                                {
                                    component.set('v.isClosed', false);    
                                }
                                
                                component.set('v.idVal', calEvent.id);
                                component.set('v.isLocked', true);
                                component.set('v.TestDriveReservation.Title__c', calEvent.title);
                                component.set('v.TestDriveReservation.Description__c', calEvent.description);
                                component.set('v.TestDriveReservation.StartTime__c', moment(calEvent.start._d).format());
                                component.set('v.TestDriveReservation.EndTime__c', moment(calEvent.end._d).format());
                                
                                component.find("InputSelectDynamic1").set("v.value",moment(calEvent.start._d).format('HH:mm'));
								component.find("InputSelectDynamic2").set("v.value",moment(calEvent.end._d).format('HH:mm'));
                                
                                component.set('v.TestDriveReservation.CarUseType__c', calEvent.carusetype);
                                component.set('v.TestDriveReservation.TestDriveStatus__c', calEvent.driveStatus);
                                
                                component.set('v.TestDriveReservation.TestDrivePerson__c', calEvent.testDrivePerson);
                                
                                component.find("myOPP").set("v.value",calEvent.optid);
                                component.find("myTestCar").set("v.value",calEvent.testcar);
                                
                                var modal = component.find('modal');
                                $A.util.addClass(modal, 'slds-fade-in-open');
                                var backdrop = component.find('backdrop');
                                $A.util.addClass(backdrop, 'slds-backdrop--open');
                            }
                            else
                            {
                                alert('No permission.');
                            }
                            
                        },
                        eventDrop: function(event, delta, revertFunc) {
                        },
                        eventResize: function(event, delta, revertFunc) {
                        },
                        dayClick: function(date, jsEvent, view) {
                            alert('請先選擇試駕車輛。');
                        }
                    });
                });
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
	},
	getReservations : function(component, event) {
		var myAction = component.get("c.getReservations");
        
        //傳入event id。
        myAction.setParams({
            TestCarID : event.getParam("PassCar")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.relatedList",response.getReturnValue());
                component.set("v.relatedList2",response.getReturnValue());
                
                var eventsMap = component.get("v.relatedList2");
                $(document).ready(function(){
                    //印之前先把calendar 燒毀。
                    $('#calendar').fullCalendar('destroy');
                    var eventArray = [];
                    $.each(eventsMap, function(index, value){
                        //alert(value.isReadable__c);
                        var tempColor = "lightBlue";
                        if(value.TestDriveStatus__c==="使用中" || value.TestDriveStatus__c==="維修中")
                        {
                            tempColor = "Red";
                        }
                        if(value.TestDriveStatus__c==="已還車" || value.TestDriveStatus__c==="已完成")
                        {
                            tempColor = "Silver ";
                        }
                        var newEvent = {
                            id : value.Id,
                            title : value.OwnerName__c ,
                            start : moment(value.StartTime__c),
                            end : moment(value.EndTime__c),
                            description : value.Description__c,
                            owner : value.OwnerName__c, 
                            testcar : value.TestCar__c, 
                            optid : value.Opportunity__c,
                            carusetype: value.CarUseType__c,
                            isReadable : value.isReadable__c,
                            driveStatus : value.TestDriveStatus__c,
                            testDrivePerson : value.TestDrivePerson__c,
                            color: tempColor
                        }
                        eventArray.push(newEvent);
                    });
                    $('#calendar').fullCalendar({
                        header: {
                            left: 'today prev,next',
                            center: 'title',
                            right: 'agendaDay,agendaWeek,month'
                        },
                        defaultDate: moment().format("YYYY-MM-DD"),
                        defaultView: 'agendaWeek',
                        firstHour: '07:00:00',
                        minTime: '07:00:00',
                        maxTime: '23:59:59',
                        navLinks: true, // can click day/week names to navigate views
                        editable: false,
                        displayEventTime: false,
                        eventLimit: true, // allow "more" link when too many events
                        weekends: true,
                        eventBackgroundColor: '#CFEBFE',
                        eventBorderColor: '#ffffff',
                        eventTextColor: '#00396b',
                        events: eventArray,
                        
                        eventClick: function(calEvent, jsEvent, view) {
                            if(calEvent.isReadable)
                            {
                                if(calEvent.driveStatus != '已預約')
                                {
                                    component.set('v.isClosed', true);    
                                }
                                else
                                {
                                    component.set('v.isClosed', false);    
                                }
                                component.set('v.idVal', calEvent.id);
                                component.set('v.isLocked', true);
                                
                                component.set('v.TestDriveReservation.Title__c', calEvent.title);
                                component.set('v.TestDriveReservation.Description__c', calEvent.description);
                                component.set('v.TestDriveReservation.StartTime__c', moment(calEvent.start._d).format());
                                component.set('v.TestDriveReservation.EndTime__c', moment(calEvent.end._d).format());
                                
                                component.find("InputSelectDynamic1").set("v.value",moment(calEvent.start._d).format('HH:mm'));
								component.find("InputSelectDynamic2").set("v.value",moment(calEvent.end._d).format('HH:mm'));
                                
                                component.set('v.TestDriveReservation.CarUseType__c', calEvent.carusetype);
                                component.set('v.TestDriveReservation.TestDriveStatus__c', calEvent.driveStatus);
								component.set('v.TestDriveReservation.TestDrivePerson__c', calEvent.testDrivePerson);
                                component.find("myOPP").set("v.value",calEvent.optid);
                                component.find("myTestCar").set("v.value",calEvent.testcar);

                                var modal = component.find('modal');
                                $A.util.addClass(modal, 'slds-fade-in-open');
                                var backdrop = component.find('backdrop');
                                $A.util.addClass(backdrop, 'slds-backdrop--open');
                            }
                            else
                            {
                                alert('No permission.');
                            }
                            
                        },
                        eventDrop: function(event, delta, revertFunc) {
                            var evObj = {
                                "Id" : event.id,
                                "title" : event.title,
                                "startDateTime" : moment(event.start._i).add(delta).format(),
                                "endDateTime" : moment(event.end._i).add(delta).format(),
                                "description" : event.description
                            };
                            
                            var action = component.get("c.upsertEvents");
                            action.setParams({ 
                                "sEventObj": JSON.stringify(evObj)
                            });
  
                            $A.enqueueAction(action);
                        },
                        eventResize: function(event, delta, revertFunc) {
                            var evObj = {
                                "Id" : event.id,
                                "title" : event.title,
                                "startDateTime" : moment(event.start._i).format(),
                                "endDateTime" : moment(event.end._i).add(delta).format(),
                                "description" : event.description
                            };
                            var action = component.get("c.upsertEvents");
                            action.setParams({ 
                                "sEventObj": JSON.stringify(evObj)
                            });

                            $A.enqueueAction(action);
                        },
                        dayClick: function(date, jsEvent, view) {
                            var ttday = new Date();
                            
                            if(moment(date).isBefore(moment(ttday), 'day'))
                            {
                                alert('不能選擇今天以前的時間。');
                            }
                            else
                            {
                                if (date._f == "YYYY-MM-DD"){
                                    component.set('v.TestDriveReservation.StartTime__c', moment(date.format()).add(12, 'hours').format());
                                    component.set('v.TestDriveReservation.EndTime__c', moment(date.format()).add(14, 'hours').format()); 
                                    component.find("InputSelectDynamic1").set("v.value",moment(date.format()).add(12, 'hours').format('HH:mm'));
                                    component.find("InputSelectDynamic2").set("v.value",moment(date.format()).add(14, 'hours').format('HH:mm'));
                                } else {
                                    component.set('v.TestDriveReservation.StartTime__c', moment(date.format()).format());
                                    component.set('v.TestDriveReservation.EndTime__c', moment(date.format()).add(2, 'hours').format());
                                    component.find("InputSelectDynamic1").set("v.value",moment(date.format()).format('HH:mm'));
                                    component.find("InputSelectDynamic2").set("v.value",moment(date.format()).add(2, 'hours').format('HH:mm'));
                                    
                                }
                                
                                var oppId = component.get('v.OpportunityID');
                                if(oppId != '')
                                {
                                    component.find("myOPP").set("v.value",oppId);
                                }
                                
                                if(component.get('v.Get_Result9') != '')
                                {
                                    component.find("myTestCar").set("v.value",component.get('v.Get_Result9'));
                                }
                                component.set('v.isClosed', false);
                                
                                var modal = component.find('modal');
                                $A.util.addClass(modal, 'slds-fade-in-open');
                                var backdrop = component.find('backdrop');
                                $A.util.addClass(backdrop, 'slds-backdrop--open');
                            }
                        }
                    });
                });
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
	},
    upsertEvent : function(component, evObj, callback) {
        var action = component.get("c.upsertEvents");
        
        action.setParams({ 
            "sEventObj": JSON.stringify(evObj)
        });
        
        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    cancelEvent : function(component, evObj, callback) {
        var action = component.get("c.cancelEvents");
        
        action.setParams({ 
            "sEventObj": JSON.stringify(evObj)
        });
        
        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    getLabels : function(component, event) {
    	var myAction = component.get("c.showMeTheFieldLabel");
        
        myAction.setParams({ 
            objectAPI : "TestDriveReservation__c"
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.reservationLabels",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
    },
    getTestCarLabels : function(component, event) {
    	var myAction = component.get("c.showMeTheFieldLabel");
        
        myAction.setParams({ 
            objectAPI : "TestCar__c"
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.testCarLabels",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
    },
    getTestCarInfo : function(component, event) {
    	var myAction = component.get("c.getTestCarInfo");
        
        myAction.setParams({ 
            TestCarId : event.getParam("PassCar")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.theTestCar",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
    },
    myOPPName : function(component, event) {
    	var myAction = component.get("c.getOPPName");
        
        myAction.setParams({ 
            OPPId : component.get('v.myOPPId')
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var changeMe = component.get('v.idVal');
                if(changeMe === undefined || changeMe === '')
                {
                	component.set('v.TestDriveReservation.TestDrivePerson__c', response.getReturnValue());
                }
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
    },
    openModal : function(component, event) {
        var modal = component.find('modal');
        $A.util.addClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.addClass(backdrop, 'slds-backdrop--open');
    },
    closeModal : function(component, event) {
        component.set('v.idVal', '');
        component.set('v.errorMessage', '');
        
        var cmpTargetMyTestCar = component.find('myTestCar');
        $A.util.removeClass(cmpTargetMyTestCar, 'redLine');
        var cmpTargetMyOPP = component.find('myOPP');
        $A.util.removeClass(cmpTargetMyOPP, 'redLine');
        var cmpTargetCarType = component.find('carType');
        $A.util.removeClass(cmpTargetCarType, 'redLine');
        var cmpTargetDescription = component.find('description');
        $A.util.removeClass(cmpTargetDescription, 'redLine');
        var cmpTargetInputSelectDynamic1 = component.find('InputSelectDynamic1');
        $A.util.removeClass(cmpTargetInputSelectDynamic1, 'redLine');
        var cmpTargetInputSelectDynamic2 = component.find('InputSelectDynamic2');
        $A.util.removeClass(cmpTargetInputSelectDynamic2, 'redLine');
        
		var modal = component.find('modal');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
    },
    timePicklist: function(component, event, helper) {
        //太笨了，無法共用option。
        var opts1 = [
            { class: "optionClass", label: "07:00", value: "07:00"},
            { class: "optionClass", label: "07:30", value: "07:30"},
            { class: "optionClass", label: "08:00", value: "08:00"},
            { class: "optionClass", label: "08:30", value: "08:30"},
            { class: "optionClass", label: "09:00", value: "09:00"},
            { class: "optionClass", label: "09:30", value: "09:30"},
            { class: "optionClass", label: "10:00", value: "10:00"},
            { class: "optionClass", label: "10:30", value: "10:30"},
            { class: "optionClass", label: "11:00", value: "11:00"},
            { class: "optionClass", label: "11:30", value: "11:30"},
            { class: "optionClass", label: "12:00", value: "12:00"},
            { class: "optionClass", label: "12:30", value: "12:30"},
            { class: "optionClass", label: "13:00", value: "13:00"},
            { class: "optionClass", label: "13:30", value: "13:30"},
            { class: "optionClass", label: "14:00", value: "14:00"},
            { class: "optionClass", label: "14:30", value: "14:30"},
            { class: "optionClass", label: "15:00", value: "15:00"},
            { class: "optionClass", label: "15:30", value: "15:30"},
            { class: "optionClass", label: "16:00", value: "16:00"},
            { class: "optionClass", label: "16:30", value: "16:30"},
            { class: "optionClass", label: "17:00", value: "17:00"},
            { class: "optionClass", label: "17:30", value: "17:30"},
            { class: "optionClass", label: "18:00", value: "18:00"},
            { class: "optionClass", label: "18:30", value: "18:30"},
            { class: "optionClass", label: "19:00", value: "19:00"},
            { class: "optionClass", label: "19:30", value: "19:30"},
            { class: "optionClass", label: "20:00", value: "20:00"},
            { class: "optionClass", label: "20:30", value: "20:30"},
            { class: "optionClass", label: "21:00", value: "21:00"},
            { class: "optionClass", label: "21:30", value: "21:30"},
            { class: "optionClass", label: "22:00", value: "22:00"},
            { class: "optionClass", label: "22:30", value: "22:30"},
            { class: "optionClass", label: "23:00", value: "23:00"},
            { class: "optionClass", label: "23:30", value: "23:30"}
        ];
        var opts2 = [
            { class: "optionClass", label: "00:00", value: "00:00"},
            { class: "optionClass", label: "07:00", value: "07:00"},
            { class: "optionClass", label: "07:30", value: "07:30"},
            { class: "optionClass", label: "08:00", value: "08:00"},
            { class: "optionClass", label: "08:30", value: "08:30"},
            { class: "optionClass", label: "09:00", value: "09:00"},
            { class: "optionClass", label: "09:30", value: "09:30"},
            { class: "optionClass", label: "10:00", value: "10:00"},
            { class: "optionClass", label: "10:30", value: "10:30"},
            { class: "optionClass", label: "11:00", value: "11:00"},
            { class: "optionClass", label: "11:30", value: "11:30"},
            { class: "optionClass", label: "12:00", value: "12:00"},
            { class: "optionClass", label: "12:30", value: "12:30"},
            { class: "optionClass", label: "13:00", value: "13:00"},
            { class: "optionClass", label: "13:30", value: "13:30"},
            { class: "optionClass", label: "14:00", value: "14:00"},
            { class: "optionClass", label: "14:30", value: "14:30"},
            { class: "optionClass", label: "15:00", value: "15:00"},
            { class: "optionClass", label: "15:30", value: "15:30"},
            { class: "optionClass", label: "16:00", value: "16:00"},
            { class: "optionClass", label: "16:30", value: "16:30"},
            { class: "optionClass", label: "17:00", value: "17:00"},
            { class: "optionClass", label: "17:30", value: "17:30"},
            { class: "optionClass", label: "18:00", value: "18:00"},
            { class: "optionClass", label: "18:30", value: "18:30"},
            { class: "optionClass", label: "19:00", value: "19:00"},
            { class: "optionClass", label: "19:30", value: "19:30"},
            { class: "optionClass", label: "20:00", value: "20:00"},
            { class: "optionClass", label: "20:30", value: "20:30"},
            { class: "optionClass", label: "21:00", value: "21:00"},
            { class: "optionClass", label: "21:30", value: "21:30"},
            { class: "optionClass", label: "22:00", value: "22:00"},
            { class: "optionClass", label: "22:30", value: "22:30"},
            { class: "optionClass", label: "23:00", value: "23:00"},
            { class: "optionClass", label: "23:30", value: "23:30"},
            { class: "optionClass", label: "24:00", value: "24:00"}
        ];

        component.find("InputSelectDynamic1").set("v.options", opts1);
        component.find("InputSelectDynamic2").set("v.options", opts2);
    },
})