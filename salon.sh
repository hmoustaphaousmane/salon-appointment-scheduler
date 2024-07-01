#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICES(){
  # get the list of services
  SERVICES=$($PSQL "SELECT * FROM services order by service_id;")

  # display the list with the format #) <service> (# -> service_id)
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
}

CUSTOMER_INFO(){
  # get customer's phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get customer's id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  # if customer not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # get customer's name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    # echo $INSERT_CUSTOMER_RESULT

    # get new customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  fi
}

NEW_APPOINTMENT(){
  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")

  # get appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  # get service name
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.?"
}

# display services numbered list
SERVICES

while true
do
  # read user input to select a service
  read SERVICE_ID_SELECTED

  # get the service
  PICKED_SERVICE=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  # echo $PICKED_SERVICE

  # if the picked service is not found
  if [[ -z $PICKED_SERVICE ]]
  then
    echo -e "\nI could not find that service. What would you like today?"

    # show the same list of services again
    SERVICES
  else
    # get customer info
    CUSTOMER_INFO
    
    # insert new appointment
    NEW_APPOINTMENT

    # break the loop
    break
  fi
done