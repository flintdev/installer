import socket
import os
import json
import time

PYTHON_EXECUTOR_PORT = 8080
ADMIN_SERVICE_PORT = 5000
WORKFLOW_ENGINE_PORT = 9090
UI_PORT = 8000

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def check_workflow_engine():
    if is_port_in_use(WORKFLOW_ENGINE_PORT):
        status = "up"
    else:
        status = "down"

    with open('.runtime/status.json', 'r') as json_file:
        data = json.load(json_file)
        data["workflow-engine"]["status"] = status
    with open('.runtime/status.json', 'w') as output_file:
        json.dump(data, output_file)

def check_ui():
    if is_port_in_use(UI_PORT):
        status = "up"
    else:
        status = "down"

    with open('.runtime/status.json', 'r') as json_file:
        data = json.load(json_file)
        data["ui"]["status"] = status
    with open('.runtime/status.json', 'w') as output_file:
        json.dump(data, output_file)

def check_python_executor():
    if is_port_in_use(PYTHON_EXECUTOR_PORT):
        status = "up"
    else:
        status = "down"

    with open('.runtime/status.json', 'r') as json_file:
        data = json.load(json_file)
        data["python-executor"]["status"] = status
    with open('.runtime/status.json', 'w') as output_file:
        json.dump(data, output_file)

def check_admin_service():
    if is_port_in_use(ADMIN_SERVICE_PORT):
        status = "up"
    else:
        status = "down"

    with open('.runtime/status.json', 'r') as json_file:
        data = json.load(json_file)
        data["admin-service"]["status"] = status
    with open('.runtime/status.json', 'w') as output_file:
        json.dump(data, output_file)

def init_status():
    if not os.path.exists(".runtime"):
        os.mkdir(".runtime")
    if not os.path.exists(".runtime/status.json"):
        with open('.runtime/status.json', 'w') as outfile:
            init_data = {
                "ui": {
                    "status": "down"
                },
                "workflow-engine": {
                    "status": "down"
                },
                "python-executor": {
                    "status": "down"
                },
                "admin-service": {
                    "status": "down"
                }
            }
            json.dump(init_data, outfile)

def watcher():
    while True:
        init_status()
        check_ui()
        check_python_executor()
        check_workflow_engine()
        check_admin_service()
        time.sleep(2)

if __name__ == "__main__":
    watcher()

