import logging
import os
from string import Template

# Confirm new user
SignUp = "CustomMessage_SignUp"
ResendCode = "CustomMessage_ResendCode"

# Password reset
ForgotPassword = "CustomMessage_ForgotPassword"

# not used
AdminCreateUser = "CustomMessage_AdminCreateUser"
UpdateUserAttribute = "CustomMessage_UpdateUserAttribute"
VerifyUserAttribute = "CustomMessage_VerifyUserAttribute"
MFA = "CustomMessage_Authentication"


def lambda_handler(event, context):
    trigger = event["triggerSource"]
    request = event["request"]

    logging.info('trigger %s request %s', trigger, request)
    if trigger == AdminCreateUser:
        if request['userAttributes']['cognito:user_status'] == 'FORCE_CHANGE_PASSWORD':
            code = event['request']['codeParameter']
            user = event['request']['usernameParameter']
            with open("./new-account.template.html") as file:
                file_contents = file.read()
            template = Template(file_contents)
            email_message = template.substitute({
                'app_name': os.environ.get("APP_NAME", "UNKNOWN_APP"),
                'code': code,
                'username': user,
                'dashboard_link': os.environ.get("DASHBOARD_LINK", "UNKNOWN_DASHBOARD_LINK"),
                'time_dashboard_link': os.environ.get("TIME_LINK", "UNKNOWN_TIME_LINK"),
                'tasks_dashboard_link': os.environ.get("TASKS_LINK", "UNKNOWN_TASKS_LINK")
            })
            event['response']['emailSubject'] = "Your temporary password"
            event['response']['emailMessage'] = email_message
    return event


level = logging.INFO
if logging.getLogger().hasHandlers():
    # The Lambda environment pre-configures a handler logging to stderr
    # ff a handler is already configured,
    # `.basicConfig` does not execute. Thus we set the level directly.
    logging.getLogger().setLevel(level)
else:
    logging.basicConfig(level=level)
