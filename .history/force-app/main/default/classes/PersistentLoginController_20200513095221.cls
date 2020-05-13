/**
* An apex page controller that exposes the site login functionality that keeps users logged in
*/
global without sharing class PersistentLoginController {
    
    global String username {get; set;}
    global String password {get; set;}
    public String startURL {get; set;}
    
    global class passwordLessRet {
    	@AuraEnabled public String userId;
        @AuraEnabled public String identifier;
        @AuraEnabled public String error;
    }

    @AuraEnabled
    public static Uplink_AuraResponse startVerificationProcessForSignUp(String firstName, String lastName, String email) {
        
        Uplink_AuraResponse retRes = new Uplink_AuraResponse();
        Map<String, String> errors = new Map<String, String>();
        Map<String,String> codeMapUser = new Map<String,String>();
        List<User> usrs = [select id, Email from User where Email =: email and IsActive =: true];
        try{
            User u = new User();        
            u.username = emailOrPhone;
            u.email = emailOrPhone;
            u.lastName = lastName;
            u.firstName = firstName;
            String alias = firstName;
            if (alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.alias = alias;
            u.emailEncodingKey = '';
            u.profileId = '';
            u.CommunityNickname = firstName.substring(0, 1) + lastName.substring(0, 1) + String.valueOf(userCount);
            u.contactId = cont[0].Id;
            String verificationID;
            verificationID = System.UserManagement.initSelfRegistration(Auth.VerificationMethod.EMAIL, u);
            codeMapUser.put('verificationID', verificationID);    
            retRes.setAuraResult((object)codeMapUser);
            retRes.setStatus('OK');
        } catch(exception ex){
            errors.put('Exception' , ex.getMessage());            
            retRes.setStatus('FAIL');
            retRes.seterrors(errors);
        }
        return retRes  ;
    }


    @AuraEnabled(cacheable=true)
    global static String passwordlessLWC(String input, String startURL) { 
        ResponseWrapper ret = new ResponseWrapper();
        String error = '';
        String identifier = '';
        ID uid;
        try {
            List<User> users = null;
            users = [select name, id, email from User where username=:input];
            uid = users[0].id;
            identifier = System.UserManagement.initPasswordlessLogin(uid, Auth.VerificationMethod.EMAIL);
        } catch (Exception e) {
            error += e.getMessage();   
        }
        ret.userId = uid;
        ret.identifier = identifier;
        ret.error = error;
        return JSON.serialize(ret);
    }     
	
   @AuraEnabled(cacheable=false)
   global static String confirm(String userId, String identifier, String code, String startUrl) {
       String message = 'error in confirmation';
       String url = '';
       try {
       	Auth.VerificationResult res = System.UserManagement.verifyPasswordlessLogin(userId, Auth.VerificationMethod.EMAIL, identifier, code, '/s/');
       //system.debug(res);
       //aura.redirect(res.redirect);
            url = res.redirect.getUrl();
       //String encoded = EncodingUtil.urlEncode(url, 'UTF-8');
      		message =  res.message;
       } catch (Exception e) {
           
       }
       return url ;
	}       
    
    public class ResponseWrapper {
        public String userId;
        public String identifier;
        public String error;
    }

        
}