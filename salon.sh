#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Main menu function to display services and handle user inputs
MAIN_MENU() {
  # Display error message if provided
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # Get the list of services from the database
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")
  
  # Show list of available services
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE; do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Prompt user for service selection
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED

  # Check if the input is a valid number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then  
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  # Check if the selected service ID exists in the database
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # If service doesn't exist, ask again
  if [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  # Prompt for the customer's phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if the customer exists in the database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If customer doesn't exist, ask for their name and create a new record
  if [[ -z $CUSTOMER_ID ]]; then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  
  # Prompt for the appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert the appointment into the database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm the appointment
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Run the main menu function
MAIN_MENU
