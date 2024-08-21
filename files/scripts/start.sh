#!/bin/bash

# Check if a logfile exists
if [[ -e "${LOG}" ]]
then
    # Delete old logfiles
    rm --force "${LOG}" > /dev/null 2>&1

    # Save exit code
    LOG_FILE_DELETED="${?}"

    # Check if old Log File has been deleted
    if [[ "${LOG_FILE_DELETED}" -ne 0 ]]
    then
        # User info
        {
            echo "Old log file could not be deleted!"
            echo "Check the \"LOG\" environment variable or the file permissions of the old logfile (maybe delete it manually)."
            echo "Container exits!"
        } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]'

        # Exit Container
        exit 1
    fi
fi

# Create Log File
/usr/bin/curl --create-dirs --output "${LOG}" file:///dev/null > /dev/null 2>&1

# Save exit code
LOG_FILE_CREATED="${?}"

# Check if Log File has been created
if [[ "${LOG_FILE_CREATED}" -ne 0 ]]
then
    # User info
    {
        echo "Log file (\"${LOG}\") could not be created!"
        echo "Check the \"LOG\" environment variable or the folder permissions."
        echo "Container exits!"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]'

    # Exit Container
    exit 1
fi

# Welcome Message
{
    echo "Welcome to Vdirsyncer DOCKERIZED! :)"
    printf "\n"

    echo "For more information please visit the official docs page."
    echo "There you will also find configuration examples."
    echo "https://vdirsyncer.pimutils.org/en/stable/index.html"
    printf "\n"

    echo "If you have any problems with Vdirsyncer, please"
    echo "visit the Github repo and open an issue."
    echo "https://github.com/pimutils/vdirsyncer"
    printf "\n"

    echo "If there is a problem with the container,"
    echo "contact me or open an issue in my Github repo."
    echo "https://github.com/Bleala/Vdirsyncer-DOCKERIZED"
    echo "I am trying to fix it, so that everything"
    echo "is running as expected. :)"
    printf "\n"

    echo "Enjoy!"
    printf "\n"
} 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

# Starting logging
{
    echo "Starting Logging..."
    printf "\n"
} 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

# Hint if the old logfile has been deleted
if [[ "${LOG_FILE_DELETED}" -eq 0 ]]
then
    # User info
    {
        echo "Old log file has been deleted."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
fi

# Hint if the logfile has been created
if [[ "${LOG_FILE_CREATED}" -eq 0 ]]
then
    # User info
    {
        echo "New log file (\"${LOG}\") has been created."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
fi

# Log current Timezone and Date/Time
{
    echo "Current timezone is ${TZ}."
    echo "Current time is $(date)."
    printf "\n"
} 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

# Check if the config.example exists
if [[ ! -e "/vdirsyncer/config.example" ]]
then
    # Copy config.example to vdirsyncer directory
    cp /files/examples/config.example /vdirsyncer/config.example
    # User info
    {
        echo "config.example has been copied to /vdirsyncer."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
fi

# Check if Autoupdate is enabled
if [[ "${AUTOUPDATE}" == "true" ]]
then
    {
        # User info
        echo "#######################################"
        printf "\n"
        echo "Autoupdate of Vdirsyncer is enabled."
        echo "Starting update..."
        printf "\n"

        # Vdirsyncer update
        PIPX_HOME="${PIPX_HOME}" PIPX_BIN_DIR="${PIPX_BIN_DIR}" pipx upgrade --include-injected vdirsyncer

        # Save exit code of update
        UPDATE_SUCCESSFUL="${?}"

        # Check if update was successful
        if [[ "${UPDATE_SUCCESSFUL}" -eq 0 ]]
        then
            # User info
            printf "\n"
            echo "Vdirsyncer update was successful."
        else
            # User info
            printf "\n"
            echo "Vdirsyncer update FAILED!"
        fi
        
        # End of update
        printf "\n"
        echo "#######################################"
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
fi

# Check, if POST_SYNC_SCRIPT_FILE is set
if [ -z "${POST_SYNC_SCRIPT_FILE}" ]
then
    # User info
    {
        echo "Custom scripts are disabled."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Set Post Sync Snippet to nothing
    POST_SYNC_SNIPPET=""

# Set POST_SYNC_SNIPPET, if  POST_SYNC_SCRIPT_FILE is set
else
    # User info
    {
        echo "Custom scripts are enabled."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Set Post Sync Snippet to Post Sync File
    POST_SYNC_SNIPPET=" ${POST_SYNC_SCRIPT_FILE} || echo Error during Script"
fi

### Apprise Config ###
# Check if Apprise notifications are disabled
if [[ "${APPRISE_ENABLED}" == "false" ]]
then
    # User info
    {
        echo "Apprise is disabled."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Set Apprise Command to nothing
    APPRISE_COMMAND_FINAL=""

# Check if Apprise notifications are enabled
elif [[ "${APPRISE_ENABLED}" == "true" ]]
then
    # User info
    {
        echo "Apprise is enabled."
        printf "\n"
    } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Create the Apprise log file
#    /usr/bin/curl --create-dirs --output "${APPRISE_LOG}" file:///dev/null > /dev/null 2>&1
#    chmod 666 "${APPRISE_LOG}"

    # Save exit code
    APPRISE_LOG_FILE_CREATED="${?}"

    # Check if Apprise log file has not been created
    if [[ "${APPRISE_LOG_FILE_CREATED}" -ne 0 ]]
    then
        # User info
        {
            echo "Apprise log file (\"${APPRISE_LOG}\") could not be created!"
            echo "Check the \"APPRISE_LOG\" environment variable or the folder permissions."
            echo "Container exits!"
        } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

        # Exit Container
        exit 1

    # Check if Apprise log file has been created
    elif [[ "${APPRISE_LOG_FILE_CREATED}" -eq 0 ]]
    then
        # User info
        {
            echo "Apprise log file (\"${APPRISE_LOG}\") has been created."
            printf "\n"
        } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
    fi

    # Check if required apprise variables are set
    if [[ -z "${APPRISE_TITLE}" ]] || [[ -z "${APPRISE_URL}" ]]
    then
        # Check if APPRISE_TITLE is not set
        if [[ -z "${APPRISE_TITLE}" ]]
        then
            # Set missing variable name
            APPRISE_MISSING_VARIABLE_NAME="APPRISE_TITLE"
        fi

        # Check if APPRISE_URL is not set
        if [[ -z "${APPRISE_URL}" ]]
        then
            # Set missing variable name
            APPRISE_MISSING_VARIABLE_NAME="APPRISE_URL"
        fi

        # User info
        {
            echo "The Apprise variable \"${APPRISE_MISSING_VARIABLE_NAME}\" is not set!"
            echo "Please use a valid value."
            echo "Container exits!"
        } 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

        # Exit Container
        exit 1
    fi

    # Check if APPRISE_BODY is not used
    if [[ -z "${APPRISE_BODY}" ]]
    then
        # Set APPRISE_BODY_FINAL to use cat --> pipe
        APPRISE_COMMAND="cat ${APPRISE_LOG} | grep -i -e 'Error' | /usr/local/bin/apprise -vv -t ${APPRISE_TITLE} ${APPRISE_URL} || :"

    # Check if APPRISE_BODY is used
    else
        # Set APPRISE_BODY_FINAL to use user body message
        APPRISE_COMMAND="/usr/local/bin/apprise -vv -t ${APPRISE_TITLE} -b ${APPRISE_BODY} ${APPRISE_URL}"
    fi

    # Set Apprise Command
    APPRISE_COMMAND_FINAL="| ts '[%Y-%m-%d %H:%M:%S]' | tee ${APPRISE_LOG}; ${APPRISE_COMMAND}"
fi

### Set up Cronjobs ###
# Append to crontab file if autodiscover and autosync are true
if [[ "${AUTODISCOVER}" == "true" ]] && [[ "${AUTOSYNC}" == "true" ]]
then
    # Write cronjob to file
    echo "${CRON_TIME} yes | /usr/local/bin/vdirsyncer -c ${VDIRSYNCER_CONFIG} discover \
    && /usr/local/bin/vdirsyncer -c ${VDIRSYNCER_CONFIG} metasync \
    && /usr/local/bin/vdirsyncer -c ${VDIRSYNCER_CONFIG} sync ${POST_SYNC_SNIPPET}" >> "${CRON_FILE}"

    # User info
    echo 'Autodiscover and Autosync are enabled.' 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Check if LOG_LEVEL environment variable is empty
    if [[ -z "${LOG_LEVEL}" ]]
    then
        # Start the cronjob
        /usr/bin/supercronic "${CRON_FILE}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}" "${APPRISE_COMMAND_FINAL}"

    # If LOG_LEVEL environment variable is set
    else
        # Start the cronjob
        /usr/bin/supercronic "${LOG_LEVEL}" "${CRON_FILE}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}" "${APPRISE_COMMAND_FINAL}"
    fi

# Append to crontab file if autosync is true
elif [[ "${AUTODISCOVER}" == "false" ]] && [[ "${AUTOSYNC}" == "true" ]]
then
    # Write cronjob to file
    echo "${CRON_TIME} (/usr/local/bin/vdirsyncer -c ${VDIRSYNCER_CONFIG} metasync && echo Metasync successful || echo Error during Metasync; \
    /usr/local/bin/vdirsyncer -c ${VDIRSYNCER_CONFIG} sync && echo Sync successful || echo Error during Sync; \
    cat /tmp/lel.txt && echo Cat Successful || echo Error during Cat; ${POST_SYNC_SNIPPET}) ${APPRISE_COMMAND_FINAL}" >> "${CRON_FILE}"

#    echo "*/1 * * * * (echo test123 && echo lul) ${APPRISE_COMMAND_FINAL}" >> "${CRON_FILE}"
#    echo "*/1 * * * * echo test123" >> "${CRON_FILE}"

    # User info
    echo 'Only Autosync is enabled.' 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Check if LOG_LEVEL environment variable is empty
    if [[ -z "${LOG_LEVEL}" ]]
    then
        # Start the cronjob
        /usr/bin/supercronic "${CRON_FILE}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # If LOG_LEVEL environment variable is set
    else
        # Start the cronjob
        /usr/bin/supercronic "${LOG_LEVEL}" "${CRON_FILE}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
    fi

# Append to crontab file if autodiscover is true
elif [[ "${AUTODISCOVER}" == "true" ]] && [[ "${AUTOSYNC}" == "false" ]]
then
    # Write cronjob to file
    echo "${CRON_TIME} yes | /usr/local/bin/vdirsyncer -c ${VDIRSYNCER_CONFIG} discover ${POST_SYNC_SNIPPET}" >> "${CRON_FILE}"

    # User info
    echo 'Only Autodiscover is enabled.' 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"

    # Check if LOG_LEVEL environment variable is empty
    if [[ -z "${LOG_LEVEL}" ]]
    then
        # Start the cronjob
        /usr/bin/supercronic "${CRON_FILE}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}" "${APPRISE_COMMAND_FINAL}"

    # If LOG_LEVEL environment variable is set
    else
        # Start the cronjob
        /usr/bin/supercronic "${LOG_LEVEL}" "${CRON_FILE}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}" "${APPRISE_COMMAND_FINAL}"
    fi

# Append nothing, if both options are disabled
else
    echo 'Autodiscover and Autosync are disabled.' 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "${LOG}"
fi

# Run Container
exec tail -f /dev/null
