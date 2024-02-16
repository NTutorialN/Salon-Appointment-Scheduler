#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SHOW_SERVICES() {
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_TYPE=$(echo $($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") | sed -E 's/^ *| *$//g')
  if [[ -z $SERVICE_TYPE ]]
  then
    SHOW_SERVICES "I could not find that service. What would you like today?"
  fi
}

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"


SHOW_SERVICES

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  if [[ ! $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
  then
    echo "Failed to add new customer to DB."
    exit 1
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID'") | sed -E 's/^ *| *$//g')
fi

echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
if [[ ! $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
then
  echo "Failed to add new appointment to db."
  exit 1
fi

echo -e "\nI have put you down for a $SERVICE_TYPE at $SERVICE_TIME, $CUSTOMER_NAME."

