#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

ENTER_SALON(){

    SERVICE_ID_ARRAY=$($PSQL "SELECT service_id FROM services")

    for ID in ${SERVICE_ID_ARRAY[@]};
    do
      NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$ID'")
      echo "$ID) $NAME"
    done

    read SERVICE_ID_SELECTED

    FOUND=0

    for ID in ${SERVICE_ID_ARRAY[@]};
    do
      if [[ ID -eq SERVICE_ID_SELECTED ]]
      then
        FOUND=1
      fi
    done
    
    if [[ FOUND -eq 0 ]]
    then
      ENTER_SALON
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
      GET_PHONE_NUMBER
    fi

}


GET_PHONE_NUMBER(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    ON_NEW_CUSTOMER
  else
    ON_EXISTING_CUSTOMER
  fi
}

ON_NEW_CUSTOMER(){

  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")

  if [[ $CUSTOMER_INSERT_RESULT == "INSERT 0 1" ]]
  then
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    ON_EXISTING_CUSTOMER
  fi
}

ON_EXISTING_CUSTOMER(){
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")
  echo -e "\nWhat time would you like your $SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME;

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")

  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}


ENTER_SALON

