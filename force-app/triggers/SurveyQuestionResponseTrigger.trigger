/**
 * Created by ryan.cox on 2019-03-03.
 */

trigger SurveyQuestionResponseTrigger on SurveyQuestionResponse (after insert) {

    SurveyQuestionResponseTriggerHandler.handle(Trigger.New);

} // end SurveyQuestionResponseTrigger