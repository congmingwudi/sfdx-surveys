({
    // Client-side function that invokes the subscribe method on the empApi component.
    subscribe: function (component, event, helper) {

        // Get the empApi component.
        const empApi = component.find('empApi');

        // Get the channel from the attribute.
        const channel = component.get('v.channel');

        // Subscription option to get only new events.
        const replayId = -1;

        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console. A helper method displays the message
        // in the console app.
        const callback = function (message) {
          	console.log('PlatformEvent_NotificationConsoleHelper > event received: ' + JSON.stringify(message));
          	helper.onReceiveNotification(component, message);
        };

        // Subscribe to the channel and save the returned subscription object.
        console.log('PlatformEvent_NotificationConsoleHelper > subscribing to channel: ' + channel);
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
            console.log('PlatformEvent_NotificationConsoleHelper > subscribed to channel: ' + channel);
          	component.set('v.subscription', newSubscription);
        }));
    },

    // Client-side function that invokes the unsubscribe method on the empApi component.
    unsubscribe: function (component, event, helper) {

        // Get the empApi component.
        const empApi = component.find('empApi');

        // Get the channel from the component attribute.
        const channel = component.get('v.subscription').channel;

        // Callback function to be passed in the unsubscribe call.
        const callback = function (message) {
            console.log('PlatformEvent_NotificationConsoleHelper > unsubscribed from channel: ' + message.channel);
        };

        // Unsubscribe from the channel using the subscription object.
        empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
    },

    // Client-side function that displays the platform event message in the console app and displays a toast if not muted.
    onReceiveNotification: function (component, message) {

        var payload = message.data.payload;

        // Extract notification from platform event
        const newNotification = {
          	time: $A.localizationService.formatDateTime(message.data.payload.CreatedDate, 'HH:mm'),
          	message: 'Low NPS (' + payload.NPS_Text__c + ')',
            surveyInvitationID: payload.Survey_Invitation_ID__c,
          	caseID: payload.Case_ID__c,
          	caseNumber: payload.Case_Number__c,
          	contactID: payload.Contact_ID__c,
            contactName: payload.Contact_First_Name__c + ' ' + payload.Contact_Last_Name__c
        };
        console.log('PlatformEvent_NotificationConsoleHelper > newNotification: ' + JSON.stringify(newNotification));

        // Save notification in history
        const notifications = component.get('v.notifications');
        notifications.push(newNotification);
        component.set('v.notifications', notifications);

        // Display notification in a toast
        var toastMessage = newNotification.message + ' received from ' + newNotification.contactName;
        this.displayToast(component, 'info', toastMessage);
    },

    // Displays the given toast message.
    displayToast: function (component, type, message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
          type: type,
          message: message
        });
        toastEvent.fire();
    },
    
    navigateToRecord : function(recordID) {

        console.log('PlatformEvent_NotificationConsoleHelper > navigateToRecord - recordID: ' + recordID);
     
        var nav = $A.get("e.force:navigateToSObject");
        if (nav) {
            nav.setParams({
                "recordId": recordID,
                "slideDevName": "detail"
            });
            nav.fire(); 
        }
        
   	}, // end navigateToRecord 

})