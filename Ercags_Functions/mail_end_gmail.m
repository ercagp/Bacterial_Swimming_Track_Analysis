function mail_end_gmail(recipient,data_label)

setpref('Internet', 'SMTP_Server',   'smtp.gmail.com');
setpref('Internet', 'E_mail','tautelab@gmail.com');
setpref('Internet', 'SMTP_Username', 'tautelab');
setpref('Internet', 'SMTP_Password', 'theyswim');

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth',                'true');  % Note: 'true' as a string, not a logical value!
props.setProperty('mail.smtp.starttls.enable',     'true');  % Note: 'true' as a string, not a logical value!
props.setProperty('mail.smtp.socketFactory.port',  '465');   % Note: '465'  as a string, not a numeric value!
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');

subject = ['The tracking of ' data_label ' has ended'];  
msg = ['This is the notification for the 3D tracking of the video ',...
     '"' data_label,'".' newline...
    'The tracking has finished on ' datestr(datetime) '.' newline,...
    'Please check the local computer ' getenv('computername') '.'];

sendmail(recipient,subject,msg)
end