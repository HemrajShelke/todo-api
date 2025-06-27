from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os
import logging
from logging.handlers import RotatingFileHandler

app = Flask(__name__)
CORS(app)

# Configure logging
if not app.debug:
    # Ensure logs directory exists
    log_dir = os.path.join(app.instance_path, 'logs')
    os.makedirs(log_dir, exist_ok=True)
    
    # Set up file handler
    file_handler = RotatingFileHandler(
        os.path.join(log_dir, 'flask.log'),
        maxBytes=10240,
        backupCount=10
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
    
    # Also log to stderr for container logs
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    app.logger.addHandler(console_handler)
    
    app.logger.setLevel(logging.INFO)
    app.logger.info('Flask app startup')

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
    app.logger.info('GET /todos request received')
    todos = Todo.query.all()
    app.logger.info(f'Returning {len(todos)} todos')
    return jsonify([todo.to_dict() for todo in todos])

@app.route('/todos/<int:id>', methods=['GET'])
def get_todo(id):
    app.logger.info(f'GET /todos/{id} request received')
    todo = Todo.query.get_or_404(id)
    app.logger.info(f'Returning todo {id}')
    return jsonify(todo.to_dict())

@app.route('/todos', methods=['POST'])
def add_todo():
    app.logger.info('POST /todos request received')
    data = request.get_json()
    if not data:
        app.logger.warning('No data provided in POST /todos request')
        return jsonify({"error": "No data provided"}), 400
    
    if 'task' not in data:
        app.logger.warning('Task field missing in POST /todos request')
        return jsonify({"error": "Task field is required"}), 400
        
    if not isinstance(data['task'], str) or not data['task'].strip():
        app.logger.warning('Invalid task value in POST /todos request')
        return jsonify({"error": "Task must be a non-empty string"}), 400
        
    new_todo = Todo(task=data['task'], completed=data.get('completed', False))
    db.session.add(new_todo)
    db.session.commit()
    app.logger.info(f'Created new todo with id {new_todo.id}')
    return jsonify(new_todo.to_dict()), 201

@app.route('/todos/<int:id>', methods=['PUT'])
def update_todo(id):
    app.logger.info(f'PUT /todos/{id} request received')
    todo = Todo.query.get_or_404(id)
    data = request.get_json()
    todo.task = data.get('task', todo.task)
    todo.completed = data.get('completed', todo.completed)
    db.session.commit()
    app.logger.info(f'Updated todo {id}')
    return jsonify(todo.to_dict())

@app.route('/todos/<int:id>', methods=['DELETE'])
def delete_todo(id):
    app.logger.info(f'DELETE /todos/{id} request received')
    todo = Todo.query.get_or_404(id)
    db.session.delete(todo)
    db.session.commit()
    app.logger.info(f'Deleted todo {id}')
    return '', 204

@app.route('/health', methods=['GET'])
def health_check():
    app.logger.debug('Health check request received')
    try:
        # Try to query the database
        Todo.query.first()
        return jsonify({
            "status": "healthy",
            "database": "connected",
            "environment": os.environ.get('FLASK_ENV', 'unknown')
        }), 200
    except Exception as e:
        app.logger.error(f'Health check failed: {str(e)}')
        return jsonify({
            "status": "unhealthy",
            "error": str(e),
            "environment": os.environ.get('FLASK_ENV', 'unknown')
        }), 500

def init_db():
    with app.app_context():
        app.logger.info('Initializing database')
        db.create_all()
        # Add a test todo if none exist
        if not Todo.query.first():
            test_todo = Todo(task="Test todo", completed=False)
            db.session.add(test_todo)
            db.session.commit()
            app.logger.info('Added test todo')

if __name__ == '__main__':
    # Ensure instance path exists
    os.makedirs(app.instance_path, exist_ok=True)
    
    # Initialize database
    init_db()
    
    # Get port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    
    app.logger.info(f'Starting Flask app on port {port}')
    
    # Run app
    app.run(
        host='0.0.0.0',  # Bind to all interfaces
        port=port,
        debug=os.environ.get('FLASK_ENV') == 'development'
    )
