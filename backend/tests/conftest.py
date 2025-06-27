import sys
import os
import pytest

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app import app as flask_app, db as sqlalchemy_db

@pytest.fixture(autouse=True)
def app():
    """Test application fixture that runs automatically for each test."""
    flask_app.config.update({
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:",
        "FLASK_ENV": "testing"  # Ensure we're in testing mode
    })

    # Set up the database for each test
    with flask_app.app_context():
        sqlalchemy_db.create_all()
        yield flask_app
        sqlalchemy_db.session.remove()  # Clear any active sessions
        sqlalchemy_db.drop_all()  # Drop all tables

@pytest.fixture
def client(app):
    """Test client fixture."""
    return app.test_client()

@pytest.fixture
def db(app):
    """Database fixture that ensures empty state."""
    sqlalchemy_db.session.begin_nested()  # Create a savepoint
    yield sqlalchemy_db
    sqlalchemy_db.session.rollback()  # Rollback to the savepoint
    sqlalchemy_db.session.remove()  # Remove the session
