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

# Get base URL from environment or use default
BASE_URL = os.environ.get('API_URL', 'http://127.0.0.1:5000')
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
    sys.stdout.flush()  # Ensure logs are written immediately

def wait_for_server():
    """Wait for the Flask server to be ready."""
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            # Try health check endpoint first
            try:
                health_response = requests.get(f"{BASE_URL}/health", timeout=5)
                if health_response.status_code == 200:
                    log("✅ Server is ready! (Health check passed)", "SUCCESS")
                    return True
            except requests.exceptions.RequestException:
                pass  # Fall back to /todos check

            # Fall back to /todos endpoint
            response = requests.get(f"{BASE_URL}/todos", timeout=5)
            if response.status_code == 200:
                log("✅ Server is ready! (Todos endpoint responding)", "SUCCESS")
                return True
        except requests.exceptions.RequestException as e:
            log(f"⏳ Waiting for server... (attempt {attempt + 1}/{max_attempts}): {str(e)}", "INFO")
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
        error_msg = f"{test_name}: {str(e)}"
        TEST_RESULTS["errors"].append(error_msg)
        log(f"💥 ERROR in {test_name}: {str(e)}", "ERROR")
        log(f"Stack trace:", "ERROR")
        import traceback
        log(traceback.format_exc(), "ERROR")
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
        log(f"Unexpected status code: {response.status_code}, Response: {response.text}", "ERROR")
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
                log(f"Request data: {json.dumps(todo_data)}", "DEBUG")
        except Exception as e:
            log(f"Error creating todo {i+1}: {e}", "ERROR")
            log(f"Request data: {json.dumps(todo_data)}", "DEBUG")
    
    log(f"Created {len(created_ids)} todos for testing", "INFO")
    return created_ids

def test_get_todo_by_id(todo_id):
    """Test GET /todos/{id} endpoint."""
    try:
        response = requests.get(f"{BASE_URL}/todos/{todo_id}", timeout=10)
        log(f"GET /todos/{todo_id} - Status: {response.status_code}", "DEBUG")
        if response.status_code == 200:
            todo = response.json()
            log(f"Retrieved todo: {todo['task']}", "DEBUG")
            return True
        log(f"Unexpected status code: {response.status_code}, Response: {response.text}", "ERROR")
        return False
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
        log(f"Unexpected status code: {response.status_code}, Response: {response.text}", "ERROR")
        return False
    except Exception as e:
        log(f"Error in PUT /todos/{todo_id}: {e}", "ERROR")
        log(f"Request data: {json.dumps(update_data)}", "DEBUG")
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
        if response.status_code == 200:
            updated_todo = response.json()
            log(f"Partially updated todo: {updated_todo['task']}", "DEBUG")
            return True
        log(f"Unexpected status code: {response.status_code}, Response: {response.text}", "ERROR")
        return False
    except Exception as e:
        log(f"Error in partial PUT /todos/{todo_id}: {e}", "ERROR")
        log(f"Request data: {json.dumps(update_data)}", "DEBUG")
    return False

def test_delete_todo(todo_id):
    """Test DELETE /todos/{id} endpoint."""
    try:
        response = requests.delete(f"{BASE_URL}/todos/{todo_id}", timeout=10)
        log(f"DELETE /todos/{todo_id} - Status: {response.status_code}", "DEBUG")
        if response.status_code == 204:
            log(f"Deleted todo {todo_id}", "DEBUG")
            return True
        log(f"Unexpected status code: {response.status_code}, Response: {response.text}", "ERROR")
        return False
    except Exception as e:
        log(f"Error in DELETE /todos/{todo_id}: {e}", "ERROR")
    return False

def test_error_cases():
    """Test error scenarios."""
    log("Testing error scenarios...", "INFO")
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
    """Main test execution function."""
    log("🚀 Starting comprehensive API testing for Keploy recording...", "INFO")
    
    # Wait for server to be ready
    if not wait_for_server():
        log("❌ Server not ready, aborting tests", "ERROR")
        sys.exit(1)
    
    # Run initial GET to check state
    run_test("GET all todos", test_get_all_todos)
    
    # Create test todos
    created_ids = test_create_todo()
    
    # Run tests with created todos
    run_test("GET all todos (after creation)", test_get_all_todos)
    
    # Test individual todo operations
    for todo_id in created_ids[:2]:  # Use first two todos for individual tests
        run_test(f"GET todo {todo_id}", lambda: test_get_todo_by_id(todo_id))
        run_test(f"PUT todo {todo_id} (full update)", lambda: test_update_todo(todo_id))
        run_test(f"PUT todo {todo_id} (partial update)", lambda: test_update_partial_todo(todo_id))
    
    # Check state after updates
    run_test("GET all todos (after updates)", test_get_all_todos)
    
    # Delete todos
    for todo_id in created_ids:
        run_test(f"DELETE todo {todo_id}", lambda: test_delete_todo(todo_id))
    
    # Test error cases
    test_error_cases()
    
    # Final state check
    run_test("GET all todos (final state)", test_get_all_todos)
    
    # Print test summary
    log("📊 Test Summary:", "INFO")
    log(f"Total tests: {TEST_RESULTS['total_tests']}", "INFO")
    log(f"Passed: {TEST_RESULTS['passed']}", "SUCCESS")
    log(f"Failed: {TEST_RESULTS['failed']}", "ERROR")
    log(f"Success rate: {(TEST_RESULTS['passed'] / TEST_RESULTS['total_tests'] * 100):.1f}%", "INFO")
    
    if TEST_RESULTS["errors"]:
        log("⚠️ Some tests failed, but continuing for Keploy recording", "WARNING")
    else:
        log("✅ All API tests completed! Keploy should have recorded comprehensive test cases.", "SUCCESS")
    
    log("📊 Check the Keploy test files for recorded interactions.", "INFO")
    
    # Write results to file for CI
    with open("test_results.json", "w") as f:
        json.dump(TEST_RESULTS, f, indent=2)

if __name__ == "__main__":
    main()
