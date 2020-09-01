public without sharing class SurveyQuestionResponseTriggerHandler {

    public static void handle(List<SurveyQuestionResponse> questionResponses) {
        
        List<SFDC_Survey_Question_Response__c> shadowQuestionResponses = new List<SFDC_Survey_Question_Response__c>();
    
        System.debug('SurveyQuestionResponseTrigger > questionResponses: ' + questionResponses.size());
    
        for (SurveyQuestionResponse questionResponse : questionResponses) {
    
            System.debug('SurveyQuestionResponseTrigger > questionResponse: ' + questionResponse);
    
            SFDC_Survey_Question_Response__c shadowQuestionResponse = new SFDC_Survey_Question_Response__c();
            shadowQuestionResponse.Survey_Invitation__c = questionResponse.InvitationId;
            shadowQuestionResponse.Survey_Question__c = questionResponse.QuestionId;
    
            SurveyQuestion question = [SELECT Name, QuestionType, SurveyPageId FROM SurveyQuestion
                WHERE Id = :questionResponse.QuestionId LIMIT 1];
            
            //SurveyPage page = [SELECT Name FROM SurveyPage
            //    WHERE Id = :question.SurveyPageId LIMIT 1];
    
            shadowQuestionResponse.Question__c = question.Name;
            
            String textResponse = questionResponse.ResponseShortText;
    
            if ((questionResponse.Datatype == 'Number')
                    || (question.QuestionType == 'Slider') || (question.QuestionType == 'NPS') || (question.QuestionType == 'Rating')                    
					) {
                Integer numberResponse = Integer.valueof(textResponse);
                shadowQuestionResponse.Number_Response__c = numberResponse;
            } else if (questionResponse.Datatype == 'String') {
                shadowQuestionResponse.Text_Response__c = textResponse;
            }
    
            //shadowQuestionResponse.Category__c = page.Name;
            if (question.QuestionType == 'NPS') {
                shadowQuestionResponse.Category__c = 'NPS';
            } else {
                shadowQuestionResponse.Category__c = 'Other';
            }
            
            shadowQuestionResponses.add(shadowQuestionResponse);
    
        } // end for
    
        insert shadowQuestionResponses;        
    } // end handle
    
}