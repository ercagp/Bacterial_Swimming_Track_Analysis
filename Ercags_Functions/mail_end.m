function mail_end(recipient,data_label)

setpref('Internet', 'SMTP_Server',   'netrider.rowland.org');
setpref('Internet', 'E_mail','epince@rowland.harvard.edu');
setpref('Internet', 'SMTP_Username', 'epince');
setpref('Internet', 'SMTP_Password', '');

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth',                'true');  % Note: 'true' as a string, not a logical value!
props.setProperty('mail.smtp.starttls.enable',     'true');  % Note: 'true' as a string, not a logical value!
props.setProperty('mail.smtp.socketFactory.port',  '143');   % Note: '465'  as a string, not a numeric value!

subject = ['The tracking of ' data_label ' has ended'];  
msg = ['This is the notification for the 3D tracking of the video ',...
     '"' data_label,'".' newline...
    'The tracking has finished on ' datestr(datetime) '.' newline,...
    'Please check the local computer ' getenv('computername') '.'];

sendmail(recipient,subject,msg)
end