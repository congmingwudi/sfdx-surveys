public without sharing class SurveyResponseTriggerHandler {

    public static void handle(List<SurveyResponse> surveyResponses) {
        
        System.debug('SurveyResponseTriggerHandler > handle');

        // get all the responses, that are completed
        Set<Id> responseIds = new Set<Id>();
        for (SurveyResponse sr : surveyResponses)
        {        
            if (sr.Status == 'Completed')
            {
                responseIds.add(sr.Id);
                System.debug('SurveyResponseTrigger > response completed: ' + sr);
                
                // post to chatter
                /**
                User user = [SELECT Id FROM User WHERE FirstName='Stacey' AND LastName='Coderre' LIMIT 1];
                System.debug('SurveyResponseTrigger > user for chatter post: ' + user);
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(
                    Network.getNetworkId(), 
                    user.Id, 
                    ConnectApi.FeedElementType.FeedItem,
                    'Survey response submitted: ' + sr.Name); 
                **/ 
            }
        }
    
        // are there any responses that we need to process?
        if (responseIds.size() > 0)
        {
            
                                    
            
            // get the question responses for the responses
            // for the correct type to score, 'Rating' is of interest here
            List<SurveyQuestionResponse> sqrs = [SELECT ResponseShortText, InvitationId
                                                 FROM SurveyQuestionResponse
                                                 WHERE Question.QuestionType = 'Rating'
                                                 AND ResponseId in :responseIds];
            
            // are there any cases we need to process?
            if (sqrs.size() > 0)
            {
                // gather all the Cases that are under consideration
                Set<Id> inviteIds = new Set<Id>();
                for (SurveyQuestionResponse sqr : sqrs)
                {
                    inviteIds.add(sqr.InvitationId);
                }
                
                // get the invitations
                List<SurveyInvitation> inviteList = [SELECT Id, Score__c
                                                     FROM SurveyInvitation
                                                     WHERE Id in :inviteIds];
                Map<Id, SurveyInvitation> inviteMap = new Map<Id, SurveyInvitation>(inviteList);
                
                // add the values of the question response to the cases
                for (SurveyQuestionResponse sqr : sqrs)
                {
                    SurveyInvitation inv = inviteMap.get(sqr.InvitationId);
                    String scoreStr = sqr.ResponseShortText;
                    if (String.isNotBlank(scoreStr))
                    {
                        Double score = Double.valueOf(scoreStr);
                        if (inv.Score__c == null)
                        {
                            inv.Score__c = score;
                        }
                        else
                        {
                            inv.Score__c = inv.Score__c + score;
                        }
                    }
                }
                
                // update the cases
                update inviteList;
            }
        }        
        
    } // end handle
}