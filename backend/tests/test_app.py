import json
from app import Todo

# Unit Test for the Todo Model
def test_todo_model():
    """Unit test for the Todo model's to_dict method."""
    todo = Todo(id=1, task="Test Task", completed=True)
    expected_dict = {
        'id': 1,
        'task': 'Test Task',
        'completed': True
    }
    assert todo.to_dict() == expected_dict

# API and Integration Tests

def test_get_todos_empty(client):
    """Test GET /todos when the database is empty."""
    response = client.get('/todos')
    assert response.status_code == 200
    assert response.json == []

def test_add_todo(client, db):
    """Test POST /todos to add a new todo."""
    response = client.post('/todos', data=json.dumps({'task': 'A new task'}), content_type='application/json')
    assert response.status_code == 201
    assert 'id' in response.json
    assert response.json['task'] == 'A new task'
    assert not response.json['completed']

    # Verify it was added to the db
    assert Todo.query.count() == 1
    assert Todo.query.first().task == 'A new task'

def test_get_todos_with_items(client, db):
    """Test GET /todos after adding an item."""
    # Add a todo first
    client.post('/todos', data=json.dumps({'task': 'Task 1'}), content_type='application/json')
    
    response = client.get('/todos')
    assert response.status_code == 200
    assert len(response.json) == 1
    assert response.json[0]['task'] == 'Task 1'

def test_update_todo(client, db):
    """Test PUT /todos/<id> to update a todo."""
    # First, add a todo to update
    post_response = client.post('/todos', data=json.dumps({'task': 'Initial Task'}), content_type='application/json')
    todo_id = post_response.json['id']

    # Now, update it
    update_data = {'task': 'Updated Task', 'completed': True}
    response = client.put(f'/todos/{todo_id}', data=json.dumps(update_data), content_type='application/json')
    
    assert response.status_code == 200
    assert response.json['task'] == 'Updated Task'
    assert response.json['completed'] is True

    # Verify the update in the db
    updated_todo = db.session.get(Todo, todo_id)
    assert updated_todo.task == 'Updated Task'
    assert updated_todo.completed is True

def test_update_todo_not_found(client):
    """Test PUT /todos/<id> for a non-existent todo."""
    response = client.put('/todos/999', data=json.dumps({'task': 'Doesn\'t matter'}), content_type='application/json')
    assert response.status_code == 404

def test_delete_todo(client, db):
    """Test DELETE /todos/<id> to delete a todo."""
    # Add a todo to delete
    post_response = client.post('/todos', data=json.dumps({'task': 'To be deleted'}), content_type='application/json')
    todo_id = post_response.json['id']
    assert Todo.query.count() == 1

    # Delete it
    response = client.delete(f'/todos/{todo_id}')
    assert response.status_code == 204
    
    # Verify it's gone from the db
    assert Todo.query.count() == 0

def test_delete_todo_not_found(client):
    """Test DELETE /todos/<id> for a non-existent todo."""
    response = client.delete('/todos/999')
    assert response.status_code == 404
