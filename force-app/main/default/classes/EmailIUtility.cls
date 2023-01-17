public without sharing class EmailIUtility{
    //send email from batch for renewal, inactive and dead
    public static void sendEmail(set<Id> recordIds, String templateName, String triggerPoint){
        try{
            system.debug('recordIds-->'+recordIds);
            system.debug('templateName-->'+templateName);
            system.debug('triggerPoint-->'+triggerPoint);
            List<Opportunity> opportunityList = new List<Opportunity>();
            List<Account> accList = new List<Account>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            EmailTemplate emailTempRec = new EmailTemplate();
            
            if (!String.isBlank(TemplateName) && TemplateName != null){
                emailTempRec = [SELECT Id, Subject, HtmlValue, Body
                                FROM EmailTemplate
                                WHERE Name = :TemplateName];
            }
            
            if (!recordIds.isEmpty()){
                system.debug('recordIds-->'+recordIds);
                system.debug('triggerPoint-->'+triggerPoint);
                
                if (triggerPoint == 'RENEWAL'){
                    opportunityList = [Select Id, Account.Name, Account_Email__c, Renewable_Date__c
                                       FROM Opportunity
                                       Where Id In:recordIds];
                } else if (triggerPoint == 'INACTIVE' || triggerPoint == 'DEAD'){
                    accList = [SELECT Id, Name, Status__c, Email__c
                               FROM Account
                               WHERE Id IN:recordIds];
                }
                system.debug('accList-->'+accList);
                system.debug('opportunityList-->'+opportunityList);   
                if (!opportunityList.isEmpty()){
                    for (Opportunity oppRec : opportunityList){
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
                        String[] toAddresses = new String[]{ oppRec.Account_Email__c };
                            email.setToAddresses(toAddresses);
                        
                        String htmlBody = emailTempRec.HtmlValue;
                        
                        if (htmlBody.contains('{!Account.Name}')){
                            htmlBody = htmlBody.replace('{!Account.Name}', oppRec.Account.Name);
                        }
                        if (htmlBody.contains('{!Opportunity.Renewable_Date__c}')){
                            htmlBody = htmlBody.replace('{!Opportunity.Renewable_Date__c}', String.ValueOf(oppRec.Renewable_Date__c));
                        }
                        email.setHtmlBody(htmlBody);
                        email.setSubject(emailTempRec.Subject);
                        emails.add(email);
                    }
                    if (!emails.isEmpty()){
                        Messaging.sendEmail(emails);
                    }
                }
                
                if (!accList.isEmpty()){
                    
                    for (Account accRec : accList){
                        system.debug('accRec-->'+accRec);
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
                        String[] toAddresses = new String[]{ accRec.Email__c };
                            email.setToAddresses(toAddresses);
                        
                        String htmlBody = emailTempRec.HtmlValue;
                        
                        if (htmlBody.contains('{!Account.Name}')){
                            htmlBody = htmlBody.replace('{!Account.Name}', accRec.Name);
                        }
                        
                        email.setHtmlBody(htmlBody);
                        email.setSubject(emailTempRec.Subject);
                        emails.add(email);
                    }
                    system.debug('emails-->'+emails.size());
                    if (!emails.isEmpty()){
                        Messaging.sendEmail(emails);
                    }
                }
            }
        } catch (Exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Errror!!-->' + ex.getLineNumber());
        }
    }
    
    public static void sendEmailForFailureStatus(set<Id> recordIds, String templateName, String objName){
        try{
            List<Opportunity> opportunityList = new List<Opportunity>();
            List<Lead> leadList = new List<Lead>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            EmailTemplate emailTempRec = new EmailTemplate();
            
            if (!String.isBlank(TemplateName) && TemplateName != null){
                emailTempRec = [SELECT Id, Subject, HtmlValue, Body
                                FROM EmailTemplate
                                WHERE Name = :TemplateName];
            }
            system.debug('recordIds-->' + recordIds);
            if (!recordIds.isEmpty()){
                
                if (objName == 'Opportunity'){
                    opportunityList = [Select Id, Account.Name, Account.Email__c, Amount
                                       FROM Opportunity
                                       Where Id In:recordIds];
                } else if (objName == 'Lead'){
                    leadList = [SELECT Id, Name, Email, Amount__c
                                FROM Lead
                                WHERE Id IN:recordIds];
                }
                system.debug('leadList-->' + leadList);
                if (!opportunityList.isEmpty()){
                    for (Opportunity oppRec : opportunityList){
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
                        String[] toAddresses = new String[]{ oppRec.Account.Email__c };
                            email.setToAddresses(toAddresses);
                        
                        String htmlBody = emailTempRec.HtmlValue;
                        
                        htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
                        
                        if (htmlBody.contains('{!Account.Name}')){
                            htmlBody = htmlBody.replace('{!Account.Name}', oppRec.Account.Name);
                        }
                        
                        if (htmlBody.contains('{!Opportunity.Amount}')){
                            htmlBody = htmlBody.replace('{!Opportunity.Amount}', String.ValueOf(oppRec.Amount) != null ? String.ValueOf(oppRec.Amount) : '');
                        }
                        
                        email.setHtmlBody(htmlBody);
                        email.setSubject(emailTempRec.Subject);
                        emails.add(email);
                    }
                    if (!emails.isEmpty()){
                        Messaging.sendEmail(emails);
                    }
                }
                
                if (!leadList.isEmpty()){
                    for (Lead leadRec : leadList){
                        system.debug('leadRec-->' + leadRec);
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
                        String[] toAddresses = new String[]{ leadRec.Email };
                            email.setToAddresses(toAddresses);
                        
                        String htmlBody = emailTempRec.HtmlValue;
                        
                        htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
                        
                        if (htmlBody.contains('{!Lead.Name}')){
                            htmlBody = htmlBody.replace('{!Lead.Name}', leadRec.Name);
                        }
                        if (htmlBody.contains('{!Lead.Amount__c}')){
                            htmlBody = htmlBody.replace('{!Lead.Amount__c}', String.ValueOf(leadRec.Amount__c));
                        }
                        email.setHtmlBody(htmlBody);
                        email.setSubject(emailTempRec.Subject);
                        emails.add(email);
                    }
                    system.debug('emails-->' + emails);
                    if (!emails.isEmpty()){
                        Messaging.sendEmail(emails);
                    }
                }
            }
        } catch (Exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Errror!!-->' + ex.getLineNumber());
        }
    }
    
    public static void sendEmailForPaymentSuccess(string email, String templateName, String objName, string invoiceId){
        try{
            //Invoice__c invDetails = [select name,Due_Date__c from Invoice__c where Account__r.id =:accId ORDER BY lastmodifieddate DESC limit 1];
            List<Invoice__c> invoiceDetails = new List<Invoice__c>();
            List<Lead> leadList = new List<Lead>();
            system.debug('email-->' + email);
            system.debug('invoiceId-->' + invoiceId);
            EmailTemplate et = [Select id, Name, DeveloperName, Subject, Body, HtmlValue
                                from EmailTemplate
                                where name = :templateName];
            Attachment files = [SELECT Name, Body, ContentType
                                FROM Attachment
                                WHERE ParentId = :invoiceId
                                ORDER BY lastmodifieddate DESC
                                limit 1];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            system.debug('mails' + mails);
            if (objName == 'Opportunity'){
                invoiceDetails = [Select Id, Opportunity__r.Account.Name, Opportunity__r.Account.Email__c, Amount__c, Opportunity__r.Amount
                                  FROM Invoice__c
                                  Where Id = :invoiceId
                                  limit 1];
            } else if (objName == 'Lead'){
                leadList = [SELECT Id, Name, Email, Amount__c
                            FROM Lead
                            WHERE Id = :invoiceId];
            }
            if (!String.isBlank(email)){
                // Step 1
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(files.Name);
                efa.setBody(files.Body);
                efa.setContentType(files.ContentType);
                
                List<String> recipients = new List<String>();
                recipients.add(email);
                system.debug('recipients------' + recipients);
                mail.setToAddresses(recipients);
                mail.setReplyTo('test@email.com');
                mail.setSenderDisplayName('Hirect');
                String subject = et.Subject;
                String htmlBody = et.HtmlValue;
                htmlBody = htmlBody.replace('{!User.Name}', userinfo.getName());
                
                if (htmlBody.contains('{!Account.Name}')){
                    htmlBody = htmlBody.replace('{!Account.Name}', invoiceDetails[0].Opportunity__r.Account.Name);
                }
                
                if (htmlBody.contains('{!Opportunity.Amount}')){
                    htmlBody = htmlBody.replace('{!Opportunity.Amount}', String.ValueOf(invoiceDetails[0].Opportunity__r.Amount) != null ? String.ValueOf(invoiceDetails[0].Opportunity__r.Amount) : '');
                }
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });
                mails.add(mail);
                system.debug('mails :: ' + mails);
            }
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Error Line==>' + e.getLineNumber() + 'Error Message==>' + e.getMessage());
        }
    }
    
    Public Static void SendEmailOnOppCreation(set<Id> recordIds, String templateName){
        system.debug('recordIds :: ' + recordIds);
        try{
            List<Opportunity> opportunityList = new List<Opportunity>();
            List<task> taskListToBeInserted = new List<task>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            EmailTemplate emailTempRec = new EmailTemplate();
            
            if (!String.isBlank(TemplateName) && TemplateName != null){
                emailTempRec = [SELECT Id, Subject, HtmlValue, Body
                                FROM EmailTemplate
                                WHERE Name = :TemplateName];
            }
            system.debug('emailTempRec :: ' + emailTempRec);
            if (!recordIds.isEmpty()){
                opportunityList = [Select Id, Account.Name, Account_Email__c, Renewable_Date__c, name, ownerId
                                   FROM Opportunity
                                   Where Id In:recordIds];
                
                if (!opportunityList.isEmpty()){
                    for (Opportunity oppRec : opportunityList){
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[]{ oppRec.Account_Email__c };
                            email.setToAddresses(toAddresses);
                        String htmlBody = emailTempRec.HtmlValue;
                        
                        if (htmlBody.contains('{!Opportunity.Name}')){
                            htmlBody = htmlBody.replace('{!Opportunity.Name}', oppRec.Name);
                        }
                        system.debug('htmlBody :: ' + htmlBody);
                        email.setHtmlBody(htmlBody);
                        email.setSubject(emailTempRec.Subject);
                        system.debug('email :: ' + email);
                        emails.add(email);
                        
                        
                        // ========================= Task Creation on Opportunity Creation ====================
                        task tas = new task();
                        tas.WhatId = oppRec.Id;
                        tas.OwnerId = oppRec.OwnerId;
                        tas.Subject = 'Introductory Call with Customer';
                        tas.Status = 'Open';
                        tas.Priority = 'Normal';
                        tas.ActivityDate = date.today();
                        system.debug('Task :: ' + tas);
                        taskListToBeInserted.add(tas);
                    }
                    system.debug('emails :: ' + emails);
                    system.debug('taskListToBeInserted :: ' + taskListToBeInserted);
                    if (!emails.isEmpty()){
                        Messaging.sendEmail(emails);
                    }
                    if (!taskListToBeInserted.isEmpty()){
                        insert taskListToBeInserted;
                    }
                }
            }
        } catch (Exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Errror!!-->' + ex.getLineNumber());
        }
    }
    
    public Static void SendEmailBeforeRenewalDate(list<Opportunity> opportunityList, String templateName){
        try{
            List<task> taskListToBeInserted = new List<task>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTempRec = new EmailTemplate();
            
            if (!String.isBlank(TemplateName) && TemplateName != null){
                emailTempRec = [SELECT Id, Subject, HtmlValue, Body
                                FROM EmailTemplate
                                WHERE Name = :TemplateName];
            }
            
            
            if (!opportunityList.isEmpty()){
                for (Opportunity oppRec : opportunityList){
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[]{ oppRec.Account_Email__c };
                        email.setToAddresses(toAddresses);
                    String htmlBody = emailTempRec.HtmlValue;
                    
                    if (htmlBody.contains('{!Opportunity.Name}')){
                        htmlBody = htmlBody.replace('{!Opportunity.Name}', oppRec.Name);
                    }
                    email.setHtmlBody(htmlBody);
                    email.setSubject(emailTempRec.Subject);
                    system.debug('email :: ' + email);
                    emails.add(email);
                    
                    // ========================= Task Creation for Renewal Opportunity ====================
                    task tas = new task();
                    tas.WhatId = oppRec.Id;
                    tas.OwnerId = oppRec.OwnerId;
                    tas.Subject = Constants.FOLLOWUP_WITHCLIENT_FOR_OPP_RENEWAL;
                    tas.Status = Constants.TASK_STATUS_OPEN;
                    tas.Priority = Constants.TASK_STATUS_NORMAL;
                    tas.ActivityDate = date.today();
                    system.debug('Task :: ' + tas);
                    taskListToBeInserted.add(tas);
                }
                system.debug('emails :: ' + emails);
                system.debug('taskListToBeInserted :: ' + taskListToBeInserted);
                if (!emails.isEmpty()){
                    Messaging.sendEmail(emails);
                }
                if (!taskListToBeInserted.isEmpty()){
                    insert taskListToBeInserted;
                }
            }
        }
        //}
        catch (Exception ex){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Errror!!-->' + ex.getLineNumber());
        }
    }
    public static void sendEmailNotificationForVerifiedLead(string emailTemplate, set<id> leadIds){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();  
        List<Lead> leadList = new  List<Lead>();
        
        if(!leadIds.isEmpty()){
            leadList = [Select FirstName,LastName,Email,Name From Lead Where id in : leadIds ];  
        }
        EmailTemplate emailTemplateRec = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where Name =: emailTemplate];
        
        if(!leadList.isEmpty()){
            for (Lead leadRec : leadList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> recipients = new List<String>();
                
                recipients.add(leadRec.Email);
                mail.setToAddresses(recipients);
                mail.setSenderDisplayName('Hirect');
                //mail.setOrgWideEmailAddressId('info@hirect.cc');
                String htmlBody = emailTemplateRec.HtmlValue;
                
                if( leadRec.Name != null && leadRec.LastName != null){
                    htmlBody = htmlBody.replace('{!Lead.Name}', leadRec.Name);
                }
                mail.setSubject(emailTemplateRec.Subject);
                mail.setHtmlBody(htmlBody);
                mails.add(mail);
            }
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);  
        }
    }
}