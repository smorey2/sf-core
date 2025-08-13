/**
* UserInfo method extensions
*/
global class UserInfoX {
    static Boolean s_isPersonAccountOrganization;
    static Boolean s_isSandboxOrganization;
    static Boolean s_isStateAndCountryPicklistOrganization;
    
    /**
    * specifies whether the organization has person accounts
    */
    global static Boolean isPersonAccountOrganization() {
        if (s_isPersonAccountOrganization != null) return s_isPersonAccountOrganization;
        s_isPersonAccountOrganization = Schema.SObjectType.Account.fields.getMap().containsKey('IsPersonAccount');
        return s_isPersonAccountOrganization;
    }

    /**
    * specifies whether the organization is a sandbox
    */
    global static Boolean isSandboxOrganization() {
        if (s_isSandboxOrganization != null) return s_isSandboxOrganization;
        s_isSandboxOrganization = [SELECT IsSandbox FROM Organization LIMIT 1]?.IsSandbox == true;
        return s_isSandboxOrganization;
    }

    /**
    * specifies whether the organization has state & country picklists
    */
    global static Boolean isStateAndCountryPicklistOrganization() {
        if (s_isStateAndCountryPicklistOrganization != null) return s_isStateAndCountryPicklistOrganization;
        s_isStateAndCountryPicklistOrganization = Schema.SObjectType.Account.fields.getMap().containsKey('BillingStateCode');
        return s_isStateAndCountryPicklistOrganization;
    }

    /**
    * gets the service user
    * @param type the type
    * @return User
    */
    global static User getServiceUser(String type) {
        String alias = Core.options.serviceUserAlias(type);
        return alias != null ? [SELECT Id, Name FROM User WHERE Alias = :alias LIMIT 1] : null;
    }
}