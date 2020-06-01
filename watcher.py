import socket
import os
import json
import time
import requests

PYTHON_EXECUTOR_PORT = 8080
ADMIN_SERVICE_PORT = 5000
WORKFLOW_ENGINE_PORT = 9090
UI_PORT = 8000

HEALTH_CHECK_URL_SUFFIX = "/health"
HEALTH_CHECK_PORT = "8080"

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
    with open('.runtime/status.json', 'r') as json_file:
        data = json.load(json_file)
        port = data["python-executor"]["port"]
        if port == "unknown":
            status = "unavailable"
        else:
            status = health_check(port)
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
                    "status": "unavailable",
                    "port": "unknown"
                },
                "workflow-engine": {
                    "status": "unavailable",
                    "port": "unknown"
                },
                "python-executor": {
                    "status": "unavailable",
                    "port": "unknown"
                },
                "admin-service": {
                    "status": "unavailable",
                    "port": "unknown"
                }
            }
            json.dump(init_data, outfile)

def health_check(port):
    try:
        r = requests.get("http://localhost:{}}/health".format(port))
        r_json = r.json()
        status = r_json["status"]
        if status == "available":
            return "available"
        else:
            return "unavailable"
    except Exception as e:
        print(e)
        return "unavailable"


def watcher():
    init_status()
    while True:
        check_python_executor()
        # check_ui()
        # check_workflow_engine()
        # check_admin_service()
        time.sleep(2)

if __name__ == "__main__":
    watcher()