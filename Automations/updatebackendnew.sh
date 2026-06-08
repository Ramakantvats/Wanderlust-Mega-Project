#!/bin/bash
#Note: Main purpose of below code is to update latest public ip in the FRONTEND_URL varialbe present in ./backend/.env.docker file so that request can route to the frontend server successfully.
# Set the Instance ID and path to the .env file
INSTANCE_ID="i-030da7d31a1dbbffc"  # (Ramakant vats) Here we will write our any kubernetes worker-vm instance id

# Retrieve the public IP address of the specified EC2 instance.   (Ramakant) in ipv4_address variable the public ipv4 address of the kubernetes worker-vm will store by the help of instance id specified above.
ipv4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Path to the .env file  (Ramakant) Env file contains the environment variables and the exact path of the env file is ../backend/.env.docker this path will store in file_to_find variable
file_to_find="../backend/.env.docker"

# Check the current FRONTEND_URL in the .env file  (Ramakant) Now this sed cmd will extract the FRONTEND_URL present in the ./backend/.env.docker file 4th line. And store in current_url variable
current_url=$(sed -n "4p" $file_to_find)

# Update the .env file if the IP address has changed (Ramakant) As usuall ip add. of kubernetes worker-vm will change after restart. So below cmd will check if current-url is not equal to FRONTEND_URL then, ./backend/.env.docker file will update and the variable in this file FRONTEND_URL will now have latest worker-vm ip add. so that during process request can be route to the frontend server.
if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:5173\"|g" $file_to_find
    else
        echo "ERROR: File not found."
    fi
fi
