import os
import json
import logging
from azure.servicebus import ServiceBusClient

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CONNECTION_STRING = os.environ["SERVICEBUS_CONNECTION_STRING"]
QUEUE_NAME        = os.environ["SERVICEBUS_QUEUE_NAME"]

def process_message(body: dict):
    logger.info(f"✅ Mesaj is being processed: {body}")
    
    

def main():
    logger.info("🚀 Job has been started")
    
    with ServiceBusClient.from_connection_string(CONNECTION_STRING) as client:
        with client.get_queue_receiver(queue_name=QUEUE_NAME, max_wait_time=5) as receiver:
            messages = receiver.receive_messages(max_message_count=10, max_wait_time=5)
            
            if not messages:
                logger.info("📭 No message to proccess. Exiting.")
                return

            for msg in messages:
                try:
                    body = json.loads(str(msg))
                    process_message(body)
                    receiver.complete_message(msg)  
                    logger.info(f"✅ Message completed")
                except Exception as e:
                    logger.error(f"❌ Error: {e}")
                    receiver.abandon_message(msg)   
                    raise

if __name__ == "__main__":
    main()
