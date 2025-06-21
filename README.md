# Todo List API Server

This project is a simple but powerful Todo List application featuring a Python Flask backend, an SQLite database, and a clean, functional frontend built with HTML, CSS, and JavaScript.

## Tech Stack

- **Backend:** Python, Flask, Flask-SQLAlchemy, Flask-CORS
- **Database:** SQLite
- **Frontend:** HTML, CSS, JavaScript
- **Testing:** Pytest, Pytest-Cov

## API Documentation

The API provides the following endpoints for managing todo items:

### Get All Todos
- **Endpoint:** `/todos`
- **Method:** `GET`
- **Description:** Retrieves a list of all todo items.
- **Success Response:** `200 OK`
  ```json
  [
    {
      "id": 1,
      "task": "Learn about APIs",
      "completed": true
    },
    {
      "id": 2,
      "task": "Build a project",
      "completed": false
    }
  ]
  ```

### Add a New Todo
- **Endpoint:** `/todos`
- **Method:** `POST`
- **Description:** Adds a new todo item to the list.
- **Request Body:**
  ```json
  {
    "task": "Write documentation"
  }
  ```
- **Success Response:** `201 Created`
  ```json
  {
    "id": 3,
    "task": "Write documentation",
    "completed": false
  }
  ```

### Update a Todo
- **Endpoint:** `/todos/<id>`
- **Method:** `PUT`
- **Description:** Updates an existing todo item's task or completion status.
- **Request Body:**
  ```json
  {
    "task": "Update the documentation",
    "completed": true
  }
  ```
- **Success Response:** `200 OK`
  ```json
  {
    "id": 3,
    "task": "Update the documentation",
    "completed": true
  }
  ```

### Delete a Todo
- **Endpoint:** `/todos/<id>`
- **Method:** `DELETE`
- **Description:** Deletes a specific todo item.
- **Success Response:** `204 No Content`

## Getting Started

### Prerequisites
- Python 3.x
- pip

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd todo-api/backend
    ```

2.  **Create and activate a virtual environment:**
    ```bash
    # For Windows
    python -m venv venv
    .\venv\Scripts\activate

    # For macOS/Linux
    python3 -m venv venv
    source venv/bin/activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the application:**
    ```bash
    python app.py
    ```
    The API server will be running at `http://127.0.0.1:5000`.

## Testing

This project uses `pytest` for comprehensive unit, integration, and API testing.

### Running Tests

From the `backend` directory, run the following command:
```bash
pytest
```

### Test Coverage

A test coverage of **93%** has been achieved, as detailed in the report below. The report was generated using `pytest-cov`.

![Test Coverage Report](path/to/your/screenshot.png)

**Coverage Breakdown:**

| File   | Statements | Missing | Coverage |
|--------|------------|---------|----------|
| app.py | 43         | 3       | 93%      |
| **Total**  | **43**     | **3**   | **93%**  |

To generate an updated HTML report, run:
```bash
pytest --cov=app --cov-report html
```
Then, open `backend/htmlcov/index.html` in your browser.

    python app.py
    ```
5.  The server will start on `http://127.0.0.1:5000`.

## How to Run the Frontend

1.  Navigate to the `frontend` directory.
2.  Open the `index.html` file in your web browser.

## How to Interact with the API

You can interact with the API using the provided frontend or by sending requests with a tool like `curl`.

**Example using `curl`:**

- **Get all todos:**
  ```bash
  curl http://127.0.0.1:5000/todos
  ```

- **Add a new todo:**
  ```bash
  curl -X POST -H "Content-Type: application/json" -d '{"task":"Test with curl"}' http://127.0.0.1:5000/todos
  ```
