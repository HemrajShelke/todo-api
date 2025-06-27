from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

# Database Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///todos.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Todo Model
class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    task = db.Column(db.String(200), nullable=False)
    completed = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            'id': self.id,
            'task': self.task,
            'completed': self.completed
        }

# API Endpoints
@app.route('/todos', methods=['GET'])
def get_todos():
    todos = Todo.query.all()
    return jsonify([todo.to_dict() for todo in todos])

@app.route('/todos/<int:id>', methods=['GET'])
def get_todo(id):
    todo = Todo.query.get_or_404(id)
    return jsonify(todo.to_dict())

@app.route('/todos', methods=['POST'])
def add_todo():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    if 'task' not in data:
        return jsonify({"error": "Task field is required"}), 400
        
    if not isinstance(data['task'], str) or not data['task'].strip():
        return jsonify({"error": "Task must be a non-empty string"}), 400
        
    new_todo = Todo(task=data['task'], completed=data.get('completed', False))
    db.session.add(new_todo)
    db.session.commit()
    return jsonify(new_todo.to_dict()), 201

@app.route('/todos/<int:id>', methods=['PUT'])
def update_todo(id):
    todo = Todo.query.get_or_404(id)
    data = request.get_json()
    todo.task = data.get('task', todo.task)
    todo.completed = data.get('completed', todo.completed)
    db.session.commit()
    return jsonify(todo.to_dict())

@app.route('/todos/<int:id>', methods=['DELETE'])
def delete_todo(id):
    todo = Todo.query.get_or_404(id)
    db.session.delete(todo)
    db.session.commit()
    return '', 204

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

def init_db():
    with app.app_context():
        db.create_all()
        # Add a test todo if none exist
        if not Todo.query.first():
            test_todo = Todo(task="Test todo", completed=False)
            db.session.add(test_todo)
            db.session.commit()

if __name__ == '__main__':
    # Ensure instance path exists
    os.makedirs(app.instance_path, exist_ok=True)
    
    # Initialize database
    init_db()
    
    # Get port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Run app
    app.run(
        host='0.0.0.0',  # Bind to all interfaces
        port=port,
        debug=os.environ.get('FLASK_ENV') == 'development'
    )
