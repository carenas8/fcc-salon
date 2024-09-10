#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~~~Welcome to the salon!~~~~~~~~"
ALL_SERVICES=$($PSQL "SELECT service_id,name FROM services")

MAIN_MENU() {
  echo -e "\nPlease select from the following services:"

  echo "$ALL_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  
  SERVICE_AVAILABLE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  

  # if input is not a number
    if [[ -z $SERVICE_AVAILABLE ]]
    then
      # send to main menu
      echo Please enter only the number of a service listed.
      MAIN_MENU 
    else
      BOOK_SERVICE
    fi


}



BOOK_SERVICE () {
 # service information
 SELECTED_SERVICE_RAW=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
 # fix service formatting
 SELECTED_SERVICE=$(echo $SELECTED_SERVICE_RAW | sed 's/ |/"/')



 # get customer info
 echo -e "\nWhat's your phone number?"
 read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nI don't see you in our system, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  
  fi

 # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

 # select time

 echo -e "\nWhat time would you like to come in for your $SELECTED_SERVICE?"
 read SERVICE_TIME

 # create appointment
  INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME') ")

  if [[ $INSERT_APPT_RESULT = "INSERT 0 1" ]]
    then
    echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}


MAIN_MENU