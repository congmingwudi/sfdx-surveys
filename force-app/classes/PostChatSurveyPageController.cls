/**
 * Created by ryan.cox on 2019-02-26.
 */

public without sharing class PostChatSurveyPageController {

    public String caseID { get; set; }
    public String surveyInvitationLink { get; set; }

    public PostChatSurveyPageController() {

        if (System.currentPageReference() != null) {

            // attachedRecords ex. {"CaseId":"5001U00000656scQAA","ContactId":"0031U00000C1e1xQAB"}
            String attachedRecordsJSON = System.currentPageReference().getParameters().get('attachedRecords');
            System.debug('PostChatSurveyPageController > attachedRecordsJSON: ' + attachedRecordsJSON);
            
            if (attachedRecordsJSON != null) {
                
                // parse attachedRecords for CaseId
                JSONParser parser = JSON.createParser(attachedRecordsJSON);
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CaseId')) {
                        parser.nextToken();
                        this.caseID = parser.getText();
                    }
                }
                System.debug('PostChatSurveyPageController > CaseID: ' + caseID);
                
                // get surveyInvitationLink from the case
                if (caseID != null) {
                    Case theCase = [SELECT SurveyInvitationLink__c FROM Case Where Id = :caseID LIMIT 1];
                    this.surveyInvitationLink = theCase.SurveyInvitationLink__c;
                }
                
            } // end if attachedRecordsJSON
        } // end while

    } // end constructor

}