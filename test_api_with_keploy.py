#!/usr/bin/env python3
"""
Comprehensive API test script for Keploy recording.
This script will make API calls to all endpoints to generate test cases.
Enhanced for CI/CD integration with better error handling and reporting.
"""

import requests
import json
import time
import sys
import os
from datetime import datetime

BASE_URL = "http://127.0.0.1:5000"
TEST_RESULTS = {
    "total_tests": 0,
    "passed": 0,
    "failed": 0,
    "errors": []
}

def log(message, level="INFO"):
    """Log messages with timestamp."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {level}: {message}")

def wait_for_server():
    """Wait for the Flask server to be ready."""
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            response = requests.get(f"{BASE_URL}/todos", timeout=5)
            if response.status_code == 200:
                log("✅ Server is ready!", "SUCCESS")
            return True
        except requests.exceptions.RequestException:
            log(f"⏳ Waiting for server... (attempt {attempt + 1}/{max_attempts})", "INFO")
            time.sleep(2)
    
    log("❌ Server failed to start within timeout period", "ERROR")
    return False

def run_test(test_name, test_func):
    """Run a test and track results."""
    TEST_RESULTS["total_tests"] += 1
    try:
        log(f"🧪 Running: {test_name}", "INFO")
        result = test_func()
        if result:
            TEST_RESULTS["passed"] += 1
            log(f"✅ PASSED: {test_name}", "SUCCESS")
        else:
            TEST_RESULTS["failed"] += 1
            log(f"❌ FAILED: {test_name}", "ERROR")
        return result
    except Exception as e:
        TEST_RESULTS["failed"] += 1
        TEST_RESULTS["errors"].append(f"{test_name}: {str(e)}")
        log(f"💥 ERROR in {test_name}: {str(e)}", "ERROR")
    return False

def test_get_all_todos():
    """Test GET /todos endpoint."""
    try:
        response = requests.get(f"{BASE_URL}/todos", timeout=10)
        log(f"GET /todos - Status: {response.status_code}", "DEBUG")
        if response.status_code == 200:
            todos = response.json()
            log(f"Retrieved {len(todos)} todos", "DEBUG")
            return True
        return False
    except Exception as e:
        log(f"Error in GET /todos: {e}", "ERROR")
        return False

def test_create_todo():
    """Test POST /todos endpoint."""
    test_todos = [
        {"task": "Learn Keploy API testing"},
        {"task": "Integrate with CI/CD pipeline"},
        {"task": "Write comprehensive tests", "completed": False},
        {"task": "Deploy to production", "completed": True},
        {"task": "Monitor application performance"},
        {"task": "Update documentation"}
    ]
    
    created_ids = []
    for i, todo_data in enumerate(test_todos):
        try:
            response = requests.post(
                f"{BASE_URL}/todos",
                headers={"Content-Type": "application/json"},
                json=todo_data,
                timeout=10
            )
            log(f"POST /todos {i+1} - Status: {response.status_code}", "DEBUG")
            if response.status_code == 201:
                todo = response.json()
                created_ids.append(todo['id'])
                log(f"Created todo: {todo['task']}", "DEBUG")
            else:
                log(f"Failed to create todo: {response.text}", "ERROR")
        except Exception as e:
            log(f"Error creating todo {i+1}: {e}", "ERROR")
    
    return created_ids

def test_get_todo_by_id(todo_id):
    """Test GET /todos/{id} endpoint."""
    try:
        response = requests.get(f"{BASE_URL}/todos/{todo_id}", timeout=10)
        log(f"GET /todos/{todo_id} - Status: {response.status_code}", "DEBUG")
        return response.status_code == 200
    except Exception as e:
        log(f"Error in GET /todos/{todo_id}: {e}", "ERROR")
        return False

def test_update_todo(todo_id):
    """Test PUT /todos/{id} endpoint."""
    update_data = {
        "task": f"Updated task {todo_id}",
        "completed": True
    }
    
    try:
        response = requests.put(
            f"{BASE_URL}/todos/{todo_id}",
            headers={"Content-Type": "application/json"},
            json=update_data,
            timeout=10
        )
        log(f"PUT /todos/{todo_id} - Status: {response.status_code}", "DEBUG")
        if response.status_code == 200:
            updated_todo = response.json()
            log(f"Updated todo: {updated_todo['task']}", "DEBUG")
            return True
        return False
    except Exception as e:
        log(f"Error in PUT /todos/{todo_id}: {e}", "ERROR")
    return False

def test_update_partial_todo(todo_id):
    """Test PUT /todos/{id} with partial update."""
    update_data = {"completed": False}
    
    try:
        response = requests.put(
            f"{BASE_URL}/todos/{todo_id}",
            headers={"Content-Type": "application/json"},
            json=update_data,
            timeout=10
        )
        log(f"PUT /todos/{todo_id} (partial) - Status: {response.status_code}", "DEBUG")
        return response.status_code == 200
    except Exception as e:
        log(f"Error in partial PUT /todos/{todo_id}: {e}", "ERROR")
    return False

def test_delete_todo(todo_id):
    """Test DELETE /todos/{id} endpoint."""
    try:
        response = requests.delete(f"{BASE_URL}/todos/{todo_id}", timeout=10)
        log(f"DELETE /todos/{todo_id} - Status: {response.status_code}", "DEBUG")
        if response.status_code == 204:
            log(f"Deleted todo {todo_id}", "DEBUG")
            return True
        return False
    except Exception as e:
        log(f"Error in DELETE /todos/{todo_id}: {e}", "ERROR")
    return False

def test_error_cases():
    """Test error scenarios."""
    error_tests = [
    # Test 404 for non-existent todo
        ("GET non-existent todo", lambda: requests.get(f"{BASE_URL}/todos/99999", timeout=10).status_code == 404),
    
    # Test 404 for update non-existent todo
        ("PUT non-existent todo", lambda: requests.put(
            f"{BASE_URL}/todos/99999",
            headers={"Content-Type": "application/json"},
            json={"task": "This should fail"},
            timeout=10
        ).status_code == 404),
    
    # Test 404 for delete non-existent todo
        ("DELETE non-existent todo", lambda: requests.delete(f"{BASE_URL}/todos/99999", timeout=10).status_code == 404),
    
        # Test 400 for invalid JSON (missing task)
        ("POST with invalid data", lambda: requests.post(
            f"{BASE_URL}/todos",
            headers={"Content-Type": "application/json"},
            json={},
            timeout=10
        ).status_code == 400),
    ]
    
    for test_name, test_func in error_tests:
        run_test(test_name, test_func)

def main():
    """Main test execution."""
    log("🚀 Starting comprehensive API testing for Keploy recording...", "INFO")
    
    if not wait_for_server():
        sys.exit(1)
    
    # Test all endpoints
    run_test("GET all todos", test_get_all_todos)
    
    # Create some todos and get their IDs
    created_ids = test_create_todo()
    log(f"Created {len(created_ids)} todos for testing", "INFO")
    
    # Test getting all todos again (should show created todos)
    run_test("GET all todos (after creation)", test_get_all_todos)
    
    # Test individual todo operations if we have created todos
    if created_ids:
        # Test getting individual todos
        for todo_id in created_ids[:2]:  # Test first 2
            run_test(f"GET todo {todo_id}", lambda tid=todo_id: test_get_todo_by_id(tid))
        
        # Test updates
        if len(created_ids) >= 2:
            run_test(f"PUT todo {created_ids[0]} (full update)", 
                    lambda: test_update_todo(created_ids[0]))
            run_test(f"PUT todo {created_ids[1]} (partial update)", 
                    lambda: test_update_partial_todo(created_ids[1]))
        
        # Test getting all todos after updates
        run_test("GET all todos (after updates)", test_get_all_todos)
        
        # Test deletions (leave some todos for final state)
        for todo_id in created_ids[:-1]:  # Delete all but the last one
            run_test(f"DELETE todo {todo_id}", lambda tid=todo_id: test_delete_todo(tid))
    
    # Test error cases
    log("Testing error scenarios...", "INFO")
    test_error_cases()
    
    # Final state check
    run_test("GET all todos (final state)", test_get_all_todos)
    
    # Print test summary
    log("📊 Test Summary:", "INFO")
    log(f"Total tests: {TEST_RESULTS['total_tests']}", "INFO")
    log(f"Passed: {TEST_RESULTS['passed']}", "SUCCESS")
    log(f"Failed: {TEST_RESULTS['failed']}", "ERROR")
    
    if TEST_RESULTS['errors']:
        log("Errors encountered:", "ERROR")
        for error in TEST_RESULTS['errors']:
            log(f"  - {error}", "ERROR")
    
    success_rate = (TEST_RESULTS['passed'] / TEST_RESULTS['total_tests']) * 100 if TEST_RESULTS['total_tests'] > 0 else 0
    log(f"Success rate: {success_rate:.1f}%", "INFO")
    
    log("✅ All API tests completed! Keploy should have recorded comprehensive test cases.", "SUCCESS")
    log("📊 Check the Keploy test files for recorded interactions.", "INFO")
    
    # Exit with appropriate code for CI/CD
    if TEST_RESULTS['failed'] > 0:
        log("⚠️ Some tests failed, but continuing for Keploy recording", "WARNING")
        return 0  # Don't fail the build for recording purposes
    else:
        log("🎉 All tests passed!", "SUCCESS")
        return 0

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
